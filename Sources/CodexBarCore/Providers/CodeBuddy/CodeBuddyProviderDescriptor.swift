import CodexBarMacroSupport
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

@ProviderDescriptorRegistration
@ProviderDescriptorDefinition
public enum CodeBuddyProviderDescriptor {
    static func makeDescriptor() -> ProviderDescriptor {
        ProviderDescriptor(
            id: .codeBuddy,
            metadata: ProviderMetadata(
                id: .codeBuddy,
                displayName: "CodeBuddy",
                sessionLabel: "Monthly",
                weeklyLabel: "Daily",
                opusLabel: nil,
                supportsOpus: false,
                supportsCredits: false,
                creditsHint: "",
                toggleTitle: "Show CodeBuddy usage",
                cliName: "codebuddy",
                defaultEnabled: false,
                isPrimaryProvider: false,
                usesAccountFallback: false,
                dashboardURL: "https://www.codebuddy.ai/profile/usage",
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
                sourceModes: [.auto, .api],
                pipeline: ProviderFetchPipeline(resolveStrategies: { context in
                    [CodeBuddyAPIFetchStrategy()]
                })),
            cli: ProviderCLIConfig(
                name: "codebuddy",
                aliases: ["codebuddy-cli"],
                versionDetector: { _ in nil }))
    }
}

// MARK: - API Key Fetch Strategy

struct CodeBuddyAPIFetchStrategy: ProviderFetchStrategy {
    let id: String = "codebuddy.api"
    let kind: ProviderFetchKind = .apiToken

    func isAvailable(_ context: ProviderFetchContext) async -> Bool {
        Self.resolveToken(environment: context.env) != nil
    }

    func fetch(_ context: ProviderFetchContext) async throws -> ProviderFetchResult {
        guard let token = Self.resolveToken(environment: context.env), !token.isEmpty else {
            throw URLError(.userAuthenticationRequired)
        }
        let fetcher = CodeBuddyUsageFetcher(apiKey: token)
        let snap = try await fetcher.fetch()
        return self.makeResult(usage: snap, sourceLabel: "api")
    }

    func shouldFallback(on _: Error, context _: ProviderFetchContext) -> Bool {
        false
    }

    private static func resolveToken(environment: [String: String]) -> String? {
        ProviderTokenResolver.codeBuddyToken(environment: environment)
    }
}

// MARK: - Usage Fetcher

public struct CodeBuddyUsageFetcher: Sendable {
    private let apiKey: String

    public init(apiKey: String) {
        self.apiKey = apiKey
    }

    public func fetch() async throws -> UsageSnapshot {
        guard let url = URL(string: "https://www.codebuddy.ai/billing/meter/get-user-resource") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        request.setValue("Bearer \(self.apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = "{}".data(using: .utf8)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
            throw URLError(.userAuthenticationRequired)
        }

        guard httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let usage = try JSONDecoder().decode(CodeBuddyUsageResponse.self, from: data)
        return self.makeSnapshot(from: usage)
    }

    private func makeSnapshot(from usage: CodeBuddyUsageResponse) -> UsageSnapshot {
        let credit = usage.credit

        // Primary: Monthly credits usage
        let monthlyUsedPercent: Double
        if credit.creditTotalMonth > 0 {
            monthlyUsedPercent = min(100, Double(credit.creditUsedMonth) / Double(credit.creditTotalMonth) * 100)
        } else {
            monthlyUsedPercent = 0
        }

        let monthlyResetDate: Date?
        if credit.resetAtMonth > 0 {
            monthlyResetDate = Date(timeIntervalSince1970: TimeInterval(credit.resetAtMonth))
        } else {
            monthlyResetDate = nil
        }

        let primary = RateWindow(
            usedPercent: monthlyUsedPercent,
            windowMinutes: nil,
            resetsAt: monthlyResetDate,
            resetDescription: nil)

        // Secondary: Daily credits usage
        let dailyUsedPercent: Double
        if credit.creditTotalDaily > 0 {
            dailyUsedPercent = min(100, Double(credit.creditUsedDaily) / Double(credit.creditTotalDaily) * 100)
        } else {
            dailyUsedPercent = 0
        }

        let dailyResetDate: Date?
        if credit.resetAtDaily > 0 {
            dailyResetDate = Date(timeIntervalSince1970: TimeInterval(credit.resetAtDaily))
        } else {
            dailyResetDate = nil
        }

        let secondary = RateWindow(
            usedPercent: dailyUsedPercent,
            windowMinutes: nil,
            resetsAt: dailyResetDate,
            resetDescription: nil)

        let identity = ProviderIdentitySnapshot(
            providerID: .codeBuddy,
            accountEmail: nil,
            accountOrganization: nil,
            loginMethod: usage.planType ?? "CodeBuddy")

        return UsageSnapshot(
            primary: primary,
            secondary: secondary.usedPercent > 0 ? secondary : nil,
            tertiary: nil,
            providerCost: nil,
            updatedAt: Date(),
            identity: identity)
    }
}

