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
        case .standard: return "com.flasharb.standard"
        case .premium: return "com.flasharb.premium"
        }
    }

    var displayName: String {
        switch self {
        case .free: return "Free"
        case .standard: return "Standard"
        case .premium: return "Premium"
        }
    }

    static func < (lhs: SubscriptionTier, rhs: SubscriptionTier) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

final class SubscriptionManager {
    static let shared = SubscriptionManager()
    private(set) var currentTier: SubscriptionTier = .free

    private init() {}

    func isSubscribed(to tier: SubscriptionTier) -> Bool {
        currentTier.rawValue >= tier.rawValue
    }

    func rateLimit(for tier: SubscriptionTier) -> Int {
        switch tier {
        case .free: return 60
        case .standard: return 600
        case .premium: return 6000
        }
    }

    func purchase(_ tier: SubscriptionTier) async throws {
#if canImport(StoreKit)
        guard let productID = tier.productID else { return }
        let products = try await Product.products(for: [productID])
        guard let product = products.first else { return }
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            if case .verified(let transaction) = verification {
                await transaction.finish()
                self.currentTier = tier
            }
        default: break
        }
#else
        currentTier = tier
#endif
    }

    func refreshStatus() {
#if canImport(StoreKit)
        if !ReceiptValidator().validateReceipt() {
            self.currentTier = .free
        }
#endif
    }
}
