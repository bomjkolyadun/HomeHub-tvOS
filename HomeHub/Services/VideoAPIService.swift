//
//  VideoAPIService.swift
//  HomeHub
//
//  Created by Dima Osipa on 6/1/25.
//

import Foundation
import SwiftUI
import Combine
import AVKit

// MARK: - API Service
@MainActor
class VideoAPIService: ObservableObject {
  @Published var videos: [VideoItem] = []
  @Published var folders: [Folder] = []
  @Published var isLoading = false
  @Published var errorMessage: String?
  @Published var serverInfo: ServerInfo?
  @Published var currentFolder: String = ""
  @Published var pagination: Pagination?

  // Configuration
  @Published var baseURL = "http://127.0.0.1:5000"

  private let session = URLSession.shared
  private var cancellables = Set<AnyCancellable>()

  init() {
    // Load saved base URL from UserDefaults
    if let savedURL = UserDefaults.standard.string(forKey: "HomeHub_BaseURL") {
      self.baseURL = savedURL
    }
  }

  init(baseURL: String) {
    self.baseURL = baseURL
    // Also save to UserDefaults for persistence
    UserDefaults.standard.set(baseURL, forKey: "HomeHub_BaseURL")
  }

  // MARK: - Public API Methods

  func fetchServerInfo() async {
    isLoading = true
    errorMessage = nil

    guard let url = URL(string: "\(baseURL)/api/info") else {
      errorMessage = "Invalid server URL"
      isLoading = false
      return
    }

    print("🔍 Fetching server info from: \(url)")

    do {
      let (data, response) = try await session.data(from: url)

      print("📡 Response received - Status: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
      print("📦 Response data size: \(data.count) bytes")

      if let responseString = String(data: data, encoding: .utf8) {
        print("📄 Response content: \(responseString)")
      }

      guard let httpResponse = response as? HTTPURLResponse,
            httpResponse.statusCode == 200 else {
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
        errorMessage = "Server connection failed - HTTP \(statusCode)"
        isLoading = false
        return
      }

      let serverInfo = try JSONDecoder().decode(ServerInfo.self, from: data)
      self.serverInfo = serverInfo
      print("✅ Server info loaded successfully: \(serverInfo.server.name)")
    } catch {
      print("❌ Error fetching server info: \(error)")
      errorMessage = "Failed to load server info: \(error.localizedDescription)"
    }

    isLoading = false
  }

  func fetchVideos(page: Int = 1, folder: String? = nil) async {
    isLoading = true
    errorMessage = nil

    var urlString = "\(baseURL)/?format=json&page=\(page)"
    if let folder = folder {
      urlString = "\(baseURL)/folder/\(folder)?format=json&page=\(page)"
    }

    guard let url = URL(string: urlString) else {
      errorMessage = "Invalid URL"
      isLoading = false
      return
    }

    do {
      let (data, response) = try await session.data(from: url)

      print("🔍 Fetching videos from: \(url)")
      print("📦 Videos response data size: \(data.count) bytes")

      if let responseString = String(data: data, encoding: .utf8) {
        print("📄 Videos response content: \(responseString)")
      }

      guard let httpResponse = response as? HTTPURLResponse,
            httpResponse.statusCode == 200 else {
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
        errorMessage = "Failed to load videos - HTTP \(statusCode)"
        isLoading = false
        return
      }

      let apiResponse = try JSONDecoder().decode(APIResponse.self, from: data)

      // If this is page 1, replace the videos array; otherwise append
      if page == 1 {
        self.videos = apiResponse.videos
      } else {
        self.videos.append(contentsOf: apiResponse.videos)
      }

      self.folders = apiResponse.folders
      self.currentFolder = apiResponse.currentFolder
      self.pagination = apiResponse.pagination

    } catch let error as DecodingError {
      print("❌ Decoding error: \(error)")
      switch error {
      case .keyNotFound(let key, let context):
        errorMessage = "Missing key '\(key.stringValue)' in JSON response: \(context.debugDescription)"
      case .typeMismatch(let type, let context):
        errorMessage = "Type mismatch for \(type) in JSON: \(context.debugDescription)"
      case .valueNotFound(let type, let context):
        errorMessage = "Value not found for \(type) in JSON: \(context.debugDescription)"
      case .dataCorrupted(let context):
        errorMessage = "Data corrupted in JSON: \(context.debugDescription)"
      @unknown default:
        errorMessage = "Unknown decoding error: \(error.localizedDescription)"
      }
    } catch {
      print("❌ Error fetching videos: \(error)")
      errorMessage = "Failed to fetch videos: \(error.localizedDescription)"
    }

    isLoading = false
  }

  func fetchFolders() async {
    isLoading = true
    errorMessage = nil

    guard let url = URL(string: "\(baseURL)/folders") else {
      errorMessage = "Invalid URL"
      isLoading = false
      return
    }

    do {
      let (data, response) = try await session.data(from: url)

      print("🔍 Fetching folders from: \(url)")
      print("📦 Folders response data size: \(data.count) bytes")

      if let responseString = String(data: data, encoding: .utf8) {
        print("📄 Folders response content: \(responseString)")
      }

      guard let httpResponse = response as? HTTPURLResponse,
            httpResponse.statusCode == 200 else {
        errorMessage = "Failed to load folders"
        isLoading = false
        return
      }

      let foldersResponse = try JSONDecoder().decode(FoldersResponse.self, from: data)
      self.folders = foldersResponse.folders
      print("✅ Folders loaded successfully: \(foldersResponse.folders.count) folders (total: \(foldersResponse.totalFolders))")

    } catch {
      print("❌ Error decoding folders: \(error)")
      errorMessage = "Failed to decode folders: \(error.localizedDescription)"
    }

    isLoading = false
  }

  func searchVideos(query: String, page: Int = 1) async {
    guard !query.isEmpty else {
      videos = []
      folders = []
      return
    }

    isLoading = true
    errorMessage = nil

    guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
          let url = URL(string: "\(baseURL)/search?format=json&q=\(encodedQuery)&page=\(page)") else {
      errorMessage = "Invalid search URL"
      isLoading = false
      return
    }

    do {
      let (data, response) = try await session.data(from: url)

      print("🔍 Search request to: \(url)")
      print("📦 Search response data size: \(data.count) bytes")

      if let responseString = String(data: data, encoding: .utf8) {
        print("📄 Search response content: \(responseString)")
      }

      guard let httpResponse = response as? HTTPURLResponse,
            httpResponse.statusCode == 200 else {
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
        errorMessage = "Search failed - HTTP \(statusCode)"
        isLoading = false
        return
      }

      let searchResponse = try JSONDecoder().decode(SearchResponse.self, from: data)
      print("✅ Search successful: \(searchResponse.results.videos.count) videos, \(searchResponse.results.folders.count) folders")

      // If this is page 1, replace the arrays; otherwise append
      if page == 1 {
        self.videos = searchResponse.results.videos
        self.folders = searchResponse.results.folders
      } else {
        self.videos.append(contentsOf: searchResponse.results.videos)
        self.folders.append(contentsOf: searchResponse.results.folders)
      }

      self.pagination = searchResponse.pagination

    } catch {
      print("❌ Search error: \(error)")
      errorMessage = "Search failed: \(error.localizedDescription)"
    }

    isLoading = false
  }

  func refreshCache() async {
    isLoading = true
    errorMessage = nil

    guard let url = URL(string: "\(baseURL)/refresh") else {
      errorMessage = "Invalid URL"
      isLoading = false
      return
    }

    do {
      let (_, response) = try await session.data(from: url)

      guard let httpResponse = response as? HTTPURLResponse,
            httpResponse.statusCode == 200 else {
        errorMessage = "Cache refresh failed"
        isLoading = false
        return
      }

      // Optionally reload the current view after refresh
      await fetchVideos()

    } catch {
      errorMessage = "Cache refresh failed: \(error.localizedDescription)"
    }

    isLoading = false
  }

  // MARK: - Configuration

  func updateBaseURL(_ newURL: String) {
    baseURL = newURL
    UserDefaults.standard.set(newURL, forKey: "HomeHub_BaseURL")
  }

  func clearData() {
    videos = []
    folders = []
    pagination = nil
    currentFolder = ""
    errorMessage = nil
  }
}