// MARK: - Response Models

struct CodeBuddyUsageResponse: Codable, Sendable {
    let credit: CodeBuddyCredit
    let planType: String?

    enum CodingKeys: String, CodingKey {
        case credit
        case planType
    }

    init(from decoder: Decoder) throws {
        // Try top-level first
        if let container = try? decoder.container(keyedBy: CodingKeys.self) {
            if let credit = try? container.decode(CodeBuddyCredit.self, forKey: .credit) {
                self.credit = credit
                self.planType = try? container.decodeIfPresent(String.self, forKey: .planType)
                return
            }
        }

        // Try nested under Response or data
        struct Wrapper: Codable {
            let Response: ResponseBody?
            let data: ResponseBody?

            struct ResponseBody: Codable {
                let credit: CodeBuddyCredit?
                let planType: String?
            }
        }

        let wrapper = try Wrapper(from: decoder)
        if let body = wrapper.Response ?? wrapper.data, let credit = body.credit {
            self.credit = credit
            self.planType = body.planType
        } else {
            // Fallback: try to decode credit from the root
            self.credit = try CodeBuddyCredit(from: decoder)
            self.planType = nil
        }
    }
}

struct CodeBuddyCredit: Codable, Sendable {
    let creditUsedMonth: Int
    let creditTotalMonth: Int
    let resetAtMonth: Int
    let expireAtMonth: Int
    let extraCreditUsed: Int
    let extraCreditTotal: Int
    let extraCreditLimit: Int
    let creditUsedDaily: Int
    let creditTotalDaily: Int
    let resetAtDaily: Int

    enum CodingKeys: String, CodingKey {
        case creditUsedMonth
        case creditTotalMonth
        case resetAtMonth
        case expireAtMonth
        case extraCreditUsed
        case extraCreditTotal
        case extraCreditLimit
        case creditUsedDaily
        case creditTotalDaily
        case resetAtDaily
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.creditUsedMonth = (try? container.decode(Int.self, forKey: .creditUsedMonth)) ?? 0
        self.creditTotalMonth = (try? container.decode(Int.self, forKey: .creditTotalMonth)) ?? 0
        self.resetAtMonth = (try? container.decode(Int.self, forKey: .resetAtMonth)) ?? 0
        self.expireAtMonth = (try? container.decode(Int.self, forKey: .expireAtMonth)) ?? 0
        self.extraCreditUsed = (try? container.decode(Int.self, forKey: .extraCreditUsed)) ?? 0
        self.extraCreditTotal = (try? container.decode(Int.self, forKey: .extraCreditTotal)) ?? 0
        self.extraCreditLimit = (try? container.decode(Int.self, forKey: .extraCreditLimit)) ?? 0
        self.creditUsedDaily = (try? container.decode(Int.self, forKey: .creditUsedDaily)) ?? 0
        self.creditTotalDaily = (try? container.decode(Int.self, forKey: .creditTotalDaily)) ?? 0
        self.resetAtDaily = (try? container.decode(Int.self, forKey: .resetAtDaily)) ?? 0
    }
}
