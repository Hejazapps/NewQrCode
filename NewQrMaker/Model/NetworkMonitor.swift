import Network
import UIKit


class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)

    var isConnected: Bool = false {
        didSet {
            // You can post a Notification or use a delegate here
            NotificationCenter.default.post(name: .networkStatusChanged, object: nil)
        }
    }

    private init() {
        monitor.pathUpdateHandler = { path in
            self.isConnected = path.status == .satisfied
        }
        monitor.start(queue: queue)
    }
}

extension Notification.Name {
    static let networkStatusChanged = Notification.Name("NetworkStatusChanged")
}
