# 📄 Spec Kit Cheatsheet

Quick reference for [GitHub Spec Kit](https://github.com/github/spec-kit) — a toolkit for **spec-driven development**, where you write the intent (constitution → spec → plan → tasks) before code, and the AI agent implements against those artifacts.

> Companion to [`prompting_tips.md`](prompting_tips.md). That handbook covers general Claude Code prompt templates (development tasks, bug hunts, tests, user stories); this sheet is the **spec-driven workflow** that turns intent into constitution → spec → plan → tasks before any code is written.

---

## 🔧 Install

```bash
# One-shot, no install (recommended to try it out)
uvx --from git+https://github.com/github/spec-kit.git specify init my-project --integration copilot

# Or install the CLI globally
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git

# Pin a specific release
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git@vX.Y.Z
```

Requires [`uv`](https://docs.astral.sh/uv/). Spec Kit works with 30+ AI coding agents — run `specify integration list` to see the token for yours (e.g. `copilot`, `claude`, `codex`).

---

## ⌨️ CLI Commands

| Command | What it does |
| --- | --- |
| `specify init my-project --integration copilot` | Scaffold a **new** project with Spec Kit + your agent's slash commands |
| `specify init . --integration copilot` | Initialize Spec Kit **in the current directory** |
| `specify integration list` | List all supported AI agent integrations |
| `specify self check` | Verify the CLI and required tools are installed |
| `specify self upgrade --dry-run` | Preview a CLI upgrade without applying it |
| `specify self upgrade` | Upgrade the CLI to the latest release |
| `specify extension search` / `add <name>` | Find / install community extensions |
| `specify preset search` / `add <name>` | Find / install template presets |
| `specify bundle install <bundle-id>` | Install a reusable spec bundle (`bundle list`, `update`, `remove`) |

---

## 🪄 Slash Commands (run inside your AI agent)

Use these **in order**. Steps marked *optional* de-risk the process on non-trivial features.

| Order | Command | Purpose |
| --- | --- | --- |
| 1 | `/speckit.constitution` | Create/update the project's governing principles & guidelines |
| 2 | `/speckit.specify` | Define **what** to build — requirements and user stories (not tech) |
| 3 *(optional)* | `/speckit.clarify` | Resolve underspecified areas **before** planning |
| 4 | `/speckit.plan` | Produce the technical plan with your **chosen tech stack** |
| 5 | `/speckit.tasks` | Generate an actionable, ordered task list |
| 6 *(optional)* | `/speckit.analyze` | Cross-artifact consistency & coverage analysis |
| 6 *(optional)* | `/speckit.checklist` | Generate a custom quality checklist for completeness/clarity |
| 7 | `/speckit.implement` | Execute all tasks to build the feature per the plan |
| — *(optional)* | `/speckit.taskstoissues` | Convert the task list into GitHub issues |
| — *(optional)* | `/speckit.converge` | Re-assess the codebase vs. spec/plan/tasks and append remaining work |

---

## 🧭 Worked Example — a "Taskify" team todo app

**1. Constitution** — set the rules once:

```text
/speckit.constitution Create principles focused on: small, testable increments;
library-first design; every feature covered by tests before merge; and clear,
documented public APIs.
```

**2. Specify** — describe the *what* and *why*, avoid tech choices:

```text
/speckit.specify Build Taskify, a team productivity board. Users pick from 5
predefined team members and drag task cards across four columns: To Do,
In Progress, In Review, Done. Cards show assignee and title. No login for the MVP.
```

**3. Clarify** *(optional)* — let the agent interrogate the gaps:

```text
/speckit.clarify
```

**4. Plan** — now commit to a stack:

```text
/speckit.plan Use React + Vite on the frontend and a local in-memory store for
the MVP (no database yet). Keep everything runnable with a single `npm run dev`.
```

**5. Tasks** — turn the plan into ordered, checkable work:

```text
/speckit.tasks
```

**6. Analyze** *(optional)* — sanity-check the artifacts line up:

```text
/speckit.analyze
```

**7. Implement** — build it:

```text
/speckit.implement
```

---

## 📁 Artifacts Created

```
.specify/                  # Spec Kit config & templates
  templates/overrides/     # project-local template overrides
specs/                     # spec-driven artifacts
  constitution.md          # governing principles      (from /speckit.constitution)
  spec.md                  # requirements & user stories (from /speckit.specify)
  plan.md                  # technical implementation plan (from /speckit.plan)
  tasks.md                 # ordered task list         (from /speckit.tasks)
```

**Template resolution** (highest priority first): project overrides → presets → extensions → Spec Kit core defaults.

---

## ✅ Rules of Thumb

- **Keep `/speckit.specify` tech-free.** The *what*/*why* lives in the spec; the *how* lives in the plan.
- **Run `/speckit.clarify` before `/speckit.plan`** on anything non-trivial — cheaper to fix ambiguity in the spec than in code.
- **Small phases win.** A tight constitution + narrow spec produces task lists the agent can finish and you can verify.
- **Re-run `/speckit.analyze`** after editing any artifact by hand to catch drift between spec, plan, and tasks.
