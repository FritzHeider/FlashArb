import Foundation

struct AlertConfig {
    var maxExposure: Double
    var maxVolatility: Double
}

class AlertManager {
    var config: AlertConfig

    init(config: AlertConfig) {
        self.config = config
    }

    /// Returns triggered alerts based on current exposure and volatility.
    func check(exposure: Double, volatility: Double) -> [String] {
        var alerts: [String] = []
        if exposure > config.maxExposure {
            alerts.append("Exposure limit exceeded")
        }
        if volatility > config.maxVolatility {
            alerts.append("Volatility threshold exceeded")
        }
        return alerts
    }
}
