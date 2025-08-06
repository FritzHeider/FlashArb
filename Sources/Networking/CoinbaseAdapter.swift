import Foundation

struct CoinbaseAdapter: ExchangeAdapter {
    let client: ExchangeAPIClient
    let rateLimiter = RateLimiter(requestsPerSecond: 3)

    var name: String { "Coinbase" }

    func fetchTicker(pair: String) async throws -> MarketQuote {
        let symbol = pair.replacingOccurrences(of: "/", with: "-").uppercased()
        let url = URL(string: "https://api.coinbase.com/v2/prices/\(symbol)/spot")!
        struct Response: Decodable {
            struct Data: Decodable { let amount: String }
            let data: Data
        }
        let response: Response = try await client.fetch(url, decode: Response.self, rateLimiter: rateLimiter)
        return MarketQuote(exchange: name, tokenPair: pair, price: Double(response.data.amount) ?? 0)
    }
}
