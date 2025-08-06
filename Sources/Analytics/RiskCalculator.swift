import Foundation

struct RiskCalculator {
    /// Historical Value at Risk (VaR) based on returns at a given confidence level.
    /// Returns positive number representing potential loss.
    static func valueAtRisk(returns: [Double], confidenceLevel: Double = 0.95) -> Double {
        guard !returns.isEmpty else { return 0 }
        let sorted = returns.sorted()
        let index = Int(Double(sorted.count) * (1 - confidenceLevel))
        let varValue = sorted[max(0, min(sorted.count - 1, index))]
        return -min(varValue, 0) // express as positive potential loss
    }

    /// Maximum drawdown for a given equity curve.
    static func maxDrawdown(equityCurve: [Double]) -> Double {
        guard !equityCurve.isEmpty else { return 0 }
        var maxDrawdown = 0.0
        var peak = equityCurve[0]
        for value in equityCurve {
            peak = max(peak, value)
            let drawdown = (value - peak) / peak
            maxDrawdown = min(maxDrawdown, drawdown)
        }
        return abs(maxDrawdown)
    }

    /// Calculates leverage as exposure divided by equity.
    static func leverage(exposure: Double, equity: Double) -> Double {
        guard equity != 0 else { return 0 }
        return exposure / equity
    }
}
