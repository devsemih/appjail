import Foundation
import Combine

class BlockList: ObservableObject {
    private static let blockedAppsKey = "blockedAppBundleIDs"
    private static let urlKeywordsKey = "urlKeywords"

    @Published var blockedAppBundleIDs: Set<String> {
        didSet { save() }
    }

    @Published var urlKeywords: [String] {
        didSet { save() }
    }

    init() {
        let savedApps = UserDefaults.standard.stringArray(forKey: Self.blockedAppsKey) ?? []
        self.blockedAppBundleIDs = Set(savedApps)
        self.urlKeywords = UserDefaults.standard.stringArray(forKey: Self.urlKeywordsKey) ?? []
    }

    func isBlocked(_ bundleID: String) -> Bool {
        blockedAppBundleIDs.contains(bundleID)
    }

    func toggleBlock(_ bundleID: String) {
        if blockedAppBundleIDs.contains(bundleID) {
            blockedAppBundleIDs.remove(bundleID)
        } else {
            blockedAppBundleIDs.insert(bundleID)
        }
    }

    func addKeyword(_ keyword: String) {
        let trimmed = keyword.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty, !urlKeywords.contains(trimmed) else { return }
        urlKeywords.append(trimmed)
    }

    func removeKeyword(_ keyword: String) {
        urlKeywords.removeAll { $0 == keyword }
    }

    func urlMatchesKeywords(_ url: String) -> String? {
        let lower = url.lowercased()
        return urlKeywords.first { lower.contains($0) }
    }

    private func save() {
        UserDefaults.standard.set(Array(blockedAppBundleIDs), forKey: Self.blockedAppsKey)
        UserDefaults.standard.set(urlKeywords, forKey: Self.urlKeywordsKey)
    }
}
