import SwiftUI

public struct LockWidgetView: View {
    @ObservedObject var spotify = SpotifyManager.shared
    @State private var dragPosition: Double? = nil
    
    public init() {}
    
    private var displayedPosition: Double {
        dragPosition ?? spotify.currentTrack.position
    }
    
    private var displayedProgress: Double {
        guard spotify.currentTrack.duration > 0 else { return 0 }
        return min(max(displayedPosition / spotify.currentTrack.duration, 0), 1)
    }
    
    public var body: some View {
        HStack(spacing: 16) {
            // Album Artwork
            ZStack {
                if let nsImage = spotify.artwork {
                    Image(nsImage: nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                    Image(systemName: "music.note")
                        .font(.system(size: 28, weight: .light))
                        .foregroundColor(.white.opacity(0.4))
                }
            }
            .frame(width: 92, height: 92)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.35), radius: 10, x: 0, y: 5)
            
            // Track Info and Interactive Controls
            VStack(alignment: .leading, spacing: 6) {
                // Track Title in Arial
                Text(spotify.currentTrack.title)
                    .font(.custom("Arial", size: 16))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                // Artist in Arial
                Text(spotify.currentTrack.artist)
                    .font(.custom("Arial", size: 13))
                    .foregroundColor(.white.opacity(0.75))
                    .lineLimit(1)
                
                Spacer(minLength: 2)
                
                // Interactive Sound Timeline
                VStack(spacing: 4) {
                    GeometryReader { geo in
                        let width = geo.size.width
                        let activeWidth = max(0, min(width, width * displayedProgress))
                        
                        ZStack(alignment: .leading) {
                            // Hit area background
                            Rectangle()
                                .fill(Color.clear)
                                .frame(height: 20)
                            
                            // Background track capsule
                            Capsule()
                                .fill(Color.white.opacity(0.18))
                                .frame(height: 5)
                            
                            // Active played progress
                            Capsule()
                                .fill(Color.white)
                                .frame(width: activeWidth, height: 5)
                            
                            // Scrubbing Thumb Knob
                            Circle()
                                .fill(Color.white)
                                .frame(width: 11, height: 11)
                                .shadow(color: .black.opacity(0.4), radius: 3, x: 0, y: 1)
                                .offset(x: max(0, min(width - 11, activeWidth - 5.5)))
                        }
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    spotify.setScrubbing(true)
                                    let ratio = max(0, min(1, value.location.x / width))
                                    let newSec = ratio * spotify.currentTrack.duration
                                    dragPosition = newSec
                                }
                                .onEnded { value in
                                    let ratio = max(0, min(1, value.location.x / width))
                                    let newSec = ratio * spotify.currentTrack.duration
                                    spotify.seek(to: newSec)
                                    dragPosition = nil
                                    spotify.setScrubbing(false)
                                }
                        )
                    }
                    .frame(height: 14)
                    
                    // Timestamps in Arial
                    HStack {
                        Text(formatTime(displayedPosition))
                            .font(.custom("Arial", size: 11))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Spacer()
                        
                        Text(formatTime(spotify.currentTrack.duration))
                            .font(.custom("Arial", size: 11))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                
                // Playback Controls
                HStack(spacing: 20) {
                    Button(action: { spotify.previousTrack() }) {
                        Image(systemName: "backward.fill")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.85))
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: { spotify.togglePlayPause() }) {
                        Image(systemName: spotify.currentTrack.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: { spotify.nextTrack() }) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.85))
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                }
                .padding(.top, 2)
            }
        }
        .padding(16)
        .frame(width: 400, height: 134)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.3), Color.white.opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: .black.opacity(0.4), radius: 24, x: 0, y: 10)
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let total = max(0, Int(seconds))
        let mins = total / 60
        let secs = total % 60
        return String(format: "%d:%02d", mins, secs)
    }
}
