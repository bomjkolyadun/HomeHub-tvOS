//
//  MainView.swift
//  HomeHub
//
//  Created by Dima Osipa on 6/1/25.
//

import SwiftUI
import AVKit

struct MainView: View {
    let server: DiscoveredServer
    @StateObject private var apiService: VideoAPIService
    @State private var selectedTab = 0
    
    init(server: DiscoveredServer) {
        self.server = server
        let baseURL = "http://\(server.host):\(server.port)"
        self._apiService = StateObject(wrappedValue: VideoAPIService(baseURL: baseURL))
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            AllVideosView()
                .tabItem {
                    Label("Videos", systemImage: "play.rectangle.fill")
                }
                .tag(0)
            
            FoldersView()
                .tabItem {
                    Label("Folders", systemImage: "folder.fill")
                }
                .tag(1)
            
            VideoSearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(2)
            
            AppSettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(3)
        }
        .environmentObject(apiService)
        .preferredColorScheme(.dark)
        .task {
            await apiService.fetchServerInfo()
            await apiService.fetchVideos()
        }
    }
}

// MARK: - All Videos View
struct AllVideosView: View {
    @EnvironmentObject var apiService: VideoAPIService
    @State private var selectedVideo: VideoItem?
    @State private var showingPlayer = false
    
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
                                    selectedVideo = video
                                    showingPlayer = true
                                }
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
        .fullScreenCover(isPresented: $showingPlayer) {
            if let video = selectedVideo {
                VideoPlayerView(video: video)
            }
        }
    }
}

// MARK: - Folders View
struct FoldersView: View {
    @EnvironmentObject var apiService: VideoAPIService
    @State private var selectedFolder: Folder?
    @State private var showingFolderContent = false
    
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
                                FolderCard(folder: folder) {
                                    selectedFolder = folder
                                    showingFolderContent = true
                                }
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

// MARK: - Search View
struct VideoSearchView: View {
    @EnvironmentObject var apiService: VideoAPIService
    @State private var searchText = ""
    @State private var selectedVideo: VideoItem?
    @State private var showingPlayer = false
    
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
                                            FolderCard(folder: folder) {
                                                // Handle folder selection
                                            }
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
                                                selectedVideo = video
                                                showingPlayer = true
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
        .fullScreenCover(isPresented: $showingPlayer) {
            if let video = selectedVideo {
                VideoPlayerView(video: video)
            }
        }
    }
}

// MARK: - Settings View
struct AppSettingsView: View {
    @EnvironmentObject var apiService: VideoAPIService
    @Environment(\.presentationMode) var presentationMode
    
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
                        // Return to server discovery
                        presentationMode.wrappedValue.dismiss()
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

// MARK: - Supporting Views

struct VideoThumbnailCard: View {
    let video: VideoItem
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Thumbnail
            AsyncImage(url: URL(string: video.thumbnail ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(16/9, contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.secondary.opacity(0.3))
                    .aspectRatio(16/9, contentMode: .fill)
                    .overlay(
                        Image(systemName: "play.rectangle")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                    )
            }
            .clipped()
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
        .focusable(true)
        .onTapGesture {
            onTap()
        }
    }
}

struct FolderCard: View {
    let folder: Folder
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "folder.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            VStack(spacing: 4) {
                Text(folder.name.isEmpty ? "All Videos" : folder.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text("Folder")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(height: 140)
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
        .focusable(true)
        .onTapGesture {
            onTap()
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    let onSearchButtonClicked: () -> Void
    
    var body: some View {
        HStack {
            TextField("Search videos...", text: $text)
                .onSubmit {
                    onSearchButtonClicked()
                }
            
            Button("Search", action: onSearchButtonClicked)
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

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
        let videoURL = "\(apiService.baseURL)/\(video.file)"
        guard let url = URL(string: videoURL) else { return }
        
        player = AVPlayer(url: url)
        player?.play()
    }
}

#Preview {
    MainView(server: DiscoveredServer(name: "Test Server", host: "127.0.0.1", port: 5000))
}
