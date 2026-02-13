# AppJail

A lightweight macOS menu bar utility that blocks distracting apps and browser tabs.

AppJail sits in your menu bar and enforces focus by terminating blocked applications and closing browser tabs that match URL keywords — all powered by native macOS APIs.

![macOS](https://img.shields.io/badge/macOS-26.0%2B-black?logo=apple)
![Swift](https://img.shields.io/badge/Swift-6-orange?logo=swift)
![License](https://img.shields.io/badge/License-MIT-blue)

## Features

- **Block Apps** — Toggle any installed application to blocked. When activated, the app is immediately terminated.
- **Block Browser Tabs** — Add URL keywords (e.g. `youtube`, `reddit`, `twitter`). Matching tabs are closed when you switch to a browser.
- **Menu Bar Only** — Runs entirely from the menu bar with no dock icon.
- **Event-Driven** — Monitors app switches via `NSWorkspace` notifications. No polling, no CPU waste.
- **Violation Alerts** — A floating panel appears briefly when a blocked app or URL is caught.
- **Persistent** — Your block lists survive app restarts (stored in UserDefaults).

## Supported Browsers

| Browser | App Block | Tab Block |
|---------|-----------|-----------|
| Safari | Yes | Yes |
| Google Chrome | Yes | Yes |
| Microsoft Edge | Yes | Yes |
| Brave | Yes | Yes |
| Arc | Yes | Yes |
| Dia | Yes | Yes |
| Vivaldi | Yes | Yes |
| Opera | Yes | Yes |
| Firefox | Yes | No (no AppleScript support) |

## Installation

### Download

Download the latest DMG from [Releases](https://github.com/devsemih/appjail/releases), open it, and drag **appjail** to your Applications folder.

Since the app is not notarized, macOS may show a "damaged" warning. Run this after installing:

```bash
xattr -cr /Applications/appjail.app
```

### Build from Source

```bash
git clone https://github.com/devsemih/appjail.git
cd appjail
xcodebuild -project appjail.xcodeproj -scheme appjail -configuration Release
```

Requires **Xcode 26.2+** and **macOS 26.0+**.

## Permissions

AppJail needs two permissions on first launch:

| Permission | Why |
|---|---|
| **Accessibility** | To monitor which app is frontmost and terminate blocked apps |
| **Automation** | To read browser URLs and close tabs via AppleScript |

The onboarding screen guides you through granting both. You can manage them later in **System Settings → Privacy & Security**.

## How It Works

1. AppJail observes `NSWorkspace.didActivateApplicationNotification` to detect app switches.
2. When a blocked app comes to the foreground, it calls `terminate()` on the process.
3. When a registered browser activates and URL keywords exist, it waits 300ms for the page to load, reads the active tab URL via AppleScript, and closes the tab if a keyword matches.

No background polling. No network requests. Everything runs locally.

## Architecture

```
Models/         Data models and persistence (BlockList, AppInfo)
Services/       Core logic (MonitoringEngine, AppScanner, BrowserRegistry, AppleScript)
Views/          SwiftUI views (Dashboard, Apps tab, Browsers tab, Onboarding)
```

## License

MIT
