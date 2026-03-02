import Foundation
import SwiftUI

// MARK: - Language enum

enum AppLanguage: String, CaseIterable, Identifiable {
    case system
    case en
    case zhHans

    var id: String { self.rawValue }

    var displayName: String {
        switch self {
        case .system: "System"
        case .en: "English"
        case .zhHans: "简体中文"
        }
    }
}

// MARK: - Localization Manager

@MainActor
@Observable
final class LocalizationManager {
    static let shared = LocalizationManager()

    private static let userDefaultsKey = "appLanguage"
    private(set) var currentLanguage: AppLanguage

    private init() {
        let raw = UserDefaults.standard.string(forKey: Self.userDefaultsKey) ?? AppLanguage.system.rawValue
        self.currentLanguage = AppLanguage(rawValue: raw) ?? .system
    }

    func setLanguage(_ language: AppLanguage) {
        self.currentLanguage = language
        UserDefaults.standard.set(language.rawValue, forKey: Self.userDefaultsKey)
    }

    var effectiveLanguage: AppLanguage {
        if self.currentLanguage == .system {
            let preferred = Locale.preferredLanguages.first ?? "en"
            if preferred.hasPrefix("zh-Hans") || preferred.hasPrefix("zh-CN") || preferred == "zh" {
                return .zhHans
            }
            return .en
        }
        return self.currentLanguage
    }

    func L(_ key: String) -> String {
        Self.strings[self.effectiveLanguage]?[key] ?? Self.strings[.en]?[key] ?? key
    }

    // MARK: - String Tables

