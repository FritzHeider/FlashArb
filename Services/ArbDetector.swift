import Foundation

enum ArbDetector {
    /// `minProfit` is a fraction (0.01 = 1%)
    static func detect(quotes: [MarketQuote], minProfit: Double) -> [ArbOpportunity] {
        guard quotes.count >= 2 else { return [] }
        /Users/space/FlashArb/Services/ArbDetector.swift:5:70 'ArbOpportunity' is ambiguous for type lookup in this context

        // best buy = lowest price, best sell = highest price across exchanges
        guard let bestBuy  = quotes.min(by: { $0.price < $1.price }),
              let bestSell = quotes.max(by: { $0.price < $1.price }),
              bestSell.price > bestBuy.price else { return [] }

        let spreadPct = (bestSell.price - bestBuy.price) / bestBuy.price
        guard spreadPct >= minProfit else { return [] }

        return [
            ArbOpportunity(
                pair: bestBuy.tokenPair,
                buyExchange: bestBuy.exchange,
                sellExchange: bestSell.exchange,
                buyPrice: bestBuy.price,
                sellPrice: bestSell.price,
                timestamp: Date()
            )
        ]
    }
}
