//
//  VideoThumbnailCard.swift
//  HomeHub
//
//  Created by Dima Osipa on 6/1/25.
//
import SwiftUI

struct VideoThumbnailCard: View {
  let video: VideoItem
  let onTap: () -> Void
  @EnvironmentObject var apiService: VideoAPIService

  private var thumbnailURL: String? {
    guard let thumbnail = video.thumbnail else { return nil }
    return "\(apiService.baseURL)\(thumbnail)"
  }

  var body: some View {
    Button(action: {
      print("🎬 Video tapped: \(video.title)")
      onTap()
    }) {
      VStack(alignment: .leading, spacing: 8) {
        // Thumbnail
        AsyncImage(url: URL(string: thumbnailURL ?? "")) { image in
          image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(height: 180)
            .clipped()
        } placeholder: {
          Rectangle()
            .fill(Color.secondary.opacity(0.3))
            .frame(height: 180)
            .overlay(
              Image(systemName: "play.rectangle")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            )
        }
        .cornerRadius(8)

        // Title and info
        VStack(alignment: .leading, spacing: 4) {
          Text(video.title)
            .font(.caption)
            .fontWeight(.medium)
            .lineLimit(2)
            .multilineTextAlignment(.leading)

          if let duration = video.duration {
            Text(duration)
              .font(.caption2)
              .foregroundColor(.secondary)
          }
        }
      }
    }
    .buttonStyle(.card)
  }
}
