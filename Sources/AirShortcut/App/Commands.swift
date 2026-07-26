import SwiftUI

struct AirShortcutCommands: Commands {
    var body: some Commands {
        CommandGroup(after: .newItem) {
            Button("Nova regra") {
                NotificationCenter.default.post(name: .airShortcutCreateRule, object: nil)
            }
            .keyboardShortcut("n", modifiers: [.command])
        }

        CommandGroup(after: .importExport) {
            Button("Importar regras…") {
                NotificationCenter.default.post(name: .airShortcutImportRules, object: nil)
            }
            .keyboardShortcut("o", modifiers: [.command, .shift])

            Button("Exportar regras…") {
                NotificationCenter.default.post(name: .airShortcutExportRules, object: nil)
            }
            .keyboardShortcut("e", modifiers: [.command, .shift])
        }

        CommandMenu("Atalhos") {
            Button("Iniciar captura") {
                NotificationCenter.default.post(name: .airShortcutStartCapture, object: nil)
            }
            .keyboardShortcut("r", modifiers: [.command, .option])

            Button("Parar captura") {
                NotificationCenter.default.post(name: .airShortcutStopCapture, object: nil)
            }
            .keyboardShortcut(".", modifiers: [.command, .option])

            Divider()

            Button("Excluir regra selecionada") {
                NotificationCenter.default.post(name: .airShortcutDeleteSelectedRule, object: nil)
            }
            .keyboardShortcut(.delete, modifiers: [.command])

            Divider()

            Button("Visão geral") {
                NotificationCenter.default.post(
                    name: .airShortcutSelectSection,
                    object: AirShortcutSection.overview.rawValue
                )
            }
            .keyboardShortcut("1", modifiers: [.command])

            Button("Permissões") {
                NotificationCenter.default.post(
                    name: .airShortcutSelectSection,
                    object: AirShortcutSection.permissions.rawValue
                )
            }
            .keyboardShortcut("2", modifiers: [.command])

            Button("Regras") {
                NotificationCenter.default.post(
                    name: .airShortcutSelectSection,
                    object: AirShortcutSection.rules.rawValue
                )
            }
            .keyboardShortcut("3", modifiers: [.command])

            Button("Perfis") {
                NotificationCenter.default.post(
                    name: .airShortcutSelectSection,
                    object: AirShortcutSection.profiles.rawValue
                )
            }
            .keyboardShortcut("4", modifiers: [.command])

            Button("Biblioteca") {
                NotificationCenter.default.post(
                    name: .airShortcutSelectSection,
                    object: AirShortcutSection.library.rawValue
                )
            }
            .keyboardShortcut("5", modifiers: [.command])

            Button("Laboratório") {
                NotificationCenter.default.post(
                    name: .airShortcutSelectSection,
                    object: AirShortcutSection.laboratory.rawValue
                )
            }
            .keyboardShortcut("6", modifiers: [.command])

            Button("Métricas") {
                NotificationCenter.default.post(
                    name: .airShortcutSelectSection,
                    object: AirShortcutSection.metrics.rawValue
                )
            }
            .keyboardShortcut("7", modifiers: [.command])

            Button("Log") {
                NotificationCenter.default.post(
                    name: .airShortcutSelectSection,
                    object: AirShortcutSection.log.rawValue
                )
            }
            .keyboardShortcut("8", modifiers: [.command])
        }
    }
}
