import Foundation
#if canImport(StoreKit)
import StoreKit
#endif

struct MarketQuote {
    let exchange: String
    let tokenPair: String
    let price: Double
}

final class ArbitrageService {
    private let adapters: [ExchangeAdapter]
    private var requestsThisMinute = 0
    private var lastReset = Date()

    init(adapters: [ExchangeAdapter]) {
        self.adapters = adapters
    }

    convenience init() {
        let client = ExchangeAPIClient()
        let defaultAdapters: [ExchangeAdapter] = [
            BinanceAdapter(client: client),
            CoinbaseAdapter(client: client)
        ]
        self.init(adapters: defaultAdapters)
    }

    // ---- Main-actor hop helpers ----
    private func isSubscribed(_ tier: SubscriptionTier) async -> Bool {
        await MainActor.run { SubscriptionManager.shared.isSubscribed(to: tier) }
    }

    private func rateLimit(for tier: SubscriptionTier) async -> Int {
        await MainActor.run { SubscriptionManager.shared.rateLimit(for: tier) }
    }

    private func currentTier() async -> SubscriptionTier {
        await MainActor.run { SubscriptionManager.shared.currentTier }
    }

    // ---- Rate-limit ----
    private func checkRateLimit() async -> Bool {
        // choose required tier for higher throughput
        let tier = await currentTier()
        let limit = await rateLimit(for: tier)

        let now = Date()
        if now.timeIntervalSince(lastReset) >= 60 {
            lastReset = now
            requestsThisMinute = 0
        }
        guard requestsThisMinute < limit else { return false }
        requestsThisMinute += 1
        return true
    }

    // ---- API ----
    func fetchQuotes(for pair: String) async throws -> [MarketQuote] {
        guard await checkRateLimit() else { return [] }

        return try await withThrowingTaskGroup(of: MarketQuote.self) { group in
            for adapter in adapters {
                group.addTask { try await adapter.fetchTicker(pair: pair) }
            }
            var results: [MarketQuote] = []
            for try await quote in group { results.append(quote) }
            return results
        }
    }

    func findOpportunities(quotes: [MarketQuote], minProfit: Double = 0) -> [ArbOpportunity] {
        ArbDetector.detect(quotes: quotes, minProfit: minProfit)
    }

    func findOpportunities(for pair: String, minProfit: Double = 0) async throws -> [ArbOpportunity] {
        guard await isSubscribed(.standard) else { return [] }
        let quotes = try await fetchQuotes(for: pair)
        return findOpportunities(quotes: quotes, minProfit: minProfit)
    }
}
