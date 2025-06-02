//
//  ServerBaseTile.swift
//  HomeHub
//
//  Created by Dima Osipa on 6/1/25.
//

import SwiftUI

struct ServerTileBaseView<Content: View>: View {
  let icon: Image
  let iconColor: Color
  let isSelected: Bool
  let isConnecting: Bool
  let backgroundColor: Color
  let content: () -> Content

  var body: some View {
    VStack(spacing: 15) {
      // Icon
      icon
        .font(.system(size: 50))
        .foregroundColor(iconColor)

      // Custom Content
      content()

      // Connection Status
      if isConnecting {
        ProgressView()
          .scaleEffect(0.8)
          .progressViewStyle(
            CircularProgressViewStyle(tint: isSelected ? .white : .primary)
          )
      }
    }
    .frame(width: 200, height: 150)
    .padding()
    .background(
      RoundedRectangle(cornerRadius: 15)
        .fill(backgroundColor)
    )
    .overlay(
      RoundedRectangle(cornerRadius: 15)
        .stroke(isSelected ? Color.white : Color.clear, lineWidth: 3)
    )
    .scaleEffect(isSelected ? 1.05 : 1.0)
    .animation(.easeInOut(duration: 0.2), value: isSelected)
  }
}
