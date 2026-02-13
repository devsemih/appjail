import AppKit

struct AppInfo: Identifiable, Hashable {
    let id: String
    let name: String
    let icon: NSImage
    let bundleURL: URL
    let isBrowser: Bool

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: AppInfo, rhs: AppInfo) -> Bool {
        lhs.id == rhs.id
    }
}
