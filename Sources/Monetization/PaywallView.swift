#if canImport(SwiftUI)
import SwiftUI

struct PaywallView: View {
    let tier: SubscriptionTier

    var body: some View {
        VStack(spacing: 20) {
            Text("Upgrade to \(tier.displayName)")
                .font(.title2)
            Text("Access advanced analytics and higher rate limits.")
                .multilineTextAlignment(.center)
            Button("Subscribe") {
                Task {
                    try? await SubscriptionManager.shared.purchase(tier)
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
#endif
