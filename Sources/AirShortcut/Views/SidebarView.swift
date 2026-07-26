import SwiftUI

struct SidebarView: View {
    @Binding var selection: AirShortcutSection?
    let enabledRuleCount: Int
    let totalRuleCount: Int
    let captureIsRunning: Bool

    var body: some View {
        List(selection: $selection) {
            Section {
                ForEach(AirShortcutSection.allCases) { section in
                    Label(section.title, systemImage: section.systemImage)
                        .tag(section)
                }
            }

            Section("Estado") {
                LabeledContent("Captura") {
                    Text(captureIsRunning ? "Ativa" : "Pausada")
                        .foregroundStyle(captureIsRunning ? .green : .secondary)
                }

                LabeledContent("Regras") {
                    Text("\(enabledRuleCount)/\(totalRuleCount)")
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle(TicoBrand.displayName)
        .frame(minWidth: 190, idealWidth: 220)
    }
}
