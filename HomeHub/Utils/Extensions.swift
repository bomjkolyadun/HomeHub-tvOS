//
//  Extensions.swift
//  HomeHub
//
//  Created by Dima Osipa on 6/1/25.
//

import Foundation
import SwiftUI

// MARK: - String Extensions
extension String {
    func formatDuration() -> String {
        // If duration is already formatted (contains ":"), return as is
        if self.contains(":") {
            return self
        }
        
        // If it's "Unknown" or similar, return as is
        if self.lowercased() == "unknown" || self.isEmpty {
            return "Unknown"
        }
        
        // Try to parse as seconds and format
        if let seconds = Double(self) {
            let hours = Int(seconds) / 3600
            let minutes = Int(seconds) % 3600 / 60
            let secs = Int(seconds) % 60
            
            if hours > 0 {
                return String(format: "%d:%02d:%02d", hours, minutes, secs)
            } else {
                return String(format: "%d:%02d", minutes, secs)
            }
        }
        
        return self
    }
}

// MARK: - File Size Formatting
extension Int {
    func formatFileSize() -> String {
        let byteCountFormatter = ByteCountFormatter()
        byteCountFormatter.allowedUnits = [.useBytes, .useKB, .useMB, .useGB, .useTB]
        byteCountFormatter.countStyle = .file
        return byteCountFormatter.string(fromByteCount: Int64(self))
    }
}

// MARK: - Color Extensions
extension Color {
    static let tvBackground = Color.black
    static let tvSecondary = Color.gray.opacity(0.2)
    static let tvAccent = Color.blue
    static let tvFocus = Color.blue.opacity(0.8)
}

// MARK: - View Extensions
extension View {
    func tvFocusable() -> some View {
        self
            .focusable(true)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    func tvCard() -> some View {
        self
            .background(Color.tvSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
