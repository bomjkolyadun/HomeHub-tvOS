//
//  FolderCard.swift
//  HomeHub
//
//  Created by Dima Osipa on 6/1/25.
//
import SwiftUI

struct FolderCard: View {
  let folder: Folder
  var isFocused: Bool
  let onTap: () -> Void

  var body: some View {
    Button(action: {
      onTap()
    }) {
      VStack(spacing: 12) {
        Image(systemName: "folder.fill")
          .font(.system(size: 60))
          .foregroundColor(.blue)

        Text(folder.name.isEmpty ? "All Videos" : folder.name)
          .font(.headline)
          .lineLimit(2)
          .multilineTextAlignment(.center)

        Text("Folder")
          .font(.caption)
          .foregroundColor(.secondary)
      }
      .frame(height: 140)
      .frame(maxWidth: .infinity)
      .padding()
      .background(
        RoundedRectangle(cornerRadius: 12)
          .fill(isFocused ? Color.blue.opacity(0.3) : Color.secondary.opacity(0.1))
      )
    }
    .buttonStyle(.plain)
  }
}
