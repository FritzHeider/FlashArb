import SwiftUI
import Combine

/// Primary dashboard surface showing portfolio, live prices and arbitrage opportunities.
struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State private var executingOpportunity: ArbitrageOpportunity?
    @State private var showConfirmation = false
    @State private var executionStatus: String?

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Portfolio")) {
                    ForEach(viewModel.portfolio.positions, id: \.token) { position in
                        HStack {
                            Text(position.token)
                            Spacer()
                            Text(String(format: "%.4f", position.amount))
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Section(header: Text("Live Prices")) {
                    ForEach(viewModel.quotes, id: \.tokenPair) { quote in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(quote.tokenPair)
                                Text(quote.exchange)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text(String(format: "%.4f", quote.price))
                                .bold()
                        }
                    }
                }

                Section(header: Text("Opportunities")) {
                    ForEach(viewModel.opportunities, id: \.tokenPair) { opp in
                        Button {
                            executingOpportunity = opp
                            showConfirmation = true
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(opp.tokenPair)
                                    Text("Buy: \(opp.buyExchange) @ \(opp.buyPrice, specifier: "%.4f")")
                                        .font(.caption)
                                    Text("Sell: \(opp.sellExchange) @ \(opp.sellPrice, specifier: "%.4f")")
                                        .font(.caption)
                                }
                                Spacer()
                                Text("Profit: \(opp.profit, specifier: "%.4f")")
                                    .bold()
                                    .foregroundColor(opp.profit > 0 ? .green : .red)
                            }
                        }
                    }
                }

                if let status = executionStatus {
                    Section(header: Text("Last Trade")) {
                        Text(status)
                            .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("Dashboard")
            .confirmationDialog("Execute trade?", isPresented: $showConfirmation, presenting: executingOpportunity) { opp in
                Button("Confirm") {
                    executionStatus = "Executing..."
                    viewModel.execute(opp) { success in
                        executionStatus = success ? "Trade executed" : "Trade failed"
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: { _ in
                Text("Confirm trade execution")
            }
        }
    }
}

/// View model powering the dashboard.
final class DashboardViewModel: ObservableObject {
    @Published var portfolio = Portfolio()
    @Published var quotes: [MarketQuote] = []
    @Published var opportunities: [ArbitrageOpportunity] = []

    private let service = ArbitrageService()
    private var timer: AnyCancellable?

    init() {
        // Seed portfolio with dummy positions
        portfolio.update(token: "ETH", delta: 1.0)
        portfolio.update(token: "DAI", delta: 500.0)
        startUpdating()
    }

    /// Starts periodic updates for quotes and opportunities
    func startUpdating() {
        timer = Timer.publish(every: 5.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.refreshData()
            }
        refreshData()
    }

    private func refreshData() {
        // In a real app this would pull from network/exchange APIs.
        let sampleQuotes = [
            MarketQuote(exchange: "DexA", tokenPair: "ETH/DAI", price: Double.random(in: 1800...2200)),
            MarketQuote(exchange: "DexB", tokenPair: "ETH/DAI", price: Double.random(in: 1800...2200))
        ]
        quotes = sampleQuotes
        opportunities = service.findOpportunities(quotes: sampleQuotes)
    }

    /// Executes an arbitrage opportunity, wiring to a future smart-contract or exchange API.
    func execute(_ opportunity: ArbitrageOpportunity, completion: @escaping (Bool) -> Void) {
        // Placeholder for asynchronous trade call.
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            completion(true)
        }
    }
}



