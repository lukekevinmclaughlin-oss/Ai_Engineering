import XCTest
import SwiftUI
@testable import Ai_Engineering

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

@MainActor
final class AppearancePreferenceTests: XCTestCase {
    func testAppearanceDefaultsToSystemAndPersistsAcrossAppStateInstances() {
        withIsolatedDefaults { defaults in
            let first = makeState(defaults: defaults)
            XCTAssertEqual(first.appearance, .system)

            first.appearance = .light
            XCTAssertEqual(defaults.string(forKey: AppState.appearanceDefaultsKey), AppAppearance.light.rawValue)

            let restored = makeState(defaults: defaults)
            XCTAssertEqual(restored.appearance, .light)
        }
    }

    func testInvalidSavedAppearanceSafelyFallsBackToSystem() {
        withIsolatedDefaults { defaults in
            defaults.set("neon", forKey: AppState.appearanceDefaultsKey)
            XCTAssertEqual(makeState(defaults: defaults).appearance, .system)
        }
    }

    func testCatalogAccentsRemainReadableOnLightSurfaces() throws {
        let accents = Set(
            CurriculumStore.load().courses.map(\.accent)
                + ProjectCatalog.all.map(\.accent)
        )

        for hex in accents {
            let components = try rgbComponents(of: AEColor.readableAccent(hex, .light))
            let foregroundLuminance = relativeLuminance(
                red: components.red,
                green: components.green,
                blue: components.blue
            )
            let contrastAgainstWhite = 1.05 / (foregroundLuminance + 0.05)
            XCTAssertGreaterThanOrEqual(
                contrastAgainstWhite,
                4.74,
                "\(hex) produced only \(contrastAgainstWhite):1 contrast"
            )
        }
    }

    private func makeState(defaults: UserDefaults) -> AppState {
        AppState(
            curriculum: Curriculum(courses: []),
            projects: [],
            progress: ProgressStore(defaults: defaults),
            userDefaults: defaults
        )
    }

    private func withIsolatedDefaults(_ body: (UserDefaults) -> Void) {
        let suiteName = "AiEngineeringAppearanceTests.\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            XCTFail("Could not create isolated UserDefaults")
            return
        }
        defaults.removePersistentDomain(forName: suiteName)
        defer { defaults.removePersistentDomain(forName: suiteName) }
        body(defaults)
    }

    private func rgbComponents(of color: Color) throws -> (red: Double, green: Double, blue: Double) {
        #if os(macOS)
        let converted = try XCTUnwrap(NSColor(color).usingColorSpace(.sRGB))
        return (converted.redComponent, converted.greenComponent, converted.blueComponent)
        #elseif os(iOS)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        XCTAssertTrue(UIColor(color).getRed(&red, green: &green, blue: &blue, alpha: &alpha))
        return (Double(red), Double(green), Double(blue))
        #endif
    }

    private func relativeLuminance(red: Double, green: Double, blue: Double) -> Double {
        func linearized(_ component: Double) -> Double {
            component <= 0.04045
                ? component / 12.92
                : pow((component + 0.055) / 1.055, 2.4)
        }

        return 0.2126 * linearized(red)
            + 0.7152 * linearized(green)
            + 0.0722 * linearized(blue)
    }
}
