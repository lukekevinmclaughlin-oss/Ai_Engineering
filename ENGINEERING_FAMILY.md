# Engineering App Family Architecture

This repository is the source of the reusable `EngineeringShared` Swift package consumed by AI Engineering, ML Engineering, and Data Engineering.

## Product boundary

| App | Professional outcome | Operating loop | Product-owned curriculum and projects |
| --- | --- | --- | --- |
| AI Engineering | Build dependable AI-enabled products and systems | Design → Evaluate → Guard → Operate | LLM interfaces, retrieval, agents, multimodal systems, evals, safety, inference, and AI observability |
| ML Engineering | Build, validate, deploy, and monitor predictive models | Frame → Experiment → Validate → Monitor | Features, baselines, classical ML, deep learning, forecasting, model serving, drift, and MLOps |
| Data Engineering | Build reliable data products and platforms | Ingest → Transform → Validate → Orchestrate | SQL, data modeling, pipelines, warehouses, streaming, quality, governance, and orchestration |

Each app owns its curriculum resource, project catalog, tutor persona, subscription presentation, navigation state, and professional workflow. The apps do not redirect users to interchangeable copies of the same curriculum.

## Shared implementation

`EngineeringShared` contains reusable infrastructure:

- design tokens, cards, buttons, metrics, progress indicators, and tags;
- learning and tutor data models;
- local progress persistence;
- syntax highlighting and code-learning controls;
- local tutor discovery and same-origin network safeguards;
- the parameterized workflow presentation component.

ML Engineering and Data Engineering pin the package to immutable commit `783e00bfde5815ec8979ac569aff87d5aabf114b`.

## Intentional adapters

`CourseDetailView` and `ProjectDetailView` remain in every app because they bind shared learning models to each product's concrete `AppState`, entitlement flow, curriculum, and project catalog. They are thin presentation adapters, not independent product logic.

After consolidation, these are the only exact Swift blobs shared by all three app targets. No additional pairwise exact Swift duplication remains.

## Release policy

- Improve these three existing listings instead of creating near-duplicate engineering SKUs.
- Put reusable infrastructure in `EngineeringShared`.
- Keep curriculum, projects, tutor behavior, workflows, screenshots, and App Store positioning product-owned.
- Re-run package and generated-project macOS tests before merging changes that affect the shared boundary.
