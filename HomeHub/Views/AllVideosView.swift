import SwiftUI


// MARK: - All Videos View
struct AllVideosView: View {
  @EnvironmentObject var apiService: VideoAPIService
  @State private var activeVideo: VideoItem? = nil
  @FocusState private var focusedItem: FocusItem?

  var body: some View {
    NavigationView {
      VStack {
        if apiService.isLoading && apiService.videos.isEmpty {
          ProgressView("Loading videos...")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if apiService.videos.isEmpty {
          ContentUnavailableView(
            "No Videos Found",
            systemImage: "play.slash",
            description: Text("No videos are available on this server")
          )
        } else {
          ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 4), spacing: 20) {
              ForEach(apiService.videos) { video in
                VideoThumbnailCard(video: video) {
                  print("Video tapped: \(video.title)")
                  activeVideo = video
                }.focused($focusedItem, equals: .video(video.uuid))
              }
            }
            .padding()

            // Load more button
            if let pagination = apiService.pagination, pagination.currentPage < pagination.totalPages {
              Button("Load More") {
                Task {
                  await apiService.fetchVideos(page: pagination.currentPage + 1)
                }
              }
              .buttonStyle(.bordered)
              .padding()
            }
          }
        }

        if let error = apiService.errorMessage {
          Text("Error: \(error)")
            .foregroundColor(.red)
            .padding()
        }
      }
      .navigationTitle("All Videos")
      .toolbar {
        ToolbarItem(placement: .primaryAction) {
          Button("Refresh") {
            Task {
              await apiService.fetchVideos()
            }
          }
        }
      }
    }
    .fullScreenCover(item: $activeVideo) { video in
      VideoPlayerView(video: video)
    }
  }
}
