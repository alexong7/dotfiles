---
name: explain-pr
description: "Use when the user wants to understand, explain, or learn from a pull request. Triggers on: PR URL, PR number, mentions of coworker's PR, 'explain PR', 'what does this PR do', 'understand changes', 'learn from PR'."
allowed-tools: Bash, Read, Agent, WebFetch
user-invocable: true
arguments:
  - name: pr
    description: "GitHub PR URL or number (if number, uses current repo)"
    required: true
---

# Explain PR

Fetch a pull request via `gh` and produce a structured, educational explanation designed for learning from teammates' work.

## Parameters

| Name | Required | Description |
|------|----------|-------------|
| `pr` | Yes | GitHub PR URL (e.g., `https://github.com/Workiva/grc-evergreen2/pull/9500`) or a PR number (uses current repo) |

## Steps

### 1. Parse PR Reference

- **URL**: Extract owner, repo, and PR number. Use `--repo owner/repo` in all `gh` commands.
- **Number only**: Omit `--repo` flag; `gh` uses the current repo.

### 2. Fetch PR Data

Run these in parallel:

```bash
# Metadata
gh pr view <number> [--repo owner/repo] --json title,body,author,state,labels,reviewers,mergedAt,baseRefName,headRefName,additions,deletions,changedFiles,url

# Full diff
gh pr diff <number> [--repo owner/repo]

# Comments and reviews
gh pr view <number> [--repo owner/repo] --json comments,reviews

# File stats
gh pr diff <number> [--repo owner/repo] --stat
```

### 3. Categorize Changed Files

Group files by type:
- **Schema**: `.graphqls`, OpenAPI specs
- **Database**: Migration `.sql` files, jOOQ generated code
- **SDS Layers**: Manager (`modules/manager/`), Engine (`modules/engine/`), Access (`modules/access/`), Platform (`modules/platform/`)
- **Tests**: `*Test.kt`, `IT*.kt`, `*Scenario.kt`
- **Config/build**: `build.gradle.kts`, CI files
- **Frontend** (ts-grc): Components, hooks, queries, styles

### 4. Deep Dive on Key Files

Use `subagent_type: Explore` subagents to read the most significant changed files. For each:
1. Read the diff hunks
2. If the repo is available locally, read surrounding context from the actual file
3. Identify the purpose of each significant change

**Local repo paths:**
- `Workiva/grc-evergreen2` -> `~/workspace/go/src/github.com/Workiva/grc-evergreen2`
- `Workiva/ts-grc` -> `~/workspace/go/src/github.com/Workiva/ts-grc`
- `Workiva/grc-evergreen3` -> `~/workspace/go/src/github.com/Workiva/grc-evergreen3`

**Constraints:**
- MUST NOT read generated files (jOOQ `generated/`, GraphQL codegen) -- summarize as "generated from schema changes" because they add noise without insight.
- SHOULD limit deep reads to top 15-20 files for large PRs (50+ files).

### 5. Produce Explanation

Adapt depth to PR complexity -- a 5-file bug fix gets shorter treatment than a 40-file feature.

**Required sections:**

**Problem** -- What issue or need motivated this PR? Derive from PR body, linked issues/JIRA tickets, the changes themselves, or review comments. If the PR description is sparse, infer from code and note that.

**Solution** -- High-level approach in 2-4 sentences. Conceptual strategy, not a file list.

**Key Changes** -- Walk through the most important areas, grouped logically. For each group: what changed, why, key patterns used, and how pieces connect. MUST skip trivial changes (formatting, imports-only, generated code).

**Design Decisions** -- Tradeoffs: why this approach over alternatives, patterns chosen, performance considerations, backward compatibility, what was intentionally not done. If none are notable, say "Straightforward implementation -- no major design tradeoffs visible."

**Architecture Impact** -- For grc-evergreen repos: which SDS layers are touched, whether boundaries are respected, cross-module dependencies, schema changes. For ts-grc: component hierarchy, state management, API contract changes. For other repos: describe impact in relevant terms.

**What I Can Learn** -- Patterns, techniques, or conventions worth adopting: code patterns, testing strategies, codebase conventions, clever solutions.

### 6. Offer Obsidian Save

After presenting the explanation, ask if the user wants it saved.

If yes, save to `/Users/alexong/Documents/Obsidian Notes/Obsidian Notes/Vault/PR-Reviews/` with filename: `YYYY-MM-DD-<repo>-PR<number>-<short-slug>.md`. Include the PR URL, author, date, and full explanation.

## Edge Cases

- **Very large PRs (50+ files)**: Focus on top 15-20 significant files. Summarize the rest by category.
- **No PR description**: Note this explicitly and derive explanation entirely from code.
- **Closed/draft PRs**: Explain them normally. Note the state.
- **Unfamiliar repos**: Skip SDS-specific analysis; focus on general explanation sections.
- **Merge noise in diff**: Note it and focus on the author's actual changes.
