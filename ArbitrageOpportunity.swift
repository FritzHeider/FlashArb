import Foundation

public struct ArbOpportunity: Identifiable, Hashable, Sendable {
    public let id = UUID()
    public let pair: String
    public let buyExchange: String
    public let sellExchange: String
    public let buyPrice: Double
    public let sellPrice: Double
    public let timestamp: Date

    public var spread: Double { sellPrice - buyPrice }
    /// e.g. 0.012 = 1.2%
    public var spreadPct: Double { (sellPrice - buyPrice) / buyPrice }
}

public typealias ArbitrageOpportunity = ArbOpportunity

public extension ArbOpportunity {
    var tokenPair: String { pair }
    var profit: Double { spread }
}
