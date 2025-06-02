import SwiftUI

struct FoldersView: View {
  @EnvironmentObject var apiService: VideoAPIService
  @State private var selectedFolder: Folder?
  @State private var showingFolderContent = false

  @FocusState private var focusedCard: FocusItem?

  var body: some View {
    NavigationView {
      VStack {
        if apiService.isLoading && apiService.folders.isEmpty {
          ProgressView("Loading folders...")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if apiService.folders.isEmpty {
          ContentUnavailableView(
            "No Folders Found",
            systemImage: "folder.slash",
            description: Text("No folders are available on this server")
          )
        } else {
          ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 3), spacing: 20) {
              ForEach(apiService.folders) { folder in
                FolderCard(
                  folder: folder,
                  isFocused: focusedCard == .folder(folder.id)
                ) {
                  selectedFolder = folder
                  showingFolderContent = true
                }
                .focused($focusedCard, equals: .folder(folder.id))
              }
            }
            .padding()
          }
        }

        if let error = apiService.errorMessage {
          Text("Error: \(error)")
            .foregroundColor(.red)
            .padding()
        }
      }
      .navigationTitle("Folders")
      .toolbar {
        ToolbarItem(placement: .primaryAction) {
          Button("Refresh") {
            Task {
              await apiService.fetchFolders()
            }
          }
        }
      }
    }
    .sheet(isPresented: $showingFolderContent) {
      if let folder = selectedFolder {
        FolderContentView(folder: folder)
      }
    }
  }
}
