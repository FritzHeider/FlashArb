import Foundation

struct MarketQuote {
    let exchange: String
    let tokenPair: String
    let price: Double
}

class ArbitrageService {
    private let adapters: [ExchangeAdapter]

    init(adapters: [ExchangeAdapter]) {
        self.adapters = adapters
    }

    func findOpportunities(for pair: String, minProfit: Double = 0) async throws -> [ArbitrageOpportunity] {
        let quotes = try await withThrowingTaskGroup(of: MarketQuote.self) { group in
            for adapter in adapters {
                group.addTask {
                    try await adapter.fetchTicker(pair: pair)
                }
            }

            var results: [MarketQuote] = []
            for try await quote in group {
                results.append(quote)
            }
            return results
        }

        return evaluate(quotes: quotes, minProfit: minProfit)
    }

    private func evaluate(quotes: [MarketQuote], minProfit: Double = 0) -> [ArbitrageOpportunity] {
        var opportunities: [ArbitrageOpportunity] = []
        let grouped = Dictionary(grouping: quotes, by: { $0.tokenPair })
        for (pair, pairQuotes) in grouped {
            for buy in pairQuotes {
                for sell in pairQuotes {
                    guard buy.exchange != sell.exchange else { continue }
                    let profit = sell.price - buy.price
                    if profit >= minProfit {
                        opportunities.append(
                            ArbitrageOpportunity(
                                tokenPair: pair,
                                buyExchange: buy.exchange,
                                sellExchange: sell.exchange,
                                buyPrice: buy.price,
                                sellPrice: sell.price
                            )
                        )
                    }
                }
            }
        }
        return opportunities
    }
}
