import Foundation

struct WebsiteCategory: Identifiable {
    let id: String
    let name: String
    let systemImage: String
    let keywords: [String]
    var isEnabled: Bool

    static let predefined: [WebsiteCategory] = [
        WebsiteCategory(
            id: "social_media",
            name: "Social Media",
            systemImage: "bubble.left.and.bubble.right.fill",
            keywords: ["facebook.com", "twitter.com", "x.com", "instagram.com", "tiktok.com", "snapchat.com", "reddit.com", "linkedin.com"],
            isEnabled: false
        ),
        WebsiteCategory(
            id: "shopping",
            name: "Shopping",
            systemImage: "cart.fill",
            keywords: ["amazon.com", "ebay.com", "etsy.com", "walmart.com", "target.com", "aliexpress.com", "shopify.com", "wish.com"],
            isEnabled: false
        ),
        WebsiteCategory(
            id: "news",
            name: "News",
            systemImage: "newspaper.fill",
            keywords: ["cnn.com", "bbc.com", "foxnews.com", "nytimes.com", "reuters.com", "theguardian.com", "huffpost.com", "news.google.com"],
            isEnabled: false
        ),
        WebsiteCategory(
            id: "entertainment",
            name: "Entertainment",
            systemImage: "film.fill",
            keywords: ["youtube.com", "netflix.com", "hulu.com", "twitch.tv", "disneyplus.com", "spotify.com", "soundcloud.com", "dailymotion.com"],
            isEnabled: false
        ),
        WebsiteCategory(
            id: "gaming",
            name: "Gaming",
            systemImage: "gamecontroller.fill",
            keywords: ["steampowered.com", "epicgames.com", "roblox.com", "miniclip.com", "itch.io", "kongregate.com", "poki.com", "coolmathgames.com"],
            isEnabled: false
        ),
    ]
}
