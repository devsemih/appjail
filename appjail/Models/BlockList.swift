import Foundation
import Combine

class BlockList: ObservableObject {
    private static let blockedAppsKey = "blockedAppBundleIDs"
    private static let urlKeywordsKey = "urlKeywords"
    private static let enabledCategoryIDsKey = "enabledCategoryIDs"
    private static let schedulesKey = "schedules"

    @Published var blockedAppBundleIDs: Set<String> {
        didSet { save() }
    }

    @Published var urlKeywords: [String] {
        didSet { save() }
    }

    @Published var enabledCategoryIDs: Set<String> {
        didSet { save() }
    }

    @Published var schedules: [BlockSchedule] {
        didSet { save() }
    }

    var effectiveKeywords: [String] {
        var combined = Set(urlKeywords)
        for category in WebsiteCategory.predefined where enabledCategoryIDs.contains(category.id) {
            combined.formUnion(category.keywords)
        }
        return Array(combined)
    }

    init() {
        let savedApps = UserDefaults.standard.stringArray(forKey: Self.blockedAppsKey) ?? []
        self.blockedAppBundleIDs = Set(savedApps)
        self.urlKeywords = UserDefaults.standard.stringArray(forKey: Self.urlKeywordsKey) ?? []

        if let catData = UserDefaults.standard.stringArray(forKey: Self.enabledCategoryIDsKey) {
            self.enabledCategoryIDs = Set(catData)
        } else {
            self.enabledCategoryIDs = []
        }

        if let scheduleData = UserDefaults.standard.data(forKey: Self.schedulesKey),
           let decoded = try? JSONDecoder().decode([BlockSchedule].self, from: scheduleData) {
            self.schedules = decoded
        } else {
            self.schedules = []
        }
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
        return effectiveKeywords.first { lower.contains($0) }
    }

    func toggleCategory(_ categoryID: String) {
        if enabledCategoryIDs.contains(categoryID) {
            enabledCategoryIDs.remove(categoryID)
        } else {
            enabledCategoryIDs.insert(categoryID)
        }
    }

    func addSchedule(_ schedule: BlockSchedule) {
        schedules.append(schedule)
    }

    func removeSchedule(_ id: UUID) {
        schedules.removeAll { $0.id == id }
    }

    func updateSchedule(_ schedule: BlockSchedule) {
        if let index = schedules.firstIndex(where: { $0.id == schedule.id }) {
            schedules[index] = schedule
        }
    }

    private func save() {
        UserDefaults.standard.set(Array(blockedAppBundleIDs), forKey: Self.blockedAppsKey)
        UserDefaults.standard.set(urlKeywords, forKey: Self.urlKeywordsKey)
        UserDefaults.standard.set(Array(enabledCategoryIDs), forKey: Self.enabledCategoryIDsKey)
        if let scheduleData = try? JSONEncoder().encode(schedules) {
            UserDefaults.standard.set(scheduleData, forKey: Self.schedulesKey)
        }
    }
}
