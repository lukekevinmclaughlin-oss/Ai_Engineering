# Ai_Engineering Direct distribution

- **App Store (`Release`)** uses `com.lukemclaughlin.aiengineering` and retains StoreKit subscriptions, trials, restoration, and review prompts.
- **Website (`Direct`)** uses `com.lukemclaughlin.aiengineering.direct`; it is purchased once, permanently unlocked, and compiles out StoreKit and recurring-purchase UI.

Run `./scripts/build-direct.sh` to build, sign, package, notarize, staple, and verify the website edition. `SKIP_NOTARIZATION=1` is only for local checks.
