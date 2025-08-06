import Foundation

struct PortfolioPosition {
    let token: String
    var amount: Double
}

struct Trade {
    let token: String
    /// Positive for buy, negative for sell
    let amount: Double
    let price: Double
    let timestamp: Date
}

struct Portfolio {
    private(set) var positions: [PortfolioPosition] = []
    private(set) var trades: [Trade] = []

    /// Average cost basis per token
    private var costBasis: [String: Double] = [:]
    /// Realized profit and loss
    private(set) var realizedPnL: Double = 0

    mutating func update(token: String, delta: Double) {
        if let index = positions.firstIndex(where: { $0.token == token }) {
            positions[index].amount += delta
            if positions[index].amount == 0 {
                positions.remove(at: index)
            }
        } else {
            positions.append(PortfolioPosition(token: token, amount: delta))
        }
    }

    /// Records a trade, updates positions and tracks realized P&L
    mutating func recordTrade(token: String, amount: Double, price: Double, date: Date = Date()) {
        let previousAmount = positions.first(where: { $0.token == token })?.amount ?? 0
        let avgCost = costBasis[token] ?? 0

        if amount > 0 {
            // Buying increases position and adjusts average cost basis
            let totalCost = avgCost * previousAmount + price * amount
            let newAmount = previousAmount + amount
            costBasis[token] = newAmount == 0 ? 0 : totalCost / newAmount
        } else if amount < 0 {
            // Selling realizes profit/loss based on average cost basis
            let sellQty = -amount
            realizedPnL += (price - avgCost) * sellQty
            let newAmount = previousAmount + amount
            if newAmount <= 0 {
                costBasis[token] = 0
            }
        }

        trades.append(Trade(token: token, amount: amount, price: price, timestamp: date))
        update(token: token, delta: amount)
    }

    /// Calculates total P&L including unrealized gains based on current prices
    func totalPnL(currentPrices: [String: Double]) -> Double {
        var pnl = realizedPnL
        for position in positions {
            if let price = currentPrices[position.token] {
                let avg = costBasis[position.token] ?? 0
                pnl += (price - avg) * position.amount
            }
        }
        return pnl
    }
}
