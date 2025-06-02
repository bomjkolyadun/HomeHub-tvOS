//
//  RefreshTIle.swift
//  HomeHub
//
//  Created by Dima Osipa on 6/1/25.
//

import SwiftUI

struct RefreshServerTileView: View {
  let isSelected: Bool

  let onRefresh: () -> Void

  var body: some View {
    Button(action: onRefresh) {
      ServerTileBaseView(
        icon: Image(systemName: "arrow.clockwise"),
        iconColor: isSelected ? .white : .primary,
        isSelected: isSelected,
        isConnecting: false,
        backgroundColor: isSelected ? .orange : Color.secondary.opacity(0.2)
      ) {
        VStack(spacing: 5) {
          Text("Refresh")
            .font(.headline)
            .foregroundColor(isSelected ? .white : .primary)

          Text("Search for servers")
            .font(.caption)
            .foregroundColor(isSelected ? .white : .secondary)
            .multilineTextAlignment(.center)
            .lineLimit(2)
        }
      }
    }
    .buttonStyle(.plain)
    .focusable(true)
  }
}
