//
//  ManualServerTileView.swift
//  HomeHub
//
//  Created by Dima Osipa on 6/1/25.
//
import SwiftUI

struct ManualServerTileView: View {
  let isSelected: Bool
  let isConnecting: Bool

  var body: some View {
    ServerTileBaseView(
      icon: Image(systemName: "plus.circle.fill"),
      iconColor: isSelected ? .white : .primary,
      isSelected: isSelected,
      isConnecting: isConnecting,
      backgroundColor: isSelected ? .green : Color.secondary.opacity(0.2)
    ) {
      VStack(spacing: 5) {
        Text("Manual Entry")
          .font(.headline)
          .foregroundColor(isSelected ? .white : .primary)

        Text("Enter custom server")
          .font(.caption)
          .foregroundColor(isSelected ? .white : .secondary)
          .multilineTextAlignment(.center)
          .lineLimit(2)
      }
    }
  }
}

