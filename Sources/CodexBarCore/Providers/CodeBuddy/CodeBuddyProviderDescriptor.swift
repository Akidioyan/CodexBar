import CodexBarMacroSupport
import Foundation

@ProviderDescriptorRegistration
@ProviderDescriptorDefinition
public enum CodeBuddyProviderDescriptor {
    static func makeDescriptor() -> ProviderDescriptor {
        ProviderDescriptor(
            id: .codeBuddy,
            metadata: ProviderMetadata(
                id: .codeBuddy,
                displayName: "CodeBuddy",
                sessionLabel: "Requests",
                weeklyLabel: "Weekly",
                opusLabel: nil,
                supportsOpus: false,
                supportsCredits: false,
                creditsHint: "",
                toggleTitle: "Show CodeBuddy usage",
                cliName: "codebuddy",
                defaultEnabled: false,
                isPrimaryProvider: false,
                usesAccountFallback: false,
                dashboardURL: nil,
                statusPageURL: nil,
                statusLinkURL: nil),
            branding: ProviderBranding(
                iconStyle: .codeBuddy,
                iconResourceName: "ProviderIcon-codebuddy",
                color: ProviderColor(red: 0 / 255, green: 122 / 255, blue: 255 / 255)),
            tokenCost: ProviderTokenCostConfig(
                supportsTokenCost: false,
                noDataMessage: { "CodeBuddy cost summary is not yet supported." }),
            fetchPlan: ProviderFetchPlan(
                sourceModes: [.auto, .cli],
                pipeline: ProviderFetchPipeline(resolveStrategies: { _ in [CodeBuddyCLIFetchStrategy()] })),
            cli: ProviderCLIConfig(
                name: "codebuddy",
                aliases: ["codebuddy-cli"],
                versionDetector: { _ in nil }))
    }
}

struct CodeBuddyCLIFetchStrategy: ProviderFetchStrategy {
    let id: String = "codebuddy.cli"
    let kind: ProviderFetchKind = .cli

    func isAvailable(_: ProviderFetchContext) async -> Bool {
        TTYCommandRunner.which("codebuddy") != nil
    }

    func fetch(_: ProviderFetchContext) async throws -> ProviderFetchResult {
        throw ProviderFetchError.noData(reason: "CodeBuddy CLI usage tracking is not yet implemented.")
    }

    func shouldFallback(on _: Error, context _: ProviderFetchContext) -> Bool {
        false
    }
}
