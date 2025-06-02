//
//  HomeHubDiscovery.swift
//  HomeHub
//
//  Created by Dima Osipa on 6/1/25.
//

import Foundation
import Network
import Combine

struct DiscoveredServer: Identifiable, Equatable, Codable, Hashable {
  let name: String
  let host: String
  let port: Int
  var id: String { "\(host):\(port)" }

  static func == (lhs: DiscoveredServer, rhs: DiscoveredServer) -> Bool {
    return lhs.host == rhs.host && lhs.port == rhs.port
  }
}

@MainActor
class HomeHubDiscovery: ObservableObject {
  @Published var discoveredServers: [DiscoveredServer] = []
  @Published var isDiscovering = false

  private var browser: NWBrowser?
  private let queue = DispatchQueue(label: "HomeHubDiscovery")

  func startDiscovery() {
    stopDiscovery()

    isDiscovering = true
    discoveredServers.removeAll()

    // Create browser for HomeHub Bonjour services
    let parameters = NWParameters()
    parameters.includePeerToPeer = true

    browser = NWBrowser(for: .bonjourWithTXTRecord(type: "_homehub._tcp", domain: nil), using: parameters)

    browser?.stateUpdateHandler = { [weak self] state in
      Task { @MainActor in
        switch state {
        case .ready:
          print("HomeHub discovery started")
        case .failed(let error):
          print("HomeHub discovery failed: \(error)")
          self?.isDiscovering = false
        case .cancelled:
          print("HomeHub discovery cancelled")
          self?.isDiscovering = false
        default:
          break
        }
      }
    }

    browser?.browseResultsChangedHandler = { [weak self] results, changes in
      Task { @MainActor in
        self?.handleBrowseResults(results: results, changes: changes)
      }
    }

    browser?.start(queue: queue)
  }

  func stopDiscovery() {
    browser?.cancel()
    browser = nil
    isDiscovering = false
  }

  private func handleBrowseResults(results: Set<NWBrowser.Result>, changes: Set<NWBrowser.Result.Change>) {
    for change in changes {
      switch change {
      case .added(let result):
        handleAddedResult(result)
      case .removed(let result):
        handleRemovedResult(result)
      default:
        break
      }
    }
  }

  private func handleAddedResult(_ result: NWBrowser.Result) {
    guard case let .bonjour(txtRecord) = result.metadata else { return }

    // Extract server information from Bonjour service
    let endpoint = result.endpoint

    var host = ""
    var port = 8080  // Default HomeHub port
    var name = "HomeHub Server"

    // Parse endpoint
    switch endpoint {
    case .hostPort(let endpointHost, let endpointPort):
      switch endpointHost {
      case .ipv4(let ipv4):
        host = ipv4.debugDescription
      case .ipv6(let ipv6):
        host = ipv6.debugDescription
      case .name(let hostname, _):
        host = hostname
      @unknown default:
        host = "unknown"
      }
      port = Int(endpointPort.rawValue)
    case .service(let serviceName, _, _, _):
      name = serviceName
    @unknown default:
      break
    }

    print("Found HomeHub service: \(name) at \(host):\(port)")

    // Parse TXT record for additional info
    let txtDict = parseTXTRecord(txtRecord)
    if let serverName = txtDict["name"] {
      name = serverName
    }
    if let serverPort = txtDict["port"], let portInt = Int(serverPort) {
      port = portInt
    }

    let server = DiscoveredServer(name: name, host: host, port: port)

    // Avoid duplicates
    if !discoveredServers.contains(server) {
      discoveredServers.append(server)
    }
  }

  private func handleRemovedResult(_ result: NWBrowser.Result) {
    // Handle server removal if needed
    // For now, we'll keep discovered servers in the list
  }

  private func parseTXTRecord(_ txtRecord: NWTXTRecord) -> [String: String] {
    var result: [String: String] = [:]

    // Iterate through TXT record entries directly
    for (key, entry) in txtRecord {
      switch entry {
      case .string(let value):
        result[key] = value
      case .data(let data):
        if let stringValue = String(data: data, encoding: .utf8) {
          result[key] = stringValue
        }

      case .empty:
        continue
      case .none:
        continue
      @unknown default:
        result[key] = ""
      }
    }

    return result
  }

  deinit {
    browser?.cancel()
    browser = nil
  }
}
