import Foundation

struct MarketQuote {
    let exchange: String
    let tokenPair: String
    let price: Double
}

struct ArbitrageOpportunity {
    let tokenPair: String
    let buyExchange: String
    let sellExchange: String
    let buyPrice: Double
    let sellPrice: Double
}

class ArbitrageService {
    private let adapters: [ExchangeAdapter]
    private let subscriptionManager = SubscriptionManager.shared
    private var requestsThisMinute = 0
    private var lastReset = Date()

    init(adapters: [ExchangeAdapter]) {
        self.adapters = adapters
    }

    func findOpportunities(for pair: String, minProfit: Double = 0) async throws -> [ArbitrageOpportunity] {
        guard checkRateLimit() else { return [] }

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

    func advancedAnalytics(quotes: [MarketQuote]) -> Double? {
        guard subscriptionManager.isSubscribed(to: .premium) else { return nil }
        let prices = quotes.map { $0.price }
        guard !prices.isEmpty else { return nil }

        let mean = prices.reduce(0, +) / Double(prices.count)
        let variance = prices.reduce(0) { $0 + pow($1 - mean, 2) } / Double(prices.count)
        return sqrt(variance) // Standard deviation
    }

    private func checkRateLimit() -> Bool {
        if Date().timeIntervalSince(lastReset) > 60 {
            requestsThisMinute = 0
            lastReset = Date()
        }

        requestsThisMinute += 1
        let limit = subscriptionManager.rateLimit(for: subscriptionManager.currentTier)
        return requestsThisMinute <= limit
    }
}
