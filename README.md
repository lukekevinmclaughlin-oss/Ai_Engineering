# Ai_Engineering

**Courses, Practical Lessons, Interactive Projects**

Ai_Engineering is a native SwiftUI learning app for becoming a production-capable AI engineer. It combines short, substantive lessons with quizzes, code exercises, architecture decisions, project workspaces, skill progression, XP, streaks, and portfolio-oriented capstones.

The same target runs on iPhone, iPad, and macOS. iOS uses a compact tab-based experience; macOS uses a persistent learning sidebar and split-pane lesson workspace.

## What is included

- Frontier-style adaptive design system with animated neural graphics, glass surfaces, grid fields, semantic color, and a complete app icon set
- System, light, and dark appearance controls available directly from the main navigation UI
- Live AI assembly visualization that turns verified lessons, completed courses, and project milestones into a progressively constructed neural system
- Home learning terminal with a featured path, daily target, momentum, course progress, and skill signal
- Searchable and filterable course catalog
- Detailed course maps with module and lesson completion
- Interactive lesson player with animated concept diagrams, architecture maps, syntax-highlighted code samples and editors, quizzes, local checks, hints, explanations, and AI-component completion celebrations
- Tutor Core: a curriculum-grounded AI tutor with an always-available offline engine, private Apple on-device generation on supported hardware, lesson/project context, novice and engineer teaching modes, and deep-dive answers
- Persistent local XP, daily goals, streaks, bookmarks, lesson completion, skill XP, and project milestones
- Project Lab with 40 realistic briefs, outcomes, project-scoped milestones, syntax-highlighted editable starter files, and simulated local quality checks
- Progress profile with role readiness, skill matrix, levels, and adjustable learning goals
- Shared unit tests for curriculum integrity and progress persistence
- StoreKit 2 subscription access on iOS and macOS with a 14-day introductory trial, localized monthly pricing, verified entitlements, purchase restoration, and subscription management

## Curriculum

The bundled curriculum contains exactly **40 courses, 80 modules, and 400 interactive lessons**:

1. Computing & Python from Zero
2. Math Intuition for AI
3. Data Foundations
4. Machine Learning Foundations
5. Neural Networks & PyTorch
6. Language Models from First Principles
7. Prompt & Context Engineering
8. Embeddings & Semantic Search
9. Retrieval-Augmented Generation
10. LLM Application Architecture
11. Agents & Tool-Using Systems
12. Evaluation Engineering
13. Safety, Security & Guardrails
14. Multimodal AI Systems
15. Fine-Tuning & Adaptation
16. Model Serving & Inference
17. LLMOps, Observability & Cost
18. Distributed AI Systems
19. AI Product & Human-Centered Design
20. Staff AI Engineer Capstone
21. Swift & On-Device AI Engineering
22. Advanced RAG & Knowledge Systems
23. Agent Protocols & Multi-Agent Systems
24. Realtime Voice AI
25. Computer Vision Engineering
26. Speech & Audio AI Systems
27. Search, Ranking & Recommenders
28. Synthetic Data & Data Engines
29. Reasoning, Planning & Test-Time Compute
30. Efficient Models, Quantization & Edge AI
31. Causal AI & Experimentation
32. Graph AI & Knowledge Graphs
33. Privacy-Preserving AI
34. Adversarial ML & AI Red Teaming
35. AI Infrastructure on Kubernetes
36. GPU Performance Engineering
37. AI Platform Architecture & Developer Experience
38. Domain AI, Governance & Compliance
39. Research-to-Production Engineering
40. Principal AI Architect Capstone

Every lesson contains a substantive explanation, a practical challenge, progressive hints, validation, feedback, and XP. The catalog includes **140 editable code labs, 100 quizzes, 80 architecture decisions, and 80 guided concept exercises**.

The Project Lab contains **40 portfolio builds** arranged as a real progression: **12 Beginner, 14 Intermediate, and 14 Advanced**. Beginner builds assume only basic arithmetic and no prior coding, then scaffold a first Python script, prompt anatomy, classification, sentiment, structured extraction, tiny search, a safe chatbot, evaluation, image and audio basics, recommendations, and a local API. Later builds span RAG, agents, multimodal systems, inference optimization, observability, realtime voice, ranking, causal experimentation, graph intelligence, privacy, GPU systems, Kubernetes serving, governance, research reproduction, and principal architecture.

## Tutor Core and privacy

