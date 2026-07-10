import Foundation
import StoreKit

@MainActor
final class SubscriptionStore: ObservableObject {
    enum AccessState: Equatable {
        case checking
        case subscribed(expirationDate: Date?)
        case subscriptionRequired
    }

    #if os(macOS)
    static let platformProductID = "com.lukemclaughlin.aiengineering.pro.monthly.macos"
    #else
    static let platformProductID = "com.lukemclaughlin.aiengineering.pro.monthly.ios"
    #endif

    static let allProductIDs: Set<String> = [
        "com.lukemclaughlin.aiengineering.pro.monthly.ios",
        "com.lukemclaughlin.aiengineering.pro.monthly.macos"
    ]
    static let manageSubscriptionsURL = URL(string: "https://apps.apple.com/account/subscriptions")!
    static let standardEULAURL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!

    @Published private(set) var accessState: AccessState = .checking
    @Published private(set) var product: Product?
    @Published private(set) var isEligibleForTrial = false
    @Published private(set) var isPurchasing = false
    @Published private(set) var isRestoring = false
    @Published var message: String?

    private var hasPrepared = false
    private var transactionUpdatesTask: Task<Void, Never>?
    #if DEBUG
    private let isScreenshotTrial = ProcessInfo.processInfo.arguments.contains("--app-store-screenshot-trial")
    #endif

    init() {
        #if DEBUG
        if isScreenshotTrial {
            accessState = .subscriptionRequired
            isEligibleForTrial = true
        } else if ProcessInfo.processInfo.arguments.contains("--app-store-screenshot-access") {
            accessState = .subscribed(expirationDate: nil)
        }
        #endif

        transactionUpdatesTask = Task { [weak self] in
            for await update in Transaction.updates {
                guard let self else { return }
                if case .verified(let transaction) = update {
                    await transaction.finish()
                    await self.refreshEntitlements()
                }
            }
        }
    }

    var hasAccess: Bool {
        if case .subscribed = accessState { return true }
        return false
    }

    var isCheckingAccess: Bool { accessState == .checking }

    var isPurchaseAvailable: Bool {
        #if DEBUG
        if isScreenshotTrial { return true }
        #endif
        return product != nil
    }

    var localizedMonthlyPrice: String { product?.displayPrice ?? "$1.99" }

    var entitlementDescription: String {
        switch accessState {
        case .checking:
            return "Checking App Store access…"
        case .subscriptionRequired:
            return "Subscription required"
        case .subscribed(let expirationDate):
            guard let expirationDate else { return "Active subscription" }
            return "Active · renews (expirationDate.formatted(date: .abbreviated, time: .omitted))"
        }
    }

    func prepare() async {
        guard !hasPrepared else { return }
        hasPrepared = true
        #if DEBUG
        if isScreenshotTrial { return }
        #endif
        await refresh()
    }

    func refresh() async {
        message = nil
        await refreshEntitlements()
        await loadProduct()
    }

    func purchase() async {
        #if DEBUG
        if isScreenshotTrial { return }
        #endif
        guard let product else {
            message = "The subscription is temporarily unavailable. Check your connection and try again."
            await loadProduct()
            return
        }

        isPurchasing = true
        message = nil
        defer { isPurchasing = false }

        do {
            switch try await product.purchase() {
            case .success(let verification):
                let transaction = try verified(verification)
                await transaction.finish()
                await refreshEntitlements()
            case .pending:
                message = "Your purchase is pending approval. Access will unlock automatically when Apple confirms it."
            case .userCancelled:
                break
            @unknown default:
                message = "The App Store returned an unknown purchase result. Please try again."
            }
        } catch {
            message = "The purchase could not be completed. (error.localizedDescription)"
        }
    }

    func restorePurchases() async {
        isRestoring = true
        message = nil
        defer { isRestoring = false }

        do {
            try await AppStore.sync()
            await refreshEntitlements()
            if !hasAccess {
                message = "No active Ai_Engineering subscription was found for this Apple Account."
            }
        } catch {
            message = "Purchases could not be restored. (error.localizedDescription)"
        }
    }

    private func loadProduct() async {
        do {
            product = try await Product.products(for: [Self.platformProductID]).first
            if let subscription = product?.subscription {
                isEligibleForTrial = await subscription.isEligibleForIntroOffer
            } else {
                isEligibleForTrial = false
            }
            if product == nil && !hasAccess {
                message = "The App Store is still preparing this subscription. Please try again in a moment."
            }
        } catch {
            product = nil
            isEligibleForTrial = false
            if !hasAccess {
                message = "The App Store could not be reached. (error.localizedDescription)"
            }
        }
    }

    private func refreshEntitlements() async {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("--app-store-screenshot-access") {
            accessState = .subscribed(expirationDate: nil)
            return
        }
        #endif

        var latestExpiration: Date?
        var foundActiveEntitlement = false

        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result,
                  Self.allProductIDs.contains(transaction.productID),
                  transaction.revocationDate == nil else { continue }

            foundActiveEntitlement = true
            if let expirationDate = transaction.expirationDate,
               latestExpiration == nil || expirationDate > latestExpiration! {
                latestExpiration = expirationDate
            }
        }

        accessState = foundActiveEntitlement
            ? .subscribed(expirationDate: latestExpiration)
            : .subscriptionRequired
    }

    private func verified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let value): return value
        case .unverified: throw SubscriptionError.failedVerification
        }
    }
}

private enum SubscriptionError: LocalizedError {
    case failedVerification

    var errorDescription: String? {
        "The App Store transaction could not be verified."
    }
}
