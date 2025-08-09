# FlashArb

FlashArb is a prototype iOS application that explores flash-loan arbitrage
opportunities across decentralized exchanges. The project currently focuses on
foundational components and does not yet integrate with live trading APIs.

## Getting Started

1. Clone the repository.
2. Open `project.xcworkspace` in Xcode.
3. Select an iOS simulator or device and run the app.

## App Analysis and Ratings

| Metric | Rating (1-10) | Notes |
|-------|---------------|-------|
| Innovation | 6 | Mobile flash-loan arbitrage is an uncommon concept but currently underdeveloped. |
| Monetization | 2 | No monetization strategy or revenue features implemented. |
| Creativity | 5 | Combining DeFi with an iOS interface shows promise but lacks execution. |
| Scalability | 4 | Lacks backend and multi-exchange support to grow beyond a prototype. |
| User Engagement | 3 | Interface and real-time feedback are absent, reducing user retention. |

## Improvements Implemented

- Added foundational arbitrage engine components:
- `ArbitrageOpportunity` model to describe trades and profit.
- `ArbitrageService` for scanning market quotes and discovering opportunities.
- `Portfolio` model for tracking token balances.
- Enhanced `Portfolio` with trade history and P&L calculations.
- Introduced `RiskCalculator` for VaR, drawdown, and leverage metrics.
- Added `PerformanceDashboard` for charting and report exports.
- Implemented configurable alerts for exposure and volatility limits.

## Next Steps Toward 10/10

- Integrate with real exchange APIs for live pricing.
- Build an engaging dashboard and execution flow.
- Introduce subscription or fee-based monetization model.
- Expand analytics and risk management features for advanced users.
