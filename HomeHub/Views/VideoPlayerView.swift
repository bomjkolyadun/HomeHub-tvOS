import Combine
import Foundation
import AVKit
import SwiftUI

struct VideoPlayerView: View {
  let video: VideoItem
  @EnvironmentObject var apiService: VideoAPIService
  @Environment(\.presentationMode) var presentationMode
  @State private var player: AVPlayer?

  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()

      if let player = player {
        VideoPlayer(player: player)
          .ignoresSafeArea()
      } else {
        ProgressView("Loading video...")
          .foregroundColor(.white)
      }
    }
    .onAppear {
      setupPlayer()
    }
    .onDisappear {
      player?.pause()
    }
    .gesture(
      TapGesture()
        .onEnded { _ in
          presentationMode.wrappedValue.dismiss()
        }
    )
  }

  private func setupPlayer() {
    let videoURL = "\(apiService.baseURL)\(video.streamURL)"
    guard let url = URL(string: videoURL) else { return }

    player = AVPlayer(url: url)
    player?.play()
  }
}
