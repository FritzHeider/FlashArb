import Foundation
import FoundationNetworking

actor RateLimiter {
    private var lastRequest: Date?
    private let minimumInterval: TimeInterval

    init(requestsPerSecond: Double) {
        self.minimumInterval = 1.0 / requestsPerSecond
    }

    func wait() async {
        let now = Date()
        if let last = lastRequest {
            let delta = now.timeIntervalSince(last)
            if delta < minimumInterval {
                let delay = UInt64((minimumInterval - delta) * 1_000_000_000)
                try? await Task.sleep(nanoseconds: delay)
            }
        }
        lastRequest = Date()
    }
}

class ExchangeAPIClient {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetch<T: Decodable>(_ url: URL, decode type: T.Type, rateLimiter: RateLimiter? = nil) async throws -> T {
        if let rateLimiter = rateLimiter {
            await rateLimiter.wait()
        }
        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse,
              200..<300 ~= http.statusCode else {
            throw URLError(.badServerResponse)
        }
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}