    // swiftlint:disable line_length
    private static let strings: [AppLanguage: [String: String]] = [
        .en: [
            // Tabs
            "tab.general": "General",
            "tab.providers": "Providers",
            "tab.display": "Display",
            "tab.advanced": "Advanced",
            "tab.about": "About",
            "tab.debug": "Debug",

            // General Pane
            "general.system": "System",
            "general.startAtLogin": "Start at Login",
            "general.startAtLogin.subtitle": "Automatically opens CodexBar when you start your Mac.",
            "general.usage": "Usage",
            "general.showCostSummary": "Show cost summary",
            "general.showCostSummary.subtitle": "Reads local usage logs. Shows today + last 30 days cost in the menu.",
            "general.autoRefresh": "Auto-refresh: hourly · Timeout: 10m",
            "general.automation": "Automation",
            "general.refreshCadence": "Refresh cadence",
            "general.refreshCadence.subtitle": "How often CodexBar polls providers in the background.",
            "general.autoRefreshOff": "Auto-refresh is off; use the menu's Refresh command.",
            "general.checkProviderStatus": "Check provider status",
            "general.checkProviderStatus.subtitle": "Polls OpenAI/Claude status pages and Google Workspace for Gemini/Antigravity, surfacing incidents in the icon and menu.",
            "general.sessionQuota": "Session quota notifications",
            "general.sessionQuota.subtitle": "Notifies when the 5-hour session quota hits 0% and when it becomes available again.",
            "general.quitCodexBar": "Quit CodexBar",
            "general.language": "Language",
            "general.language.subtitle": "Change the display language of the application.",

            // Display Pane
            "display.menuBar": "Menu bar",
            "display.mergeIcons": "Merge Icons",
            "display.mergeIcons.subtitle": "Use a single menu bar icon with a provider switcher.",
            "display.switcherShowsIcons": "Switcher shows icons",
            "display.switcherShowsIcons.subtitle": "Show provider icons in the switcher (otherwise show a weekly progress line).",
            "display.showMostUsed": "Show most-used provider",
            "display.showMostUsed.subtitle": "Menu bar auto-shows the provider closest to its rate limit.",
            "display.showPercent": "Menu bar shows percent",
            "display.showPercent.subtitle": "Replace critter bars with provider branding icons and a percentage.",
            "display.displayMode": "Display mode",
            "display.displayMode.subtitle": "Choose what to show in the menu bar (Pace shows usage vs. expected).",
            "display.menuContent": "Menu content",
            "display.showUsageAsUsed": "Show usage as used",
            "display.showUsageAsUsed.subtitle": "Progress bars fill as you consume quota (instead of showing remaining).",
            "display.showResetAsClock": "Show reset time as clock",
            "display.showResetAsClock.subtitle": "Display reset times as absolute clock values instead of countdowns.",
            "display.showCredits": "Show credits + extra usage",
            "display.showCredits.subtitle": "Show Codex Credits and Claude Extra usage sections in the menu.",
            "display.showAllTokenAccounts": "Show all token accounts",
            "display.showAllTokenAccounts.subtitle": "Stack token accounts in the menu (otherwise show an account switcher bar).",
            "display.overviewProviders": "Overview tab providers",
            "display.enableMergeIcons": "Enable Merge Icons to configure Overview tab providers.",
            "display.noEnabledProviders": "No enabled providers available for Overview.",
            "display.configure": "Configure…",
            "display.chooseProviders": "Choose up to %@ providers",
            "display.overviewOrder": "Overview rows always follow provider order.",
            "display.noProviders": "No providers selected",

            // Advanced Pane
            "advanced.keyboardShortcut": "Keyboard shortcut",
            "advanced.openMenu": "Open menu",
            "advanced.triggerMenu": "Trigger the menu bar menu from anywhere.",
            "advanced.installCLI": "Install CLI",
            "advanced.installCLI.subtitle": "Symlink CodexBarCLI to /usr/local/bin and /opt/homebrew/bin as codexbar.",
            "advanced.showDebug": "Show Debug Settings",
            "advanced.showDebug.subtitle": "Expose troubleshooting tools in the Debug tab.",
            "advanced.surprise": "Surprise me",
            "advanced.surprise.subtitle": "Check if you like your agents having some fun up there.",
            "advanced.hidePersonal": "Hide personal information",
            "advanced.hidePersonal.subtitle": "Obscure email addresses in the menu bar and menu UI.",
            "advanced.keychain": "Keychain access",
            "advanced.keychain.subtitle": "Disable all Keychain reads and writes. Browser cookie import is unavailable; paste Cookie headers manually in Providers.",
            "advanced.disableKeychain": "Disable Keychain access",
            "advanced.disableKeychain.subtitle": "Prevents any Keychain access while enabled.",

            // About Pane
            "about.version": "Version %@",
            "about.built": "Built %@",
            "about.slogan": "May your tokens never run out—keep agent limits in view.",
            "about.checkUpdatesAuto": "Check for updates automatically",
            "about.updateChannel": "Update Channel",
            "about.checkUpdates": "Check for Updates…",
            "about.updatesUnavailable": "Updates unavailable in this build.",
            "about.copyright": "© 2025 Peter Steinberger. MIT License.",

            // Menu
            "menu.noUsageConfigured": "No usage configured.",
            "menu.noUsageYet": "No usage yet",
            "menu.settings": "Settings...",
            "menu.aboutCodexBar": "About CodexBar",
            "menu.quit": "Quit",
            "menu.refresh": "Refresh",
            "menu.account": "Account:",
            "menu.plan": "Plan:",
            "menu.switchAccount": "Switch Account...",
            "menu.addAccount": "Add Account...",
            "menu.usageDashboard": "Usage Dashboard",
            "menu.statusPage": "Status Page",
            "menu.updateReady": "Update ready, restart now?",
            "menu.quota": "Quota:",

            // Provider Detail
            "provider.state": "State",
            "provider.source": "Source",
            "provider.version": "Version",
            "provider.updated": "Updated",
            "provider.status": "Status",
            "provider.account": "Account",
            "provider.plan": "Plan",
            "provider.balance": "Balance",
            "provider.enabled": "Enabled",
            "provider.disabled": "Disabled",
            "provider.refreshing": "Refreshing",
            "provider.notFetchedYet": "Not fetched yet",
            "provider.disabledNoData": "Disabled — no recent data",
            "provider.noUsageYet": "No usage yet",
            "provider.usage": "Usage",
            "provider.credits": "Credits",
            "provider.cost": "Cost",
            "provider.refresh": "Refresh",
            "provider.selectProvider": "Select a provider",

            // Card
            "card.left": "left",
            "card.used": "used",
            "card.usageRemaining": "Usage remaining",
            "card.usageUsed": "Usage used",
            "card.refreshing": "Refreshing...",
            "card.notFetchedYet": "Not fetched yet",
            "card.today": "Today:",
            "card.last30Days": "Last 30 days:",
            "card.extraUsage": "Extra usage",
            "card.quotaUsage": "Quota usage",
            "card.thisMonth": "This month",
            "card.codeReview": "Code review",
            "card.copied": "Copied",
            "card.copyError": "Copy error",
            "card.overview": "Overview",

            // Notifications
            "notification.sessionDepleted": "session depleted",
            "notification.zeroLeft": "0% left. Will notify when it's available again.",
            "notification.sessionRestored": "session restored",
            "notification.available": "Session quota is available again.",

            // Usage pace
            "pace.onPace": "On pace",
            "pace.inDeficit": "in deficit",
            "pace.inReserve": "in reserve",
            "pace.lastsUntilReset": "Lasts until reset",
            "pace.runsOutNow": "Runs out now",
            "pace.runsOutIn": "Runs out in",

            // Misc
            "misc.unsupported": "unsupported",
            "misc.fetching": "fetching…",
            "misc.noDataYet": "no data yet",
            "misc.lastAttempt": "last attempt",
            "misc.cancel": "Cancel",
            "misc.hideDetails": "Hide details",
            "misc.showDetails": "Show details",
            "misc.dragToReorder": "Drag to reorder",
            "misc.reorder": "Reorder",
        ],
        .zhHans: [
            // Tabs
            "tab.general": "通用",
            "tab.providers": "服务商",
            "tab.display": "显示",
            "tab.advanced": "高级",
            "tab.about": "关于",
            "tab.debug": "调试",

            // General Pane
            "general.system": "系统",
            "general.startAtLogin": "开机自启",
            "general.startAtLogin.subtitle": "开机时自动启动 CodexBar。",
            "general.usage": "用量",
            "general.showCostSummary": "显示费用摘要",
            "general.showCostSummary.subtitle": "读取本地使用日志，在菜单中显示今日和近 30 天费用。",
            "general.autoRefresh": "自动刷新：每小时 · 超时：10 分钟",
            "general.automation": "自动化",
            "general.refreshCadence": "刷新频率",
            "general.refreshCadence.subtitle": "CodexBar 在后台轮询服务商的时间间隔。",
            "general.autoRefreshOff": "自动刷新已关闭；请使用菜单中的刷新命令。",
            "general.checkProviderStatus": "检查服务商状态",
            "general.checkProviderStatus.subtitle": "轮询 OpenAI/Claude 状态页面和 Google Workspace（用于 Gemini/Antigravity），在图标和菜单中显示故障信息。",
            "general.sessionQuota": "会话配额通知",
            "general.sessionQuota.subtitle": "当 5 小时会话配额归零和恢复时发送通知。",
            "general.quitCodexBar": "退出 CodexBar",
            "general.language": "语言",
            "general.language.subtitle": "更改应用的显示语言。",

            // Display Pane
            "display.menuBar": "菜单栏",
            "display.mergeIcons": "合并图标",
            "display.mergeIcons.subtitle": "使用单个菜单栏图标和服务商切换器。",
            "display.switcherShowsIcons": "切换器显示图标",
            "display.switcherShowsIcons.subtitle": "在切换器中显示服务商图标（否则显示每周进度线）。",
            "display.showMostUsed": "显示最常用的服务商",
            "display.showMostUsed.subtitle": "菜单栏自动显示最接近速率限制的服务商。",
            "display.showPercent": "菜单栏显示百分比",
            "display.showPercent.subtitle": "用服务商品牌图标和百分比替换动物条。",
            "display.displayMode": "显示模式",
            "display.displayMode.subtitle": "选择菜单栏显示内容（节奏模式显示用量 vs 预期）。",
            "display.menuContent": "菜单内容",
            "display.showUsageAsUsed": "以已用量显示",
            "display.showUsageAsUsed.subtitle": "进度条随使用增长（而非显示剩余）。",
            "display.showResetAsClock": "以时钟显示重置时间",
            "display.showResetAsClock.subtitle": "将重置时间显示为绝对时间而非倒计时。",
            "display.showCredits": "显示额度和额外用量",
            "display.showCredits.subtitle": "在菜单中显示 Codex 额度和 Claude 额外用量部分。",
            "display.showAllTokenAccounts": "显示所有 Token 账户",
            "display.showAllTokenAccounts.subtitle": "在菜单中堆叠 Token 账户（否则显示账户切换栏）。",
            "display.overviewProviders": "概览标签页服务商",
            "display.enableMergeIcons": "启用合并图标以配置概览标签页服务商。",
            "display.noEnabledProviders": "没有可用的服务商供概览使用。",
            "display.configure": "配置…",
            "display.chooseProviders": "最多选择 %@ 个服务商",
            "display.overviewOrder": "概览行始终按服务商顺序排列。",
            "display.noProviders": "未选择服务商",

            // Advanced Pane
            "advanced.keyboardShortcut": "键盘快捷键",
            "advanced.openMenu": "打开菜单",
            "advanced.triggerMenu": "从任何位置触发菜单栏菜单。",
            "advanced.installCLI": "安装 CLI",
            "advanced.installCLI.subtitle": "将 CodexBarCLI 链接到 /usr/local/bin 和 /opt/homebrew/bin。",
            "advanced.showDebug": "显示调试设置",
            "advanced.showDebug.subtitle": "在调试标签页中开放故障排除工具。",
            "advanced.surprise": "给我惊喜",
            "advanced.surprise.subtitle": "看看你的 AI 助手在菜单栏里玩什么花样。",
            "advanced.hidePersonal": "隐藏个人信息",
            "advanced.hidePersonal.subtitle": "在菜单栏和菜单界面中遮盖邮箱地址。",
            "advanced.keychain": "钥匙串访问",
            "advanced.keychain.subtitle": "禁用所有钥匙串读写。浏览器 Cookie 导入不可用；请在服务商中手动粘贴 Cookie 头。",
            "advanced.disableKeychain": "禁用钥匙串访问",
            "advanced.disableKeychain.subtitle": "启用后阻止所有钥匙串访问。",

            // About Pane
            "about.version": "版本 %@",
            "about.built": "构建于 %@",
            "about.slogan": "愿你的 Token 永不耗尽——时刻关注 AI 用量限制。",
            "about.checkUpdatesAuto": "自动检查更新",
            "about.updateChannel": "更新频道",
            "about.checkUpdates": "检查更新…",
            "about.updatesUnavailable": "此版本不支持更新。",
            "about.copyright": "© 2025 Peter Steinberger. MIT 许可证。",

            // Menu
            "menu.noUsageConfigured": "未配置用量监控。",
            "menu.noUsageYet": "暂无用量数据",
            "menu.settings": "设置...",
            "menu.aboutCodexBar": "关于 CodexBar",
            "menu.quit": "退出",
            "menu.refresh": "刷新",
            "menu.account": "账户：",
            "menu.plan": "方案：",
            "menu.switchAccount": "切换账户...",
            "menu.addAccount": "添加账户...",
            "menu.usageDashboard": "用量面板",
            "menu.statusPage": "状态页面",
            "menu.updateReady": "更新已就绪，立即重启？",
            "menu.quota": "配额：",

            // Provider Detail
            "provider.state": "状态",
            "provider.source": "来源",
            "provider.version": "版本",
            "provider.updated": "更新时间",
            "provider.status": "状态",
            "provider.account": "账户",
            "provider.plan": "方案",
            "provider.balance": "余额",
            "provider.enabled": "已启用",
            "provider.disabled": "已禁用",
            "provider.refreshing": "刷新中",
            "provider.notFetchedYet": "尚未获取",
            "provider.disabledNoData": "已禁用 — 无近期数据",
            "provider.noUsageYet": "暂无用量数据",
            "provider.usage": "用量",
            "provider.credits": "额度",
            "provider.cost": "费用",
            "provider.refresh": "刷新",
            "provider.selectProvider": "选择一个服务商",

            // Card
            "card.left": "剩余",
            "card.used": "已用",
            "card.usageRemaining": "剩余用量",
            "card.usageUsed": "已用用量",
            "card.refreshing": "刷新中...",
            "card.notFetchedYet": "尚未获取",
            "card.today": "今日：",
            "card.last30Days": "近 30 天：",
            "card.extraUsage": "额外用量",
            "card.quotaUsage": "配额用量",
            "card.thisMonth": "本月",
            "card.codeReview": "代码审查",
            "card.copied": "已复制",
            "card.copyError": "复制错误信息",
            "card.overview": "概览",

            // Notifications
            "notification.sessionDepleted": "会话额度已耗尽",
            "notification.zeroLeft": "剩余 0%。恢复后将通知你。",
            "notification.sessionRestored": "会话额度已恢复",
            "notification.available": "会话配额已恢复可用。",

            // Usage pace
            "pace.onPace": "进度正常",
            "pace.inDeficit": "超前使用",
            "pace.inReserve": "有余量",
            "pace.lastsUntilReset": "可用至重置",
            "pace.runsOutNow": "即将耗尽",
            "pace.runsOutIn": "将在此后耗尽：",

            // Misc
            "misc.unsupported": "不支持",
            "misc.fetching": "获取中…",
            "misc.noDataYet": "暂无数据",
            "misc.lastAttempt": "上次尝试",
            "misc.cancel": "取消",
            "misc.hideDetails": "隐藏详情",
            "misc.showDetails": "显示详情",
            "misc.dragToReorder": "拖拽排序",
            "misc.reorder": "排序",
        ],
    ]
    // swiftlint:enable line_length
}

// Convenience global function
@MainActor
func L(_ key: String) -> String {
    LocalizationManager.shared.L(key)
}
