//
//  FolderContentView.swift
//  HomeHub
//
//  Created by Dima Osipa on 6/1/25.
//
import SwiftUI


struct FolderContentView: View {
  let folder: Folder
  @EnvironmentObject var apiService: VideoAPIService
  @State private var folderVideos: [VideoItem] = []
  @State private var isLoading = false
  @State private var selectedVideo: VideoItem?
  @State private var showingPlayer = false
  @Environment(\.presentationMode) var presentationMode

  var body: some View {
    NavigationView {
      VStack {
        if isLoading {
          ProgressView("Loading folder content...")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if folderVideos.isEmpty {
          ContentUnavailableView(
            "No Videos",
            systemImage: "play.slash",
            description: Text("This folder contains no videos")
          )
        } else {
          ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 4), spacing: 20) {
              ForEach(folderVideos) { video in
                VideoThumbnailCard(video: video) {
                  selectedVideo = video
                  showingPlayer = true
                }
              }
            }
            .padding()
          }
        }
      }
      .navigationTitle(folder.name)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Close") {
            presentationMode.wrappedValue.dismiss()
          }
        }
      }
    }
    .task {
      await loadFolderContent()
    }
    .fullScreenCover(isPresented: $showingPlayer) {
      if let video = selectedVideo {
        VideoPlayerView(video: video)
      }
    }
  }

  private func loadFolderContent() async {
    isLoading = true
    await apiService.fetchVideos(folder: folder.path)
    folderVideos = apiService.videos
    isLoading = false
  }
}
