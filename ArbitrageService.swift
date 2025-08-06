import Foundation

struct MarketQuote {
    let exchange: String
    let tokenPair: String
    let price: Double
}

class ArbitrageService {
    func findOpportunities(quotes: [MarketQuote], minProfit: Double = 0) -> [ArbitrageOpportunity] {
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
