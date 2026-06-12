# Claude Code Kit

A curated collection of **agents**, **skills**, and **settings** that supercharge [Claude Code](https://docs.claude.com/en/docs/claude-code). The goal of this kit is to gather battle-tested subagents, reusable skills, and sensible default settings in one place so practitioners can drop them into their local Claude Code environment and immediately boost productivity.

## 🚀 What's Inside

| Component | Count | Location | Installs to |
| --- | --- | --- | --- |
| **Agents** | 133 specialized subagents | [`agents/`](agents/) | `~/.claude/agents/` |
| **Skills** | 197 reusable skills | [`skills/`](skills/) | `~/.claude/skills/` |
| **Settings** | Global config + permissions | [`settings/`](settings/) | `~/.claude/` |

- **Agents** are role-focused subagents (language experts, reviewers, architects, etc.) that Claude Code can delegate work to.
- **Skills** are self-contained capability packages (each with a `SKILL.md`) that teach Claude how to use a specific tool, library, or workflow.
- **Settings** provide a ready-to-use `settings.json` with environment tuning, permission guardrails, and a status line.

## 🔧 Installation (user-level / global)

These steps install everything at the **user level** so the agents, skills, and settings are available across **all** your projects (Claude Code reads from `~/.claude/`).

> Run the commands from the root of this repository.

```bash
# 1. Create the target directories if they don't exist
mkdir -p ~/.claude/agents ~/.claude/skills

# 2. Copy all agents (the .md files) into the user agents folder
cp -v agents/*.md ~/.claude/agents/

# 3. Copy all skills (each skill is its own directory) into the user skills folder
cp -rv skills/* ~/.claude/skills/

# 4. Copy the global settings into ~/.claude/
cp -v settings/settings.json ~/.claude/settings.json
```

### Using `rsync` (recommended for re-syncing / updates)

`rsync` is idempotent and lets you re-run installs to pick up updates without clobbering unrelated files:

```bash
rsync -av agents/  ~/.claude/agents/
rsync -av skills/  ~/.claude/skills/
rsync -av settings/settings.json       ~/.claude/settings.json
```

> **Heads up — settings.** Copying `settings.json` overwrites your existing global Claude Code settings. If you already have a customized `~/.claude/settings.json`, back it up first (`cp ~/.claude/settings.json ~/.claude/settings.json.bak`) and merge by hand instead of overwriting.

> **Note.** The `agents/` folder also contains a `CLAUDE.md` and an `AGENTS-REFERENCE.md`. These are reference/instruction docs, not agents — you can skip copying them, or copy them deliberately if you want their guidance.

### Status Line

The kit ships two richer status-line scripts that replace the plain `jq` one-liner bundled in `settings.json`. Both display model name, working directory, git branch (staged / modified counts), a 10-block context bar, session cost, and rate-limit percentages — all in two compact lines.

**Linux / macOS**

```bash
# 1. Copy the script
cp settings/statusline.sh ~/.claude/statusline.sh
chmod +x ~/.claude/statusline.sh
```

Then point `statusLine` in `~/.claude/settings.json` to it:

```json
"statusLine": {
  "type": "command",
  "command": "~/.claude/statusline.sh"
}
```

Requires `jq` (`brew install jq` / `apt install jq`). `git` is optional — the script degrades gracefully when not in a repo.

**Windows (PowerShell)**

```powershell
# 1. Copy the script
Copy-Item settings\statusline.ps1 "$env:USERPROFILE\.claude\statusline.ps1"
```

Then point `statusLine` in `%USERPROFILE%\.claude\settings.json` to it:

```json
"statusLine": {
  "type": "command",
  "command": "powershell -NoProfile -ExecutionPolicy Bypass -File C:/Users/<YourName>/.claude/statusline.ps1"
}
```

Replace `<YourName>` with your Windows username (forward slashes in the JSON path). If you have PowerShell 7 installed, swap `powershell` for `pwsh`. Windows Terminal is recommended for correct ANSI / UTF-8 rendering. No `jq` required — the script uses PowerShell's native JSON parser.

After installing, restart Claude Code (or start a new session). The agents become available for delegation, and skills trigger automatically based on their descriptions.

---

## 🤖 Agents

133 subagents grouped by domain. Each links to its definition file.

### Meta / Orchestration

| Agent | Description |
| --- | --- |
| [grand-architect](agents/grand-architect.md) | Meta-orchestrator that plans complex features, breaks down large tasks, and coordinates multiple agents. |
| [tech-lead-orchestrator](agents/tech-lead-orchestrator.md) | Senior tech lead that analyzes projects and returns structured task breakdowns for agent coordination. |
| [project-analyst](agents/project-analyst.md) | Analyzes unfamiliar codebases to detect frameworks, tech stacks, and architecture for routing. |
| [code-archaeologist](agents/code-archaeologist.md) | Explores and documents unfamiliar, legacy, or complex codebases with full risk/action reports. |

### Languages & Runtimes

| Agent | Description |
| --- | --- |
| [python-pro](agents/python-pro.md) | Type-safe, production-ready Python with modern async patterns and extensive typing. |
| [typescript-pro](agents/typescript-pro.md) | Advanced TypeScript type system, full-stack development, and build optimization. |
| [javascript-pro](agents/javascript-pro.md) | Modern ES2023+ JavaScript for browser, Node.js, and full-stack apps. |
| [golang-pro](agents/golang-pro.md) | Idiomatic Go for concurrent, high-performance, cloud-native systems. |
| [rust-engineer](agents/rust-engineer.md) | Rust systems programming with memory safety and zero-cost abstractions. |
| [cpp-pro](agents/cpp-pro.md) | High-performance modern C++20/23 and template metaprogramming. |
| [java-pro](agents/java-pro.md) | Modern Java 21+ with virtual threads, pattern matching, and Spring Boot 3.x. |
| [java-architect](agents/java-architect.md) | Enterprise Java architecture across the Spring ecosystem and microservices. |
| [csharp-developer](agents/csharp-developer.md) | ASP.NET Core APIs and cloud-native .NET with clean architecture. |
| [dotnet-core-expert](agents/dotnet-core-expert.md) | Cloud-native .NET Core microservices with minimal APIs. |
| [dotnet-framework-4.8-expert](agents/dotnet-framework-4.8-expert.md) | Legacy .NET Framework 4.8 maintenance and modernization. |
| [php-pro](agents/php-pro.md) | Modern PHP 8.3+ with strong typing and enterprise frameworks. |
| [kotlin-specialist](agents/kotlin-specialist.md) | Kotlin coroutines, multiplatform, and Android development. |
| [swift-expert](agents/swift-expert.md) | Native iOS/macOS/server-side Swift with advanced concurrency. |
| [elixir-expert](agents/elixir-expert.md) | Fault-tolerant concurrent systems with OTP and Phoenix. |
| [sql-pro](agents/sql-pro.md) | Complex SQL query optimization and schema design across major engines. |

### Frameworks (Frontend / Backend / Mobile)

| Agent | Description |
| --- | --- |
| [react-specialist](agents/react-specialist.md) | React 18+ patterns, performance optimization, and server components. |
| [react-coder](agents/react-coder.md) | Simplicity-first React 19 components using internal UI packages. |
| [vue-expert](agents/vue-expert.md) | Vue 3 Composition API, reactivity, and Nuxt 3 development. |
| [angular-architect](agents/angular-architect.md) | Enterprise Angular 15+ with complex state and micro-frontends. |
| [nextjs-developer](agents/nextjs-developer.md) | Production Next.js 14+ with App Router and server components. |
| [frontend-developer](agents/frontend-developer.md) | Robust, scalable React frontend components and UX. |
| [fullstack-developer](agents/fullstack-developer.md) | End-to-end feature delivery from database to UI. |
| [backend-developer](agents/backend-developer.md) | Scalable API development and microservices. |
| [django-developer](agents/django-developer.md) | Django 4+ apps and REST APIs with async views. |
| [rails-expert](agents/rails-expert.md) | Rails apps with Hotwire reactivity and idiomatic patterns. |
| [laravel-specialist](agents/laravel-specialist.md) | Laravel 10+ with Eloquent, queues, and enterprise features. |
| [laravel-backend-expert](agents/laravel-backend-expert.md) | Laravel backend controllers, services, and Eloquent models. |
| [laravel-eloquent-expert](agents/laravel-eloquent-expert.md) | Laravel Eloquent schemas, relationships, and query tuning. |
| [spring-boot-engineer](agents/spring-boot-engineer.md) | Enterprise Spring Boot 3+ microservices and reactive patterns. |
| [wordpress-master](agents/wordpress-master.md) | WordPress themes, plugins, headless APIs, and scaling. |
| [mobile-developer](agents/mobile-developer.md) | Cross-platform mobile with React Native and Flutter. |
| [mobile-app-developer](agents/mobile-app-developer.md) | Native and cross-platform iOS/Android development. |
| [flutter-expert](agents/flutter-expert.md) | Cross-platform Flutter 3+ with custom UI and state management. |
| [electron-pro](agents/electron-pro.md) | Electron desktop apps with native OS integration and distribution. |
| [cli-developer](agents/cli-developer.md) | Command-line tools with intuitive design and cross-platform support. |

### Architecture & API Design

| Agent | Description |
| --- | --- |
| [architect-reviewer](agents/architect-reviewer.md) | System design validation, architectural patterns, and scalability analysis. |
| [api-designer](agents/api-designer.md) | Scalable, developer-friendly REST and GraphQL API design. |
| [graphql-architect](agents/graphql-architect.md) | GraphQL schema design, federation, and query performance. |
| [microservices-architect](agents/microservices-architect.md) | Distributed microservice ecosystems and communication patterns. |
| [websocket-engineer](agents/websocket-engineer.md) | Scalable real-time WebSocket architectures and low-latency messaging. |
| [database-architect](agents/database-architect.md) | Data layer design, technology selection, and schema modeling. |

### Data & Databases

| Agent | Description |
| --- | --- |
| [database-administrator](agents/database-administrator.md) | High-availability DBs, performance tuning, and disaster recovery. |
| [database-optimizer](agents/database-optimizer.md) | Query optimization, indexing, caching, and partitioning. |
| [postgres-pro](agents/postgres-pro.md) | PostgreSQL performance, replication, and advanced features. |
| [data-engineer](agents/data-engineer.md) | Scalable data pipelines, ETL/ELT, and data infrastructure. |
| [data-analyst](agents/data-analyst.md) | Business data insights, dashboards, and statistical analysis. |
| [data-scientist](agents/data-scientist.md) | Statistical analysis, ML, and data storytelling. |
| [data-researcher](agents/data-researcher.md) | Discover, collect, and validate data from multiple sources. |

### AI / ML

| Agent | Description |
| --- | --- |
| [ai-engineer](agents/ai-engineer.md) | AI system design, model implementation, and production deployment. |
| [ml-engineer](agents/ml-engineer.md) | Production ML training pipelines, serving, and retraining. |
| [machine-learning-engineer](agents/machine-learning-engineer.md) | Model deployment, serving infrastructure, and edge inference. |
| [mlops-engineer](agents/mlops-engineer.md) | ML infrastructure, CI/CD, versioning, and experiment tracking. |
| [llm-architect](agents/llm-architect.md) | Production LLM systems, fine-tuning, RAG, and inference serving. |
| [nlp-engineer](agents/nlp-engineer.md) | NLP/NLU/NLG with transformer models and production pipelines. |
| [prompt-engineer](agents/prompt-engineer.md) | Design, optimize, and evaluate prompts for production LLMs. |
| [mcp-developer](agents/mcp-developer.md) | Model Context Protocol server and client development. |

### Infrastructure / DevOps / Cloud

| Agent | Description |
| --- | --- |
| [cloud-architect](agents/cloud-architect.md) | Multi-cloud (AWS/Azure/GCP) IaC, FinOps, and architecture. |
| [devops-engineer](agents/devops-engineer.md) | CI/CD, containerization, monitoring, and automation. |
| [deployment-engineer](agents/deployment-engineer.md) | CI/CD pipelines and zero-downtime deployment strategies. |
| [platform-engineer](agents/platform-engineer.md) | Internal developer platforms, golden paths, and self-service. |
| [kubernetes-architect](agents/kubernetes-architect.md) | Cloud-native K8s, GitOps, service mesh, and multi-tenancy. |
| [kubernetes-specialist](agents/kubernetes-specialist.md) | Production-grade K8s deployments and cluster management. |
| [docker-expert](agents/docker-expert.md) | Container image building, optimization, and orchestration. |
| [terraform-engineer](agents/terraform-engineer.md) | Multi-cloud Terraform IaC and state management. |
| [terragrunt-expert](agents/terragrunt-expert.md) | Terragrunt orchestration and DRY multi-environment IaC. |
| [azure-infra-engineer](agents/azure-infra-engineer.md) | Azure infrastructure, Entra ID, Bicep, and PowerShell automation. |
| [network-engineer](agents/network-engineer.md) | Cloud/hybrid network design, security, and troubleshooting. |
| [cost-optimizer](agents/cost-optimizer.md) | Cloud cost analysis, resource optimization, and scaling plans. |
| [windows-infra-admin](agents/windows-infra-admin.md) | Windows Server, Active Directory, DNS, DHCP, and Group Policy. |
| [iot-engineer](agents/iot-engineer.md) | Connected device architectures, edge computing, and IoT platforms. |

### PowerShell / Windows Automation

| Agent | Description |
| --- | --- |
| [powershell-5.1-expert](agents/powershell-5.1-expert.md) | PowerShell 5.1 Windows automation with RSAT modules. |
| [powershell-7-expert](agents/powershell-7-expert.md) | Cross-platform PowerShell 7+ cloud automation and CI/CD. |
| [powershell-module-architect](agents/powershell-module-architect.md) | PowerShell module architecture and reusable automation libraries. |
| [powershell-security-hardening](agents/powershell-security-hardening.md) | Hardening PowerShell automation and remoting security. |
| [powershell-ui-architect](agents/powershell-ui-architect.md) | WinForms/WPF/TUI interfaces for PowerShell tools. |

### Reliability / Operations / Incident Response

| Agent | Description |
| --- | --- |
| [sre-engineer](agents/sre-engineer.md) | SLOs, automation, and resilient self-healing systems. |
| [observability-engineer](agents/observability-engineer.md) | Monitoring, logging, tracing, and SLI/SLO management. |
| [incident-responder](agents/incident-responder.md) | Active security breach and outage response and recovery. |
| [devops-incident-responder](agents/devops-incident-responder.md) | Production incident diagnosis and postmortems. |
| [chaos-engineer](agents/chaos-engineer.md) | Controlled failure experiments and resilience validation. |
| [error-detective](agents/error-detective.md) | Diagnose errors, correlate across services, and find root causes. |
| [debugger](agents/debugger.md) | Diagnose and fix bugs from error logs and stack traces. |

### Security

| Agent | Description |
| --- | --- |
| [security-engineer](agents/security-engineer.md) | DevSecOps, cloud security, and zero-trust architecture. |
| [security-auditor](agents/security-auditor.md) | Security assessments, compliance validation, and risk management. |
| [security-specialist](agents/security-specialist.md) | Mobile (RN/Expo) security audits and OWASP Mobile Top 10. |
| [penetration-tester](agents/penetration-tester.md) | Authorized offensive testing and vulnerability exploitation. |
| [ad-security-reviewer](agents/ad-security-reviewer.md) | Active Directory security posture and privilege escalation audit. |
| [compliance-auditor](agents/compliance-auditor.md) | GDPR, HIPAA, PCI DSS, SOC 2, and ISO compliance. |

### Quality / Review / Testing

| Agent | Description |
| --- | --- |
| [code-reviewer](agents/code-reviewer.md) | Code quality, security, and best-practice review across languages. |
| [senior-code-reviewer](agents/senior-code-reviewer.md) | Comprehensive senior-level fullstack code review. |
| [qa-expert](agents/qa-expert.md) | Test strategy, manual/automated testing, and quality metrics. |
| [test-automator](agents/test-automator.md) | Automated test frameworks and CI/CD test integration. |
| [test-generator](agents/test-generator.md) | Smart test generation for RN/Expo with ROI prioritization. |
| [refactoring-specialist](agents/refactoring-specialist.md) | Transform complex/duplicated code while preserving behavior. |
| [legacy-modernizer](agents/legacy-modernizer.md) | Incremental legacy migration and technical-debt reduction. |
| [dependency-manager](agents/dependency-manager.md) | Dependency auditing, conflict resolution, and bundle optimization. |

### Performance & Build

| Agent | Description |
| --- | --- |
| [performance-engineer](agents/performance-engineer.md) | System optimization, profiling, and scalability engineering. |
| [performance-optimizer](agents/performance-optimizer.md) | Bottleneck identification and workload optimization. |
| [performance-enforcer](agents/performance-enforcer.md) | Bundle size and performance budget tracking for RN/Expo. |
| [performance-prophet](agents/performance-prophet.md) | Predictive performance analysis for RN/Expo before deployment. |
| [build-engineer](agents/build-engineer.md) | Build performance optimization and faster compilation. |
| [dx-optimizer](agents/dx-optimizer.md) | Developer workflow, feedback loops, and DX metrics. |
| [tooling-engineer](agents/tooling-engineer.md) | Developer tools, CLIs, code generators, and IDE extensions. |
| [git-workflow-manager](agents/git-workflow-manager.md) | Git workflows, branching strategies, and merge management. |

### UI / UX / Accessibility / Design

| Agent | Description |
| --- | --- |
| [ui-designer](agents/ui-designer.md) | Visual interfaces, design systems, and component libraries. |
| [ux-researcher](agents/ux-researcher.md) | User research, usability testing, and persona development. |
| [accessibility-tester](agents/accessibility-tester.md) | WCAG compliance and assistive-technology testing. |
| [a11y-enforcer](agents/a11y-enforcer.md) | WCAG 2.2 accessibility enforcement for RN/Expo apps. |
| [design-token-guardian](agents/design-token-guardian.md) | Detect hardcoded styles and enforce design tokens in RN/Expo. |

### Documentation

| Agent | Description |
| --- | --- |
| [documentation-engineer](agents/documentation-engineer.md) | Documentation-as-code systems and automated generation. |
| [documentation-specialist](agents/documentation-specialist.md) | READMEs, API specs, architecture guides, and user manuals. |
| [technical-writer](agents/technical-writer.md) | API references, user guides, and SDK documentation. |

### Specialized Engineering

| Agent | Description |
| --- | --- |
| [fintech-engineer](agents/fintech-engineer.md) | Financial systems, payments, and regulatory compliance. |
| [slack-expert](agents/slack-expert.md) | Slack apps, API integrations, and bot security review. |

### Product / Business / Research

| Agent | Description |
| --- | --- |
| [product-manager](agents/product-manager.md) | Product strategy, feature prioritization, and roadmaps. |
| [project-manager](agents/project-manager.md) | Project plans, risk management, and stakeholder coordination. |
| [scrum-master](agents/scrum-master.md) | Agile facilitation, ceremonies, and velocity improvement. |
| [business-analyst](agents/business-analyst.md) | Business process analysis and requirements gathering. |
| [customer-success-manager](agents/customer-success-manager.md) | Customer health, retention, and lifetime value. |
| [sales-engineer](agents/sales-engineer.md) | Technical pre-sales, solution architecture, and POCs. |
| [content-marketer](agents/content-marketer.md) | SEO content strategy and multi-channel campaigns. |
| [legal-advisor](agents/legal-advisor.md) | Contracts, compliance, IP strategy, and legal risk. |
| [market-researcher](agents/market-researcher.md) | Market analysis, consumer behavior, and opportunity sizing. |
| [competitive-analyst](agents/competitive-analyst.md) | Competitor analysis and competitive positioning. |
| [research-analyst](agents/research-analyst.md) | Multi-source research synthesis and trend identification. |
| [trend-analyst](agents/trend-analyst.md) | Emerging patterns, industry shifts, and future scenarios. |
| [search-specialist](agents/search-specialist.md) | Advanced search strategies and targeted information retrieval. |
| [scientific-literature-researcher](agents/scientific-literature-researcher.md) | Evidence-grounded answers from full-text research papers. |

---

## 🧩 Skills

197 skills, each packaged as a directory containing a `SKILL.md` (and supporting scripts/templates). Skills trigger automatically based on their descriptions. Grouped below by domain.

<details>
<summary><strong>Token Efficiency / Caveman</strong></summary>

| Skill | Description |
| --- | --- |
| [caveman](skills/caveman/) | Ultra-compressed communication mode (~75% token reduction). Lite / full / ultra / wenyan variants. Trigger: `/caveman`. |
| [caveman-commit](skills/caveman-commit/) | Terse Conventional Commits messages. ≤50-char subject, body only when "why" isn't obvious. Trigger: `/caveman-commit`. |
| [caveman-compress](skills/caveman-compress/) | Compress `.md` memory files to caveman prose (~46% input-token savings). Backs up originals. Trigger: `/caveman-compress <file>`. |
| [caveman-help](skills/caveman-help/) | Quick-reference card for all caveman modes, skills, and commands. One-shot display. Trigger: `/caveman-help`. |
| [caveman-review](skills/caveman-review/) | Ultra-compressed PR review: one line per finding — location, problem, fix. Trigger: `/caveman-review`. |
| [caveman-stats](skills/caveman-stats/) | Show real token usage and estimated savings for the current session via hook. Trigger: `/caveman-stats`. |
| [cavecrew](skills/cavecrew/) | Decision guide for delegating to caveman-style subagents (~60% smaller tool results vs vanilla agents). |

</details>

<details>
<summary><strong>Claude Code Workflow & Engineering Practice</strong></summary>

| Skill | Description |
| --- | --- |
| [brainstorming](skills/brainstorming/) | Explore intent, requirements, and design before any creative/build work. |
| [writing-plans](skills/writing-plans/) | Turn a spec into a multi-step implementation plan before coding. |
| [executing-plans](skills/executing-plans/) | Execute a written plan in a separate session with review checkpoints. |
| [subagent-driven-development](skills/subagent-driven-development/) | Execute plans with independent tasks in the current session. |
| [dispatching-parallel-agents](skills/dispatching-parallel-agents/) | Handle 2+ independent tasks with no shared state in parallel. |
| [test-driven-development](skills/test-driven-development/) | TDD before writing implementation code for features/bugfixes. |
| [systematic-debugging](skills/systematic-debugging/) | Structured debugging before proposing fixes. |
| [verification-before-completion](skills/verification-before-completion/) | Require verification commands before claiming work is done. |
| [requesting-code-review](skills/requesting-code-review/) | Verify work meets requirements before merging. |
| [receiving-code-review](skills/receiving-code-review/) | Rigorously evaluate review feedback before implementing. |
| [finishing-a-development-branch](skills/finishing-a-development-branch/) | Decide how to integrate completed work (merge/PR/cleanup). |
| [using-git-worktrees](skills/using-git-worktrees/) | Create isolated workspaces via git worktrees. |
| [using-superpowers](skills/using-superpowers/) | Establish how to find and use skills at conversation start. |
| [writing-skills](skills/writing-skills/) | Create, edit, and verify skills before deployment. |
| [skill-creator](skills/skill-creator/) | Create, improve, eval, and benchmark skills. |
| [autoskill](skills/autoskill/) | Observe workflows via screenpipe and draft new skills. |
| [pi-agent](skills/pi-agent/) | Build with and use the Pi minimal terminal coding harness. |
| [mcp-builder](skills/mcp-builder/) | Build high-quality MCP servers (Python FastMCP / TS SDK). |
| [claude-api](skills/claude-api/) | Reference for the Claude API / Anthropic SDK: model IDs, pricing, params, streaming, tool use. |

</details>

<details>
<summary><strong>Expo / React Native Development</strong></summary>

| Skill | Description |
| --- | --- |
| [building-native-ui](skills/building-native-ui/) | Build apps with Expo Router: styling, navigation, animations. |
| [native-data-fetching](skills/native-data-fetching/) | Network requests, React Query/SWR, caching, and offline support. |
| [add-app-clip](skills/add-app-clip/) | Add an iOS App Clip target to an Expo app. |
| [expo-api-routes](skills/expo-api-routes/) | Create API routes in Expo Router with EAS Hosting. |
| [expo-brownfield](skills/expo-brownfield/) | Integrate Expo/React Native into existing native apps. |
| [expo-cicd-workflows](skills/expo-cicd-workflows/) | Author EAS workflow YAML for build/deploy pipelines. |
| [expo-deployment](skills/expo-deployment/) | Deploy Expo apps to App Store, Play Store, and web. |
| [expo-dev-client](skills/expo-dev-client/) | Build and distribute Expo development clients. |
| [expo-module](skills/expo-module/) | Build Expo native modules/views (Swift, Kotlin, TS). |
| [expo-observe](skills/expo-observe/) | Add and query EAS Observe performance metrics. |
| [expo-tailwind-setup](skills/expo-tailwind-setup/) | Set up Tailwind v4 / NativeWind v5 in Expo. |
| [expo-ui-jetpack-compose](skills/expo-ui-jetpack-compose/) | Use Jetpack Compose views via `@expo/ui`. |
| [expo-ui-swift-ui](skills/expo-ui-swift-ui/) | Use SwiftUI views via `@expo/ui`. |
| [eas-update-insights](skills/eas-update-insights/) | Check EAS Update health: crash rates, installs, payload size. |
| [upgrading-expo](skills/upgrading-expo/) | Upgrade Expo SDK versions and fix dependency issues. |
| [use-dom](skills/use-dom/) | Run web code in a webview via Expo DOM components. |

</details>

<details>
<summary><strong>Web / Frontend / Design</strong></summary>

| Skill | Description |
| --- | --- |
| [frontend-design](skills/frontend-design/) | Distinctive, intentional visual design for new/existing UI. |
| [web-artifacts-builder](skills/web-artifacts-builder/) | Build complex multi-component HTML artifacts (React/Tailwind/shadcn). |
| [web-asset-generator](skills/web-asset-generator/) | Generate favicons, app icons (PWA), and Open Graph images. |
| [canvas-design](skills/canvas-design/) | Create visual art in PNG/PDF using design philosophy. |
| [algorithmic-art](skills/algorithmic-art/) | Generative/algorithmic art with p5.js. |
| [theme-factory](skills/theme-factory/) | Style artifacts (slides, docs, HTML) with preset/custom themes. |
| [brand-guidelines](skills/brand-guidelines/) | Apply Anthropic brand colors and typography to artifacts. |
| [generate-image](skills/generate-image/) | Generate/edit images with AI (FLUX, Nano Banana 2). |
| [infographics](skills/infographics/) | Create professional infographics with AI and iterative refinement. |
| [slack-gif-creator](skills/slack-gif-creator/) | Create animated GIFs optimized for Slack. |
| [playwright-test-automation](skills/playwright-test-automation/) | Browser automation and testing with Playwright. |
| [webapp-testing](skills/webapp-testing/) | Test/debug local web apps with Playwright. |

</details>

<details>
<summary><strong>Documents, Office & Publishing</strong></summary>

| Skill | Description |
| --- | --- |
| [docx](skills/docx/) | Create, read, and edit Word (.docx) documents. |
| [pptx](skills/pptx/) | Create, read, and edit PowerPoint (.pptx) presentations. |
| [xlsx](skills/xlsx/) | Open, read, edit, and create spreadsheets (.xlsx/.csv/.tsv). |
| [pdf](skills/pdf/) | Read, merge, split, fill, OCR, and create PDF files. |
| [markitdown](skills/markitdown/) | Convert office/media files to Markdown. |
| [liteparse](skills/liteparse/) | Local PDF/DOC parsing with bounding boxes and OCR for RAG. |
| [doc-coauthoring](skills/doc-coauthoring/) | Structured workflow for co-authoring documentation. |
| [markdown-mermaid-writing](skills/markdown-mermaid-writing/) | Markdown + Mermaid diagram writing standards. |
| [slides-generator](skills/slides-generator/) | Build animation-rich HTML presentations (or convert PPT). |
| [internal-comms](skills/internal-comms/) | Write internal communications (status reports, updates, FAQs). |

</details>

<details>
<summary><strong>Research, Search & Reasoning</strong></summary>

| Skill | Description |
| --- | --- |
| [research-lookup](skills/research-lookup/) | Look up current research via parallel-cli / Parallel Chat / Perplexity. |
| [paper-lookup](skills/paper-lookup/) | Search 10 academic paper databases via REST APIs. |
| [database-lookup](skills/database-lookup/) | Search 78 public scientific/biomedical/economic database APIs. |
| [literature-review](skills/literature-review/) | Systematic literature reviews across academic databases. |
| [citation-management](skills/citation-management/) | Search, validate, and format citations / BibTeX. |
| [pyzotero](skills/pyzotero/) | Manage Zotero reference libraries via the Web API. |
| [exa-search](skills/exa-search/) | Web/scholarly search and URL extraction via Exa. |
| [parallel-web](skills/parallel-web/) | Web search, extraction, enrichment, and deep research via parallel-cli. |
| [bgpt-paper-search](skills/bgpt-paper-search/) | Search papers with structured experimental data via BGPT MCP. |
| [open-notebook](skills/open-notebook/) | Self-hosted NotebookLM alternative for research/document analysis. |
| [paperzilla](skills/paperzilla/) | Project/paper recommendations and summaries in Paperzilla. |
| [scholar-evaluation](skills/scholar-evaluation/) | Evaluate scholarly work with the ScholarEval framework. |
| [peer-review](skills/peer-review/) | Structured, checklist-based manuscript/grant review. |
| [scientific-critical-thinking](skills/scientific-critical-thinking/) | Evaluate scientific claims and evidence quality. |
| [scientific-brainstorming](skills/scientific-brainstorming/) | Creative research ideation and interdisciplinary exploration. |
| [hypothesis-generation](skills/hypothesis-generation/) | Formulate testable hypotheses from observations. |
| [hypogenic](skills/hypogenic/) | Automated LLM-driven hypothesis generation/testing on data. |
| [consciousness-council](skills/consciousness-council/) | Multi-perspective "Mind Council" deliberation on decisions. |
| [what-if-oracle](skills/what-if-oracle/) | Structured What-If scenario branch analysis. |
| [dhdna-profiler](skills/dhdna-profiler/) | Extract cognitive/thinking patterns from text. |

</details>

<details>
<summary><strong>Scientific Writing & Publishing</strong></summary>

| Skill | Description |
| --- | --- |
| [scientific-writing](skills/scientific-writing/) | Write scientific manuscripts in IMRAD prose with citations. |
| [scientific-slides](skills/scientific-slides/) | Build research talk decks (PowerPoint / Beamer). |
| [scientific-schematics](skills/scientific-schematics/) | Publication-quality scientific diagrams via AI. |
| [scientific-visualization](skills/scientific-visualization/) | Publication-ready multi-panel figures with journal styling. |
| [latex-posters](skills/latex-posters/) | Research posters in LaTeX (beamerposter/tikzposter/baposter). |
| [pptx-posters](skills/pptx-posters/) | Research posters in HTML/CSS exported to PDF/PPTX. |
| [venue-templates](skills/venue-templates/) | LaTeX templates for journals, conferences, posters, grants. |
| [research-grants](skills/research-grants/) | Write competitive NSF/NIH/DOE/DARPA/NSTC proposals. |
| [market-research-reports](skills/market-research-reports/) | Consulting-style market research reports (50+ pages). |

</details>

<details>
<summary><strong>Data Science, Stats & Visualization</strong></summary>

| Skill | Description |
| --- | --- |
| [exploratory-data-analysis](skills/exploratory-data-analysis/) | EDA across 200+ scientific file formats with reports. |
| [statistical-analysis](skills/statistical-analysis/) | Guided test selection, assumptions, and APA reporting. |
| [statsmodels](skills/statsmodels/) | Statistical models (OLS, GLM, mixed, ARIMA) with diagnostics. |
| [scikit-learn](skills/scikit-learn/) | Supervised/unsupervised ML, pipelines, and tuning. |
| [shap](skills/shap/) | Model interpretability/explainability with SHAP. |
| [umap-learn](skills/umap-learn/) | Nonlinear dimensionality reduction and embeddings. |
| [matplotlib](skills/matplotlib/) | Low-level fully customizable plotting. |
| [seaborn](skills/seaborn/) | Statistical visualization with pandas integration. |
| [polars](skills/polars/) | High-performance DataFrame ETL/analytics. |
| [dask](skills/dask/) | Distributed/larger-than-RAM pandas/NumPy workflows. |
| [vaex](skills/vaex/) | Out-of-core DataFrames for billions of rows. |
| [networkx](skills/networkx/) | Create, analyze, and visualize graphs/networks. |
| [sympy](skills/sympy/) | Exact symbolic math (algebra, calculus, solving). |
| [matlab](skills/matlab/) | MATLAB/Octave numerical computing and visualization. |
| [pymc](skills/pymc/) | Bayesian modeling and MCMC/variational inference. |
| [pymoo](skills/pymoo/) | Multi-objective optimization (NSGA-II/III, MOEA/D). |
| [simpy](skills/simpy/) | Process-based discrete-event simulation. |
| [aeon](skills/aeon/) | Time series ML (classification, forecasting, clustering). |
| [timesfm-forecasting](skills/timesfm-forecasting/) | Zero-shot time series forecasting with TimesFM. |
| [scikit-survival](skills/scikit-survival/) | Survival analysis and time-to-event modeling. |
| [usfiscaldata](skills/usfiscaldata/) | Query the U.S. Treasury Fiscal Data REST API. |
| [get-available-resources](skills/get-available-resources/) | Detect CPU/GPU/memory/disk and recommend a compute strategy. |

</details>

<details>
<summary><strong>Deep Learning, RL & GPU</strong></summary>

| Skill | Description |
| --- | --- |
| [transformers](skills/transformers/) | Hugging Face Transformers inference and fine-tuning. |
| [pytorch-lightning](skills/pytorch-lightning/) | Organize PyTorch with Lightning for scalable training. |
| [torch-geometric](skills/torch-geometric/) | Graph neural networks with PyTorch Geometric. |
| [stable-baselines3](skills/stable-baselines3/) | Standard RL algorithms with a scikit-learn-like API. |
| [pufferlib](skills/pufferlib/) | High-performance parallel/multi-agent RL. |
| [optimize-for-gpu](skills/optimize-for-gpu/) | GPU-accelerate Python (CuPy, Numba, cuDF, cuML, etc.). |
| [modal](skills/modal/) | Serverless cloud GPU compute with the Modal SDK. |
| [hugging-science](skills/hugging-science/) | Discover scientific datasets/models/Spaces on Hugging Face. |

</details>

<details>
<summary><strong>Bioinformatics & Genomics</strong></summary>

| Skill | Description |
| --- | --- |
| [biopython](skills/biopython/) | Molecular biology toolkit: sequences, parsing, NCBI access. |
| [bioservices](skills/bioservices/) | Unified interface to 40+ bioinformatics services. |
| [gget](skills/gget/) | Fast CLI/Python queries to 20+ bioinformatics databases. |
| [pysam](skills/pysam/) | Read/write SAM/BAM/CRAM/VCF/FASTA for NGS pipelines. |
| [scanpy](skills/scanpy/) | Standard single-cell RNA-seq analysis pipeline. |
| [anndata](skills/anndata/) | Annotated matrix data structure for single-cell. |
| [scvi-tools](skills/scvi-tools/) | Deep generative models for single-cell omics. |
| [scvelo](skills/scvelo/) | RNA velocity analysis for single-cell trajectories. |
| [cellxgene-census](skills/cellxgene-census/) | Query CZ CELLxGENE Census for single-cell data. |
| [bulk-rnaseq](skills/bulk-rnaseq/) | End-to-end bulk RNA-seq orchestration (FASTQ to DEG). |
| [pydeseq2](skills/pydeseq2/) | Differential gene expression for bulk RNA-seq. |
| [pathway-enrichment](skills/pathway-enrichment/) | Pathway/gene-set enrichment analysis (ORA/GSEA). |
| [arboreto](skills/arboreto/) | Infer gene regulatory networks (GRNBoost2, GENIE3). |
| [geniml](skills/geniml/) | ML on genomic interval data (region embeddings, scATAC). |
| [gtars](skills/gtars/) | High-performance genomic interval analysis (Rust). |
| [polars-bio](skills/polars-bio/) | Genomic interval ops and bioinformatics I/O on Polars. |
| [deeptools](skills/deeptools/) | NGS analysis: bigWig, QC, heatmaps for ChIP/RNA/ATAC-seq. |
| [pyopenms](skills/pyopenms/) | Mass spectrometry / proteomics analysis platform. |
| [matchms](skills/matchms/) | Spectral similarity and compound ID for metabolomics. |
| [flowio](skills/flowio/) | Parse FCS flow cytometry files. |
| [scikit-bio](skills/scikit-bio/) | Microbiome analysis: alignments, diversity, ordination. |
| [phylogenetics](skills/phylogenetics/) | Build/analyze phylogenetic trees (MAFFT, IQ-TREE, FastTree). |
| [etetoolkit](skills/etetoolkit/) | Phylogenetic tree manipulation and visualization (ETE). |
| [cobrapy](skills/cobrapy/) | Constraint-based metabolic modeling (FBA/FVA). |
| [esm](skills/esm/) | ESM3/ESMC protein models and ESMFold folding. |
| [glycoengineering](skills/glycoengineering/) | Analyze/engineer protein glycosylation. |
| [tiledbvcf](skills/tiledbvcf/) | Scalable genomic variant storage/query with TileDB. |
| [lamindb](skills/lamindb/) | Lineage-native lakehouse for biological datasets/models. |
| [depmap](skills/depmap/) | Cancer Dependency Map gene/drug dependency queries. |
| [primekg](skills/primekg/) | Query the Precision Medicine Knowledge Graph. |
| [nextflow](skills/nextflow/) | Build/run Nextflow and nf-core bioinformatics pipelines. |
| [pacsomatic](skills/pacsomatic/) | Operate nf-core/pacsomatic tumor-normal workflows. |

</details>

<details>
<summary><strong>Cheminformatics & Drug Discovery</strong></summary>

| Skill | Description |
| --- | --- |
| [rdkit](skills/rdkit/) | Cheminformatics toolkit for fine-grained molecular control. |
| [datamol](skills/datamol/) | Pythonic RDKit wrapper for standard drug discovery. |
| [deepchem](skills/deepchem/) | Molecular ML with featurizers and MoleculeNet datasets. |
| [torchdrug](skills/torchdrug/) | PyTorch GNNs for molecules and proteins. |
| [molfeat](skills/molfeat/) | Molecular featurization for ML (100+ featurizers). |
| [medchem](skills/medchem/) | Medicinal chemistry filters and compound triage. |
| [pytdc](skills/pytdc/) | Therapeutics Data Commons AI-ready drug datasets. |
| [diffdock](skills/diffdock/) | DiffDock molecular docking and pose prediction. |
| [molecular-dynamics](skills/molecular-dynamics/) | MD simulations with OpenMM and MDAnalysis. |
| [rowan](skills/rowan/) | Cloud-native molecular modeling workflow platform. |

</details>

<details>
<summary><strong>Physics, Astronomy, Materials, Quantum & Geospatial</strong></summary>

| Skill | Description |
| --- | --- |
| [astropy](skills/astropy/) | Astronomy/astrophysics workflows with Astropy. |
| [pymatgen](skills/pymatgen/) | Materials science: structures, phase diagrams, band structure. |
| [fluidsim](skills/fluidsim/) | Computational fluid dynamics simulations. |
| [qiskit](skills/qiskit/) | IBM quantum computing framework. |
| [cirq](skills/cirq/) | Google quantum computing framework. |
| [pennylane](skills/pennylane/) | Hardware-agnostic quantum ML with autodiff. |
| [qutip](skills/qutip/) | Open quantum systems simulation. |
| [zarr-python](skills/zarr-python/) | Chunked N-D arrays for cloud storage. |
| [geomaster](skills/geomaster/) | Remote sensing, GIS, and spatial ML. |
| [geopandas](skills/geopandas/) | Geospatial vector data analysis. |

</details>

<details>
<summary><strong>Clinical, Medical & Healthcare</strong></summary>

| Skill | Description |
| --- | --- |
| [pydicom](skills/pydicom/) | Read/write/anonymize DICOM medical imaging files. |
| [pyhealth](skills/pyhealth/) | Clinical/healthcare deep-learning pipelines. |
| [neurokit2](skills/neurokit2/) | Biosignal processing (ECG, EEG, EDA, PPG, EMG). |
| [neuropixels-analysis](skills/neuropixels-analysis/) | Neuropixels extracellular recording analysis. |
| [clinical-decision-support](skills/clinical-decision-support/) | CDS documents: cohort analyses and treatment reports. |
| [clinical-reports](skills/clinical-reports/) | Case/diagnostic/trial reports (CARE, ICH-E3, SOAP). |
| [treatment-plans](skills/treatment-plans/) | Focused medical treatment plans in LaTeX/PDF. |
| [iso-13485-certification](skills/iso-13485-certification/) | ISO 13485 medical device QMS documentation. |
| [imaging-data-commons](skills/imaging-data-commons/) | Query/download NCI Imaging Data Commons. |
| [histolab](skills/histolab/) | WSI tile extraction and preprocessing. |
| [pathml](skills/pathml/) | Full-featured computational pathology toolkit. |
| [bids](skills/bids/) | Brain Imaging Data Structure (BIDS) tooling. |

</details>

<details>
<summary><strong>Lab Automation & Platform Integrations</strong></summary>

| Skill | Description |
| --- | --- |
| [opentrons-integration](skills/opentrons-integration/) | Opentrons OT-2/Flex protocol API. |
| [pylabrobot](skills/pylabrobot/) | Vendor-agnostic lab automation framework. |
| [ginkgo-cloud-lab](skills/ginkgo-cloud-lab/) | Submit/manage protocols on Ginkgo Bioworks Cloud Lab. |
| [benchling-integration](skills/benchling-integration/) | Benchling SDK/API for registry, inventory, and ELN. |
| [labarchive-integration](skills/labarchive-integration/) | LabArchives electronic lab notebook API. |
| [protocolsio-integration](skills/protocolsio-integration/) | protocols.io API for scientific protocol management. |
| [omero-integration](skills/omero-integration/) | OMERO microscopy data management platform. |
| [dnanexus-integration](skills/dnanexus-integration/) | DNAnexus cloud genomics platform. |
| [latchbio-integration](skills/latchbio-integration/) | Latch bioinformatics workflow platform. |
| [adaptyv](skills/adaptyv/) | Adaptyv Bio Foundry API for protein experiments. |

</details>

---

## ⚙️ Settings

The [`settings/`](settings/) directory contains the global Claude Code configuration file:

### [`settings.json`](settings/settings.json)

**`env`** — environment variables that tune the Claude Code harness. Each one:

| Variable | Value | What it does |
| --- | --- | --- |
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` | `70` | Triggers automatic context compaction once the context window reaches 70% usage (instead of the higher default), keeping more room before the limit. |
| `BASH_MAX_OUTPUT_LENGTH` | `20000` | Maximum number of characters captured from a Bash command's output before it is truncated. Raised so long command outputs aren't cut short. |
| `MAX_MCP_OUTPUT_TOKENS` | `8000` | Caps the number of tokens returned by MCP (Model Context Protocol) tool calls, preventing a single MCP response from flooding the context. |
| `CLAUDE_CODE_EFFORT_LEVEL` | `medium` | Sets the default reasoning/effort level Claude applies to tasks (`low` / `medium` / `high`), balancing speed against thoroughness. |

Other keys:
- **`permissions.deny`** — read guardrails that block sensitive/noisy paths (`./secrets/**`, `node_modules`, build/dist/coverage/.next, logs, `*.log`).
- **`statusLine`** — a command-based status line showing the active model and context-window usage percentage (via `jq`).
- **`theme`** — `dark`.
- **`model`** — `sonnet`.

> Adjust `model`, `theme`, and the permission lists to match your own environment before relying on them.
>
> A `settings.local.json` (machine-local permission overrides) is intentionally **not** tracked in this repo — it is git-ignored. Create your own at `~/.claude/settings.local.json` if you need per-machine permission allowlists.

---

## 📁 Repository Layout

```
claude-code-kit/
├── agents/      # 133 subagent .md definitions (+ CLAUDE.md, AGENTS-REFERENCE.md)
├── skills/      # 197 skill directories, each with a SKILL.md
├── settings/    # settings.json (global config)
└── README.md
```
