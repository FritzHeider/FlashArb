import SwiftUI
import Combine

/// Primary dashboard surface showing portfolio, live prices and arbitrage opportunities.
struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State private var executingOpportunity: ArbitrageOpportunity?
    @State private var showConfirmation = false
    @State private var executionStatus: String?
    @State private var showPaywall = false
    @State private var showHowItWorks = false

    var body: some View {
        NavigationView {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Welcome to FlashArb")
                            .font(.headline)
                        Text("Start with a simple setup: connect an exchange, pick a pair, and track opportunities.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Button("How FlashArb works") {
                            showHowItWorks = true
                        }
                        .font(.subheadline)
                    }
                    .padding(.vertical, 4)
                }

                Section(header: Text("Quick Start")) {
                    Label("Connect an exchange account", systemImage: "link")
                    Label("Choose a pair to monitor", systemImage: "chart.line.uptrend.xyaxis")
                    Label("Enable alerts for price gaps", systemImage: "bell.badge")
                }

                Section(header: Text("Overview")) {
                    HStack {
                        Text("Assets tracked")
                        Spacer()
                        Text("\(viewModel.portfolio.positions.count)")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Pairs monitored")
                        Spacer()
                        Text("\(Set(viewModel.quotes.map(\.tokenPair)).count)")
                            .foregroundColor(.secondary)
                    }
                }

                Section(header: Text("Portfolio")) {
                    if viewModel.portfolio.positions.isEmpty {
                        Text("No assets yet. Connect an exchange to import balances.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(viewModel.portfolio.positions, id: \.token) { position in
                            HStack {
                                Text(position.token)
                                Spacer()
                                Text(String(format: "%.4f", position.amount))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }

                Section(header: Text("Live Prices")) {
                    if viewModel.quotes.isEmpty {
                        Text("Add a pair to see live pricing updates.")
                            .foregroundColor(.secondary)
                    } else {
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
                }

                Section(header: Text("Opportunities")) {
                    if viewModel.opportunities.isEmpty {
                        Text("Opportunities appear when price gaps are detected.")
                            .foregroundColor(.secondary)
                    } else {
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
                }

                if let status = executionStatus {
                    Section(header: Text("Last Trade")) {
                        Text(status)
                            .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("Dashboard")
            .toolbar {
                Button("Help") { showHowItWorks = true }
                Button("Upgrade") { showPaywall = true }
            }
            .alert("How FlashArb Works", isPresented: $showHowItWorks) {
                Button("Got it", role: .cancel) { }
            } message: {
                Text("FlashArb watches prices across exchanges and highlights spreads. Start by connecting an exchange and choosing a pair to monitor.")
            }
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
            .sheet(isPresented: $showPaywall) {
                PaywallView(tier: .premium)
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
                Task { await self?.refreshData() }
            }
        Task { await refreshData() }
    }

    private func refreshData() async {
        do {
            let pair = "ETH/DAI"
            let fetched = try await service.fetchQuotes(for: pair)
            let detected = service.findOpportunities(quotes: fetched)
            await MainActor.run {
                self.quotes = fetched
                self.opportunities = detected
            }
        } catch {
            print("Failed to fetch quotes: \(error)")
        }
    }

    /// Executes an arbitrage opportunity, wiring to a future smart-contract or exchange API.
    func execute(_ opportunity: ArbitrageOpportunity, completion: @escaping (Bool) -> Void) {
        // Placeholder for asynchronous trade call.
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            completion(true)
        }
    }
}

