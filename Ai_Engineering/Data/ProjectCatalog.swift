import Foundation

enum ProjectCatalog {
    static let all: [LabProject] = [
        LabProject(
            id: "beginner-first-python-ai",
            title: "Write your first AI-flavoured script",
            subtitle: "Python basics · Data · Simple decisions",
            summary: "Learn variables, lists, loops, and functions by turning a tiny table of help requests into a useful daily summary.",
            icon: "terminal.fill",
            accent: "61F2C2",
            difficulty: "Beginner",
            estimatedHours: 2,
            xp: 900,
            skills: ["Python basics", "Lists and dictionaries", "Functions", "Data summaries"],
            outcomes: [
                "Read a small Python program one line at a time without assuming prior coding knowledge",
                "Store real-world records as friendly dictionaries inside a list",
                "Use a loop and an if statement to count simple categories",
                "Turn repeated steps into a function and check its output"
            ],
            milestones: [
                .init(id: "read", title: "Meet the data", detail: "Label each value, record, list, and printed result in plain language.", systemImage: "text.book.closed.fill"),
                .init(id: "count", title: "Count with a loop", detail: "Walk through one request at a time and update category totals.", systemImage: "number.circle.fill"),
                .init(id: "function", title: "Make a reusable helper", detail: "Wrap the working steps in a named function with one input and one output.", systemImage: "shippingbox.fill"),
                .init(id: "check", title: "Check three examples", detail: "Predict each result on paper, run it, and explain any difference.", systemImage: "checkmark.circle.fill")
            ],
            brief: "A neighborhood library records five common help requests each morning. Build its first Python helper: count requests by topic, identify the busiest topic, and print a short summary the librarian can understand. No model or internet connection is required.",
            starterFiles: [
                .init(name: "requests.py", language: "python", contents: "requests = [{\"topic\": \"printing\"}, {\"topic\": \"email\"}, {\"topic\": \"printing\"}]\n\ndef count_topics(rows):\n    counts = {}\n    for row in rows:\n        topic = row[\"topic\"]\n        counts[topic] = counts.get(topic, 0) + 1\n    return counts\n\nprint(count_topics(requests))\n"),
                .init(name: "checks.py", language: "python", contents: "from requests import count_topics\nassert count_topics([]) == {}\nassert count_topics([{\"topic\": \"email\"}]) == {\"email\": 1}\n# Add a check containing two different topics.\n")
            ]
        ),
        LabProject(
            id: "beginner-prompt-anatomy",
            title: "Build a prompt anatomy playground",
            subtitle: "Instructions · Context · Examples",
            summary: "Discover what a prompt is by assembling its parts and comparing saved responses with a small, human-readable rubric.",
            icon: "text.quote",
            accent: "A98BFF",
            difficulty: "Beginner",
            estimatedHours: 2,
            xp: 900,
            skills: ["Prompt structure", "Clear instructions", "Examples", "Simple rubrics"],
            outcomes: [
                "Separate a prompt into task, context, constraints, example, and output format",
                "Replace vague requests with observable instructions",
                "Compare saved responses without trusting whichever sounds more confident",
                "Record a prompt version and an evidence-based reason for changing it"
            ],
            milestones: [
                .init(id: "parts", title: "Label the prompt parts", detail: "Color-code the task, background, limits, example, and answer shape.", systemImage: "highlighter"),
                .init(id: "rewrite", title: "Remove ambiguity", detail: "Replace words such as good with concrete, checkable requirements.", systemImage: "pencil.line"),
                .init(id: "compare", title: "Score saved responses", detail: "Use four yes-or-no checks before expressing a preference.", systemImage: "rectangle.2.swap"),
                .init(id: "version", title: "Keep a prompt journal", detail: "Save the before, after, result, and lesson learned.", systemImage: "book.pages.fill")
            ],
            brief: "A community museum wants an assistant to turn exhibit notes into child-friendly labels, but its request only says 'make this better.' Create a clear prompt template and use supplied responses to show how instructions change quality without requiring an API.",
            starterFiles: [
                .init(name: "prompt_builder.py", language: "python", contents: "def build_prompt(notes, audience=\"age 10\"):\n    parts = [\"Task: Explain the exhibit notes.\", f\"Audience: {audience}\", f\"Context: {notes}\",\n             \"Constraints: Use 60 words or fewer. Define unfamiliar terms.\",\n             \"Output: One title followed by one paragraph.\"]\n    return \"\\n\".join(parts)\n\nprint(build_prompt(\"The telescope was built in 1880.\"))\n"),
                .init(name: "rubric.py", language: "python", contents: "SAVED_RESPONSES = [\n    \"Star Watcher\\nThis telescope was built in 1880. It helped people study faraway stars.\",\n    \"An optical apparatus of considerable historical significance, manufactured in the nineteenth century.\",\n]\n\ndef score(response):\n    checks = {\"has_title\": \"\\n\" in response, \"within_limit\": len(response.split()) <= 60,\n              \"mentions_year\": \"1880\" in response, \"avoids_jargon\": \"optical apparatus\" not in response.lower()}\n    return checks, sum(checks.values())\n\nfor number, response in enumerate(SAVED_RESPONSES, start=1):\n    print(number, score(response))\n")
            ]
        ),
        LabProject(
            id: "beginner-rules-vs-model",
            title: "Compare rules with a tiny classifier",
            subtitle: "Categories · Baselines · Mistakes",
            summary: "Route simple messages with readable keyword rules, then compare them with supplied model predictions to learn why baselines matter.",
            icon: "arrow.triangle.branch",
            accent: "FFB85C",
            difficulty: "Beginner",
            estimatedHours: 3,
            xp: 950,
            skills: ["Classification", "Rule baselines", "Labels", "Error analysis"],
            outcomes: [
                "Explain classification as choosing one label from a small allowed set",
                "Build a transparent keyword baseline before considering a model",
                "Calculate accuracy as correct examples divided by total examples",
                "Inspect mistakes and decide whether rules, data, or labels need work"
            ],
            milestones: [
                .init(id: "labels", title: "Define three labels", detail: "Write one definition and two examples for each category.", systemImage: "tag.fill"),
                .init(id: "rules", title: "Create the baseline", detail: "Route messages with visible keywords and a safe unknown result.", systemImage: "list.bullet.indent"),
                .init(id: "measure", title: "Count correct predictions", detail: "Build a scorecard and calculate accuracy with basic division.", systemImage: "percent"),
                .init(id: "mistakes", title: "Read every mistake", detail: "Group failures and propose one small improvement.", systemImage: "magnifyingglass")
            ],
            brief: "A bicycle shop wants to sort website messages into repair, sales, or unknown. Build an understandable rules baseline, compare it with supplied model predictions, and recommend which approach may assist staff without automatically replying.",
            starterFiles: [
                .init(name: "classifier.py", language: "python", contents: "def classify(message):\n    text = message.lower()\n    if any(word in text for word in [\"broken\", \"flat\", \"repair\"]): return \"repair\"\n    if any(word in text for word in [\"buy\", \"price\", \"stock\"]): return \"sales\"\n    return \"unknown\"\n"),
                .init(name: "evaluate.py", language: "python", contents: "from classifier import classify\n\nCASES = [(\"My tire is flat\", \"repair\"), (\"What is the price?\", \"sales\"), (\"Open Sunday?\", \"unknown\")]\nMODEL_PREDICTIONS = [\"repair\", \"sales\", \"sales\"]  # Supplied offline results; the last one is wrong.\nRULE_PREDICTIONS = [classify(text) for text, _ in CASES]\n\ndef accuracy(predictions):\n    correct = sum(prediction == expected for prediction, (_, expected) in zip(predictions, CASES))\n    return correct / len(CASES)\n\nprint(\"rules\", accuracy(RULE_PREDICTIONS))\nprint(\"model\", accuracy(MODEL_PREDICTIONS))\nfor case, rule, model in zip(CASES, RULE_PREDICTIONS, MODEL_PREDICTIONS):\n    print(case[0], \"expected=\", case[1], \"rule=\", rule, \"model=\", model)\n")
            ]
        ),
        LabProject(
            id: "beginner-sentiment-explorer",
            title: "Explore sentiment without the hype",
            subtitle: "Text features · Scores · Limitations",
            summary: "Build a small review explorer that counts positive and negative words while learning why tone cannot be reduced to a perfect label.",
            icon: "face.smiling.inverse",
            accent: "FF7E9D",
            difficulty: "Beginner",
            estimatedHours: 3,
            xp: 950,
            skills: ["Text processing", "Sentiment", "Scores", "Responsible interpretation"],
            outcomes: [
                "Turn text into lowercase word tokens and count simple signals",
                "Explain a sentiment score as evidence rather than an objective emotion reading",
                "Handle negation, mixed reviews, and unknown words as visible limitations",
                "Summarize a group of reviews without judging individual people"
            ],
            milestones: [
                .init(id: "words", title: "Create a word list", detail: "Choose a few positive and negative terms and document what they miss.", systemImage: "textformat.abc"),
                .init(id: "score", title: "Add the score", detail: "Count signals, subtract negatives, and keep raw counts visible.", systemImage: "plus.forwardslash.minus"),
                .init(id: "edge", title: "Test tricky language", detail: "Try negation, mixed opinions, sarcasm, and another language.", systemImage: "exclamationmark.bubble.fill"),
                .init(id: "report", title: "Write a careful report", detail: "Aggregate themes and uncertainty without ranking people.", systemImage: "chart.bar.doc.horizontal.fill")
            ],
            brief: "A volunteer-run cinema has twenty anonymous visitor comments and wants broad service themes. Build a local sentiment explorer that shows its word counts and caveats, then write a summary that does not claim to know anyone's feelings.",
            starterFiles: [
                .init(name: "sentiment.py", language: "python", contents: "POSITIVE = {\"friendly\", \"clean\", \"comfortable\", \"great\"}\nNEGATIVE = {\"slow\", \"noisy\", \"dirty\", \"uncomfortable\"}\ndef sentiment(text):\n    words = set(text.lower().replace(\".\", \"\").split())\n    positive, negative = len(words & POSITIVE), len(words & NEGATIVE)\n    return {\"positive\": positive, \"negative\": negative, \"score\": positive-negative}\n"),
                .init(name: "examples.py", language: "python", contents: "from sentiment import sentiment\nCOMMENTS = [\"Friendly staff and comfortable seats.\", \"The queue was slow, but the room was clean.\",\n            \"Not good is harder than one-word counting.\"]\nfor comment in COMMENTS: print(comment, sentiment(comment))\n")
            ]
        ),
        LabProject(
            id: "beginner-structured-extraction",
            title: "Turn messy notes into clean records",
            subtitle: "Fields · Validation · JSON",
            summary: "Extract a few known fields from event messages and validate them before saving structured JSON.",
            icon: "curlybraces.square.fill",
            accent: "53D7C5",
            difficulty: "Beginner",
            estimatedHours: 3,
            xp: 1000,
            skills: ["Structured data", "JSON", "Validation", "Human review"],
            outcomes: [
                "Explain free text versus a record with named fields",
                "Design a small schema with required and optional values",
                "Validate counts and missing fields before acceptance",
                "Route uncertain records to a person instead of inventing values"
            ],
            milestones: [
                .init(id: "schema", title: "Draw the record", detail: "Choose four fields, their types, and which must be present.", systemImage: "rectangle.3.group.fill"),
                .init(id: "extract", title: "Extract one message", detail: "Use labeled lines so every transformation is inspectable.", systemImage: "doc.text.magnifyingglass"),
                .init(id: "validate", title: "Reject bad values", detail: "Check missing names, impossible counts, and malformed dates.", systemImage: "checkmark.shield.fill"),
                .init(id: "review", title: "Add a review queue", detail: "Keep the original note beside records needing help.", systemImage: "person.crop.circle.badge.questionmark")
            ],
            brief: "A community center receives workshop registrations as short labeled messages. Build a local extractor for name, workshop, date, and attendee count. Clear messages become JSON; missing or invalid values must be marked for staff review rather than guessed.",
            starterFiles: [
                .init(name: "extract.py", language: "python", contents: "import json\ndef extract(message):\n    record = {}\n    for line in message.splitlines():\n        if \":\" in line:\n            key, value = line.split(\":\", 1)\n            record[key.strip().lower()] = value.strip()\n    return record\nprint(json.dumps(extract(\"Name: Ada\\nAttendees: 2\"), indent=2))\n"),
                .init(name: "validate.py", language: "python", contents: "REQUIRED = {\"name\", \"workshop\", \"date\", \"attendees\"}\ndef validate(record):\n    errors = [f\"missing {field}\" for field in REQUIRED - record.keys()]\n    if \"attendees\" in record and not record[\"attendees\"].isdigit(): errors.append(\"attendees must be a whole number\")\n    return errors\n")
            ]
        ),
        LabProject(
            id: "beginner-tiny-semantic-search",
            title: "Make a tiny meaning-based search",
            subtitle: "Words · Similarity · Ranking",
            summary: "Build an understandable search engine for ten notes and calculate similarity with counts and basic arithmetic.",
            icon: "magnifyingglass.circle.fill",
            accent: "58C9FF",
            difficulty: "Beginner",
            estimatedHours: 4,
            xp: 1050,
            skills: ["Search", "Tokenization", "Similarity", "Ranking"],
            outcomes: [
                "Represent a document as a set of useful lowercase words",
                "Calculate overlap similarity from shared and total unique words",
                "Rank documents and display each score beside its result",
                "Test vocabulary mismatch and explain why embeddings are a later improvement"
            ],
            milestones: [
                .init(id: "clean", title: "Clean the words", detail: "Lowercase text, remove punctuation, and ignore a short stop-word list.", systemImage: "textformat.abc.dottedunderline"),
                .init(id: "similarity", title: "Calculate similarity", detail: "Count shared and unique words with a paper example.", systemImage: "divide.circle.fill"),
                .init(id: "rank", title: "Sort the results", detail: "Return the three highest scores with note titles.", systemImage: "list.number"),
                .init(id: "test", title: "Find weak spots", detail: "Try synonyms, spelling mistakes, and an unrelated question.", systemImage: "ladybug.fill")
            ],
            brief: "A makerspace has ten short safety and equipment notes. Build a fully local search tool that ranks notes for a question, exposes every score, and returns 'no confident match' when word overlap is too small.",
            starterFiles: [
                .init(name: "search.py", language: "python", contents: "STOP = {\"a\", \"an\", \"and\", \"how\", \"is\", \"the\", \"to\"}\ndef tokens(text):\n    cleaned = \"\".join(c.lower() if c.isalnum() else \" \" for c in text)\n    return {word for word in cleaned.split() if word not in STOP}\ndef similarity(left, right):\n    a, b = tokens(left), tokens(right); union = a | b\n    return len(a & b) / len(union) if union else 0.0\n"),
                .init(name: "catalog.py", language: "python", contents: "from search import similarity\nNOTES = [{\"title\":\"Laser safety\",\"text\":\"Wear eye protection before using the laser cutter.\"},\n         {\"title\":\"Printer jam\",\"text\":\"Turn off the printer before clearing stuck filament.\"}]\ndef rank(query):\n    return sorted([(similarity(query,n[\"text\"]),n) for n in NOTES], key=lambda item:item[0], reverse=True)\n")
            ]
        ),
        LabProject(
            id: "beginner-first-chatbot",
            title: "Build your first safe chatbot",
            subtitle: "Conversation · State · Fallbacks",
            summary: "Create a small local FAQ chatbot that remembers one choice, explains its limits, and hands unknown questions to a person.",
            icon: "bubble.left.and.bubble.right.fill",
            accent: "8F80FF",
            difficulty: "Beginner",
            estimatedHours: 4,
            xp: 1050,
            skills: ["Chatbots", "Conversation state", "Fallback design", "Testing"],
            outcomes: [
                "Model a conversation as messages with user and assistant roles",
                "Answer a bounded FAQ from approved local content",
                "Remember one explicit preference without storing sensitive free text",
                "Use an honest fallback and escalation path for unsupported questions"
            ],
            milestones: [
                .init(id: "scope", title: "Choose five supported questions", detail: "Write approved answers and one clear limits sentence.", systemImage: "scope"),
                .init(id: "reply", title: "Match a question", detail: "Normalize the message and retrieve from the FAQ table.", systemImage: "bubble.left.fill"),
                .init(id: "memory", title: "Remember one preference", detail: "Store only the selected class level and allow clearing it.", systemImage: "memorychip.fill"),
                .init(id: "fallback", title: "Handle the unknown", detail: "Ask for clarification or show a human contact path.", systemImage: "person.crop.circle.badge.questionmark")
            ],
            brief: "An adult-learning center needs a helper for class times, locations, costs, accessibility, and enrollment. Build a local FAQ chatbot that remembers a learner's selected level for the session but never invents policy or pretends to be general purpose.",
            starterFiles: [
                .init(name: "chatbot.py", language: "python", contents: "FAQ = {\"cost\":\"Intro classes are free.\", \"location\":\"Classes meet in Room 4.\",\n       \"accessibility\":\"Room 4 has step-free access and a hearing loop.\"}\ndef reply(message):\n    for topic, answer in FAQ.items():\n        if topic in message.lower(): return answer\n    return \"I do not know that yet. Would you like the center contact details?\"\n"),
                .init(name: "conversation.py", language: "python", contents: "from chatbot import reply\ndef add_turn(history, role, text):\n    history.append({\"role\":role,\"text\":text}); return history[-10:]\nhistory=[]; question=\"Is the room accessible?\"\nadd_turn(history,\"user\",question); add_turn(history,\"assistant\",reply(question))\n")
            ]
        ),
        LabProject(
            id: "beginner-evaluation-kit",
            title: "Create a first AI scorecard",
            subtitle: "Test cases · Checks · Regression",
            summary: "Turn 'this answer looks good' into a tiny repeatable evaluation set with exact, readable checks.",
            icon: "checkmark.seal.fill",
            accent: "FFD068",
            difficulty: "Beginner",
            estimatedHours: 3,
            xp: 1000,
            skills: ["Evaluation", "Test cases", "Quality criteria", "Regression checks"],
            outcomes: [
                "Write cases with an input, expected behavior, and reason",
                "Use deterministic checks before a subjective rating",
                "Calculate a pass rate and keep individual failures visible",
                "Compare two versions without changing tests after seeing results"
            ],
            milestones: [
                .init(id: "cases", title: "Write ten test cases", detail: "Include normal, missing, unsafe, and wording-variation examples.", systemImage: "square.stack.3d.up.fill"),
                .init(id: "checks", title: "Add exact checks", detail: "Test required phrases, forbidden claims, length, and fields.", systemImage: "checklist"),
                .init(id: "run", title: "Run the scorecard", detail: "Count passes, print failures, and retain severe errors.", systemImage: "play.rectangle.fill"),
                .init(id: "compare", title: "Compare two versions", detail: "Report wins, losses, unchanged cases, and a recommendation.", systemImage: "arrow.left.arrow.right")
            ],
            brief: "A food-bank information helper answers from one approved guide. Build a ten-case scorecard checking opening hours, eligibility wording, unsupported questions, and emergency redirection so volunteers can compare answer versions before publishing.",
            starterFiles: [
                .init(name: "cases.py", language: "python", contents: "CASES = [\n {\"question\":\"When are you open?\",\"must_include\":[\"Tuesday\"],\"must_not_include\":[]},\n {\"question\":\"Can you guarantee help?\",\"must_include\":[],\"must_not_include\":[\"guarantee\"]},\n]\n"),
                .init(name: "score.py", language: "python", contents: "def check(answer, case):\n    text=answer.lower()\n    return all(x.lower() in text for x in case[\"must_include\"]) and all(x.lower() not in text for x in case[\"must_not_include\"])\ndef pass_rate(results): return sum(results)/len(results) if results else 0.0\n")
            ]
        ),
        LabProject(
            id: "beginner-image-inspector",
            title: "Teach a computer to inspect simple images",
            subtitle: "Pixels · Features · Thresholds",
            summary: "Use small grids of brightness values to understand how an image becomes numbers and how a simple visual rule makes mistakes.",
            icon: "photo.fill",
            accent: "48D7A8",
            difficulty: "Beginner",
            estimatedHours: 3,
            xp: 1000,
            skills: ["Image basics", "Pixels", "Feature extraction", "Thresholds"],
            outcomes: [
                "Explain a grayscale image as rows of numbers from dark to bright",
                "Calculate average brightness with addition and division",
                "Create a transparent threshold classifier for bright versus dark scenes",
                "Test lighting changes and explain why production vision needs better data"
            ],
            milestones: [
                .init(id: "pixels", title: "Read a pixel grid", detail: "Map zero to black, 255 to white, and middle values to gray.", systemImage: "square.grid.3x3.fill"),
                .init(id: "feature", title: "Average brightness", detail: "Add every value and divide by the number of pixels.", systemImage: "sun.max.fill"),
                .init(id: "classify", title: "Choose a threshold", detail: "Label examples and show the decision boundary.", systemImage: "slider.horizontal.3"),
                .init(id: "stress", title: "Change the lighting", detail: "Darken and brighten one scene and record failures.", systemImage: "sun.haze.fill")
            ],
            brief: "A school garden club wants a demonstration that sorts supplied thumbnail grids into daylight and nighttime. Build the simplest transparent image classifier, then show why brightness alone cannot identify weather, animals, or hazards.",
            starterFiles: [
                .init(name: "image_features.py", language: "python", contents: "def average_brightness(pixels):\n    values=[value for row in pixels for value in row]\n    return sum(values)/len(values) if values else 0.0\ndef classify_light(pixels, threshold=120):\n    return \"daylight\" if average_brightness(pixels)>=threshold else \"nighttime\"\n"),
                .init(name: "examples.py", language: "python", contents: "from image_features import *\nDAY=[[210,190],[180,220]]; NIGHT=[[20,35],[42,18]]\nassert classify_light(DAY)==\"daylight\"\nassert classify_light(NIGHT)==\"nighttime\"\nprint(\"day average\", average_brightness(DAY))\n")
            ]
        ),
        LabProject(
            id: "beginner-audio-detector",
            title: "Find a clap in a tiny audio signal",
            subtitle: "Waveforms · Amplitude · Events",
            summary: "Treat audio as a sequence of numbers, measure loudness, and detect a simple sound event without claiming to understand speech.",
            icon: "waveform",
            accent: "FF70A6",
            difficulty: "Beginner",
            estimatedHours: 3,
            xp: 1000,
            skills: ["Audio basics", "Waveforms", "Amplitude", "Event detection"],
            outcomes: [
                "Explain a waveform as sound-pressure samples measured over time",
                "Calculate peak and average absolute amplitude",
                "Detect a short loud event with a visible threshold and duration rule",
                "Test background noise and describe false positives and false negatives"
            ],
            milestones: [
                .init(id: "samples", title: "Read a waveform", detail: "Connect positive and negative sample magnitude with loudness.", systemImage: "waveform.path"),
                .init(id: "feature", title: "Measure amplitude", detail: "Use absolute values so both directions count together.", systemImage: "ruler.fill"),
                .init(id: "event", title: "Detect the clap", detail: "Require several loud samples instead of one noisy number.", systemImage: "hands.clap.fill"),
                .init(id: "noise", title: "Test noisy rooms", detail: "Adjust the threshold and document the trade-off.", systemImage: "speaker.wave.3.fill")
            ],
            brief: "A science teacher wants an offline demonstration that lights an indicator when students clap. Build it from supplied sample arrays, show measured amplitude, and explain why it must never be described as speech recognition or used for surveillance.",
            starterFiles: [
                .init(name: "audio_features.py", language: "python", contents: "def peak_amplitude(samples): return max((abs(x) for x in samples), default=0.0)\ndef average_amplitude(samples): return sum(abs(x) for x in samples)/len(samples) if samples else 0.0\ndef contains_clap(samples, threshold=.75, minimum=3): return sum(abs(x)>=threshold for x in samples)>=minimum\n"),
                .init(name: "test_signals.py", language: "python", contents: "from audio_features import contains_clap\nQUIET=[.02,-.04,.08,-.03]; CLAP=[.10,.82,-.91,.86,.20]; CLICK=[.01,.95,.03,-.02]\nassert not contains_clap(QUIET)\nassert contains_clap(CLAP)\nassert not contains_clap(CLICK)\n")
            ]
        ),
        LabProject(
            id: "beginner-recommendation-engine",
            title: "Recommend the next learning activity",
            subtitle: "Preferences · Similarity · Explanations",
            summary: "Build a small content-based recommender that matches learner interests to activity tags and explains every suggestion.",
            icon: "sparkles.rectangle.stack.fill",
            accent: "FFAA45",
            difficulty: "Beginner",
            estimatedHours: 4,
            xp: 1050,
            skills: ["Recommendations", "Sets", "Similarity", "Explainability"],
            outcomes: [
                "Represent interests and activities with small sets of descriptive tags",
                "Calculate a match score from shared tags divided by all unique tags",
                "Rank suggestions while filtering activities already completed",
                "Explain every suggestion and handle a learner with no interests"
            ],
            milestones: [
                .init(id: "tags", title: "Tag the activities", detail: "Choose factual topic and format tags without profiling.", systemImage: "tag.fill"),
                .init(id: "match", title: "Calculate the match", detail: "Count shared and total tags on paper before coding.", systemImage: "equal.circle.fill"),
                .init(id: "rank", title: "Return three choices", detail: "Sort scores, remove completed work, and preserve ties.", systemImage: "list.number"),
                .init(id: "explain", title: "Explain the reason", detail: "Show shared tags and a neutral fallback when none match.", systemImage: "lightbulb.fill")
            ],
            brief: "A youth coding club has twelve optional activities and wants suggestions from topics a learner explicitly selected. Build a transparent recommender that does not infer age, ability, or personality and always shows why an item was suggested.",
            starterFiles: [
                .init(name: "recommend.py", language: "python", contents: "def similarity(left,right):\n    union=left|right; return len(left&right)/len(union) if union else 0.0\ndef recommend(interests, activities, completed):\n    candidates=[(similarity(interests,set(a[\"tags\"])),a) for a in activities if a[\"id\"] not in completed]\n    return sorted(candidates,key=lambda item:(-item[0],item[1][\"title\"]))[:3]\n"),
                .init(name: "activities.py", language: "python", contents: "ACTIVITIES=[\n {\"id\":\"story\",\"title\":\"Interactive story\",\"tags\":[\"python\",\"creative\",\"text\"]},\n {\"id\":\"weather\",\"title\":\"Weather chart\",\"tags\":[\"python\",\"data\",\"visual\"]},\n {\"id\":\"robot\",\"title\":\"Robot route\",\"tags\":[\"logic\",\"hardware\",\"visual\"]},\n]\n")
            ]
        ),
        LabProject(
            id: "beginner-ai-api",
            title: "Wrap a small AI helper in an API",
            subtitle: "Requests · JSON · Validation",
            summary: "Expose a tiny local text classifier through a standard-library HTTP endpoint with clear inputs, outputs, errors, and health checks.",
            icon: "network",
            accent: "66B5FF",
            difficulty: "Beginner",
            estimatedHours: 4,
            xp: 1100,
            skills: ["APIs", "HTTP basics", "JSON", "Input validation", "Error handling"],
            outcomes: [
                "Explain an API request and response with an everyday order-slip analogy",
                "Accept JSON containing one documented text field and return a stable shape",
                "Validate empty, malformed, and oversized inputs before classification",
                "Add health and version information so another program can use it safely"
            ],
            milestones: [
                .init(id: "contract", title: "Draw the API contract", detail: "Write one request, one response, and three errors.", systemImage: "doc.text.fill"),
                .init(id: "handler", title: "Handle one request", detail: "Decode JSON, validate text, call the helper, and encode a response.", systemImage: "arrow.left.arrow.right.square.fill"),
                .init(id: "errors", title: "Make errors useful", detail: "Return stable status codes without stack traces.", systemImage: "exclamationmark.triangle.fill"),
                .init(id: "test", title: "Test the boundary", detail: "Check health, valid input, missing text, bad JSON, and long input.", systemImage: "checkmark.rectangle.stack.fill")
            ],
            brief: "A school help-desk has a local rules classifier for account, device, or unknown. Turn it into a tiny localhost API that another classroom program can call. It must require no cloud service, reject bad input, and make its limitations clear.",
            starterFiles: [
                .init(name: "model.py", language: "python", contents: "def classify(text):\n    lowered=text.lower()\n    if any(w in lowered for w in [\"password\",\"login\",\"account\"]): return {\"label\":\"account\"}\n    if any(w in lowered for w in [\"laptop\",\"screen\",\"keyboard\"]): return {\"label\":\"device\"}\n    return {\"label\":\"unknown\"}\n"),
                .init(name: "server.py", language: "python", contents: "import json\nfrom http.server import BaseHTTPRequestHandler, HTTPServer\nfrom model import classify\nclass Handler(BaseHTTPRequestHandler):\n    def do_GET(self): self.respond(200,{\"status\":\"ok\",\"version\":\"1\"}) if self.path==\"/health\" else self.respond(404,{\"error\":\"not found\"})\n    def respond(self,status,body):\n        data=json.dumps(body).encode(); self.send_response(status); self.send_header(\"Content-Type\",\"application/json\")\n        self.send_header(\"Content-Length\",str(len(data))); self.end_headers(); self.wfile.write(data)\n# Add validated POST /classify, then bind to 127.0.0.1.\n")
            ]
        ),
        LabProject(
            id: "edge-inference-optimizer",
            title: "Optimize an edge inference stack",
            subtitle: "Quantization · Batching · Profiling",
            summary: "Fit a useful language model into strict memory, latency, and energy budgets while measuring every quality trade-off.",
            icon: "cpu.fill",
            accent: "5AC8FA",
            difficulty: "Intermediate",
            estimatedHours: 8,
            xp: 2_400,
            skills: ["Inference optimization", "Quantization", "Profiling", "KV caching", "Quality evaluation"],
            outcomes: [
                "Build a repeatable baseline for latency, memory, energy, and quality",
                "Choose quantization precision by layer sensitivity rather than guesswork",
                "Improve prefill and decode performance with caching and batching",
                "Reject optimizations whose quality loss exceeds the product budget"
            ],
            milestones: [
                .init(id: "baseline", title: "Profile the baseline", detail: "Separate load, prefill, first-token, decode, and peak-memory costs.", systemImage: "stopwatch.fill"),
                .init(id: "compress", title: "Compress the model", detail: "Compare precision schemes on difficult evaluation slices.", systemImage: "arrow.down.right.and.arrow.up.left.square.fill"),
                .init(id: "runtime", title: "Tune the runtime", detail: "Reuse caches, bound concurrency, and avoid unnecessary copies.", systemImage: "memorychip.fill"),
                .init(id: "budget", title: "Enforce the budget", detail: "Ship automated gates for quality, p95 latency, memory, and thermal load.", systemImage: "speedometer")
            ],
            brief: "A field-service app must summarize equipment notes on a fanless laptop with 8 GB of shared memory. It must work offline, produce its first token within 700 ms, and retain at least 97% of the reference model's task score.",
            starterFiles: [
                .init(name: "profile.py", language: "python", contents: """
from dataclasses import dataclass
from time import perf_counter
import tracemalloc

@dataclass
class InferenceMetrics:
    load_ms: float
    first_token_ms: float
    tokens_per_second: float
    peak_memory_mb: float
    quality_score: float

def profile(model, prompts: list[str]) -> InferenceMetrics:
    tracemalloc.start()
    started = perf_counter()
    # Measure load separately, synchronize the backend, then sample generation.
    raise NotImplementedError
"""),
                .init(name: "tradeoffs.py", language: "python", contents: """
def acceptable(candidate: dict, baseline: dict) -> bool:
    retained_quality = candidate["quality"] / baseline["quality"]
    return (
        retained_quality >= 0.97
        and candidate["p95_first_token_ms"] <= 700
        and candidate["peak_memory_mb"] <= 5500
    )
""")
            ]
        ),
        LabProject(
            id: "ai-observability-control-plane",
            title: "Build an AI observability control plane",
            subtitle: "Traces · Quality signals · Cost",
            summary: "Make an AI service operable by connecting request traces, user outcomes, token spend, and model quality without logging sensitive content.",
            icon: "waveform.path.ecg.rectangle.fill",
            accent: "34C759",
            difficulty: "Intermediate",
            estimatedHours: 7,
            xp: 2_100,
            skills: ["Observability", "Cost engineering", "Tracing", "SLOs", "Privacy"],
            outcomes: [
                "Define service-level indicators for stochastic AI behavior",
                "Trace retrieval, model, tool, and validation stages end to end",
                "Attribute spend to features and tenants with privacy-safe metadata",
                "Detect quality drift before aggregate success metrics collapse"
            ],
            milestones: [
                .init(id: "schema", title: "Design trace semantics", detail: "Standardize spans, error classes, token counts, and redaction rules.", systemImage: "point.3.connected.trianglepath.dotted"),
                .init(id: "slos", title: "Set useful SLOs", detail: "Combine availability and latency with groundedness and task success.", systemImage: "gauge.with.dots.needle.50percent"),
                .init(id: "cost", title: "Control unit economics", detail: "Allocate cost per workflow and identify wasteful retries or context.", systemImage: "dollarsign.arrow.circlepath"),
                .init(id: "respond", title: "Close the loop", detail: "Route alerts to playbooks and capture examples for evaluation.", systemImage: "bell.and.waves.left.and.right.fill")
            ],
            brief: "A marketplace's AI listing assistant serves 40 product teams, but the platform group cannot explain a sudden 35% cost increase or which workflows are silently degrading. Build the telemetry and budgets needed to operate it without retaining customer prompts.",
            starterFiles: [
                .init(name: "telemetry.py", language: "python", contents: """
from contextlib import contextmanager
from dataclasses import dataclass, field
from time import perf_counter

@dataclass
class Span:
    name: str
    attributes: dict[str, str | int | float] = field(default_factory=dict)

@contextmanager
def trace_stage(name: str, safe_attributes: dict):
    started = perf_counter()
    span = Span(name, safe_attributes.copy())
    try:
        yield span
    finally:
        span.attributes["duration_ms"] = (perf_counter() - started) * 1000
        export(span)

def export(span: Span) -> None:
    # Reject raw prompt, response, credential, and personal-data fields.
    raise NotImplementedError
"""),
                .init(name: "budgets.py", language: "python", contents: """
def projected_monthly_cost(events: list[dict]) -> dict[str, float]:
    totals: dict[str, float] = {}
    for event in events:
        feature = event["feature"]
        totals[feature] = totals.get(feature, 0.0) + event["estimated_cost"]
    return totals

def detect_budget_anomalies(current: dict, baseline: dict) -> list[str]:
    # Account for traffic before alerting on spend growth.
    raise NotImplementedError
""")
            ]
        ),
        LabProject(
            id: "realtime-voice-coach",
            title: "Create a realtime voice coach",
            subtitle: "Streaming audio · Turn taking · Offline fallback",
            summary: "Build a low-latency voice tutor that handles interruptions, weak connectivity, and sensitive conversations with graceful local fallbacks.",
            icon: "waveform.circle.fill",
            accent: "FF2D95",
            difficulty: "Intermediate",
            estimatedHours: 7,
            xp: 2_000,
            skills: ["Speech recognition", "Streaming", "Voice activity detection", "Turn taking", "Accessibility"],
            outcomes: [
                "Design a streaming audio pipeline with bounded buffers and backpressure",
                "Implement barge-in without speaking over or losing the learner",
                "Separate transcript confidence from answer confidence",
                "Fall back to local transcription and text when realtime service fails"
            ],
            milestones: [
                .init(id: "audio", title: "Stream the audio", detail: "Frame, buffer, and timestamp audio without blocking interaction.", systemImage: "waveform.badge.microphone"),
                .init(id: "turns", title: "Manage turns", detail: "Use voice activity and partial transcripts to detect starts, stops, and interruptions.", systemImage: "arrow.left.and.right.circle.fill"),
                .init(id: "latency", title: "Shape perceived latency", detail: "Acknowledge quickly while preserving an interruptible response plan.", systemImage: "bolt.horizontal.circle.fill"),
                .init(id: "fallback", title: "Survive degraded mode", detail: "Switch to private on-device transcription and queued text responses.", systemImage: "wifi.slash")
            ],
            brief: "An apprenticeship program needs a hands-free coaching mode for trainees repairing equipment. The coach must understand short questions in a noisy workshop, stop immediately when interrupted, and continue in a private offline text mode when connectivity disappears.",
            starterFiles: [
                .init(name: "turn_manager.py", language: "python", contents: """
from dataclasses import dataclass
from enum import Enum

class TurnState(Enum):
    LISTENING = "listening"
    THINKING = "thinking"
    SPEAKING = "speaking"
    INTERRUPTED = "interrupted"

@dataclass
class AudioEvent:
    timestamp_ms: int
    speech_probability: float
    partial_text: str = ""

def transition(state: TurnState, event: AudioEvent) -> TurnState:
    # Add hysteresis so workshop noise does not flap the state machine.
    raise NotImplementedError
"""),
                .init(name: "latency_budget.py", language: "python", contents: """
LATENCY_BUDGET_MS = {
    "capture_chunk": 40,
    "partial_transcript": 180,
    "first_response_audio": 700,
    "interrupt_stop": 120,
}

def remaining_budget(stage: str, elapsed_ms: float) -> float:
    return max(0.0, LATENCY_BUDGET_MS[stage] - elapsed_ms)
""")
            ]
        ),
        LabProject(
            id: "two-stage-recommender",
            title: "Ship a two-stage recommender",
            subtitle: "Candidate retrieval · Ranking · Feedback",
            summary: "Build a responsible recommendation system that retrieves broadly, ranks for user value, and evaluates beyond click-through rate.",
            icon: "sparkles.square.filled.on.square",
            accent: "FF9F0A",
            difficulty: "Intermediate",
            estimatedHours: 8,
            xp: 2_300,
            skills: ["Recommendation systems", "Embeddings", "Ranking", "Offline evaluation", "Experiment design"],
            outcomes: [
                "Generate diverse candidates under a strict latency budget",
                "Train a ranker without leaking future behavior into features",
                "Balance relevance with novelty, coverage, and creator fairness",
                "Design online experiments with guardrail and long-term metrics"
            ],
            milestones: [
                .init(id: "candidates", title: "Retrieve candidates", detail: "Blend collaborative, semantic, popular, and exploration sources.", systemImage: "rectangle.stack.badge.plus"),
                .init(id: "rank", title: "Train the ranker", detail: "Build time-safe features and correct for exposure bias.", systemImage: "list.number.rtl"),
                .init(id: "rerank", title: "Apply product constraints", detail: "Increase diversity and coverage without hiding the objective.", systemImage: "shuffle.circle.fill"),
                .init(id: "experiment", title: "Plan the experiment", detail: "Track satisfaction and retention alongside clicks and safety.", systemImage: "flask.fill")
            ],
            brief: "A learning platform wants to recommend the next AI-engineering lesson to each learner. Build a system that considers mastery and goals, avoids a popularity feedback loop, gives new courses a fair chance, and never optimizes engagement at the expense of learning progress.",
            starterFiles: [
                .init(name: "candidates.py", language: "python", contents: """
from dataclasses import dataclass

@dataclass(frozen=True)
class Candidate:
    item_id: str
    source: str
    retrieval_score: float

def merge_candidates(sources: list[list[Candidate]], per_source: int = 50) -> list[Candidate]:
    best: dict[str, Candidate] = {}
    for source in sources:
        for item in source[:per_source]:
            if item.item_id not in best or item.retrieval_score > best[item.item_id].retrieval_score:
                best[item.item_id] = item
    return list(best.values())
"""),
                .init(name: "rerank.py", language: "python", contents: """
def constrained_rerank(scored_items: list[dict], limit: int = 10) -> list[dict]:
    selected = []
    represented_topics: set[str] = set()
    for item in sorted(scored_items, key=lambda row: row["score"], reverse=True):
        diversity_bonus = 0.08 if item["topic"] not in represented_topics else 0.0
        item["final_score"] = item["score"] + diversity_bonus
        selected.append(item)
        represented_topics.add(item["topic"])
        if len(selected) == limit:
            break
    return sorted(selected, key=lambda row: row["final_score"], reverse=True)
""")
            ]
        ),
        LabProject(
            id: "ai-safety-review",
            title: "Lead an AI launch safety review",
            subtitle: "Hazard analysis · Controls · Residual risk",
            summary: "Turn a vague request for 'safe AI' into a rigorous launch case with hazards, measurable controls, evidence, and accountable sign-off.",
            icon: "checkmark.shield.fill",
            accent: "30D158",
            difficulty: "Intermediate",
            estimatedHours: 6,
            xp: 1_900,
            skills: ["AI safety", "Risk assessment", "Control design", "Assurance cases", "Governance"],
            outcomes: [
                "Identify hazards from users, models, tools, data, and operating context",
                "Prioritize risks by severity, likelihood, exposure, and detectability",
                "Connect each claimed mitigation to testable evidence and an owner",
                "Write a conditional launch decision with residual risks and kill criteria"
            ],
            milestones: [
                .init(id: "context", title: "Bound the use case", detail: "Document intended users, prohibited uses, autonomy, and affected parties.", systemImage: "scope"),
                .init(id: "hazards", title: "Analyze hazards", detail: "Trace credible failure chains instead of listing generic model weaknesses.", systemImage: "exclamationmark.triangle.fill"),
                .init(id: "controls", title: "Verify controls", detail: "Test prevention, detection, response, and recovery layers independently.", systemImage: "shield.checkered"),
                .init(id: "decision", title: "Make the launch case", detail: "State accepted risk, named owners, monitoring, and automatic stop conditions.", systemImage: "signature")
            ],
            brief: "A regional bank wants to launch an assistant that drafts explanations for declined loan applications. Conduct the pre-launch review: surface fairness, privacy, hallucination, automation-bias, and appeals risks, then define what evidence is required before any employee can use it.",
            starterFiles: [
                .init(name: "risk_register.py", language: "python", contents: """
from dataclasses import dataclass

@dataclass
class Hazard:
    hazard_id: str
    affected_party: str
    failure: str
    severity: int
    likelihood: int
    controls: list[str]
    owner: str

def risk_score(hazard: Hazard) -> int:
    return hazard.severity * hazard.likelihood

def missing_assurance(hazards: list[Hazard], evidence_by_control: dict[str, list[str]]) -> list[str]:
    return [
        control
        for hazard in hazards
        for control in hazard.controls
        if not evidence_by_control.get(control)
    ]
"""),
                .init(name: "launch_gate.py", language: "python", contents: """
BLOCKING_CONDITIONS = {
    "material demographic quality gap",
    "untraceable adverse-action reason",
    "missing human appeal path",
    "sensitive data in model logs",
}

def launch_decision(findings: list[dict]) -> tuple[bool, list[str]]:
    blockers = [item["finding"] for item in findings if item["finding"] in BLOCKING_CONDITIONS]
    return not blockers, blockers
""")
            ]
        ),
        LabProject(
            id: "distributed-model-serving",
            title: "Engineer distributed model serving",
            subtitle: "Scheduling · Backpressure · Resilience",
            summary: "Design a multi-node inference service that stays predictable under bursty load, partial failure, and rolling model upgrades.",
            icon: "server.rack",
            accent: "64D2FF",
            difficulty: "Intermediate",
            estimatedHours: 10,
            xp: 2_500,
            skills: ["Distributed systems", "Model serving", "Load shedding", "Continuous batching", "Capacity planning", "Rollouts"],
            outcomes: [
                "Model capacity from prefill, decode, memory, and request-shape distributions",
                "Schedule heterogeneous requests without starving short interactive work",
                "Apply bounded queues, admission control, and graceful degradation",
                "Roll model versions safely with shadow traffic and rapid rollback"
            ],
            milestones: [
                .init(id: "capacity", title: "Model capacity", detail: "Estimate throughput and KV-cache pressure from real request shapes.", systemImage: "chart.line.uptrend.xyaxis"),
                .init(id: "schedule", title: "Build the scheduler", detail: "Batch compatible work while honoring priority and latency budgets.", systemImage: "calendar.badge.clock"),
                .init(id: "overload", title: "Survive overload", detail: "Reject early, shed optional work, and preserve critical capacity.", systemImage: "arrow.down.to.line.compact"),
                .init(id: "rollout", title: "Roll out safely", detail: "Warm replicas, shadow requests, compare signals, and automate rollback.", systemImage: "arrow.triangle.2.circlepath.circle.fill")
            ],
            brief: "A collaborative coding product expects tenfold traffic during a conference launch. Its 8-billion-parameter model runs across mixed accelerators, interactive completions require sub-second first-token latency, and background indexing can wait. Design the serving plane and demonstrate its behavior during a replica loss.",
            starterFiles: [
                .init(name: "scheduler.py", language: "python", contents: """
from dataclasses import dataclass, field
import heapq

@dataclass(order=True)
class Request:
    sort_key: tuple = field(init=False, repr=False)
    priority: int
    deadline_ms: int
    request_id: str
    prompt_tokens: int
    max_new_tokens: int

    def __post_init__(self):
        self.sort_key = (-self.priority, self.deadline_ms)

def form_batch(queue: list[Request], token_budget: int) -> list[Request]:
    chosen, used = [], 0
    while queue:
        request = heapq.heappop(queue)
        projected = request.prompt_tokens + request.max_new_tokens
        if used + projected <= token_budget:
            chosen.append(request)
            used += projected
    return chosen
"""),
                .init(name: "admission.py", language: "python", contents: """
def admit(request: dict, state: dict) -> tuple[bool, str]:
    if state["queue_delay_ms"] > request["latency_budget_ms"]:
        return False, "deadline cannot be met"
    if state["kv_cache_fraction"] > 0.92 and request["priority"] < 2:
        return False, "capacity reserved for critical traffic"
    return True, "admitted"
""")
            ]
        ),
        LabProject(
            id: "enterprise-ai-platform-architecture",
            title: "Architect an enterprise AI platform",
            subtitle: "Platform strategy · Tenancy · Governance",
            summary: "Produce a staff-level architecture that lets many teams ship AI products safely without centralizing every product decision.",
            icon: "building.2.crop.circle.fill",
            accent: "BF5AF2",
            difficulty: "Intermediate",
            estimatedHours: 12,
            xp: 2_500,
            skills: ["Platform architecture", "Multi-tenancy", "Security", "Build versus buy", "Migration strategy", "Technical leadership"],
            outcomes: [
                "Define a platform boundary from recurring product-team pain",
                "Design tenant isolation, identity, data controls, and regional routing",
                "Standardize evaluation and observability while preserving team autonomy",
                "Sequence a migration with ownership, adoption metrics, and exit criteria"
            ],
            milestones: [
                .init(id: "strategy", title: "Write the platform thesis", detail: "Name customers, paved-road capabilities, non-goals, and success metrics.", systemImage: "map.circle.fill"),
                .init(id: "architecture", title: "Design the control plane", detail: "Separate policy, registry, routing, evaluation, and runtime responsibilities.", systemImage: "square.3.layers.3d.down.right"),
                .init(id: "decisions", title: "Record hard decisions", detail: "Compare build, buy, and federated options against explicit constraints.", systemImage: "arrow.triangle.branch"),
                .init(id: "migration", title: "Plan adoption", detail: "Deliver thin vertical slices, migrate willing teams, and measure paved-road pull.", systemImage: "figure.walk.motion")
            ],
            brief: "A multinational manufacturer has 28 AI initiatives using different vendors, logging rules, and data paths. Design a platform that supports on-device, private-cloud, and hosted models across three regulatory regions while giving product teams a fast path and security teams enforceable controls.",
            starterFiles: [
                .init(name: "architecture.md", language: "markdown", contents: """
# Enterprise AI platform decision

## Context and forces
- Product teams need a supported path from prototype to production.
- Data residency, auditability, and tenant isolation are mandatory.
- The platform must not force every workload onto one model provider.

## Decision
Describe the control plane, runtime plane, trust boundaries, and ownership model.

## Alternatives
Compare centralized gateway, federated libraries, and managed platform options.

## Consequences and reassessment triggers
List new failure modes, operating costs, migration risks, and exit criteria.
"""),
                .init(name: "policy_router.py", language: "python", contents: """
from dataclasses import dataclass

@dataclass(frozen=True)
class Workload:
    tenant: str
    region: str
    data_classification: str
    required_capabilities: frozenset[str]
    latency_budget_ms: int

def eligible_runtimes(workload: Workload, registry: list[dict]) -> list[dict]:
    return [
        runtime for runtime in registry
        if workload.region in runtime["regions"]
        and workload.data_classification in runtime["allowed_data"]
        and workload.required_capabilities <= set(runtime["capabilities"])
    ]
""")
            ]
        ),
        LabProject(
            id: "learning-feedback-flywheel",
            title: "Design a trustworthy feedback flywheel",
            subtitle: "Signals · Active learning · Continuous improvement",
            summary: "Convert product feedback into privacy-aware evaluation and training improvements without optimizing noisy thumbs-up counts.",
            icon: "arrow.triangle.2.circlepath.circle.fill",
            accent: "32D7C4",
            difficulty: "Intermediate",
            estimatedHours: 7,
            xp: 2_100,
            skills: ["Data flywheels", "Active learning", "Feedback quality", "Experimentation", "Data governance"],
            outcomes: [
                "Separate behavioral outcomes, explicit ratings, and expert labels",
                "Sample informative failures without overrepresenting angry power users",
                "Promote feedback into evaluation before considering it for training",
                "Measure whether each iteration improves users rather than only proxies"
            ],
            milestones: [
                .init(id: "signals", title: "Map feedback signals", detail: "Document meaning, bias, consent, latency, and manipulability for each signal.", systemImage: "dot.radiowaves.left.and.right"),
                .init(id: "sample", title: "Prioritize review", detail: "Combine uncertainty, impact, novelty, and slice coverage for labeling.", systemImage: "line.3.horizontal.decrease.circle.fill"),
                .init(id: "promote", title: "Build promotion gates", detail: "Require consent, redaction, adjudication, and split protection.", systemImage: "arrow.up.forward.square.fill"),
                .init(id: "iterate", title: "Close the experiment loop", detail: "Trace a change from feedback cohort to eval win to user outcome.", systemImage: "chart.dots.scatter")
            ],
            brief: "An AI writing coach has millions of interactions but cannot tell whether a rewrite was useful: users edit, copy, dismiss, rate, and sometimes abandon. Design a flywheel that finds high-value failure modes, protects private writing, and proves that prompt, retrieval, or model changes actually help.",
            starterFiles: [
                .init(name: "feedback.py", language: "python", contents: """
from dataclasses import dataclass

@dataclass
class FeedbackSignal:
    interaction_id: str
    signal_type: str
    value: float
    user_consented: bool
    product_slice: str
    model_uncertainty: float
    impact: float

def review_priority(signal: FeedbackSignal, slice_rarity: float) -> float:
    if not signal.user_consented:
        return 0.0
    return 0.4 * signal.model_uncertainty + 0.4 * signal.impact + 0.2 * slice_rarity
"""),
                .init(name: "promotion.py", language: "python", contents: """
REQUIRED_APPROVALS = {"privacy_review", "label_adjudication", "split_leakage_check"}

def promotable(example: dict) -> tuple[bool, list[str]]:
    completed = set(example.get("approvals", []))
    missing = sorted(REQUIRED_APPROVALS - completed)
    safe = example.get("consented", False) and not example.get("contains_sensitive_data", True)
    return safe and not missing, missing
""")
            ]
        ),
        LabProject(
            id: "swift-on-device-tutor",
            title: "Ship a native on-device tutor",
            subtitle: "Swift · Foundation Models · Local retrieval",
            summary: "Build a production-quality Swift tutor that retrieves bundled lessons, teaches adaptively, and remains useful on devices without Apple Intelligence.",
            icon: "swift",
            accent: "FF6B4A",
            difficulty: "Intermediate",
            estimatedHours: 10,
            xp: 2_600,
            skills: ["Swift concurrency", "Foundation Models", "Local retrieval", "SwiftUI", "Privacy engineering"],
            outcomes: [
                "Abstract generative, retrieval-only, and unavailable states behind one testable tutor interface",
                "Build a local lesson index with deterministic relevance and source provenance",
                "Manage conversation sessions, cancellation, and context limits without stale responses",
                "Prove that default and fallback modes never initiate a network request"
            ],
            milestones: [
                .init(id: "contract", title: "Define the tutor contract", detail: "Model engine capabilities, availability, cancellation, answers, and verified sources.", systemImage: "curlybraces.square.fill"),
                .init(id: "retrieval", title: "Index lessons locally", detail: "Precompute normalized fields and return evidence only above a relevance threshold.", systemImage: "text.magnifyingglass"),
                .init(id: "session", title: "Manage on-device sessions", detail: "Scope model state to a conversation and rebuild cleanly after context exhaustion.", systemImage: "bubble.left.and.bubble.right.fill"),
                .init(id: "prove", title: "Prove offline behavior", detail: "Use injected transports and integration tests to fail on any unexpected network access.", systemImage: "network.slash")
            ],
            brief: "A vocational school is issuing iPads to apprentices who often work underground with no connectivity. Deliver a native tutor that explains AI-engineering lessons from first principles, uses Apple’s on-device model when available, and provides a useful cited fallback on every supported device.",
            starterFiles: [
                .init(name: "TutorEngine.swift", language: "swift", contents: """
import Foundation

struct TutorEvidence: Sendable {
    let sourceID: String
    let title: String
    let excerpt: String
}

struct TutorReply: Sendable {
    let text: String
    let evidence: [TutorEvidence]
}

protocol TutorEngine: Sendable {
    var isAvailable: Bool { get async }
    func answer(_ question: String, evidence: [TutorEvidence]) async throws -> TutorReply
    func reset() async
}
"""),
                .init(name: "TutorCoordinator.swift", language: "swift", contents: """
import Foundation

actor TutorCoordinator {
    private var generation = UUID()
    private var inFlight: Task<TutorReply, Error>?

    func beginNewConversation() {
        inFlight?.cancel()
        inFlight = nil
        generation = UUID()
    }

    func send(_ question: String, using engine: any TutorEngine) async throws -> TutorReply {
        let requestGeneration = generation
        let task = Task { try await engine.answer(question, evidence: []) }
        inFlight = task
        let reply = try await task.value
        guard requestGeneration == generation else { throw CancellationError() }
        return reply
    }
}
""")
            ]
        ),
        LabProject(
            id: "knowledge-graph-rag",
            title: "Engineer knowledge-graph RAG",
            subtitle: "Entities · Claims · Graph traversal",
            summary: "Answer multi-hop enterprise questions by combining vector retrieval with a temporal knowledge graph and claim-level provenance.",
            icon: "circle.hexagongrid.fill",
            accent: "8E7CFF",
            difficulty: "Intermediate",
            estimatedHours: 11,
            xp: 2_900,
            skills: ["Knowledge graphs", "Graph retrieval", "Entity resolution", "RAG", "Temporal reasoning", "Provenance"],
            outcomes: [
                "Extract canonical entities, typed relations, claims, and validity intervals from source documents",
                "Resolve ambiguous names without merging distinct people, services, or products",
                "Plan hybrid retrieval across semantic passages and bounded graph traversals",
                "Generate answers whose multi-hop claims retain document and edge-level provenance"
            ],
            milestones: [
                .init(id: "ontology", title: "Design the ontology", detail: "Define entities, relation semantics, claim confidence, time, and source ownership.", systemImage: "square.grid.3x3.topleft.filled"),
                .init(id: "resolve", title: "Resolve identities", detail: "Combine deterministic keys and scored candidates with a review path for ambiguity.", systemImage: "person.2.badge.gearshape.fill"),
                .init(id: "retrieve", title: "Plan hybrid retrieval", detail: "Seed from semantic search, traverse only allowed relations, then rerank evidence paths.", systemImage: "point.3.connected.trianglepath.dotted"),
                .init(id: "verify", title: "Verify every hop", detail: "Reject answers when a path is stale, contradictory, unauthorized, or unsupported.", systemImage: "checkmark.seal.text.page.fill")
            ],
            brief: "An aerospace manufacturer needs engineers to ask, 'Which flight-control components are affected by suppliers linked to the revised alloy specification?' The evidence spans contracts, parts catalogs, change notices, and test reports. Build a temporal graph-RAG system that can show every hop behind its answer.",
            starterFiles: [
                .init(name: "graph_model.py", language: "python", contents: """
from dataclasses import dataclass
from datetime import datetime

@dataclass(frozen=True)
class ClaimEdge:
    subject_id: str
    relation: str
    object_id: str
    valid_from: datetime
    valid_to: datetime | None
    source_id: str
    confidence: float

def active_at(edge: ClaimEdge, when: datetime) -> bool:
    return edge.valid_from <= when and (edge.valid_to is None or when < edge.valid_to)
"""),
                .init(name: "hybrid_retrieval.py", language: "python", contents: """
from collections import deque

def bounded_paths(seed_ids: set[str], adjacency: dict, allowed_relations: set[str], max_hops: int = 3):
    queue = deque((seed, []) for seed in seed_ids)
    seen = {(seed, 0) for seed in seed_ids}
    while queue:
        node, path = queue.popleft()
        if path:
            yield path
        if len(path) == max_hops:
            continue
        for edge in adjacency.get(node, []):
            if edge.relation not in allowed_relations:
                continue
            state = (edge.object_id, len(path) + 1)
            if state not in seen:
                seen.add(state)
                queue.append((edge.object_id, path + [edge]))
""")
            ]
        ),
        LabProject(
            id: "incident-command-agents",
            title: "Command incidents with agent teams",
            subtitle: "Agent roles · Evidence ledger · Human command",
            summary: "Coordinate specialized agents during a live service incident while keeping one human incident commander in control of consequential actions.",
            icon: "exclamationmark.arrow.triangle.2.circlepath",
            accent: "FF5A67",
            difficulty: "Intermediate",
            estimatedHours: 10,
            xp: 2_800,
            skills: ["Multi-agent systems", "Incident response", "Event sourcing", "Tool safety", "Distributed systems"],
            outcomes: [
                "Assign investigation, mitigation, communication, and challenge roles with non-overlapping authority",
                "Maintain an append-only evidence ledger that separates observations, hypotheses, and actions",
                "Schedule parallel investigation under time, tool, and blast-radius budgets",
                "Require human approval for mitigations and produce a replayable incident timeline"
            ],
            milestones: [
                .init(id: "roles", title: "Bound the responders", detail: "Give each agent a narrow mission, read scope, action scope, and stop condition.", systemImage: "person.3.fill"),
                .init(id: "ledger", title: "Build the evidence ledger", detail: "Record sourced facts, confidence, contradictions, decisions, and idempotency keys.", systemImage: "books.vertical.fill"),
                .init(id: "coordinate", title: "Coordinate under pressure", detail: "Prioritize independent checks and prevent duplicate or conflicting tool actions.", systemImage: "arrow.triangle.branch"),
                .init(id: "exercise", title: "Run a game day", detail: "Inject misleading signals, replica loss, and a failed mitigation, then audit recovery.", systemImage: "figure.run.circle.fill")
            ],
            brief: "A payments company loses authorization traffic during its busiest hour. Logs suggest a database issue, metrics suggest a regional network fault, and a recent model-serving rollout may be consuming shared capacity. Build an agent incident team that accelerates diagnosis without allowing autonomous rollback, customer messaging, or data mutation.",
            starterFiles: [
                .init(name: "ledger.py", language: "python", contents: """
from dataclasses import dataclass, field
from datetime import datetime, timezone
from enum import Enum

class EntryKind(Enum):
    OBSERVATION = "observation"
    HYPOTHESIS = "hypothesis"
    DECISION = "decision"
    ACTION = "action"

@dataclass(frozen=True)
class LedgerEntry:
    entry_id: str
    kind: EntryKind
    author: str
    statement: str
    evidence_ids: tuple[str, ...] = ()
    confidence: float | None = None
    created_at: datetime = field(default_factory=lambda: datetime.now(timezone.utc))
"""),
                .init(name: "command.py", language: "python", contents: """
CONSEQUENTIAL_TOOLS = {"rollback", "failover_region", "disable_payments", "publish_status"}

def authorize_tool(agent_role: str, tool: str, human_approval: str | None) -> bool:
    if tool in CONSEQUENTIAL_TOOLS:
        return bool(human_approval)
    return agent_role in {"investigator", "operations", "commander"}

def choose_next_tasks(open_hypotheses: list[dict], active_tools: set[str]) -> list[dict]:
    # Maximize information gain while avoiding shared dependencies and duplicate actions.
    raise NotImplementedError
""")
            ]
        ),
        LabProject(
            id: "realtime-voice-support-desk",
            title: "Build a realtime voice support desk",
            subtitle: "Duplex audio · Agent assist · Compliance",
            summary: "Create a live support copilot that transcribes, retrieves policy, suggests responses, and survives interruption without speaking over the customer.",
            icon: "headset",
            accent: "FF3B9D",
            difficulty: "Intermediate",
            estimatedHours: 9,
            xp: 2_500,
            skills: ["Realtime audio", "Streaming ASR", "Turn detection", "RAG", "PII redaction", "Latency engineering"],
            outcomes: [
                "Stream duplex audio through bounded queues with timestamps and backpressure",
                "Handle overlapping speech, corrections, and barge-in as explicit turn-state transitions",
                "Retrieve policy from stable transcript segments while redacting sensitive identifiers",
                "Measure end-to-end latency, interruption accuracy, suggestion quality, and agent adoption"
            ],
            milestones: [
                .init(id: "stream", title: "Build the media pipeline", detail: "Frame audio, align partial transcripts, and prevent slow consumers from growing memory.", systemImage: "waveform.badge.microphone"),
                .init(id: "turns", title: "Resolve conversation turns", detail: "Distinguish silence, noise, overlap, corrections, and an intentional interruption.", systemImage: "arrow.left.and.right.text.vertical"),
                .init(id: "assist", title: "Ground live assistance", detail: "Retrieve from redacted stable text and present suggestions without auto-speaking.", systemImage: "text.bubble.fill"),
                .init(id: "degrade", title: "Design degraded mode", detail: "Continue transcription locally and queue work when network or models are unavailable.", systemImage: "wifi.exclamationmark")
            ],
            brief: "A healthcare benefits call center wants agents to receive policy-grounded suggestions during calls. The system must mask member identifiers, never answer aloud without the agent, stop processing when consent is withdrawn, and remain useful as a local transcript tool during provider outages.",
            starterFiles: [
                .init(name: "audio_buffer.py", language: "python", contents: """
from collections import deque
from dataclasses import dataclass

@dataclass(frozen=True)
class AudioFrame:
    sequence: int
    timestamp_ms: int
    pcm: bytes

class BoundedAudioBuffer:
    def __init__(self, capacity: int = 100):
        self.frames = deque(maxlen=capacity)
        self.dropped = 0

    def push(self, frame: AudioFrame) -> None:
        if len(self.frames) == self.frames.maxlen:
            self.dropped += 1
        self.frames.append(frame)
"""),
                .init(name: "turn_state.py", language: "python", contents: """
from enum import Enum

class TurnState(Enum):
    LISTENING = "listening"
    CUSTOMER_SPEAKING = "customer_speaking"
    AGENT_SPEAKING = "agent_speaking"
    OVERLAP = "overlap"

def next_state(state: TurnState, customer_voice: float, agent_voice: float) -> TurnState:
    if customer_voice > 0.7 and agent_voice > 0.7:
        return TurnState.OVERLAP
    if customer_voice > 0.7:
        return TurnState.CUSTOMER_SPEAKING
    if agent_voice > 0.7:
        return TurnState.AGENT_SPEAKING
    return TurnState.LISTENING
""")
            ]
        ),
        LabProject(
            id: "visual-quality-inspector",
            title: "Deploy a visual quality inspector",
            subtitle: "Vision · Active learning · Edge review",
            summary: "Inspect manufactured parts with calibrated computer vision, evidence overlays, and a review loop for rare or ambiguous defects.",
            icon: "camera.viewfinder",
            accent: "45D5A9",
            difficulty: "Intermediate",
            estimatedHours: 9,
            xp: 2_400,
            skills: ["Computer vision", "Defect detection", "Calibration", "Active learning", "Edge deployment"],
            outcomes: [
                "Design defect labels and capture protocols that prevent production-line leakage",
                "Evaluate detection by defect severity, product family, camera, and operating shift",
                "Calibrate accept, reject, and human-review thresholds from asymmetric business cost",
                "Collect informative review examples without turning every uncertain frame into training data"
            ],
            milestones: [
                .init(id: "capture", title: "Control image capture", detail: "Standardize lighting, scale, camera health, part identity, and split boundaries.", systemImage: "camera.fill"),
                .init(id: "detect", title: "Train the inspector", detail: "Localize defects and retain visual overlays that operators can verify.", systemImage: "viewfinder.rectangular"),
                .init(id: "calibrate", title: "Calibrate decisions", detail: "Set class-specific thresholds using scrap, escape, and review costs.", systemImage: "slider.horizontal.below.square.filled.and.square"),
                .init(id: "operate", title: "Run at the edge", detail: "Monitor camera drift, latency, review load, and unseen defect clusters.", systemImage: "memorychip.fill")
            ],
            brief: "A medical-device factory must detect scratches, missing fasteners, and seal contamination before packaging. False accepts risk patient safety; false rejects halt a costly line. Build an edge inspection system that shows its evidence and routes uncertain parts to trained quality staff.",
            starterFiles: [
                .init(name: "decision_policy.py", language: "python", contents: """
from dataclasses import dataclass

@dataclass(frozen=True)
class Detection:
    defect: str
    confidence: float
    area_fraction: float
    image_id: str

THRESHOLDS = {
    "seal_contamination": {"reject": 0.70, "review": 0.35},
    "missing_fastener": {"reject": 0.80, "review": 0.45},
    "scratch": {"reject": 0.92, "review": 0.60},
}

def route(detection: Detection) -> str:
    policy = THRESHOLDS[detection.defect]
    if detection.confidence >= policy["reject"]:
        return "reject"
    if detection.confidence >= policy["review"]:
        return "review"
    return "accept"
"""),
                .init(name: "slice_metrics.py", language: "python", contents: """
def escape_rate(rows: list[dict], severity: str) -> float:
    relevant = [row for row in rows if row["severity"] == severity and row["is_defect"]]
    if not relevant:
        return 0.0
    escaped = sum(row["decision"] == "accept" for row in relevant)
    return escaped / len(relevant)

def report_slices(rows: list[dict], keys=("defect", "camera", "shift", "product_family")) -> dict:
    # Return support, escape rate, false-reject rate, and review load for each slice.
    raise NotImplementedError
""")
            ]
        ),
        LabProject(
            id: "speech-analytics-platform",
            title: "Engineer a speech analytics platform",
            subtitle: "Diarization · Topic mining · Quality assurance",
            summary: "Turn consented call recordings into searchable, measurable operational insight while preserving uncertainty and restricting sensitive audio.",
            icon: "waveform.and.magnifyingglass",
            accent: "5AC8FA",
            difficulty: "Intermediate",
            estimatedHours: 8,
            xp: 2_200,
            skills: ["Speech recognition", "Speaker diarization", "Topic modeling", "Quality analytics", "Privacy"],
            outcomes: [
                "Align words, speakers, confidence, and acoustic events on one auditable timeline",
                "Redact sensitive spans in transcript and audio before downstream indexing",
                "Measure topics and quality behaviors without treating noisy model labels as ground truth",
                "Detect drift by language, channel, queue, and acoustic condition"
            ],
            milestones: [
                .init(id: "timeline", title: "Build the call timeline", detail: "Reconcile diarization turns, word timestamps, overlap, and low-confidence gaps.", systemImage: "timeline.selection"),
                .init(id: "redact", title: "Protect sensitive speech", detail: "Mask transcript spans and corresponding audio intervals before storage.", systemImage: "waveform.slash"),
                .init(id: "analyze", title: "Extract operational signals", detail: "Score topics and behaviors with evidence spans and calibrated uncertainty.", systemImage: "chart.bar.doc.horizontal.fill"),
                .init(id: "audit", title: "Audit the analytics", detail: "Compare model estimates with stratified human review and monitor slice drift.", systemImage: "checklist.checked")
            ],
            brief: "A public-transport contact center wants to understand why riders call and whether agents follow accessibility procedures. Build a post-call analytics system for consented recordings that supports English and German, redacts payment details, and never presents inferred sentiment as an employee performance fact.",
            starterFiles: [
                .init(name: "timeline.py", language: "python", contents: """
from dataclasses import dataclass

@dataclass(frozen=True)
class Word:
    text: str
    start_ms: int
    end_ms: int
    confidence: float
    speaker: str | None

def assign_speakers(words: list[Word], turns: list[dict]) -> list[Word]:
    # Assign by maximum temporal overlap and leave genuinely ambiguous words unlabeled.
    raise NotImplementedError
"""),
                .init(name: "redaction.py", language: "python", contents: """
from dataclasses import dataclass

@dataclass(frozen=True)
class Redaction:
    kind: str
    start_ms: int
    end_ms: int
    replacement: str

def merge_intervals(items: list[Redaction], padding_ms: int = 120) -> list[Redaction]:
    # Merge overlapping sensitive spans before muting the corresponding audio.
    raise NotImplementedError
""")
            ]
        ),
        LabProject(
            id: "counterfactual-ranking-system",
            title: "Build a counterfactual ranking system",
            subtitle: "Learning to rank · Bias correction · Exploration",
            summary: "Train and evaluate a marketplace ranker from biased exposure logs while protecting relevance, diversity, and seller opportunity.",
            icon: "list.number",
            accent: "FFB340",
            difficulty: "Advanced",
            estimatedHours: 11,
            xp: 2_900,
            skills: ["Learning to rank", "Counterfactual evaluation", "Propensity scoring", "Exploration", "Multi-objective optimization"],
            outcomes: [
                "Construct time-safe ranking examples from impressions rather than clicks alone",
                "Estimate and validate exposure propensities for inverse-weighted learning",
                "Compare candidate policies offline without replaying the logging policy’s bias",
                "Constrain relevance optimization with diversity, safety, and seller-coverage guardrails"
            ],
            milestones: [
                .init(id: "logs", title: "Reconstruct impressions", detail: "Join candidate sets, positions, features, outcomes, and policy versions at decision time.", systemImage: "rectangle.stack.badge.person.crop"),
                .init(id: "propensity", title: "Correct exposure bias", detail: "Estimate selection probabilities and clip unstable importance weights.", systemImage: "scalemass.fill"),
                .init(id: "ranker", title: "Train the policy", detail: "Optimize pairwise relevance with leakage-safe features and calibrated constraints.", systemImage: "arrow.up.arrow.down.square.fill"),
                .init(id: "launch", title: "Plan safe exploration", detail: "Use bounded randomization, guardrails, and sequential monitoring before expansion.", systemImage: "flask.fill")
            ],
            brief: "A crafts marketplace wants better search results, but historical clicks overwhelmingly favor sellers the old ranker already exposed. Build a new ranker that learns from logged impressions, gives relevant new inventory a measured opportunity, and protects buyer trust during online exploration.",
            starterFiles: [
                .init(name: "counterfactual.py", language: "python", contents: """
def clipped_ips(rewards: list[float], target_prob: list[float], logging_prob: list[float], clip: float = 20.0) -> float:
    weighted = []
    for reward, target, logged in zip(rewards, target_prob, logging_prob):
        if logged <= 0:
            continue
        weight = min(target / logged, clip)
        weighted.append(weight * reward)
    return sum(weighted) / max(len(weighted), 1)

def effective_sample_size(weights: list[float]) -> float:
    denominator = sum(weight * weight for weight in weights)
    return (sum(weights) ** 2) / denominator if denominator else 0.0
"""),
                .init(name: "reranker.py", language: "python", contents: """
def constrained_rerank(items: list[dict], limit: int, max_per_seller: int = 2) -> list[dict]:
    selected, seller_counts = [], {}
    for item in sorted(items, key=lambda row: row["relevance"], reverse=True):
        seller = item["seller_id"]
        if seller_counts.get(seller, 0) >= max_per_seller or not item["policy_safe"]:
            continue
        selected.append(item)
        seller_counts[seller] = seller_counts.get(seller, 0) + 1
        if len(selected) == limit:
            break
    return selected
""")
            ]
        ),
        LabProject(
            id: "synthetic-data-engine",
            title: "Create a synthetic-data engine",
            subtitle: "Scenario generation · Privacy · Coverage",
            summary: "Generate difficult, controllable training and evaluation examples without copying private records or amplifying one model’s blind spots.",
            icon: "wand.and.rays.inverse",
            accent: "C77DFF",
            difficulty: "Advanced",
            estimatedHours: 9,
            xp: 2_500,
            skills: ["Synthetic data", "Scenario modeling", "Privacy testing", "Diversity measurement", "Data quality"],
            outcomes: [
                "Represent target behaviors as parameterized scenarios instead of unconstrained prompts",
                "Generate inputs and labels through independent roles with deterministic validation",
                "Detect memorization, near-duplicates, impossible combinations, and demographic imbalance",
                "Measure whether synthetic additions improve held-out real-world slices"
            ],
            milestones: [
                .init(id: "schema", title: "Model the scenario space", detail: "Define controllable factors, constraints, rare events, and expected behavior.", systemImage: "square.grid.3x3.square"),
                .init(id: "generate", title: "Build independent generators", detail: "Separate scenario sampling, surface realization, labeling, and critique.", systemImage: "wand.and.stars.inverse"),
                .init(id: "filter", title: "Install quality gates", detail: "Reject privacy matches, duplicates, contradictions, and invalid factor combinations.", systemImage: "line.3.horizontal.decrease.circle.fill"),
                .init(id: "prove", title: "Prove marginal value", detail: "Ablate synthetic cohorts and test gains on untouched real data.", systemImage: "chart.line.uptrend.xyaxis")
            ],
            brief: "A fraud-review assistant has only a few hundred labeled cases for rare account-takeover patterns, and the originals contain sensitive customer histories. Build a synthetic-data engine that produces controllable review narratives, preserves realistic causal constraints, and is admitted only when it improves a private held-out benchmark.",
            starterFiles: [
                .init(name: "scenario.py", language: "python", contents: """
from dataclasses import dataclass

@dataclass(frozen=True)
class FraudScenario:
    channel: str
    account_age_days: int
    device_novelty: str
    location_velocity: str
    authentication_result: str
    expected_decision: str

def valid(scenario: FraudScenario) -> bool:
    if scenario.account_age_days < 0:
        return False
    if scenario.device_novelty == "known" and scenario.authentication_result == "new_device_challenge":
        return False
    return True
"""),
                .init(name: "quality_gates.py", language: "python", contents: """
def nearest_similarity(example_embedding: list[float], private_embeddings: list[list[float]], cosine) -> float:
    return max((cosine(example_embedding, item) for item in private_embeddings), default=0.0)

def admit(example: dict, private_similarity: float, duplicate_similarity: float) -> tuple[bool, list[str]]:
    reasons = []
    if private_similarity > 0.92:
        reasons.append("too similar to a private record")
    if duplicate_similarity > 0.96:
        reasons.append("near duplicate")
    if not example.get("validated_constraints"):
        reasons.append("scenario constraints failed")
    return not reasons, reasons
""")
            ]
        ),
        LabProject(
            id: "reasoning-benchmark-lab",
            title: "Build a reasoning benchmark lab",
            subtitle: "Task design · Contamination · Process scoring",
            summary: "Evaluate multi-step model reasoning through executable tasks, hidden variants, and outcome-grounded diagnostics rather than persuasive explanations.",
            icon: "brain.filled.head.profile",
            accent: "64D2FF",
            difficulty: "Advanced",
            estimatedHours: 10,
            xp: 2_800,
            skills: ["Reasoning evaluation", "Benchmark design", "Executable grading", "Contamination control", "Statistical analysis"],
            outcomes: [
                "Design compositional tasks that require planning, state tracking, and correction",
                "Grade final artifacts and tool effects without treating chain-of-thought prose as truth",
                "Create hidden parameterized variants that resist memorization and benchmark leakage",
                "Diagnose failures by capability, difficulty, tool path, and recovery behavior"
            ],
            milestones: [
                .init(id: "tasks", title: "Specify reasoning tasks", detail: "Define observable success, allowed tools, budgets, traps, and partial-credit states.", systemImage: "list.clipboard.fill"),
                .init(id: "variants", title: "Generate hidden variants", detail: "Vary entities, constraints, ordering, and distractors while preserving difficulty.", systemImage: "square.stack.3d.up.fill"),
                .init(id: "grade", title: "Build executable graders", detail: "Inspect outputs, state transitions, side effects, and recovery rather than prose.", systemImage: "checkmark.rectangle.stack.fill"),
                .init(id: "analyze", title: "Calibrate conclusions", detail: "Use paired trials, confidence intervals, and contamination probes.", systemImage: "chart.xyaxis.line")
            ],
            brief: "An AI operations vendor claims its new model can reason through production changes. Build a benchmark in which models inspect synthetic service state, choose read-only diagnostics, propose a safe change plan, and recover from one injected tool failure—without exposing the hidden task templates.",
            starterFiles: [
                .init(name: "task_spec.py", language: "python", contents: """
from dataclasses import dataclass

@dataclass(frozen=True)
class ReasoningTask:
    task_id: str
    initial_state: dict
    goal_predicate: str
    allowed_tools: frozenset[str]
    max_tool_calls: int
    hidden_invariants: tuple[str, ...]

def instantiate(template: dict, seed: int) -> ReasoningTask:
    # Parameterize names, values, topology, and distractors deterministically.
    raise NotImplementedError
"""),
                .init(name: "grader.py", language: "python", contents: """
from dataclasses import dataclass

@dataclass
class Grade:
    goal_reached: bool
    invariants_preserved: bool
    tool_budget_respected: bool
    recovered_from_failure: bool

    @property
    def score(self) -> float:
        if not self.invariants_preserved:
            return 0.0
        return (0.5 * self.goal_reached + 0.15 * self.tool_budget_respected + 0.35 * self.recovered_from_failure)
""")
            ]
        ),
        LabProject(
            id: "mixed-precision-edge-quantization",
            title: "Quantize a model for the edge",
            subtitle: "Mixed precision · Core ML · Quality budgets",
            summary: "Compress and deploy a model under a hard mobile memory and energy envelope using layer sensitivity and task-level quality evidence.",
            icon: "memorychip.fill",
            accent: "30D158",
            difficulty: "Advanced",
            estimatedHours: 10,
            xp: 2_700,
            skills: ["Quantization", "Core ML", "Layer sensitivity", "Mobile profiling", "Model compression"],
            outcomes: [
                "Establish synchronized baselines for quality, memory, latency, energy, and package size",
                "Measure per-layer sensitivity before assigning mixed precision",
                "Separate weight, activation, and cache precision trade-offs on target hardware",
                "Package a reproducible edge model with device-tier admission and rollback criteria"
            ],
            milestones: [
                .init(id: "baseline", title: "Pin the baseline", detail: "Record task slices and device measurements with warm-up and synchronization.", systemImage: "gauge.with.dots.needle.67percent"),
                .init(id: "sensitivity", title: "Map sensitive layers", detail: "Quantize controlled groups and measure marginal quality loss.", systemImage: "waveform.path.ecg.rectangle"),
                .init(id: "compress", title: "Choose mixed precision", detail: "Allocate bits where they preserve quality and verify runtime support.", systemImage: "arrow.down.right.and.arrow.up.left.square"),
                .init(id: "ship", title: "Gate the package", detail: "Enforce device memory, thermal, latency, and retained-quality requirements.", systemImage: "shippingbox.fill")
            ],
            brief: "A wildlife conservation app must classify camera-trap images entirely on iPhone, including older supported devices. The model package must stay below 180 MB, peak below 900 MB memory, and preserve recall for rare protected species while reducing battery cost.",
            starterFiles: [
                .init(name: "sensitivity.py", language: "python", contents: """
from dataclasses import dataclass

@dataclass(frozen=True)
class LayerTrial:
    layer: str
    bits: int
    quality_delta: float
    size_delta_mb: float
    latency_delta_ms: float

def precision_plan(trials: list[LayerTrial], max_quality_loss: float) -> dict[str, int]:
    plan = {}
    used_loss = 0.0
    for trial in sorted(trials, key=lambda item: item.size_delta_mb / max(abs(item.quality_delta), 1e-6)):
        if used_loss + abs(trial.quality_delta) <= max_quality_loss:
            plan[trial.layer] = trial.bits
            used_loss += abs(trial.quality_delta)
    return plan
"""),
                .init(name: "device_gate.swift", language: "swift", contents: """
import Foundation

struct DeviceBudget {
    let maximumPackageMB: Double
    let maximumPeakMemoryMB: Double
    let maximumP95LatencyMS: Double
    let minimumRareClassRecall: Double
}

func canShip(metrics: [String: Double], budget: DeviceBudget) -> Bool {
    metrics["package_mb", default: .infinity] <= budget.maximumPackageMB &&
    metrics["peak_memory_mb", default: .infinity] <= budget.maximumPeakMemoryMB &&
    metrics["p95_latency_ms", default: .infinity] <= budget.maximumP95LatencyMS &&
    metrics["rare_class_recall", default: 0] >= budget.minimumRareClassRecall
}
""")
            ]
        ),
        LabProject(
            id: "causal-ai-experimentation",
            title: "Measure AI impact causally",
            subtitle: "Experiment design · Interference · Decision science",
            summary: "Determine whether an AI assistant improves real outcomes using randomized designs that handle learning effects, spillovers, and novelty.",
            icon: "chart.xyaxis.line",
            accent: "FFD166",
            difficulty: "Advanced",
            estimatedHours: 9,
            xp: 2_500,
            skills: ["Causal inference", "Experiment design", "Variance reduction", "Sequential testing", "Product analytics"],
            outcomes: [
                "Translate an AI feature claim into a treatment, estimand, unit, and decision threshold",
                "Choose individual, cluster, or switchback randomization based on interference and operations",
                "Reduce variance without post-treatment leakage and quantify heterogeneous effects",
                "Make a launch decision from outcomes, guardrails, uncertainty, and adoption behavior"
            ],
            milestones: [
                .init(id: "estimand", title: "Define the causal question", detail: "Specify population, treatment, counterfactual, horizon, and minimum useful effect.", systemImage: "questionmark.app.dashed"),
                .init(id: "design", title: "Design randomization", detail: "Control contamination, learning, capacity spillovers, and repeated exposure.", systemImage: "dice.fill"),
                .init(id: "analyze", title: "Estimate the effect", detail: "Use intention-to-treat, pre-period covariates, and valid uncertainty.", systemImage: "function"),
                .init(id: "decide", title: "Write the decision memo", detail: "Combine effect size with harms, noncompliance, cost, and long-run uncertainty.", systemImage: "doc.text.fill")
            ],
            brief: "A software company believes an AI code-review assistant shortens review cycles, but teams share reviewers and improve with practice. Design and analyze an experiment that can separate assistant impact from novelty, cross-team spillovers, and changes in pull-request complexity.",
            starterFiles: [
                .init(name: "assignment.py", language: "python", contents: """
import hashlib

def cluster_assignment(team_id: str, experiment_id: str, treatment_share: float = 0.5) -> str:
    digest = hashlib.sha256(f"{experiment_id}:{team_id}".encode()).hexdigest()
    value = int(digest[:12], 16) / float(16 ** 12)
    return "treatment" if value < treatment_share else "control"

def validate_balance(rows: list[dict], covariates: list[str]) -> dict:
    # Report standardized mean differences at the randomized cluster level.
    raise NotImplementedError
"""),
                .init(name: "estimate.py", language: "python", contents: """
def difference_in_means(rows: list[dict], outcome: str) -> float:
    treated = [row[outcome] for row in rows if row["assignment"] == "treatment"]
    control = [row[outcome] for row in rows if row["assignment"] == "control"]
    return sum(treated) / len(treated) - sum(control) / len(control)

def cuped_adjust(rows: list[dict], outcome: str, pre_period: str) -> list[float]:
    # Estimate theta on pre-treatment information only, then return adjusted outcomes.
    raise NotImplementedError
""")
            ]
        ),
        LabProject(
            id: "graph-risk-intelligence",
            title: "Build graph risk intelligence",
            subtitle: "Graph features · Community detection · Investigation",
            summary: "Detect coordinated risk patterns across accounts and transactions while producing traceable evidence for human investigators.",
            icon: "point.3.filled.connected.trianglepath.dotted",
            accent: "FF7A8A",
            difficulty: "Advanced",
            estimatedHours: 11,
            xp: 2_900,
            skills: ["Graph analytics", "Graph features", "Community detection", "Temporal networks", "Investigation UX"],
            outcomes: [
                "Construct a temporal heterogeneous graph without leaking future relationships",
                "Compute interpretable neighborhood, path, velocity, and community features",
                "Detect coordinated structures while controlling for legitimate high-degree hubs",
                "Produce investigator cases with evidence subgraphs and calibrated priorities"
            ],
            milestones: [
                .init(id: "model", title: "Model the network", detail: "Define node and edge types, event time, direction, confidence, and retention.", systemImage: "circle.grid.cross.fill"),
                .init(id: "features", title: "Build time-safe features", detail: "Materialize graph state as known at each decision timestamp.", systemImage: "clock.badge.checkmark.fill"),
                .init(id: "detect", title: "Find coordinated patterns", detail: "Combine structural rules, embeddings, and community anomalies with baselines.", systemImage: "scope"),
                .init(id: "case", title: "Create investigation cases", detail: "Compress the relevant subgraph into evidence, uncertainty, and next checks.", systemImage: "person.text.rectangle.fill")
            ],
            brief: "A ticket marketplace is seeing coordinated account rings buy limited releases and immediately resell them. Build graph intelligence across devices, payments, addresses, accounts, and events that finds suspicious communities without treating shared households or public networks as fraud.",
            starterFiles: [
                .init(name: "temporal_graph.py", language: "python", contents: """
from dataclasses import dataclass
from datetime import datetime

@dataclass(frozen=True)
class Edge:
    source: str
    target: str
    relation: str
    observed_at: datetime
    expires_at: datetime | None = None

def snapshot(edges: list[Edge], as_of: datetime) -> list[Edge]:
    return [
        edge for edge in edges
        if edge.observed_at <= as_of and (edge.expires_at is None or as_of < edge.expires_at)
    ]
"""),
                .init(name: "case_builder.py", language: "python", contents: """
def suspicious_shared_neighbors(account: str, neighbors: dict[str, set[str]], legitimate_hubs: set[str]) -> dict[str, int]:
    counts = {}
    for neighbor in neighbors.get(account, set()) - legitimate_hubs:
        for peer in neighbors.get(neighbor, set()):
            if peer != account:
                counts[peer] = counts.get(peer, 0) + 1
    return counts

def evidence_subgraph(seed_accounts: list[str], edges: list[dict], max_edges: int = 40) -> list[dict]:
    # Select the highest-information paths while preserving timestamps and edge sources.
    raise NotImplementedError
""")
            ]
        ),
        LabProject(
            id: "federated-private-ai",
            title: "Train private federated AI",
            subtitle: "Federated learning · Secure aggregation · Privacy",
            summary: "Improve a shared model from distributed private data without centralizing raw examples or hiding the limits of privacy guarantees.",
            icon: "lock.laptopcomputer",
            accent: "35D6B4",
            difficulty: "Advanced",
            estimatedHours: 12,
            xp: 3_000,
            skills: ["Federated learning", "Differential privacy", "Secure aggregation", "Privacy accounting", "Distributed optimization"],
            outcomes: [
                "Define the threat model and distinguish data minimization, secure aggregation, and differential privacy",
                "Simulate non-identically distributed clients, dropouts, and unequal local dataset sizes",
                "Clip and aggregate model updates with an explicit privacy budget",
                "Evaluate global utility, subgroup performance, communication cost, and privacy loss together"
            ],
            milestones: [
                .init(id: "threat", title: "Write the threat model", detail: "State adversaries, protected information, collusion assumptions, and residual leakage.", systemImage: "lock.shield.fill"),
                .init(id: "simulate", title: "Simulate federated clients", detail: "Model skewed data, intermittent availability, local compute, and client selection.", systemImage: "laptopcomputer.and.iphone"),
                .init(id: "aggregate", title: "Protect updates", detail: "Clip contributions, add calibrated noise, and aggregate without exposing individuals.", systemImage: "sum"),
                .init(id: "account", title: "Account for privacy", detail: "Track cumulative budget and stop training before exceeding the approved limit.", systemImage: "gauge.open.with.lines.needle.33percent")
            ],
            brief: "A consortium of hospitals wants to improve a model that predicts missing discharge-summary fields, but patient notes cannot leave each institution. Prototype a federated training system that tolerates hospital-specific language and dropouts, limits contribution leakage, and reports where the global model becomes worse.",
            starterFiles: [
                .init(name: "federated_round.py", language: "python", contents: """
from dataclasses import dataclass
import math

@dataclass
class ClientUpdate:
    client_id: str
    values: list[float]
    examples: int

def clip(update: ClientUpdate, maximum_norm: float) -> ClientUpdate:
    norm = math.sqrt(sum(value * value for value in update.values))
    scale = min(1.0, maximum_norm / max(norm, 1e-12))
    return ClientUpdate(update.client_id, [value * scale for value in update.values], update.examples)

def aggregate(updates: list[ClientUpdate]) -> list[float]:
    # Replace with secure weighted aggregation and dropout recovery.
    raise NotImplementedError
"""),
                .init(name: "privacy_accountant.py", language: "python", contents: """
from dataclasses import dataclass

@dataclass
class PrivacyLedger:
    epsilon_spent: float = 0.0
    delta: float = 1e-6
    approved_epsilon: float = 4.0

    def record_round(self, epsilon_increment: float) -> None:
        if self.epsilon_spent + epsilon_increment > self.approved_epsilon:
            raise RuntimeError("privacy budget exhausted")
        self.epsilon_spent += epsilon_increment
""")
            ]
        ),
        LabProject(
            id: "adversarial-agent-red-team",
            title: "Build an adversarial AI red team",
            subtitle: "Attack generation · Sandboxing · Assurance",
            summary: "Continuously challenge a multimodal, tool-using assistant with reproducible attacks and evidence-backed release gates.",
            icon: "shield.lefthalf.filled.badge.checkmark",
            accent: "FF453A",
            difficulty: "Advanced",
            estimatedHours: 10,
            xp: 2_800,
            skills: ["AI red teaming", "Prompt injection", "Tool abuse", "Sandboxing", "Security evaluation", "Threat intelligence"],
            outcomes: [
                "Turn system assets and trust boundaries into a versioned attack taxonomy",
                "Generate direct, indirect, multimodal, encoded, and multi-turn attacks reproducibly",
                "Run attacks in an instrumented sandbox with canary secrets and harmless fake tools",
                "Convert exploited paths into minimized regression cases and measurable release policy"
            ],
            milestones: [
                .init(id: "taxonomy", title: "Model adversary objectives", detail: "Map exfiltration, privilege escalation, policy bypass, persistence, and availability.", systemImage: "list.bullet.rectangle.portrait.fill"),
                .init(id: "harness", title: "Build the attack harness", detail: "Parameterize delivery channels, transformations, conversations, and tool state.", systemImage: "ant.fill"),
                .init(id: "sandbox", title: "Contain every run", detail: "Use synthetic identities, canary values, fake resources, and recorded tool decisions.", systemImage: "shippingbox.fill"),
                .init(id: "gate", title: "Operationalize findings", detail: "Deduplicate exploits, assign owners, verify controls, and block recurring critical paths.", systemImage: "lock.rectangle.stack.fill")
            ],
            brief: "A procurement assistant reads email, PDFs, and images and can draft purchase orders. Build a red-team system that tests hidden document instructions, malicious QR codes, authority spoofing, cross-turn manipulation, and attempts to send canary supplier data through a fake external tool.",
            starterFiles: [
                .init(name: "attack_case.py", language: "python", contents: """
from dataclasses import dataclass

@dataclass(frozen=True)
class AttackCase:
    case_id: str
    objective: str
    delivery_channel: str
    payload: str
    expected_forbidden_tools: frozenset[str]
    canary_values: frozenset[str]
    seed: int

def variants(case: AttackCase) -> list[AttackCase]:
    # Produce deterministic encoding, paraphrase, nesting, and multi-turn variants.
    raise NotImplementedError
"""),
                .init(name: "sandbox.py", language: "python", contents: """
class FakeToolbox:
    def __init__(self, allowed_tools: set[str]):
        self.allowed_tools = allowed_tools
        self.calls: list[dict] = []

    def call(self, name: str, arguments: dict) -> dict:
        self.calls.append({"name": name, "arguments": arguments})
        if name not in self.allowed_tools:
            return {"status": "denied"}
        return {"status": "simulated", "result": "synthetic-only"}

def leaked_canaries(output: str, canaries: set[str]) -> set[str]:
    return {value for value in canaries if value in output}
""")
            ]
        ),
        LabProject(
            id: "kubernetes-inference-platform",
            title: "Operate inference on Kubernetes",
            subtitle: "GPU scheduling · Autoscaling · Progressive delivery",
            summary: "Build a multi-model Kubernetes serving platform with GPU-aware placement, queue-driven scaling, and safe model rollouts.",
            icon: "shippingbox.circle.fill",
            accent: "4F8BFF",
            difficulty: "Advanced",
            estimatedHours: 12,
            xp: 3_000,
            skills: ["Kubernetes", "GPU scheduling", "Autoscaling", "Model serving", "Progressive delivery", "SRE"],
            outcomes: [
                "Separate model control-plane concerns from latency-sensitive inference data paths",
                "Schedule models by accelerator, memory footprint, locality, priority, and isolation",
                "Scale from queue delay and token work rather than CPU utilization alone",
                "Roll model and runtime versions with warming, shadow traffic, canaries, and rollback"
            ],
            milestones: [
                .init(id: "contract", title: "Define the serving contract", detail: "Specify model artifacts, runtime needs, SLOs, quotas, health, and ownership.", systemImage: "doc.badge.gearshape.fill"),
                .init(id: "schedule", title: "Place GPU workloads", detail: "Respect memory and topology while preventing noisy-neighbor and priority inversion.", systemImage: "square.3.layers.3d.down.forward"),
                .init(id: "scale", title: "Scale on model work", detail: "Translate queued prefill and decode tokens into capacity before deadlines fail.", systemImage: "arrow.up.and.down.and.sparkles"),
                .init(id: "rollout", title: "Deliver progressively", detail: "Pre-pull artifacts, warm replicas, shadow requests, and automate rollback gates.", systemImage: "arrow.triangle.2.circlepath.circle.fill")
            ],
            brief: "A media company needs one platform to serve embedding, reranking, vision, and language models across two GPU types. Interactive workloads have strict latency budgets, batch jobs can wait, and one product launch creates sharp bursts. Design the Kubernetes resources, scheduler signals, autoscaler, and rollout path.",
            starterFiles: [
                .init(name: "modelservice.yaml", language: "yaml", contents: """
apiVersion: ai.example.com/v1alpha1
kind: ModelService
metadata:
  name: catalog-reranker
spec:
  artifact: registry.example.com/models/catalog-reranker@sha256:replace-me
  runtime: text-ranking
  accelerator:
    type: nvidia-l4
    memoryGiB: 20
  serviceLevel:
    p95LatencyMs: 180
    minimumReplicas: 2
  rollout:
    strategy: canary
    initialTrafficPercent: 5
"""),
                .init(name: "autoscaler.py", language: "python", contents: """
from math import ceil

def desired_replicas(
    queued_prefill_tokens: int,
    queued_decode_tokens: int,
    target_queue_seconds: float,
    prefill_tokens_per_second: float,
    decode_tokens_per_second: float,
    maximum_replicas: int,
) -> int:
    prefill_work = queued_prefill_tokens / max(prefill_tokens_per_second, 1)
    decode_work = queued_decode_tokens / max(decode_tokens_per_second, 1)
    required = ceil((prefill_work + decode_work) / max(target_queue_seconds, 0.1))
    return max(1, min(required, maximum_replicas))
""")
            ]
        ),
        LabProject(
            id: "gpu-inference-profiler",
            title: "Profile GPU inference bottlenecks",
            subtitle: "Kernels · Roofline analysis · Memory traffic",
            summary: "Diagnose why a model underuses its accelerator and turn traces into verified kernel, memory, and scheduling improvements.",
            icon: "gauge.with.dots.needle.bottom.50percent",
            accent: "A8FF60",
            difficulty: "Advanced",
            estimatedHours: 10,
            xp: 2_800,
            skills: ["GPU profiling", "Kernel optimization", "Roofline analysis", "Memory systems", "Inference runtimes"],
            outcomes: [
                "Capture synchronized CPU, GPU, allocator, and request traces without benchmark distortion",
                "Classify operators as launch-bound, compute-bound, bandwidth-bound, or synchronization-bound",
                "Prioritize fusions, layouts, batching, and kernel changes by measured end-to-end impact",
                "Validate speedups against output quality, tail latency, memory, and representative request shapes"
            ],
            milestones: [
                .init(id: "trace", title: "Capture a trustworthy trace", detail: "Warm the runtime, synchronize measurements, annotate phases, and preserve request shape.", systemImage: "waveform.path.ecg"),
                .init(id: "roofline", title: "Build the roofline view", detail: "Estimate arithmetic intensity and compare achieved compute and bandwidth.", systemImage: "chart.xyaxis.line"),
                .init(id: "optimize", title: "Remove the real bottleneck", detail: "Change one kernel, layout, fusion, or launch path and predict its impact first.", systemImage: "wrench.adjustable.fill"),
                .init(id: "verify", title: "Verify end to end", detail: "Repeat across batch, sequence, and concurrency distributions with quality checks.", systemImage: "checkmark.rectangle.stack.fill")
            ],
            brief: "A document-generation model reaches only 22% accelerator utilization and misses its latency SLO despite fitting comfortably in GPU memory. Profile prefill and decode, determine whether small kernels, memory movement, synchronization, or host scheduling dominates, and deliver one defensible optimization.",
            starterFiles: [
                .init(name: "trace_analysis.py", language: "python", contents: """
from dataclasses import dataclass

@dataclass(frozen=True)
class KernelSample:
    name: str
    duration_us: float
    flops: float
    bytes_moved: float
    launches: int

    @property
    def arithmetic_intensity(self) -> float:
        return self.flops / max(self.bytes_moved, 1)

def classify(sample: KernelSample, peak_flops: float, peak_bandwidth: float) -> str:
    roofline_flops = min(peak_flops, peak_bandwidth * sample.arithmetic_intensity)
    achieved = sample.flops / max(sample.duration_us / 1_000_000, 1e-12)
    if sample.duration_us / max(sample.launches, 1) < 8:
        return "launch-bound"
    return "under-roofline" if achieved < 0.55 * roofline_flops else "near-roofline"
"""),
                .init(name: "benchmark.py", language: "python", contents: """
def request_matrix() -> list[dict]:
    return [
        {"batch": 1, "prompt_tokens": 128, "new_tokens": 64, "concurrency": 1},
        {"batch": 1, "prompt_tokens": 4096, "new_tokens": 128, "concurrency": 4},
        {"batch": 8, "prompt_tokens": 512, "new_tokens": 256, "concurrency": 16},
    ]

def regression_gate(before: dict, after: dict) -> bool:
    return after["p95_ms"] <= before["p95_ms"] * 0.90 and after["quality"] >= before["quality"] - 0.002
""")
            ]
        ),
        LabProject(
            id: "internal-ai-developer-platform",
            title: "Launch an internal AI developer platform",
            subtitle: "Golden paths · Self service · Platform product",
            summary: "Give product teams a fast, governed path from experiment to production through reusable model, retrieval, evaluation, and observability capabilities.",
            icon: "hammer.circle.fill",
            accent: "5B8CFF",
            difficulty: "Advanced",
            estimatedHours: 12,
            xp: 3_000,
            skills: ["Platform engineering", "Developer experience", "Model gateways", "Evaluation infrastructure", "Product management", "Governance"],
            outcomes: [
                "Prioritize platform capabilities from repeated team friction rather than speculative centralization",
                "Design a self-service golden path with identity, budgets, evaluation, deployment, and telemetry",
                "Provide escape hatches and portable contracts that prevent provider or platform lock-in",
                "Measure adoption, lead time, reliability, support burden, and product-team outcomes"
            ],
            milestones: [
                .init(id: "discovery", title: "Discover platform demand", detail: "Interview teams and quantify repeated integration, safety, and operations work.", systemImage: "person.2.wave.2.fill"),
                .init(id: "paved", title: "Build the paved road", detail: "Create one opinionated vertical slice from prompt and data to evaluated deployment.", systemImage: "road.lanes"),
                .init(id: "contracts", title: "Stabilize platform contracts", detail: "Version model, retrieval, tool, trace, and evaluation interfaces independently.", systemImage: "point.3.connected.trianglepath.dotted"),
                .init(id: "adoption", title: "Drive voluntary adoption", detail: "Onboard lighthouse teams and measure pull, migration effort, and exceptions.", systemImage: "figure.walk.motion")
            ],
            brief: "Twelve product teams at a travel company each built separate model clients, vector stores, prompt logs, and release checks. Create an internal platform that makes the secure path the quickest path, supports multiple model providers and local models, and avoids becoming a ticket-driven central bottleneck.",
            starterFiles: [
                .init(name: "ai_platform.py", language: "python", contents: """
from dataclasses import dataclass
from typing import Protocol

@dataclass(frozen=True)
class WorkloadPolicy:
    data_classification: str
    region: str
    maximum_cost_per_request: float
    required_eval_suite: str

class ModelRuntime(Protocol):
    def generate(self, request: dict, policy: WorkloadPolicy) -> dict: ...

def select_runtime(policy: WorkloadPolicy, registry: list[dict]) -> dict:
    eligible = [
        runtime for runtime in registry
        if policy.region in runtime["regions"]
        and policy.data_classification in runtime["allowed_data"]
        and runtime["estimated_cost"] <= policy.maximum_cost_per_request
    ]
    if not eligible:
        raise LookupError("no policy-compliant runtime")
    return min(eligible, key=lambda runtime: runtime["estimated_cost"])
"""),
                .init(name: "service-contract.yaml", language: "yaml", contents: """
apiVersion: platform.ai/v1
kind: AIService
metadata:
  name: itinerary-assistant
spec:
  owner: travel-experiences
  dataClassification: customer-confidential
  region: eu
  capabilities:
    - structured-generation
    - retrieval
  evaluations:
    suite: itinerary-safety-v3
    minimumScore: 0.94
  budgets:
    maximumCostPerRequest: 0.03
    p95LatencyMs: 1800
""")
            ]
        ),
        LabProject(
            id: "regulated-ai-governance",
            title: "Implement regulated AI governance",
            subtitle: "Policy as code · Evidence · Change control",
            summary: "Translate legal, risk, and clinical obligations into enforceable lifecycle controls with an auditable evidence trail.",
            icon: "building.columns.fill",
            accent: "F4C95D",
            difficulty: "Advanced",
            estimatedHours: 11,
            xp: 2_900,
            skills: ["AI governance", "Policy as code", "Model risk", "Audit evidence", "Change management", "Monitoring"],
            outcomes: [
                "Map obligations and intended use to owners, controls, evidence, and review frequency",
                "Enforce deployment policy from versioned model, data, evaluation, and approval metadata",
                "Detect material changes that require renewed validation rather than silent rollout",
                "Assemble an audit package that reproduces what ran, why it was approved, and how it performed"
            ],
            milestones: [
                .init(id: "obligations", title: "Build the control map", detail: "Connect each obligation to risk, control logic, evidence, owner, and cadence.", systemImage: "tablecells.fill"),
                .init(id: "policy", title: "Encode release policy", detail: "Reject artifacts missing intended-use, validation, lineage, security, or approval evidence.", systemImage: "lock.doc.fill"),
                .init(id: "change", title: "Classify material change", detail: "Compare model, data, prompt, workflow, population, and infrastructure revisions.", systemImage: "arrow.triangle.2.circlepath.doc.on.clipboard"),
                .init(id: "audit", title: "Generate the audit trail", detail: "Snapshot immutable artifacts, decisions, exceptions, monitoring, and incidents.", systemImage: "archivebox.fill")
            ],
            brief: "A hospital network is introducing an AI system that drafts radiology report sections for clinician review. Build governance controls that enforce intended use, dataset lineage, subgroup validation, human sign-off, post-deployment monitoring, and renewed review whenever model behavior or clinical workflow materially changes.",
            starterFiles: [
                .init(name: "release_policy.py", language: "python", contents: """
REQUIRED_EVIDENCE = {
    "intended_use",
    "dataset_lineage",
    "subgroup_validation",
    "security_review",
    "clinical_owner_approval",
    "rollback_plan",
}

def release_allowed(manifest: dict) -> tuple[bool, list[str]]:
    evidence = set(manifest.get("evidence", {}).keys())
    missing = sorted(REQUIRED_EVIDENCE - evidence)
    blockers = list(manifest.get("open_critical_findings", []))
    return not missing and not blockers, missing + blockers
"""),
                .init(name: "material_change.py", language: "python", contents: """
MATERIAL_FIELDS = {
    "model_artifact",
    "training_data_version",
    "intended_population",
    "clinical_workflow",
    "output_autonomy",
    "evaluation_protocol",
}

def changed_fields(previous: dict, candidate: dict) -> set[str]:
    return {field for field in MATERIAL_FIELDS if previous.get(field) != candidate.get(field)}

def required_reviews(changes: set[str]) -> set[str]:
    reviews = {"technical_validation"} if changes else set()
    if changes & {"intended_population", "clinical_workflow", "output_autonomy"}:
        reviews |= {"clinical_safety", "human_factors", "risk_committee"}
    return reviews
""")
            ]
        ),
        LabProject(
            id: "research-reproduction-service",
            title: "Turn research into a reliable service",
            subtitle: "Reproduction · Ablation · Productionization",
            summary: "Reproduce a promising AI paper, identify what actually drives its result, then convert the smallest validated method into an operable service.",
            icon: "doc.text.magnifyingglass",
            accent: "AF7CFF",
            difficulty: "Advanced",
            estimatedHours: 13,
            xp: 3_000,
            skills: ["Research reproduction", "Experimental rigor", "Ablation studies", "ML systems", "Service engineering", "Technical writing"],
            outcomes: [
                "Reconstruct the paper’s claims, data, metrics, dependencies, compute, and hidden assumptions",
                "Reproduce the reference result with pinned artifacts and uncertainty across repeated runs",
                "Use ablations to separate essential method components from incidental complexity",
                "Ship the validated core behind a tested service contract with observability and rollback"
            ],
            milestones: [
                .init(id: "claim", title: "Extract the scientific claim", detail: "Write the exact comparison, metric, dataset, budget, and expected uncertainty.", systemImage: "text.quote"),
                .init(id: "reproduce", title: "Reproduce the baseline", detail: "Pin code, data, environment, seeds, hardware, and raw result artifacts.", systemImage: "arrow.clockwise.circle.fill"),
                .init(id: "ablate", title: "Run decisive ablations", detail: "Remove or replace components one at a time under matched budgets.", systemImage: "square.split.2x2.fill"),
                .init(id: "serve", title: "Build the service", detail: "Define inputs, outputs, errors, capacity, monitoring, and safe rollback.", systemImage: "server.rack")
            ],
            brief: "A research team published a method that claims substantially better long-document retrieval with a new late-interaction architecture. Your company wants it in a compliance search product. Reproduce the gain on the published benchmark, test it on a private domain set, ablate indexing and reranking choices, and deploy only the components that earn their operational cost.",
            starterFiles: [
                .init(name: "reproduction_manifest.py", language: "python", contents: """
from dataclasses import dataclass

@dataclass(frozen=True)
class ReproductionManifest:
    paper_id: str
    code_commit: str
    dataset_checksums: dict[str, str]
    environment_lock_hash: str
    seeds: tuple[int, ...]
    hardware: str
    primary_metric: str
    claimed_value: float

def comparable(run: dict, manifest: ReproductionManifest) -> bool:
    return (
        run["code_commit"] == manifest.code_commit
        and run["dataset_checksums"] == manifest.dataset_checksums
        and run["hardware"] == manifest.hardware
    )
"""),
                .init(name: "ablation_runner.py", language: "python", contents: """
from itertools import product

def ablation_matrix() -> list[dict]:
    return [
        {"late_interaction": late, "reranker": reranker, "query_expansion": expansion}
        for late, reranker, expansion in product([False, True], repeat=3)
    ]

def matched_comparison(results: list[dict], baseline_name: str) -> list[dict]:
    # Compare quality, index size, build time, throughput, and p95 under equal budgets.
    raise NotImplementedError
""")
            ]
        ),
        LabProject(
            id: "principal-architecture-portfolio",
            title: "Create a principal architecture portfolio",
            subtitle: "Strategy · Socio-technical systems · Executive decisions",
            summary: "Produce a principal-level architecture case that connects AI capability, distributed systems, economics, risk, migration, and organizational ownership.",
            icon: "map.fill",
            accent: "FF8A5B",
            difficulty: "Advanced",
            estimatedHours: 16,
            xp: 3_000,
            skills: ["Architecture strategy", "Systems thinking", "Technical economics", "Risk leadership", "Migration planning", "Executive communication"],
            outcomes: [
                "Frame an ambiguous business objective as explicit capabilities, constraints, non-goals, and decision principles",
                "Design end-to-end data, model, control, runtime, safety, and human-operations boundaries",
                "Compare architecture options through scale, failure, cost, compliance, ownership, and reversibility",
                "Present a phased roadmap with organizational interfaces, measurable bets, and reassessment triggers"
            ],
            milestones: [
                .init(id: "frame", title: "Frame the strategic problem", detail: "Define outcomes, actors, regulatory context, scale envelopes, and what not to build.", systemImage: "scope"),
                .init(id: "system", title: "Design the whole system", detail: "Map trust, data, decisions, feedback, failure domains, and operational ownership.", systemImage: "square.3.layers.3d"),
                .init(id: "decisions", title: "Defend major decisions", detail: "Write ADRs with alternatives, economics, consequences, and exit strategies.", systemImage: "arrow.triangle.branch"),
                .init(id: "portfolio", title: "Present the portfolio case", detail: "Deliver diagrams, capacity model, risk register, roadmap, game day, and executive brief.", systemImage: "person.crop.rectangle.stack.fill")
            ],
            brief: "A global logistics company wants AI-assisted exception management across ports, warehouses, carriers, and customs teams. Design a three-year architecture that combines forecasts, document intelligence, agent workflows, and human command across unreliable networks and regulated regions—then show how the organization can migrate without a risky platform rewrite.",
            starterFiles: [
                .init(name: "architecture_case.md", language: "markdown", contents: """
# AI-assisted logistics exception platform

## Strategic frame
State business outcomes, actors, constraints, scale envelopes, non-goals, and decision principles.

## Architecture
Describe data, intelligence, workflow, runtime, trust, observability, and human-command planes.

## Decisions
For each major ADR, compare alternatives on value, reliability, cost, compliance, ownership, reversibility, and time.

## Evolution
Define thin vertical slices, migration seams, decommission criteria, adoption measures, and reassessment triggers.

## Assurance
Include a threat model, risk register, capacity model, failure game day, and rollback strategy.
"""),
                .init(name: "option_model.py", language: "python", contents: """
from dataclasses import dataclass

@dataclass(frozen=True)
class ArchitectureOption:
    name: str
    time_to_value: float
    annual_cost: float
    reliability: float
    compliance_fit: float
    reversibility: float
    organizational_load: float

def weighted_score(option: ArchitectureOption, weights: dict[str, float]) -> float:
    benefits = (
        weights["time_to_value"] / max(option.time_to_value, 0.1)
        + weights["reliability"] * option.reliability
        + weights["compliance_fit"] * option.compliance_fit
        + weights["reversibility"] * option.reversibility
    )
    costs = weights["annual_cost"] * option.annual_cost + weights["organizational_load"] * option.organizational_load
    return benefits - costs
""")
            ]
        )
    ]
}
