//
//  SearchBar.swift
//  HomeHub
//
//  Created by Dima Osipa on 6/1/25.
//

import SwiftUI

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
