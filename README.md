# LockWidget

A minimalist, zero clutter macOS lock screen music player with live Spotify artwork and interactive track scrubbing.

---

## Overview

LockWidget brings the Windows 11 lock screen media experience to macOS with zero workspace pollution.

Most desktop and lock screen widget tools force you to keep an editor open, clutter your desktop with widgets while you are trying to work, or charge subscriptions for basic functionality.

LockWidget follows a single principle: **invisible when unlocked, glanceable and interactive when locked.**

---

## Features

• **Zero Desktop Clutter:** Runs as a pure macOS accessory process (`LSUIElement`). No dock icon, no floating panels and no open windows during normal use.
• **Interactive Sound Timeline:** Click or drag anywhere along the sound bar to seek and change track position in real time.
• **High Resolution Artwork:** Pulls live album art directly from Spotify with rounded glass aesthetics.
• **Clean Typography:** Built strictly in Arial with high contrast white text and zero third party brand badges.
• **SkyLight Window Integration:** Hooks into Apple's private SkyLight window server framework to attach to the lock space (`kSLSSpaceAbsoluteLevelNotificationCenterAtScreenLock`), requiring zero screen recording permissions.
• **Battery and Resource Efficient:** Polling and rendering pause completely the millisecond you unlock your Mac.
• **Adjustable Placement:** Includes menu bar nudge controls to adjust vertical card height to your exact display.

---

## Installation

1. Download the latest **`LockWidget.dmg`** release.
2. Open the disk image and drag **LockWidget.app** into your **Applications** folder.
3. Launch **LockWidget.app**. A subtle music note icon will appear in your top menu bar.
4. Grant the one-time macOS automation permission when prompted so LockWidget can query Spotify playback.

---

## How It Works

```
[Screen Locked Notification]
          │
          ▼
[SkyLight Attaches Window to Lock Space]
          │
          ▼
[Fetch Track Info, Artwork & Position via Local Bridge]
          │
          ▼
[Render Frosted Glass SwiftUI Card with Scrubbing Timeline]
          │
          ▼
[Screen Unlocked Notification] ──► [Window Vanishes Instantly & Polling Stops]
```

---

## Building from Source

### Prerequisites
• macOS 14.0 (Sonoma) or newer
• Xcode 16 / Command Line Tools with Swift 6

### Compile Binary
```bash
git clone https://github.com/<your-username>/LockWidget.git
cd LockWidget
swift build -c release
```

### Build .app Bundle
```bash
./bundle.sh
```

### Build Distribution .dmg
```bash
./make_dmg.sh
```

The compressed installer will be generated at `./LockWidget.dmg`.

---

## Tech Stack

• **Language:** Swift 6
• **UI Framework:** SwiftUI & AppKit (`NSPanel` with `.ultraThinMaterial`)
• **Window Server:** Apple SkyLight Framework (private CGS/SLS APIs)
• **Bridge:** Local AppleScript execution via `NSAppleScript`
• **Dependencies:** 0 external libraries (100% native Apple SDKs)

---

## Menu Bar Controls

Clicking the menu bar icon gives you immediate control:
• **LockWidget Active:** Confirms the background listener is healthy.
• **Preview Lock Widget (5s):** Displays the card on your active screen for five seconds to test layouts and scrubbing without locking your computer.
• **Nudge Position Down / Up:** Adjusts the vertical offset by 4% increments and flashes a quick preview.
• **Quit LockWidget:** Gracefully shuts down the background daemon.

---

## License

MIT License. Free to use, modify and distribute.
