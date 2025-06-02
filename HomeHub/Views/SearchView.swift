import SwiftUI


// MARK: - Search View
struct VideoSearchView: View {
  @EnvironmentObject var apiService: VideoAPIService
  @State private var searchText = ""
  @State private var activeVideo: VideoItem?

  @FocusState private var focusedItem: FocusItem?

  var body: some View {
    NavigationView {
      VStack {
        SearchBar(text: $searchText) {
          if !searchText.isEmpty {
            Task {
              await apiService.searchVideos(query: searchText)
            }
          } else {
            apiService.clearData()
          }
        }

        if apiService.isLoading {
          ProgressView("Searching...")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if searchText.isEmpty {
          ContentUnavailableView(
            "Search Videos",
            systemImage: "magnifyingglass",
            description: Text("Enter a search term to find videos")
          )
        } else if apiService.videos.isEmpty && apiService.folders.isEmpty {
          ContentUnavailableView(
            "No Results",
            systemImage: "magnifyingglass",
            description: Text("No videos or folders found for '\(searchText)'")
          )
        } else {
          ScrollView {
            VStack(alignment: .leading, spacing: 20) {
              // Folders section
              if !apiService.folders.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                  Text("Folders")
                    .font(.headline)
                    .padding(.leading)

                  LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 3), spacing: 20) {
                    ForEach(apiService.folders) { folder in
                      FolderCard(
                        folder: folder,
                        isFocused: focusedItem == .folder(folder.id)
                      ) {
                        // Handle folder selection
                      }
                      .focused($focusedItem, equals: .folder(folder.id))
                    }
                  }
                  .padding(.horizontal)
                }
              }

              // Videos section
              if !apiService.videos.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                  Text("Videos")
                    .font(.headline)
                    .padding(.leading)

                  LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 4), spacing: 20) {
                    ForEach(apiService.videos) { video in
                      VideoThumbnailCard(video: video) {
                        activeVideo = video
                      }
                    }
                  }
                  .padding(.horizontal)
                }
              }
            }
          }
        }

        if let error = apiService.errorMessage {
          Text("Error: \(error)")
            .foregroundColor(.red)
            .padding()
        }
      }
      .navigationTitle("Search")
    }
    .fullScreenCover(item: $activeVideo) { video in
      VideoPlayerView(video: video)
    }
  }
}
