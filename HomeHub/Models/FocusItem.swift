//
//  FocusItem.swift
//  HomeHub
//
//  Created by Dima Osipa on 6/1/25.
//

import Foundation

enum FocusItem: Hashable {
  case folder(UUID)
  case video(String)
  case server(String)
  case manualEntry
}