Tutor Core does not require an API key, login, paid account, or LLM subscription.

- **Automatic (default):** selects the best private engine available and never selects a connected provider.
- **Offline Core:** always available on iOS 17 and macOS 14 or later. It retrieves relevant material from the 400 bundled lessons and produces structured, novice-friendly explanations without network access.
- **Apple On-Device:** on compatible Apple Intelligence devices running iOS 26 or macOS 26, the Foundation Models framework adds stateful generative tutoring while keeping inference on-device.
- **Connected Provider:** an optional, explicitly enabled provider API connection. Presets cover OpenAI, Anthropic, Google Gemini, xAI, DeepSeek, Mistral, Groq, OpenRouter, Together, Fireworks, Perplexity, Cerebras, and a custom OpenAI-compatible endpoint; the user supplies the API key and model. Native request adapters support OpenAI-compatible chat completions, Anthropic Messages, and Gemini `generateContent`. It is never used as an automatic fallback.
- **Local model server:** Ollama and LM Studio are detected only on this device’s loopback interface, never by scanning the LAN. Selecting either option attempts a short local detection and connects the first available model; settings can retry detection or switch detected models. On iPhone and iPad, localhost means that mobile device, not a Mac on the same network.

Provider API credentials are stored in Keychain, bound to the configured endpoint origin, and never followed across origins during redirects. The settings screen discloses exactly what is sent before a provider is enabled.

## Requirements

- macOS with Xcode 15 or newer; Xcode 26 is required to compile the optional Apple Foundation Models integration
- iOS 17 / macOS 14 deployment targets
- XcodeGen 2.38 or newer

Install XcodeGen with Homebrew if needed:

```sh
brew install xcodegen
```

## Generate and open the project

The generated Xcode project is intentionally ignored so `project.yml` remains the source of truth.

```sh
./scripts/generate-project.sh
open Ai_Engineering.xcodeproj
```

Select the `Ai_Engineering` scheme and run on My Mac or any iOS simulator.

## Command-line verification

Build macOS:

```sh
xcodebuild \
  -project Ai_Engineering.xcodeproj \
  -scheme Ai_Engineering \
  -destination 'platform=macOS' \
  build
```

Build iOS Simulator:

```sh
xcodebuild \
  -project Ai_Engineering.xcodeproj \
  -scheme Ai_Engineering \
  -destination 'generic/platform=iOS Simulator' \
  build
```

Run the macOS tests:

```sh
xcodebuild \
  -project Ai_Engineering.xcodeproj \
  -scheme Ai_Engineering \
  -destination 'platform=macOS,arch=arm64' \
  test
```

## Repository structure

```text
Ai_Engineering/
├── App/                 App entry point, state, and adaptive navigation
├── Components/          Cards, buttons, tags, metrics, and progress UI
├── Data/                Curriculum loader and project catalog
├── Design/              Color, typography, motion, backgrounds, and effects
├── Models/              Learning and project domain models
├── Resources/           Curriculum JSON and asset catalogs
├── Services/            Progress, offline retrieval, on-device tutor, optional provider
└── Views/
    ├── Dashboard/
    ├── Learn/
    ├── Lessons/
    ├── Profile/
    ├── Projects/
    └── Tutor/
```

## Editing course content

Course content is data-driven. Authoring fragments live in `scripts/content/`; the app bundle reads the generated `Ai_Engineering/Resources/curriculum.json`. A course contains two modules, each module contains five lessons, and every lesson contains content blocks plus one challenge. The app supports heading, paragraph, callout, code, and bullet blocks plus quiz, architecture, concept, and code challenges.

Merge and validate changes before building:

```sh
./scripts/merge-curriculum.sh
jq empty Ai_Engineering/Resources/curriculum.json
```

`CurriculumTests` also verifies identifier uniqueness, lesson completeness, and coverage of the production AI engineering core.

## Execution model

The app is offline-first and has no required external runtime dependencies. Quiz and architecture exercises use exact local validation. Code labs provide an editable workspace and deterministic local structural checks without executing untrusted Python on the device. Tutor Core’s default engines run locally; only the clearly labeled Connected Provider mode performs a tutor network request.

For a public multi-user release, the natural next infrastructure layer is authenticated progress sync, a containerized remote code runner, a course CMS, and server-managed evaluation datasets. Those services are intentionally kept outside this native client repository. Subscriptions are handled entirely by StoreKit and App Store Connect; the app does not operate a payment backend.
