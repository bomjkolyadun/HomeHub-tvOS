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
        VStack(spacing: 15) {
            // Manual Entry Icon
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(isSelected ? .white : .primary)
            
            // Label
            VStack(spacing: 5) {
                Text("Manual Entry")
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Text("Enter custom server")
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : .secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            
            // Connection Status
            if isConnecting {
                ProgressView()
                    .scaleEffect(0.8)
                    .progressViewStyle(CircularProgressViewStyle(tint: isSelected ? .white : .primary))
            }
        }
        .frame(width: 200, height: 150)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(isSelected ? Color.green : Color.secondary.opacity(0.2))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(isSelected ? Color.white : Color.clear, lineWidth: 3)
        )
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}
