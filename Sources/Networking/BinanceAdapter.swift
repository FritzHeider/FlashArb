import Foundation

struct BinanceAdapter: ExchangeAdapter {
    let client: ExchangeAPIClient
    let rateLimiter = RateLimiter(requestsPerSecond: 5)

    var name: String { "Binance" }

    func fetchTicker(pair: String) async throws -> MarketQuote {
        let symbol = pair.replacingOccurrences(of: "/", with: "").uppercased()
        let url = URL(string: "https://api.binance.com/api/v3/ticker/price?symbol=\(symbol)")!
        struct Response: Decodable { let symbol: String; let price: String }
        let response: Response = try await client.fetch(url, decode: Response.self, rateLimiter: rateLimiter)
        return MarketQuote(exchange: name, tokenPair: pair, price: Double(response.price) ?? 0)
    }
}
