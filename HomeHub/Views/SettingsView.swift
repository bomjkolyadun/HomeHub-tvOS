import SwiftUI


// MARK: - Settings View
struct AppSettingsView: View {
  @EnvironmentObject var apiService: VideoAPIService
  let onDisconnect: () -> Void

  init(onDisconnect: @escaping () -> Void = {}) {
    self.onDisconnect = onDisconnect
  }

  var body: some View {
    NavigationView {
      List {
        Section("Server Information") {
          if let serverInfo = apiService.serverInfo {
            LabeledContent("Name", value: serverInfo.server.name)
            LabeledContent("Version", value: serverInfo.server.version)
            LabeledContent("Host", value: "\(serverInfo.server.host):\(serverInfo.server.port)")
            LabeledContent("Videos per Page", value: "\(serverInfo.server.videosPerPage)")
            LabeledContent("Video Extensions", value: serverInfo.server.videoExtensions.joined(separator: ", "))
          } else {
            Text("Server information not available")
              .foregroundColor(.secondary)
          }
        }

        Section("Server URL") {
          LabeledContent("Base URL", value: apiService.baseURL)
        }

        Section("Actions") {
          Button("Refresh Cache") {
            Task {
              await apiService.refreshCache()
            }
          }

          Button("Disconnect") {
            onDisconnect()
          }
          .foregroundColor(.red)
        }

        if let error = apiService.errorMessage {
          Section("Status") {
            Text("Error: \(error)")
              .foregroundColor(.red)
          }
        }
      }
      .navigationTitle("Settings")
    }
  }
}
