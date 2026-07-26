import SwiftUI

struct RulesView: View {
    @ObservedObject var store: ShortcutStore
    @Binding var selectedRuleID: ShortcutRule.ID?
    let latestRecordedEvent: InputEventDescriptor?
    let recordingIsActive: Bool
    let trackpadCaptureMode: TrackpadCaptureMode
    let trackpadStartupError: String?
    let trackpadSnapshot: TrackpadLaboratorySnapshot?
    let applications: [ApplicationChoice]
    let macOSShortcuts: [String]
    let profiles: [ShortcutProfile]
    let reusableWorkflows: [ActionWorkflow]
    let presets: [GesturePreset]
    let detectedTrackpads: [TrackpadHardwareInfo]
    let deviceCapabilities: [String: TrackpadDeviceCapability]
    let currentContext: ContextSnapshot?
    let onStartRecording: () -> Void
    let onStopRecording: () -> Void
    let onSaveReusableWorkflow: (ActionWorkflow) throws -> Void
    let onSavePreset: (GesturePreset) throws -> Void

    @State private var searchText = ""
    @State private var presentedError: String?
    @State private var rulePendingDeletion: ShortcutRule?

    var body: some View {
        HSplitView {
            ruleList
                .frame(minWidth: 240, idealWidth: 280, maxWidth: 340)

            Group {
                if let rule = selectedRule {
                    RuleEditorView(
                        rule: rule,
                        latestRecordedEvent: latestRecordedEvent,
                        recordingIsActive: recordingIsActive,
                        trackpadCaptureMode: trackpadCaptureMode,
                        trackpadStartupError: trackpadStartupError,
                        trackpadSnapshot: trackpadSnapshot,
                        applications: applications,
                        macOSShortcuts: macOSShortcuts,
                        profiles: profiles,
                        reusableWorkflows: reusableWorkflows,
                        presets: presets,
                        detectedTrackpads: detectedTrackpads,
                        deviceCapabilities: deviceCapabilities,
                        currentContext: currentContext,
                        onStartRecording: onStartRecording,
                        onStopRecording: onStopRecording,
                        onSaveReusableWorkflow: onSaveReusableWorkflow,
                        onSavePreset: onSavePreset,
                        conflictsForRule: store.conflicts,
                        onSave: save,
                        onReplaceConflicts: replaceConflicts,
                        onDelete: { rulePendingDeletion = rule }
                    )
                    .id(rule.id)
                } else {
                    ContentUnavailableView(
                        "Selecione uma regra",
                        systemImage: "bolt.badge.clock",
                        description: Text("Escolha uma regra na lista ou crie uma nova.")
                    )
                }
            }
            .frame(minWidth: 420, maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationTitle("Regras")
        .alert("Não foi possível salvar", isPresented: errorIsPresented) {
            Button("OK", role: .cancel) { presentedError = nil }
        } message: {
            Text(presentedError ?? "Erro desconhecido")
        }
        .confirmationDialog(
            "Excluir \(rulePendingDeletion?.name ?? "esta regra")?",
            isPresented: deletionIsPresented
        ) {
            Button("Excluir regra", role: .destructive, action: deletePendingRule)
            Button("Cancelar", role: .cancel) { rulePendingDeletion = nil }
        } message: {
            Text("Esta ação não pode ser desfeita.")
        }
    }

    private var ruleList: some View {
        List(selection: $selectedRuleID) {
            ForEach(filteredRules) { rule in
                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text(rule.name)
                            .fontWeight(.medium)
                            .lineLimit(1)
                        Spacer()
                        Circle()
                            .fill(rule.isEnabled ? Color.green : Color.secondary.opacity(0.45))
                            .frame(width: 7, height: 7)
                            .accessibilityLabel(rule.isEnabled ? "Ativa" : "Inativa")
                    }
                    HStack(spacing: 5) {
                        Text(rule.trigger.displayName)
                            .lineLimit(1)
                        Text("·")
                        Text(contextName(for: rule))
                            .lineLimit(1)
                        if !store.conflicts(for: rule).isEmpty {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                                .help("Esta regra tem um gatilho duplicado ou sobreposto.")
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                .tag(rule.id)
                .contextMenu {
                    Button(rule.isEnabled ? "Desativar" : "Ativar") {
                        do {
                            try store.setEnabled(!rule.isEnabled, for: rule.id)
                        } catch {
                            presentedError = error.localizedDescription
                        }
                    }
                    Divider()
                    Button("Excluir", role: .destructive) {
                        rulePendingDeletion = rule
                    }
                }
            }
        }
        .overlay {
            if filteredRules.isEmpty {
                ContentUnavailableView.search(text: searchText)
            }
        }
        .searchable(text: $searchText, placement: .sidebar, prompt: "Buscar regras")
    }

    private var filteredRules: [ShortcutRule] {
        guard !searchText.isEmpty else { return store.rules }
        return store.rules.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
                || $0.trigger.displayName.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var selectedRule: ShortcutRule? {
        guard let selectedRuleID else { return nil }
        return store.rules.first { $0.id == selectedRuleID }
    }

    private func contextName(for rule: ShortcutRule) -> String {
        if let profileID = rule.profileID,
           let profile = profiles.first(where: { $0.id == profileID }) {
            return profile.name
        }
        return rule.scope.displayName(applications: applications)
    }

    private var errorIsPresented: Binding<Bool> {
        Binding(
            get: { presentedError != nil },
            set: { if !$0 { presentedError = nil } }
        )
    }

    private var deletionIsPresented: Binding<Bool> {
        Binding(
            get: { rulePendingDeletion != nil },
            set: { if !$0 { rulePendingDeletion = nil } }
        )
    }

    private func save(_ rule: ShortcutRule) throws {
        try store.update(rule)
    }

    private func replaceConflicts(_ rule: ShortcutRule) throws {
        try store.replaceConflictingRules(with: rule)
    }

    private func deletePendingRule() {
        guard let rulePendingDeletion else { return }
        do {
            try store.delete(id: rulePendingDeletion.id)
            if selectedRuleID == rulePendingDeletion.id {
                selectedRuleID = store.rules.first?.id
            }
            self.rulePendingDeletion = nil
        } catch {
            presentedError = error.localizedDescription
        }
    }
}
