import CodexBarCore
import CodexBarMacroSupport
import Foundation

@ProviderImplementationRegistration
struct CodeBuddyProviderImplementation: ProviderImplementation {
    let id: UsageProvider = .codeBuddy
}
