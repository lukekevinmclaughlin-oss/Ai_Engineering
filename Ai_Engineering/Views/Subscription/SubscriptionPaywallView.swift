import EngineeringShared
#if DIRECT_DISTRIBUTION
import SwiftUI

/// A compile-time placeholder for sheet call sites that are unreachable in the
/// permanently unlocked Direct edition. No purchase UI is shipped.
struct SubscriptionPaywallView: View {
    let store: SubscriptionStore
    var body: some View { EmptyView() }
}
#else
import SwiftUI

struct SubscriptionLaunchView: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            AEFrontierBackground(accent: AEColor.signal, intensity: 0.8)
            VStack(spacing: AESpacing.lg) {
                TrialNeuralCoreView(size: 116)
                Text("SYNCHRONIZING LEARNING CORE")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .tracking(1.4)
                    .foregroundStyle(AEColor.readableSignal(colorScheme))
                ProgressView().controlSize(.large).tint(AEColor.signal)
            }
        }
    }
}

struct SubscriptionPaywallView: View {
    @ObservedObject var store: SubscriptionStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showPrivacyPolicy = false
    /// Annual is the recommended plan; monthly remains available.
    @State private var wantsAnnual = true

    var body: some View {
        ZStack {
            AEFrontierBackground(accent: AEColor.violet, intensity: 1.05)

            ScrollView {
                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .center, spacing: 54) {
                        narrative.frame(maxWidth: 560)
                        purchaseCard.frame(width: 420)
                    }
                    VStack(spacing: AESpacing.xl) {
                        compactNarrative
                        purchaseCard
                        featureGrid
                    }
                }
                .padding(.horizontal, responsivePadding)
                .padding(.vertical, 38)
                .frame(maxWidth: 1_180)
                .frame(maxWidth: .infinity, minHeight: minimumContentHeight)
            }
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            SubscriptionPrivacyPolicyView()
        }
        .animation(reduceMotion ? nil : AEMotion.gentle, value: store.isEligibleForTrial)
        .animation(reduceMotion ? nil : AEMotion.quick, value: store.message)
    }

    private var narrative: some View {
        VStack(alignment: .leading, spacing: AESpacing.xl) {
            HStack(spacing: AESpacing.sm) {
                AELogoMark(size: 44)
                VStack(alignment: .leading, spacing: 2) {
                    Text("AI_ENGINEERING")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .tracking(1.1)
                        .foregroundStyle(AEColor.textPrimary(colorScheme))
                    Text("FROM FIRST PRINCIPLES TO PRODUCTION")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .tracking(0.9)
                        .foregroundStyle(AEColor.readableSignal(colorScheme))
                }
            }

            TrialNeuralCoreView(size: neuralCoreSize)
                .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: AESpacing.md) {
                Text("Build the mind.\nBecome the engineer.")
                    .font(.system(size: headlineSize, weight: .bold, design: .rounded))
                    .tracking(-1.2)
                    .foregroundStyle(AEColor.textPrimary(colorScheme))
                    .fixedSize(horizontal: false, vertical: true)

                Text("A complete, interactive path from basic arithmetic and first code to production AI systems.")
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundStyle(AEColor.textSecondary(colorScheme))
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }

            featureGrid
        }
    }

    private var compactNarrative: some View {
        VStack(spacing: AESpacing.lg) {
            HStack(spacing: AESpacing.sm) {
                AELogoMark(size: 38)
                VStack(alignment: .leading, spacing: 1) {
                    Text("AI_ENGINEERING")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .tracking(0.9)
                        .foregroundStyle(AEColor.textPrimary(colorScheme))
                    Text("LEARN · BUILD · SHIP")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .tracking(0.8)
                        .foregroundStyle(AEColor.readableSignal(colorScheme))
                }
                Spacer()
                TrialNeuralCoreView(size: 72)
            }

            VStack(alignment: .leading, spacing: AESpacing.sm) {
                Text("Build the mind. Become the engineer.")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .tracking(-0.9)
                    .foregroundStyle(AEColor.textPrimary(colorScheme))
                    .fixedSize(horizontal: false, vertical: true)
                Text("From basic arithmetic and first code to production AI systems.")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(AEColor.textSecondary(colorScheme))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var featureGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 210), spacing: AESpacing.md)], spacing: AESpacing.md) {
            PaywallFeature(icon: "graduationcap.fill", title: "400 lessons", detail: "Beginner to principal level", color: AEColor.signal)
            PaywallFeature(icon: "chevron.left.forwardslash.chevron.right", title: "140 code labs", detail: "Edit, validate, improve", color: AEColor.azure)
            PaywallFeature(icon: "hammer.fill", title: "40 projects", detail: "A portfolio that proves skill", color: AEColor.violet)
            PaywallFeature(icon: "brain.head.profile", title: "Offline tutor", detail: "Private, patient, contextual", color: AEColor.coral)
        }
    }

    private var purchaseCard: some View {
        VStack(alignment: .leading, spacing: AESpacing.lg) {
            VStack(alignment: .leading, spacing: 5) {
                Text("FULL LEARNING ACCESS")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .tracking(1.2)
                    .foregroundStyle(AEColor.readableViolet(colorScheme))
                Text(store.isEligibleForTrial ? "Start with 7 days free" : "Continue your AI journey")
                    .font(.system(size: 27, weight: .bold, design: .rounded))
                    .foregroundStyle(AEColor.textPrimary(colorScheme))
            }

            VStack(alignment: .leading, spacing: AESpacing.sm) {
                planRow(selected: wantsAnnual,
                        title: "Annual",
                        badge: "BEST VALUE",
                        price: store.annualProduct?.displayPrice ?? "$29.99",
                        caption: "per year") { wantsAnnual = true }
                planRow(selected: !wantsAnnual,
                        title: "Monthly",
                        badge: nil,
                        price: store.product?.displayPrice ?? store.localizedMonthlyPrice,
                        caption: "per month") { wantsAnnual = false }
                Text(store.isEligibleForTrial
                     ? "7 days free, then the plan you pick. No charge today — cancel anytime."
                     : "Auto-renews until cancelled. Your progress is never deleted.")
                    .font(.aeCaption)
                    .foregroundStyle(AEColor.textSecondary(colorScheme))
            }
            .padding(.vertical, AESpacing.xs)

            VStack(alignment: .leading, spacing: AESpacing.sm) {
                PaywallCheck(text: "All courses, exercises, and projects")
                PaywallCheck(text: "Contextual Ask Tutor everywhere")
                PaywallCheck(text: "XP, streaks, bookmarks, and progress")
                PaywallCheck(text: "iPhone, iPad, and Mac access")
            }

            Button {
                Task {
                    if wantsAnnual, let annual = store.annualProduct {
                        await store.purchase(annual)
                    } else {
                        await store.purchase()
                    }
                }
            } label: {
                HStack(spacing: AESpacing.sm) {
                    if store.isPurchasing { ProgressView().controlSize(.small) }
                    Text(primaryButtonTitle)
                    Image(systemName: "arrow.right")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(AEButtonStyle(.primary, size: .large, expands: true, tint: AEColor.signal))
            .disabled(!store.isPurchaseAvailable || store.isPurchasing || store.isRestoring)

            Button {
                Task { await store.restorePurchases() }
            } label: {
                HStack {
                    if store.isRestoring { ProgressView().controlSize(.small) }
                    Text("Restore purchases")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(AEButtonStyle(.ghost, size: .compact, expands: true))
            .disabled(store.isPurchasing || store.isRestoring)

            Button("Continue free") { dismiss() }
                .buttonStyle(.plain)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(AEColor.readableAzure(colorScheme))
                .frame(maxWidth: .infinity)

            Text("Continue with every course's first module, saved progress, and offline learning tools. Upgrade only when you want the full curriculum.")
                .font(.aeCaption)
                .foregroundStyle(AEColor.textSecondary(colorScheme))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            if let message = store.message {
                Label(message, systemImage: "info.circle.fill")
                    .font(.aeCaption)
                    .foregroundStyle(AEColor.textSecondary(colorScheme))
                    .padding(AESpacing.sm)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AEColor.subtleFill(colorScheme), in: RoundedRectangle(cornerRadius: AERadius.small))
            }

            Text("Payment is charged to your Apple Account when you confirm. The subscription automatically renews at the end of each billing period — monthly or yearly, depending on the plan you choose — unless cancelled at least 24 hours before the current period ends.")
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(AEColor.textTertiary(colorScheme))
                .lineSpacing(2)

            HStack(spacing: AESpacing.md) {
                Link("Terms of Use", destination: SubscriptionStore.standardEULAURL)
                Button("Privacy Policy") { showPrivacyPolicy = true }
                Link("Manage", destination: SubscriptionStore.manageSubscriptionsURL)
            }
            .buttonStyle(.plain)
            .font(.system(size: 11, weight: .semibold, design: .rounded))
            .foregroundStyle(AEColor.readableAzure(colorScheme))
        }
        .padding(purchaseCardPadding)
        .aeGlassSurface(cornerRadius: 30, tint: AEColor.violet, borderOpacity: 0.26)
        .aeGlow(color: AEColor.violet, radius: 28, intensity: 0.42)
    }

    private var primaryButtonTitle: String {
        store.isPurchasing ? "Connecting to App Store…" : (store.isEligibleForTrial ? "Start free trial" : "Subscribe now")
    }

    private var responsivePadding: CGFloat {
        #if os(macOS)
        return 40
        #else
        return 20
        #endif
    }

    private var minimumContentHeight: CGFloat {
        #if os(macOS)
        return 760
        #else
        return 0
        #endif
    }

    private var neuralCoreSize: CGFloat {
        #if os(macOS)
        return 230
        #else
        return 176
        #endif
    }

    private var headlineSize: CGFloat {
        #if os(macOS)
        return 48
        #else
        return 39
        #endif
    }

    private var purchaseCardPadding: CGFloat {
        #if os(macOS)
        return 28
        #else
        return 22
        #endif
    }
}

private struct PaywallFeature: View {
    @Environment(\.colorScheme) private var colorScheme
    let icon: String
    let title: String
    let detail: String
    let color: Color

    var body: some View {
        HStack(spacing: AESpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 38, height: 38)
                .background(color.opacity(0.11), in: RoundedRectangle(cornerRadius: 11))
            VStack(alignment: .leading, spacing: 1) {
                Text(title).font(.aeLabel).foregroundStyle(AEColor.textPrimary(colorScheme))
                Text(detail).font(.aeCaption).foregroundStyle(AEColor.textTertiary(colorScheme))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct PaywallCheck: View {
    @Environment(\.colorScheme) private var colorScheme
    let text: String

    var body: some View {
        Label {
            Text(text).font(.aeCallout).foregroundStyle(AEColor.textPrimary(colorScheme))
        } icon: {
            Image(systemName: "checkmark.circle.fill").foregroundStyle(AEColor.signal)
        }
    }
}

private struct TrialNeuralCoreView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let size: CGFloat

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 20.0, paused: reduceMotion)) { timeline in
            let time = reduceMotion ? 0.5 : timeline.date.timeIntervalSinceReferenceDate
            ZStack {
                Circle()
                    .fill(RadialGradient(colors: [AEColor.violet.opacity(0.36), AEColor.azure.opacity(0.12), .clear], center: .center, startRadius: 0, endRadius: size * 0.52))
                    .blur(radius: 8)

                ForEach(0..<3, id: \.self) { ring in
                    Circle()
                        .trim(from: CGFloat(ring) * 0.08, to: 0.66 + CGFloat(ring) * 0.09)
                        .stroke(
                            ring == 0 ? AEColor.signal : (ring == 1 ? AEColor.azure : AEColor.violet),
                            style: StrokeStyle(lineWidth: ring == 0 ? 2.5 : 1.25, lineCap: .round, dash: ring == 2 ? [5, 8] : [])
                        )
                        .frame(width: size * (0.50 + CGFloat(ring) * 0.18), height: size * (0.50 + CGFloat(ring) * 0.18))
                        .rotationEffect(.degrees((ring.isMultiple(of: 2) ? 1 : -1) * time * (10 + Double(ring) * 5)))
                }

                Canvas { context, canvasSize in
                    let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
                    let count = 11
                    var lines = Path()
                    for index in 0..<count {
                        let angle = Double(index) / Double(count) * .pi * 2 + time * 0.06
                        let radius = size * (index.isMultiple(of: 3) ? 0.34 : 0.27)
                        let point = CGPoint(x: center.x + cos(angle) * radius, y: center.y + sin(angle) * radius)
                        lines.move(to: center)
                        lines.addLine(to: point)
                        let pulse = 2.4 + sin(time * 2.1 + Double(index)) * 0.9
                        let node = CGRect(x: point.x - pulse, y: point.y - pulse, width: pulse * 2, height: pulse * 2)
                        context.fill(Path(ellipseIn: node), with: .color(index.isMultiple(of: 2) ? AEColor.signal : AEColor.azure))
                    }
                    context.stroke(lines, with: .color(AEColor.azure.opacity(0.19)), lineWidth: 0.8)
                }

                Circle()
                    .fill(AEGradient.signal)
                    .frame(width: size * 0.28, height: size * 0.28)
                    .overlay {
                        Text("AI")
                            .font(.system(size: size * 0.095, weight: .black, design: .rounded))
                            .foregroundStyle(Color(red: 0.02, green: 0.07, blue: 0.10))
                    }
                    .aeGlow(color: AEColor.signal, radius: 22, intensity: 1)
            }
            .frame(width: size, height: size)
        }
        .accessibilityHidden(true)
    }
}

private struct SubscriptionPrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AESpacing.lg) {
                    Text("Privacy Policy").font(.aeTitle).foregroundStyle(AEColor.textPrimary(colorScheme))
                    policySection("Your learning stays yours", "Course progress, XP, streaks, bookmarks, project workspaces, and Tutor Core conversations are stored on your device. Ai_Engineering does not require an account and the developer does not collect this data.")
                    policySection("Offline Tutor Core", "The default tutor works locally. Questions and lesson context do not leave your device when using Offline Core or Apple On-Device tutoring.")
                    policySection("Optional connected providers", "If you explicitly connect your own API provider or local model server, the app sends only the question, recent chat, and relevant learning context directly to the endpoint you choose. The developer does not receive or proxy those requests. Provider terms and privacy policies apply.")
                    policySection("Purchases", "Apple processes subscriptions and provides the app with verified entitlement status. Ai_Engineering does not receive your payment-card details.")
                    policySection("Contact", "Privacy questions: lukekevinmclaughlin.oss@gmail.com")
                    Text("Effective 10 July 2026")
                        .font(.aeCaption)
                        .foregroundStyle(AEColor.textTertiary(colorScheme))
                }
                .padding(AESpacing.xl)
                .frame(maxWidth: 720, alignment: .leading)
                .frame(maxWidth: .infinity)
            }
            .background(AEColor.canvas(colorScheme))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 620, minHeight: 640)
        #endif
    }

    private func policySection(_ title: String, _ body: String) -> some View {
        VStack(alignment: .leading, spacing: AESpacing.xs) {
            Text(title).font(.aeHeading).foregroundStyle(AEColor.textPrimary(colorScheme))
            Text(body).font(.aeBody).foregroundStyle(AEColor.textSecondary(colorScheme)).lineSpacing(3)
        }
    }
}


private extension SubscriptionPaywallView {
    func planRow(selected: Bool, title: String, badge: String?, price: String,
                 caption: String, tap: @escaping () -> Void) -> some View {
        Button(action: tap) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(title)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(AEColor.textPrimary(colorScheme))
                        if let badge {
                            Text(badge)
                                .font(.system(size: 8.5, weight: .black, design: .monospaced))
                                .padding(.horizontal, 5).padding(.vertical, 2)
                                .background(AEColor.signal.opacity(0.16), in: Capsule())
                                .foregroundStyle(AEColor.readableSignal(colorScheme))
                        }
                    }
                    Text(caption)
                        .font(.aeCaption)
                        .foregroundStyle(AEColor.textSecondary(colorScheme))
                }
                Spacer()
                Text(price)
                    .font(.system(size: 19, weight: .black, design: .rounded))
                    .foregroundStyle(AEGradient.spectral)
            }
            .padding(AESpacing.md)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(selected ? AEColor.signal : AEColor.divider(colorScheme),
                            lineWidth: selected ? 2 : 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
#endif
