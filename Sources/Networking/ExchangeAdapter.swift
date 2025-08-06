import Foundation

protocol ExchangeAdapter {
    var name: String { get }
    func fetchTicker(pair: String) async throws -> MarketQuote
}
