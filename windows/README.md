# AI Engineering for Windows

Local, unsigned Windows 11 x64 release candidate. Not published or offered for sale. The original macOS/iOS source is unchanged; all Windows implementation lives in this directory in the existing repository.

The Windows edition includes the original 40 courses, 80 modules and 400 lessons: 80 concepts, 100 knowledge checks, 140 code exercises and 80 architecture lessons. It includes all 40 project briefs, 80 starter files and 160 project-scoped milestones extracted from the Swift catalogue. The curriculum JSON is byte-identical to the original. `content/provenance.json` records the source SHA-256 values used for the port.

Home, Learn, Tutor, Projects and Progress preserve the original navy/mint/violet design language and Design → Evaluate → Guard → Operate learning workflow. Search and level filters, course bookmarks, module/lesson navigation, hints, worked solutions, reference examples, lesson drafts, project file tabs, structure checks and milestone self-review are available. Individual project source files can be exported into a new folder selected by the user.

Lesson XP is awarded only on first completion. Daily XP and streaks use local calendar days. Skill XP derives from completed lessons; no synthetic baseline is shown. Progress, drafts, preferences and tutor conversation are stored in IndexedDB with atomic current/previous records. Backups validate IDs, types, dates and size before a confirmed import. Credentials are excluded. The previous save can be restored. Failed writes are reported and do not silently overwrite existing records.

Offline Core retrieves and organizes all 440 bundled lesson/project documents, expands common AI terms, applies lesson/project context, adapts learner level and depth, and links back to its sources. It runs without network access or model downloads. It is a retrieval-based tutor, not a generative model. The original Apple Intelligence engine requires macOS and is not available on Windows.

Optional generative tutoring supports the original OpenAI-compatible, Anthropic Messages and Gemini protocols, with presets for the original 13 hosted providers plus same-machine Ollama and LM Studio discovery. Model IDs are entered by the user; no model or provider subscription is bundled. API keys and connection details are encrypted using Electron safeStorage/Windows user-bound encryption, written atomically, and never returned to the renderer. Saving or enabling a connection requires a native confirmation explaining the endpoint and data sent. Network permission lasts for one app session. Hosted endpoints require HTTPS; named providers are pinned to their preset endpoints. Redirects are refused, responses and requests are bounded, and cancellation/timeouts abort active requests. Provider errors fall back visibly to Offline Core. No real API calls or provider charges were used for development verification.

The renderer is sandboxed, context-isolated and has no Node access. Only the trusted application main frame can invoke the narrow preload API. External navigation, popups, webviews, renderer HTTP/WebSocket requests and device permissions are blocked. User content and model responses render as escaped text.

Code exercises preserve the original reference-token review approach. Project checks inspect edits and placeholders. **Neither executes code or verifies runtime correctness.** The UI identifies these checks as text/structure review and displays test examples as reference expectations. Exported project code needs a configured development environment. Milestones are self-assessments and do not award lesson XP.

Build locally with Node 24 and pnpm 11:

```powershell
pnpm install
pnpm test
pnpm run build
pnpm run package:win
node scripts/verify-package.cjs
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/build-installer.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/make-portable.ps1
```

The installer is per-user and removes only packaged files on uninstall. Unrelated files in the installation directory are preserved. The ZIP contains the same application; learning data still uses the current user's application profile. Electron 39.8.10 and Chromium notices are included beside the executable. The frontend and host have no third-party runtime JavaScript package dependencies; build tools are not distributed.

Validation: 454 automated checks cover every lesson's reference/choice consistency, exact original content, Windows filenames, XP/streak/milestone behavior, backup rejection/recovery, grounded tutoring, encrypted-store failure handling, provider protocol payloads, and real loopback HTTP size/redirect/cancellation/timeout behavior. Encryption unit tests use a synthetic cipher adapter. A separate headless Windows test passed an actual safeStorage encrypted credential roundtrip and forget operation with synthetic data; native dialogs remain unverified. Chrome UI checks and packaged/installer reports are recorded separately beside the candidate artifacts.

Release gates: native Windows window/menu/dialog checks, real provider/local-model integration, accessibility and Windows compatibility review, code signing and final distribution review. No Actions runs, LFS transfers or GitHub Releases uploads are part of this build process. Disable repository Actions before pushing source.

Protocol references: [OpenAI Chat API](https://developers.openai.com/api/reference/resources/chat), [Anthropic Messages](https://docs.anthropic.com/en/api/messages), [Gemini generateContent](https://ai.google.dev/api/generate-content). Preset endpoints and product behavior were ported from the existing macOS source; live providers were not exercised.

The original curriculum includes Apple-specific Foundation Models/Core ML/Swift examples. These remain available for study, editing and export, with a visible platform notice; executing them requires supported Apple hardware and tooling.

The original six assembly stages use the same 600-component total: 400 lessons, 40 completed courses and 160 scoped milestones. An animated neural scaffold grows with this progress and respects reduced-motion preferences. Learning levels advance every 500 XP. Curriculum coverage shows actual lesson completion by level and self-reviewed projects rather than asserting job readiness. Appearance can follow Windows, and resetting learning progress retains drafts and project source.

Code editors and worked examples include offline syntax colouring for common programming, query and markup constructs. The accessible textarea retains native selection, keyboard editing and Unicode text; a separate inert visual layer follows scrolling. Forced-colour mode uses the standard text field. Colouring is lexical and does not parse or execute source.

Home and Progress include the original weekly momentum feature, calculated from first lesson completions for the last seven local calendar days. Days without earned XP display zero; replaying a lesson does not move or duplicate its XP.
