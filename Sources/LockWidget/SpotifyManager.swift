import Foundation
import AppKit
import Combine

public struct TrackInfo: Equatable, Sendable {
    public let title: String
    public let artist: String
    public let album: String
    public let artworkUrl: String
    public let position: Double
    public let duration: Double
    public let isPlaying: Bool
    
    public var progress: Double {
        guard duration > 0 else { return 0 }
        return min(max(position / duration, 0), 1)
    }
    
    public static let empty = TrackInfo(
        title: "No Track Playing",
        artist: "",
        album: "",
        artworkUrl: "",
        position: 0,
        duration: 0,
        isPlaying: false
    )
}

@MainActor
public final class SpotifyManager: ObservableObject {
    public static let shared = SpotifyManager()
    
    @Published public var currentTrack: TrackInfo = .empty
    @Published public var artwork: NSImage? = nil
    @Published public var isSpotifyRunning: Bool = false
    
    private var timer: Timer?
    private var lastLoadedArtworkUrl: String = ""
    private var isUserScrubbing: Bool = false
    
    private init() {
        refresh()
    }
    
    public func startPolling() {
        stopPolling()
        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self, !self.isUserScrubbing else { return }
                self.refresh()
            }
        }
    }
    
    public func stopPolling() {
        timer?.invalidate()
        timer = nil
    }
    
    public func refresh() {
        let isRunning = NSWorkspace.shared.runningApplications.contains { app in
            app.bundleIdentifier == "com.spotify.client"
        }
        self.isSpotifyRunning = isRunning
        
        guard isRunning else {
            if currentTrack != .empty {
                currentTrack = .empty
                artwork = nil
                lastLoadedArtworkUrl = ""
            }
            return
        }
        
        let scriptSource = """
        tell application "Spotify"
            try
                set pState to player state
                if pState is playing or pState is paused then
                    set tName to name of current track
                    set tArtist to artist of current track
                    set tAlbum to album of current track
                    set tArt to artwork url of current track
                    set tPos to player position
                    set tDur to (duration of current track) / 1000
                    set stStr to "PLAYING"
                    if pState is paused then
                        set stStr to "PAUSED"
                    end if
                    return stStr & ":::" & tName & ":::" & tArtist & ":::" & tAlbum & ":::" & tArt & ":::" & (tPos as string) & ":::" & (tDur as string)
                else
                    return "STOPPED"
                end if
            on error
                return "ERROR"
            end try
        end tell
        """
        
        var error: NSDictionary?
        guard let script = NSAppleScript(source: scriptSource) else { return }
        let output = script.executeAndReturnError(&error)
        guard error == nil, let raw = output.stringValue, raw != "ERROR", raw != "STOPPED" else {
            return
        }
        
        let parts = raw.components(separatedBy: ":::")
        guard parts.count >= 7 else { return }
        
        let isPlaying = parts[0] == "PLAYING"
        let title = parts[1]
        let artist = parts[2]
        let album = parts[3]
        let artworkUrl = parts[4]
        
        let posStr = parts[5].replacingOccurrences(of: ",", with: ".")
        let durStr = parts[6].replacingOccurrences(of: ",", with: ".")
        let position = Double(posStr) ?? 0.0
        let duration = Double(durStr) ?? 0.0
        
        let updatedTrack = TrackInfo(
            title: title,
            artist: artist,
            album: album,
            artworkUrl: artworkUrl,
            position: position,
            duration: duration,
            isPlaying: isPlaying
        )
        
        self.currentTrack = updatedTrack
        
        if artworkUrl != lastLoadedArtworkUrl && !artworkUrl.isEmpty {
            lastLoadedArtworkUrl = artworkUrl
            loadArtwork(from: artworkUrl)
        }
    }
    
    public func seek(to seconds: Double) {
        let target = max(0, min(seconds, currentTrack.duration))
        let targetFormatted = String(format: "%.1f", target)
        executeScript("tell application \"Spotify\" to set player position to \(targetFormatted)")
        
        let updated = TrackInfo(
            title: currentTrack.title,
            artist: currentTrack.artist,
            album: currentTrack.album,
            artworkUrl: currentTrack.artworkUrl,
            position: target,
            duration: currentTrack.duration,
            isPlaying: currentTrack.isPlaying
        )
        self.currentTrack = updated
    }
    
    public func setScrubbing(_ scrubbing: Bool) {
        self.isUserScrubbing = scrubbing
    }
    
    private func loadArtwork(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let image = NSImage(data: data) else { return }
            Task { @MainActor [weak self] in
                self?.artwork = image
            }
        }.resume()
    }
    
    public func togglePlayPause() {
        executeScript("tell application \"Spotify\" to playpause")
        refresh()
    }
    
    public func nextTrack() {
        executeScript("tell application \"Spotify\" to next track")
        refresh()
    }
    
    public func previousTrack() {
        executeScript("tell application \"Spotify\" to previous track")
        refresh()
    }
    
    private func executeScript(_ source: String) {
        var error: NSDictionary?
        if let script = NSAppleScript(source: source) {
            script.executeAndReturnError(&error)
        }
    }
}
