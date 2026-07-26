import Foundation
import OSLog

final class WorkflowExecutor {
    private let actionRunner: ActionRunner
    private let now: () -> Date
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.pedronazarito.AirShortcut",
        category: "Workflow"
    )

    init(
        actionRunner: ActionRunner = ActionRunner(),
        now: @escaping () -> Date = Date.init
    ) {
        self.actionRunner = actionRunner
        self.now = now
    }

    func execute(
        _ workflow: ActionWorkflow,
        approval: ScriptApprovalHandler? = nil,
        onStep: ((WorkflowStepExecution) -> Void)? = nil
    ) async -> WorkflowExecutionReport {
        let startedAt = now()
        var executions: [WorkflowStepExecution] = []
        guard workflow.timeout.isFinite,
              (1...600).contains(workflow.timeout),
              (1...20).contains(workflow.steps.count) else {
            return invalidReport(
                workflow: workflow,
                message: "O workflow contém limites inválidos.",
                startedAt: startedAt
            )
        }

        for (index, step) in workflow.enabledSteps.enumerated() {
            guard step.delayBefore.isFinite,
                  (0...300).contains(step.delayBefore),
                  step.timeout.map({ $0.isFinite && (0.25...300).contains($0) }) ?? true else {
                let execution = WorkflowStepExecution(
                    stepID: step.id,
                    stepName: step.displayName,
                    index: index,
                    result: .failed("A etapa contém limites inválidos.", executedAt: now()),
                    duration: 0
                )
                executions.append(execution)
                onStep?(execution)
                break
            }
            if Task.isCancelled {
                return report(
                    workflow: workflow,
                    executions: executions,
                    startedAt: startedAt,
                    cancelled: true
                )
            }
            if now().timeIntervalSince(startedAt) >= workflow.timeout {
                let result = ActionExecutionResult.failed(
                    "O workflow excedeu o tempo limite de \(Int(workflow.timeout)) s.",
                    executedAt: now()
                )
                let execution = WorkflowStepExecution(
                    stepID: step.id,
                    stepName: step.displayName,
                    index: index,
                    result: result,
                    duration: 0
                )
                executions.append(execution)
                onStep?(execution)
                break
            }

            if step.delayBefore > 0 {
                do {
                    try await Task.sleep(for: .seconds(step.delayBefore))
                } catch {
                    return report(
                        workflow: workflow,
                        executions: executions,
                        startedAt: startedAt,
                        cancelled: true
                    )
                }
            }

            let stepStartedAt = now()
            logger.info(
                "Starting workflow step \(index + 1, privacy: .public) action=\(step.action.displayName, privacy: .public)"
            )
            let result = await execute(step: step, approval: approval)
            let execution = WorkflowStepExecution(
                stepID: step.id,
                stepName: step.displayName,
                index: index,
                result: result,
                duration: now().timeIntervalSince(stepStartedAt)
            )
            executions.append(execution)
            onStep?(execution)
            if !result.success, workflow.failurePolicy == .stop {
                break
            }
        }

        return report(
            workflow: workflow,
            executions: executions,
            startedAt: startedAt,
            cancelled: Task.isCancelled
        )
    }

    private func execute(
        step: WorkflowStep,
        approval: ScriptApprovalHandler?
    ) async -> ActionExecutionResult {
        guard let timeout = step.timeout else {
            return await actionRunner.execute(step.action, scriptApproval: approval)
        }
        guard timeout.isFinite, (0.25...300).contains(timeout) else {
            return .failed("O timeout da etapa é inválido.", executedAt: now())
        }

        return await withTaskGroup(of: ActionExecutionResult.self) { group in
            group.addTask { [actionRunner] in
                await actionRunner.execute(step.action, scriptApproval: approval)
            }
            group.addTask { [now] in
                do {
                    try await Task.sleep(for: .seconds(timeout))
                } catch {
                    return .failed("Etapa cancelada.", executedAt: now())
                }
                return .failed("A etapa excedeu \(Int(timeout)) s.", executedAt: now())
            }
            let result = await group.next()
                ?? .failed("A etapa não produziu resultado.", executedAt: now())
            group.cancelAll()
            return result
        }
    }

    private func report(
        workflow: ActionWorkflow,
        executions: [WorkflowStepExecution],
        startedAt: Date,
        cancelled: Bool
    ) -> WorkflowExecutionReport {
        WorkflowExecutionReport(
            workflowID: workflow.id,
            stepExecutions: executions,
            startedAt: startedAt,
            finishedAt: now(),
            wasCancelled: cancelled
        )
    }

    private func invalidReport(
        workflow: ActionWorkflow,
        message: String,
        startedAt: Date
    ) -> WorkflowExecutionReport {
        let execution = WorkflowStepExecution(
            stepID: workflow.steps.first?.id ?? workflow.id,
            stepName: workflow.steps.first?.displayName ?? workflow.name,
            index: 0,
            result: .failed(message, executedAt: now()),
            duration: 0
        )
        return report(
            workflow: workflow,
            executions: [execution],
            startedAt: startedAt,
            cancelled: false
        )
    }
}
