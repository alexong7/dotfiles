---
name: brag
description: "Use when the user wants to log an accomplishment, track a brag, record an achievement, or generate a performance review summary."
allowed-tools: Bash, Read, Write, Edit
user-invocable: true
arguments:
  - name: action
    description: "'add' to log an accomplishment, 'review' to generate a summary, or the accomplishment text directly"
    required: false
---

# Brag Book

Maintain a running log of accomplishments and generate performance-review-ready summaries.

## Constants

- **Vault**: `/Users/alexong/Documents/Obsidian Notes/Obsidian Notes/Vault`
- **Brag doc**: `{vault}/Brag Book.md`

## Action Resolution

Determine the action from the `action` argument or user message:

| Signal | Action |
|--------|--------|
| "add", or user describes an accomplishment | **Add** |
| "review" | **Review** |
| No argument, no description | Ask what they accomplished |
| Any other text | Treat as accomplishment description, **Add** |

---

## Add an Accomplishment

### 1. Get details

Use the provided description. If none, ask: "What did you accomplish?"

### 2. Categorize and assess impact

Auto-categorize from this list (MUST NOT ask the user to categorize):

| Category | Use When |
|----------|----------|
| Shipped Feature | New feature or capability delivered to production |
| Bug Fix | Fixed a bug, especially customer-impacting |
| Architecture/Design | Design docs, ADRs, architectural improvements, refactors |
| Mentoring | Code reviews, pairing, onboarding help, knowledge sharing |
| Process Improvement | Tooling, CI/CD, workflow improvements, automation |
| Learning | Certifications, courses, deep dives |
| Cross-team | Collaboration with other teams, cross-org initiatives |

Assess impact:
- **High**: Major feature, critical bug fix, multi-team architectural decision, significant process improvement
- **Medium**: Standard feature work, moderate bug fixes, team-level improvements
- **Low**: Minor fixes, small improvements, learning activities

### 3. Write the entry

Read the existing brag doc. If it does not exist, create it with:

```markdown
---
tags:
  - brag-book
  - career
---

# Brag Book

Running log of accomplishments for performance reviews and career tracking.

## Entries

```

Append under `## Entries` at the top (newest first):

```markdown
- **[YYYY-MM-DD]** Category -- Description in 1-2 review-ready sentences. Impact: level.
```

Format constraints:
- Date in brackets, bolded
- Category then em dash (`--`) then description
- 1-2 sentences: what was done and why it matters
- End with `Impact: level.`
- Brief input SHOULD be expanded with impact context; verbose input SHOULD be condensed
- Date override: if user says "last week I shipped X", use the approximate mentioned date

### 4. Confirm

Report: what was added, category chosen, impact level. Mention they can edit the file to adjust.

### Duplicate check

Before adding, check if a very similar entry (same date + similar description) already exists. If so, warn and ask whether to proceed.

---

## Generate Review Summary

### 1. Read and parse

Read `{vault}/Brag Book.md`. If it does not exist or has no entries, tell the user and stop.

Parse each entry: date, category, description, impact.

### 2. Generate summary

Output directly to the user (MUST NOT write to a file unless asked):

```markdown
# Performance Review Summary

**Period**: {earliest date} to {latest date}
**Total accomplishments**: N

## High-Impact Highlights

{All high-impact entries, expanded with context.}

## By Category

### Category Name (N entries)
{Theme synthesis at top, then entries most-recent-first. Skip empty categories.}

## Key Themes

{2-3 sentences: strongest areas, growth patterns, scope/impact.}

## Suggested Talking Points

{3-5 impact statements for review conversations.}
- "I shipped X which enabled Y, resulting in Z"
```

### 3. Offer next steps

- "Want me to save this to a file?"
- "Want me to filter to a specific time period?"
