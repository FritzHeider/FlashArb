import Foundation
#if canImport(StoreKit)
import StoreKit
#endif

enum SubscriptionTier: Int, CaseIterable, Comparable {
    case free = 0
    case standard = 1
    case premium = 2

    var productID: String? {
        switch self {
        case .free: return nil
        case .standard: return "com.flasharb.standard"   // ← ensure exact IDs
        case .premium:  return "com.flasharb.premium"
        }
    }

    var displayName: String {
        switch self {
        case .free:     return "Free"
        case .standard: return "Standard"
        case .premium:  return "Premium"
        }
    }

    static func < (lhs: SubscriptionTier, rhs: SubscriptionTier) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

@MainActor
final class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()

    @Published private(set) var currentTier: SubscriptionTier = .free

    #if canImport(StoreKit)
    private let paidProductIDs: Set<String> = [
        "com.flasharb.standard",
        "com.flasharb.premium"
    ]
    #endif

    private init() { }

    func isSubscribed(to tier: SubscriptionTier) -> Bool {
        currentTier.rawValue >= tier.rawValue
    }

    func rateLimit(for tier: SubscriptionTier) -> Int {
        switch tier {
        case .free:     return 60
        case .standard: return 600
        case .premium:  return 6000
        }
    }

    // MARK: - Purchase

    func purchase(_ tier: SubscriptionTier) async throws {
        #if canImport(StoreKit)
        guard let productID = tier.productID else { return }
        let products = try await Product.products(for: [productID])
        guard let product = products.first else { return }

        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            guard case .verified(let transaction) = verification else { break }
            // Finish and refresh entitlements
            await transaction.finish()
            await refreshStatus()
        case .pending, .userCancelled:
            break
        @unknown default:
            break
        }
        #else
        currentTier = tier
        #endif
    }

    // MARK: - Entitlement Refresh (StoreKit 2, no custom validator)
    @MainActor
    func refreshStatus() async {
        #if canImport(StoreKit)
        var resolvedTier: SubscriptionTier = .free

        for await result in Transaction.currentEntitlements {
            guard case .verified(let txn) = result else { continue }
            guard paidProductIDs.contains(txn.productID) else { continue }
            guard txn.revocationDate == nil else { continue }
            if let exp = txn.expirationDate, exp < Date() { continue }

            if txn.productID == SubscriptionTier.premium.productID {
                resolvedTier = .premium
                break
            } else if txn.productID == SubscriptionTier.standard.productID {
                resolvedTier = max(resolvedTier, .standard)
            }
        }

        self.currentTier = resolvedTier
        #else
        self.currentTier = .free
        #endif
    }

    // MARK: - Live updates (restore, refunds, server-side changes)

    func startListeningForTransactions() {
        #if canImport(StoreKit)
        Task.detached { [weak self] in
            for await update in Transaction.updates {
                guard case .verified(let txn) = update else { continue }
                await txn.finish()
                await self?.refreshStatus()
            }
        }
        #endif
    }
}
