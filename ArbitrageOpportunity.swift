import Foundation

public struct ArbitrageOpportunity: Identifiable, Hashable, Sendable {
    public let id = UUID()
    public let tokenPair: String
    public let buyExchange: String
    public let sellExchange: String
    public let buyPrice: Double
    public let sellPrice: Double
    public let timestamp: Date

    /// Absolute profit between the buy and sell legs.
    public var profit: Double { sellPrice - buyPrice }

    /// Percentage spread expressed as a fraction (0.01 = 1%).
    public var spread: Double { (sellPrice - buyPrice) / buyPrice }
}
