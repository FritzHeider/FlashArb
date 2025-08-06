import Foundation

struct PerformanceDashboard {
    /// Converts an equity curve into chart-ready data points (index, equity).
    func chartData(from equityCurve: [Double]) -> [(Int, Double)] {
        return equityCurve.enumerated().map { ($0.offset, $0.element) }
    }

    /// Exports a simple CSV report for the provided equity curve.
    func exportReport(equityCurve: [Double], to url: URL) throws {
        var csv = "Index,Equity\n"
        for (i, value) in equityCurve.enumerated() {
            csv += "\(i),\(value)\n"
        }
        try csv.write(to: url, atomically: true, encoding: .utf8)
    }
}
