# LockWidget

A zero clutter macOS lock screen music player built in Swift and SwiftUI.

Central Vault Link: [[INDEX|Alma's Central Knowledge Base]]
Norms Link: [[05-Agent-Brain/Rules/ALMA_NORMS|Alma's Non-Negotiable Norms]]

---

## 1. Core Architecture and Philosophy

LockWidget brings the Windows 11 lock screen media experience to macOS with zero desktop clutter:
• **Zero Desktop Clutter:** Operates as a pure background agent (`LSUIElement: true`). It never keeps an open editor or preview window over your workspace.
• **Instant Visibility on Lock:** Listens for `com.apple.screenIsLocked` notifications, wakes up and attaches to the macOS lock space.
• **Vanishes on Unlock:** When `com.apple.screenIsUnlocked` fires, the card disappears completely.
• **Pure Performance:** Polling and rendering pause completely while your Mac is unlocked to preserve battery and CPU.

---

## 2. Technical Stack and Components

1. **SkyLight Helper (`SkyLightHelper.swift`):**
   • Interacts with Apple's private SkyLight window server framework.
   • Creates a custom space at absolute level 400 (`kSLSSpaceAbsoluteLevelNotificationCenterAtScreenLock`).
   • Attaches the overlay window directly to the lock space via `SLSSpaceAddWindowsAndRemoveFromSpaces`.

2. **Overlay Panel (`LockOverlayWindow.swift`):**
   • Custom `NSPanel` with `canBecomeVisibleWithoutLogin = true`.
   • Positioned cleanly at bottom left (48pt margins) away from the macOS lock screen clock and password field.
   • Level set to `Int32.max - 2`.

3. **Music Engine (`SpotifyManager.swift`):**
   • Communicates with Spotify via native AppleScript.
   • Extracts real time song title, artist, album, artwork URL, playback position and total track duration.
   • Downloads and caches high resolution artwork in memory.
   • Provides track controls for play, pause, next and previous.

4. **UI Design (`LockWidgetView.swift`):**
   • Frosted glass container using native `.ultraThinMaterial` with a subtle white gradient border.
   • 96x96 rounded artwork thumbnail with soft drop shadow.
   • Live glowing status indicator, title, artist and animated progress capsule.

5. **Application Lifecycle (`AppDelegate.swift` and `LockWidgetCoordinator.swift`):**
   • Silent menu bar presence with preview and quit capabilities.
   • Auto detection of lock and sleep transitions.

---

## 3. Build and Deployment Commands

To build the native release application bundle:
```bash
cd /Users/soul/repo/LockWidget
./bundle.sh
```

To run the application:
```bash
open /Users/soul/repo/LockWidget/LockWidget.app
```
