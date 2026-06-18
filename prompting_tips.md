# Prompt Templates — Claude Code

**Reference handbook for classroom and daily use.**

This document gathers the 4 main templates taught in the training track, with **detailed descriptions of every field**, filled-in examples, and patterns for invoking **skills** and **subagents** within prompts.

Use it as a starting point — copy, paste, adapt. Over time, the templates become instinct and you prompt directly.

---

## Table of Contents

1. [Template 1 — Development Task](#template-1--development-task)
2. [Template 2 — Bug Hunt (4-step protocol)](#template-2--bug-hunt-4-step-protocol)
3. [Template 3 — Test Generation](#template-3--test-generation)
4. [Template 4 — User Story Generation](#template-4--user-story-generation)
5. [How to invoke Skills in prompts](#how-to-invoke-skills-in-prompts)
6. [How to invoke Subagents in prompts](#how-to-invoke-subagents-in-prompts)
7. [Combining Skills + Subagents + MCP](#combining-skills--subagents--mcp)

---

## Template 1 — Development Task

Use whenever you ask Claude to **implement, modify, or extend** code.

### Structure

```
[CONTEXT]
<where we are, which stack, which file>

[TASK]
<what exactly should be done>

[CONSTRAINTS]
<what must NOT be touched, required libs, patterns>

[ACCEPTANCE CRITERIA]
<how we know it is done>
```

### Field descriptions

| Field | What to put | Examples |
|---|---|---|
| **[CONTEXT]** | The **environmental information** Claude needs to understand the problem before acting. Includes: project type, framework, version, affected file/module, existing dependencies, architectural pattern in use. | "REST endpoint of an e-commerce API in FastAPI 0.115. The file is app/api/v1/orders.py. Redis is already configured in app/infra/cache.py and async SQLAlchemy in app/infra/db.py." |
| **[TASK]** | The **specific change** you want. Verb in the infinitive + direct object + essential qualifiers. One task per prompt. | "Add Redis cache with a 5-minute TTL to the GET /orders/{id} endpoint." |
| **[CONSTRAINTS]** | What **limits** Claude's work. Required libraries, patterns to maintain, untouchable areas, project conventions. Think "what could go wrong if I didn't say so?". | "- Use redis-py 5.x already installed<br>- Key pattern: 'order:{id}'<br>- Do NOT change the function signature<br>- Logs in English via the existing logger<br>- Do NOT touch other endpoints" |
| **[ACCEPTANCE CRITERIA]** | The objective definition of **"done"**. A list of verifiable items. Without this, Claude may stop too early or run indefinitely. | "- Cache hit returns in < 50ms (measure with pytest-benchmark)<br>- Cache miss preserves original behavior<br>- pytest test covering hit and miss<br>- Full suite (pytest) passes<br>- No coverage regression" |

### Full filled-in example

```
[CONTEXT]
GET /orders/{id} endpoint of an e-commerce API in FastAPI 0.115.
File: app/api/v1/orders.py.
Redis already configured in app/infra/cache.py (async client).
Async SQLAlchemy already in app/infra/db.py.

[TASK]
Add Redis cache with a 5-minute TTL to the GET /orders/{id} endpoint.

[CONSTRAINTS]
- Use redis-py 5.x already installed (client at app.infra.cache.redis_client)
- Key pattern: "order:{id}"
- Do NOT change the function signature
- Logs in English via app.logger
- Do NOT touch other endpoints
- Cache-miss handling MUST preserve the current response byte for byte

[ACCEPTANCE CRITERIA]
- Cache hit returns in < 50ms (validate with pytest-benchmark)
- Cache miss preserves original behavior
- pytest test covering: cache hit, cache miss, and Redis connection error
- pytest tests/ passes without new warnings
- ruff check . has no new violations
```

### Useful variants

- **Small task (1 file, < 30 lines):** you can omit `[CONSTRAINTS]` if they are obvious.
- **Medium/high-risk task:** always enter **Plan Mode** (`Shift+Tab`) first.
- **Very large task:** split it into 3–5 smaller tasks, each with its own template.

---

## Template 2 — Bug Hunt (4-step protocol)

Use whenever there is **incorrect behavior**. Resist the temptation to ask "fix it" directly — follow the protocol.

### Structure

```
STEP 1 — UNDERSTAND (do not fix anything)
STEP 2 — HYPOTHESIZE
STEP 3 — REPRODUCE
STEP 4 — FIX
```

These are **4 separate prompts**, executed in sequence. Do not combine them into one.

### Description of each step

#### Step 1 — UNDERSTAND

**Goal:** ensure that Claude (and you) understand how the code works BEFORE any change.

**What to ask for:**
- A description of the execution flow
- A list of files/functions involved
- Invariants assumed by the code

**Do NOT ask for:** a fix, a change suggestion, an opinion on code quality.

**Why this step exists:** if the agent does not understand, it "fixes" the wrong thing.

#### Step 2 — HYPOTHESIZE

**Goal:** list probable causes before jumping into coding.

**What to ask for:**
- 3 hypotheses ranked by probability
- For each one: what evidence would confirm or refute it
- Make it explicit: "do not fix anything yet"

**Do NOT ask for:** a fix. The step ends with hypotheses, not a diff.

**Why this exists:** it forces reasoning before action. It avoids the "first idea that came to mind" bias.

#### Step 3 — REPRODUCE

**Goal:** materialize the bug as an automated test that **fails** in the current state.

**What to ask for:**
- For the most likely hypothesis, write a pytest (or equivalent) test that reproduces the issue
- The test MUST fail now — if it passes, the bug is somewhere else

**Why this exists:** without a regression test, you can never be sure the bug will not return. And the act of reproducing confirms the hypothesis.

#### Step 4 — FIX

**Goal:** the smallest possible change that makes the test pass without breaking anything else.

**What to ask for:**
- Fix it while keeping the test passing
- Do not touch unrelated files
- Run the full suite after the fix

**Why this exists:** delimiting the scope of the fix prevents "collateral fixes" — Claude rewriting half the code.

### Example prompt sequence

```
# STEP 1 — Understand
GET /users?page=2&size=10 returns 9 users instead of 10.

Describe how pagination works in this project.
List every file involved in the request flow.
Do NOT fix anything. Just explain.

# STEP 2 — Hypothesize
Based on your explanation, what are the 3 most likely
hypotheses for the bug? Rank them by probability.
For each one, what evidence would confirm or refute it?
Do NOT fix anything yet.

# STEP 3 — Reproduce
For the most likely hypothesis (off-by-one in offset calculation),
write a pytest test that reproduces the bug.
The test MUST fail in the current state.
Run pytest and confirm it fails.

# STEP 4 — Fix
Now fix the bug while keeping the Step 3 test passing.
Do not touch anything else. Run the full suite (pytest tests/)
after the fix and show me the result.
```

---

## Template 3 — Test Generation

Use whenever you ask for tests — Claude is excellent at happy paths but **forgets edge cases and error scenarios** if you do not list them.

### Structure

```
[CONTEXT]
<function/module under test, framework, existing fixtures>

[TASK]
<generate pytest/jest/etc. tests covering the scenarios below>

[SCENARIOS — happy path]
<valid inputs and expected output>

[SCENARIOS — edges]
<extreme inputs, None, empty, limits>

[CONSTRAINTS]
<project's test patterns, libs to use>
```

### Field descriptions

| Field | What to put |
|---|---|
| **[CONTEXT]** | Function/class under test, test framework in use (pytest, jest, junit), fixtures and helpers already available, project patterns (mock with pytest-mock, respx, etc.). |
| **[TASK]** | Clear verb: "Generate suite", "Add missing tests", "Cover scenarios X and Y". Specify the **target file**. |
| **[SCENARIOS — happy path]** | List of **typical valid inputs** and the expected output. Claude can invent these on its own, but listing them avoids ambiguity. |
| **[SCENARIOS — edges]** | The part Claude forgets on its own: `None`, empty list, empty string, boundary values (0, MAX_INT), invalid types, malformed format, frozen time, concurrency. |
| **[CONSTRAINTS]** | Patterns: use `parametrize` when possible, mock I/O with respx, test naming convention, do NOT use `unittest.TestCase`, do NOT touch production code. |

### Filled-in example

```
[CONTEXT]
Function compute_discount(price, customer_tier, coupon) in
app/core/pricing.py. The project uses pytest + pytest-mock.
Tier is an Enum (BRONZE, SILVER, GOLD). Coupon is a dataclass with
fields: code (str), percent (int 0-100), expires_at (datetime).

[TASK]
Generate a test suite in tests/core/test_pricing.py covering
all the scenarios below.

[SCENARIOS — happy path]
- BRONZE tier without coupon → 0% discount
- SILVER tier without coupon → 5% discount
- GOLD tier without coupon → 10% discount
- SILVER tier with 10% coupon → 15% (stacked)
- GOLD tier with 20% coupon → 30% (stacked)

[SCENARIOS — edges]
- price = 0 → discount = 0, no error
- negative price → ValueError
- expired coupon (expires_at in the past) → tier-only discount
- coupon with percent = 0 → tier-only discount
- coupon with percent > 100 → ValueError
- customer_tier = None → ValueError
- invalid customer_tier (string instead of Enum) → ValueError

[CONSTRAINTS]
- Use @pytest.mark.parametrize for tier + coupon combinations
- Use pytest-mock for datetime.now (expired coupon case)
- Naming pattern: test_<scenario>__<expected>
- Do NOT use unittest.TestCase
- Do NOT touch app/core/pricing.py (read-only)
```

---

## Template 4 — User Story Generation

Use to generate/refine **user stories** with acceptance criteria. Useful for backlog grooming, feature specification, and academic projects (PIBIC, MCTI, FAPESB-funded apps).

### Structure

```
[PRODUCT CONTEXT]
<what the product is, for whom, at what stage>

[PERSONA]
<who the user is, usage context, pain points>

[JOBS-TO-BE-DONE]
<what this persona is trying to achieve>

[SCOPE]
<what is in and what is explicitly OUT of the epic/feature>

[TASK]
<generate N stories covering the scope, in format Y>

[OUTPUT FORMAT]
<how each story should be structured>

[QUALITY CRITERIA]
<INVEST, Gherkin, explicit business value, etc.>
```

### Field descriptions

| Field | What to put |
|---|---|
| **[PRODUCT CONTEXT]** | Product name, 2–3 line description, target audience, stage (MVP, growth, mature). Mention the stack if relevant to the stories. |
| **[PERSONA]** | Who the user of this story is. Include: role (e.g., "Research Coordinator"), tech literacy, usage context (web/mobile/CLI), known pain points. Ideally based on real research. |
| **[JOBS-TO-BE-DONE]** | The **outcome** the persona seeks. Use Clayton Christensen's Jobs-to-be-Done structure: "When ___, I want ___, so that ___". Focus on the result, not the solution. |
| **[SCOPE]** | A clear boundary: what IS in the epic/feature, and what is **explicitly OUT** (next features, discarded edge cases). Without this, Claude invents extra stories. |
| **[TASK]** | Approximate number of stories, desired granularity ("stories of 1–3 days each"), and whether you also want epics or only stories. |
| **[OUTPUT FORMAT]** | Specific template. Common patterns: (a) "As a `<persona>` I want `<action>` so that `<benefit>`"; (b) Job Story ("When `<situation>`, I want `<motivation>`, so that `<outcome>`"); (c) with criteria in Gherkin (`Given/When/Then`). |
| **[QUALITY CRITERIA]** | Patterns to respect: **INVEST** (Independent, Negotiable, Valuable, Estimable, Small, Testable), explicit business value, actionable acceptance criteria, no technical jargon when the user is non-technical, etc. |

### Filled-in example (real case: ConectaEditais)

```
[PRODUCT CONTEXT]
ConectaEditais — a mobile app (React Native) that centralizes Brazilian
research funding calls (CNPq, FAPESB, MCTI, etc.) for researchers and
research coordinators. In MVP stage, funded by a FAPESB grant.
Stack: React Native + Expo, Node/Fastify backend.

[PERSONA]
Research Coordinator at a public Brazilian university (UFRB-like).
Profile:
- 35–55 years old, PhD, dual workload (teaching + management)
- Tracks 8–15 active funding calls at any time
- Works on mobile (commuting) and desktop (office)
- Frustrations: misses deadlines, gets no notifications of changes,
  has to open 7 different sites to check calls

[JOBS-TO-BE-DONE]
When a funding call relevant to my area is published or changed,
I want to be notified and have the key information in one place,
so that I can submit proposals on time without sweeping multiple
portals every week.

[SCOPE]
INSIDE this feature:
- User registration of areas of interest
- Push notifications for new calls and for changes
- Personalized home list
- Save favorite calls
OUTSIDE this feature (next ones):
- Proposal submission inside the app
- Social sharing
- Integration with the Lattes CV database
- Translation to other languages

[TASK]
Generate 6 to 8 user stories covering the "INSIDE" scope.
Granularity: each story deliverable in one sprint (1–3 dev days).
Include 1 summary epic at the top.

[OUTPUT FORMAT]
For each story:
- Title (8–12 words)
- Job Story: "When <situation>, I want <motivation>, so that <outcome>"
- Acceptance criteria in Gherkin (Given/When/Then), 3–5 scenarios
- Technical notes (if any) in a separate section
- Estimate in story points (Fibonacci scale 1,2,3,5,8)

[QUALITY CRITERIA]
- INVEST: each story Independent, Negotiable, Valuable, Estimable,
  Small, Testable
- Value to the persona MUST be explicit in the "so that"
- Measurable and verifiable criteria
- No technical jargon in the Job Story (the "how" goes into tech notes)
- Each Gherkin scenario is a possible test
- Explicit edges: error states, offline, absence of notifications
```

### Useful variants

- **Refining (not generating new):** replace `[TASK]` with "Refine the story below, splitting it if it's too large. Current story: …".
- **Estimation:** you may ask for T-shirt sizing (S/M/L) instead of Fibonacci.
- **Different output style:** swap `[OUTPUT FORMAT]` for "As a … I want … so that …" + Gherkin or any other team standard.

---

## How to invoke Skills in prompts

Skills (`.claude/skills/<name>/SKILL.md`) are **auto-invoked**: you do not mention the name, you just write what you want and Claude detects the trigger in the skill's `description` field.

### Principle

```
✅ RIGHT: you describe the task in natural language
          Claude recognizes the trigger and activates the skill

❌ WRONG: you try to invoke the skill by name with some
          special syntax (skills do not work that way)
```

### Example 1 — `code-review` skill (auto-invocation by topic)

Suppose you have in `.claude/skills/code-review/SKILL.md`:

```yaml
---
name: code-review
description: |
  Use this skill whenever the user asks for a code review of one
  or more files, or asks to review changes in a PR/commit. Triggers
  include "review", "audit", "check this code", "is this correct?".
---
```

**Prompts that ACTIVATE the skill automatically:**

```
Can you review the files I changed since the last commit?
```
```
Audit app/api/v1/orders.py focused on security and performance.
```
```
Is this code correct? @app/core/pricing.py
```

**Prompts that do NOT activate (and why):**

```
❌ Take a look at this code.
   (too vague, no trigger word)

❌ Do an analysis.
   (does not say what kind)

❌ I want feedback on my code.
   ("feedback" is not in the skill's triggers)
```

**How to reinforce the invocation when in doubt:**

```
Do a code review focused on security on @app/api/v1/orders.py
```
> The phrase "code review" is literal and hits the trigger.

### Example 2 — `migration-writer` skill (auto-invocation by domain)

`.claude/skills/migration-writer/SKILL.md`:

```yaml
---
name: migration-writer
description: |
  Use when the user needs to create, modify or revert an Alembic
  migration. Triggers: "migration", "alembic", "schema change",
  "add column", "drop table", "rename field".
---
```

**Prompts that activate:**

```
Create a migration that adds the verified_at column (datetime)
to the users table.
```
```
I need an alembic migration to rename customer_id to client_id
in orders.
```

### When the skill does NOT activate (and what to do)

If Claude did not activate the expected skill:

1. **Check the `description`** — does it contain the trigger you used?
2. **Rephrase the prompt** using one of the listed keywords.
3. **Force the invocation** by being explicit: "Do a critical code review of…" instead of "take a look".
4. **Last resort:** call it via slash command. Skills and slash commands are not exclusive — you can have `.claude/commands/code-review.md` that fires the same logic via `/code-review`.

---

## How to invoke Subagents in prompts

Subagents (`.claude/agents/<name>.md`) are isolated instances with their own context. There are **three ways** to invoke them:

### Form 1 — Explicit mention with `@`

The most direct way. Use the subagent's name prefixed with `@`.

```
@python-tester Write tests for the compute_discount function
in app/core/pricing.py covering happy paths and edges.
```

```
@security-reviewer Analyze PR #234 focused on SQL injection
and authorization bypass.
```

```
@db-reader List all users inactive for more than 90 days.
Do NOT modify anything — SELECT only.
```

**When to use:** you know exactly which subagent you want. It is the equivalent of calling a specific team member by name.

### Form 2 — Proactive auto-invocation (via `description`)

If the subagent's `description` is good (especially with "use proactively"), the main Claude chooses to use the subagent on its own:

`.claude/agents/python-tester.md`:
```yaml
---
name: python-tester
description: |
  Use proactively when user wants to write, run, or debug Python
  tests with pytest.
tools: Read, Edit, Bash, Grep, Glob
model: sonnet
---
```

**Prompt without mentioning the subagent:**

```
I need tests for the compute_discount function in
app/core/pricing.py.
```

Claude detects "tests" + "Python (pytest implied by CLAUDE.md)" and delegates to `python-tester` automatically.

### Form 3 — Parallel orchestration via the Task tool

When you want **multiple** subagents (named or ephemeral) working at the same time on independent dimensions, ask for parallel orchestration via the Task tool:

```
Run in parallel via the Task tool:

1. Research official documentation about rate limiting in FastAPI
   (look for slowapi, fastapi-limiter, and custom approaches).

2. Explore this project's codebase and identify:
   (a) where similar features have already been implemented,
   (b) existing middleware patterns,
   (c) corresponding tests.

3. Analyze security and performance risks of adding
   rate limiting to ALL /api/* routes.

When the 3 return, synthesize into a single implementation plan
and present it to me for approval BEFORE coding anything.
```

**When to use:** tasks with several **independent** dimensions (research + analysis + risk analysis), where one's output is NOT needed by the next. Multi-agent multiplies cost, so it only pays off when parallelism is real.

### Form 4 — Sequential orchestration (pipeline pattern)

When each stage **depends on the output of the previous one**, run subagents sequentially. Each agent receives the previous one's result as input and adds value before passing the work forward.

Sequential orchestration trades parallelism for **information flow**. It's the right pattern when:

- Stage N cannot start without stage N-1's result (research → architecture → implementation)
- You want a **handoff** with isolated context at each stage (each agent sees only what it needs)
- The pipeline encodes a **process** you want repeatable (e.g., the 4-step bug protocol)

#### Three ways to express a pipeline

**a) Single prompt, Claude orchestrates internally**

```
Run this pipeline sequentially via the Task tool. Each step
must wait for the previous one and use its output as input:

Step 1 — Spawn an "investigator" agent:
  "Describe how pagination works in this project. List every
  file in the request flow for GET /users. Do NOT fix anything."

Step 2 — After Step 1 returns, spawn a "hypothesizer" agent
with Step 1's output as input:
  "Given this flow description, list the 3 most likely
  hypotheses for the off-by-one bug. For each, state what
  evidence would confirm or refute it. Do NOT fix anything."

Step 3 — After Step 2 returns, spawn a "reproducer" agent
with the top hypothesis as input:
  "Write a pytest test that reproduces the bug under this
  hypothesis. The test MUST fail in the current state."

Step 4 — After Step 3 returns, spawn a "fixer" agent
with the failing test as input:
  "Fix the bug with the smallest possible change. Keep the
  Step 3 test passing. Do not touch unrelated files."

Show me the final consolidated report at the end.
```

**b) Manual chaining (user controls each handoff)**

You prompt agent 1, read its output, then prompt agent 2 with that output. Slower wall-clock time, but you supervise every transition.

```
# Prompt 1
@investigator Describe how pagination works in this project.
List every file in the GET /users flow.

# (after reading the response, user prompts the next one)

# Prompt 2
@hypothesizer Given the flow below, list 3 hypotheses for the
off-by-one bug, ranked by probability.

<paste investigator's output here>

# Prompt 3
@reproducer For hypothesis #1, write a failing pytest test.

# Prompt 4
@fixer Fix it. Keep the test passing. Touch nothing else.
```

**c) Codified as a slash command (repeatable pipeline)**

When the pipeline is something the team runs often, freeze it as a slash command so it's one keystroke away:

```yaml
# .claude/commands/bug-pipeline.md
---
description: Full 4-step bug protocol via subagents
allowed-tools: Task, Read, Edit, Bash, Grep, Glob
---

Run the 4-step bug protocol sequentially for: $ARGUMENTS

Step 1 — Investigator (Task tool, isolated context):
  Describe the flow involved in "$ARGUMENTS".
  List all files. Do NOT fix.

Step 2 — Hypothesizer (Task tool, receives Step 1 output):
  Given the investigator's flow description, list 3 hypotheses
  ranked by probability. Do NOT fix.

Step 3 — Reproducer (Task tool, receives top hypothesis):
  Write a failing pytest test.

Step 4 — Fixer (Task tool, receives failing test):
  Smallest fix. Keep test green. Touch nothing else.

End with: a Markdown report containing all 4 outputs.
```

Usage: `/bug-pipeline pagination off-by-one in /users`

#### When sequential beats parallel

| Symptom in your task | Pattern |
|---|---|
| "Each stage builds on the previous" | Sequential |
| "These three could run independently" | Parallel |
| "I need an audit AFTER the implementation" | Sequential |
| "I need three opinions BEFORE deciding" | Parallel |
| "Pipeline I run weekly" | Sequential, codified as slash command |
| "One-off exploration of options" | Parallel, ephemeral |

#### Cost considerations

Sequential pipelines spend **fewer tokens than parallel** when the same work would otherwise be done by one big prompt — because each subagent has an isolated, smaller context. But total **wall-clock time** is the sum of stages, not the max. Use sequential when the information flow is real, not just for the sake of it.

### How to decide which form to use

| Situation | Recommended form |
|---|---|
| You know exactly the right subagent | Explicit `@name` (Form 1) |
| You describe the task and have a proactive subagent configured | Auto-invocation (Form 2) |
| The task has multiple **independent** dimensions | Parallel via Task tool (Form 3) |
| Each stage **depends on** the previous one's output | Sequential pipeline (Form 4) |
| You run the same workflow often | Codify it as a slash command (Form 4c) |
| You want to isolate context and not pollute the main session | Any of the four (subagents always isolate) |

---

## Combining Skills + Subagents + MCP

Real cases combine several mechanisms. Examples:

### Case 1 — Production bug from a Jira issue

```
Pull issue ENG-1234 from Jira and fix the bug following the
protocol: understand, hypothesize, reproduce, fix.
When done, open a PR on GitHub using 'gh' with a structured
description.
```

**What happens:**
- **Jira MCP** is called to fetch the issue
- **`bug-protocol` skill** (if it exists) or the main Claude follows the protocol
- **`python-tester` subagent** (if proactive) writes the regression test
- **GitHub MCP** or the `gh` CLI opens the PR

### Case 2 — Refactoring with a security review

```
Migrate all /api/v1 endpoints to /api/v2, changing the error
pattern to Problem+JSON (RFC 7807).
Use Plan Mode.
After implementation, ask @security-reviewer to audit and
bring me both reports (plan + audit) BEFORE the commit.
```

**What happens:**
- Claude enters **Plan Mode** and proposes a plan
- You approve
- Claude implements
- The **`security-reviewer` subagent** is invoked explicitly to audit
- You receive both artifacts before the commit

### Case 3 — Onboarding a new feature

```
For the "push notifications for funding calls" feature described
in @docs/features/push-notifications.md:

1. Generate the user stories using the standard template
   (use proactively the user-stories skill if it exists).

2. Research in parallel via Task: 
   (a) push libraries for React Native + Expo, 
   (b) Node backend libs for FCM/APNs, 
   (c) Brazilian LGPD privacy requirements for notifications.

3. Synthesize an implementation plan across 3 sprints.

Do NOT write code yet. I want to validate the plan first.
```

**What happens:**
- The **`user-stories` skill** auto-invokes to generate the stories
- The **Task tool** spawns 3 clones in parallel for the research
- The final synthesis is done by the main Claude
- Nothing is coded until your approval

### Case 4 — Sequential pipeline: from spec to PR

```
For the spec in @docs/specs/order-export.md, run this pipeline
sequentially via Task. Each step waits for the previous and
uses its output as input:

Step 1 — @architect:
  Read the spec. Propose architecture in Markdown
  (modules, contracts, data flow). Do NOT code.

Step 2 — @security-reviewer (receives Step 1 output):
  Audit the proposed architecture. List risks and mitigations.
  Do NOT code.

Step 3 — STOP and show me both reports.
  I will approve or request changes before continuing.

Step 4 — (only after my approval) @implementer:
  Implement the approved architecture incorporating
  mitigations from Step 2. Plan Mode before each file.

Step 5 — @python-tester (receives implementation):
  Write tests covering the implementation and the security
  mitigations. Run pytest until everything passes.

Step 6 — @docs-writer (receives final code):
  Update CLAUDE.md and the README with the new module.
  Open a PR via 'gh' with a structured description.
```

**What happens:**
- Each stage runs in isolation with only its predecessor's output as context
- A **human gate** at Step 3 prevents waste on a bad plan
- The pipeline encodes a **process** — repeatable for the next spec
- Total cost is lower than running everything in a single bloated context, because each subagent sees only what it needs
- If your team runs this often, codify Steps 1–6 as `.claude/commands/spec-to-pr.md`

---

## Pocket cheatsheet

Print it and pin it on your desk.

```
═══ DEV TASK ══════════════════════════
[CONTEXT]    → stack, file, libs
[TASK]       → 1 verb + object
[CONSTRAINTS] → what NOT + required libs
[ACCEPTANCE] → how we know it is done

═══ BUG ═══════════════════════════════
1. UNDERSTAND   → "describe, do not fix"
2. HYPOTHESIZE  → "3 hypotheses, no fix"
3. REPRODUCE    → "test that FAILS"
4. FIX          → "smallest fix possible"

═══ TESTS ═════════════════════════════
[CONTEXT]              → function, framework
[TASK]                 → target file
[SCENARIOS happy path] → valid inputs
[SCENARIOS edges]      → None, empty, limit, error
[CONSTRAINTS]          → patterns, test libs

═══ USER STORIES ══════════════════════
[PRODUCT CONTEXT]    → what it is, for whom
[PERSONA]            → role, context, pain
[JOBS-TO-BE-DONE]    → when / want / so that
[SCOPE]              → inside × outside
[TASK]               → how many, granularity
[OUTPUT FORMAT]      → Job Story + Gherkin
[QUALITY CRITERIA]   → INVEST, explicit value

═══ SKILLS ════════════════════════════
✓ Use natural language with keywords
✗ Do not invoke by name

═══ SUBAGENTS ═════════════════════════
@name        → explicit
proactive    → auto-invocation by description
Task // par. → independent dimensions
Task seq.    → each stage feeds the next
/command     → codified pipeline (repeatable)
```

---

*Reference document for the Claude Code track. Use, copy, adapt. Suggestions: open a PR in the course repository.*