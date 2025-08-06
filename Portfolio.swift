import Foundation

struct PortfolioPosition {
    let token: String
    var amount: Double
}

struct Portfolio {
    private(set) var positions: [PortfolioPosition] = []

    mutating func update(token: String, delta: Double) {
        if let index = positions.firstIndex(where: { $0.token == token }) {
            positions[index].amount += delta
        } else {
            positions.append(PortfolioPosition(token: token, amount: delta))
        }
    }
}
