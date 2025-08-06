import Foundation

struct ArbitrageOpportunity {
    let tokenPair: String
    let buyExchange: String
    let sellExchange: String
    let buyPrice: Double
    let sellPrice: Double

    var profit: Double {
        sellPrice - buyPrice
    }
}
