---
name: weekly-recap
description: "Use when the user wants a weekly summary, is preparing for standup or 1:1, asks for a recap of the week, or says weekly recap."
allowed-tools: Bash, Read, Write, Edit
user-invocable: true
---

# Weekly Recap

Aggregate daily notes and git data from the current week into a structured weekly summary for standups, 1:1s, and progress tracking.

## Parameters

| Name | Default | Description |
|------|---------|-------------|
| week | current | ISO week to summarize, e.g. `2026-W21`. Defaults to the current week. |

## Constants

- **Vault**: `/Users/alexong/Documents/Obsidian Notes/Obsidian Notes/Vault`
- **Daily folder**: `{vault}/Daily/`
- **Weekly folder**: `{vault}/Weekly Work Log/`
- **Filename**: `{YYYY}-W{XX}.md`
- **Git author**: `Alex Ong` / `alex.ong@workiva.com`
- **Repos** (skip silently if missing):
  - `~/workspace/go/src/github.com/Workiva/grc-evergreen2`
  - `~/workspace/go/src/github.com/Workiva/ts-grc`
  - `~/workspace/go/src/github.com/Workiva/grc-evergreen3`

## Steps

### 1. Determine week boundaries

```bash
date +%Y        # year
date +%V        # ISO week number
# Monday and Friday of the target week (macOS):
date -v-mon -v0H -v0M -v0S +%Y-%m-%d
date -v-mon -v+4d +%Y-%m-%d
```

Output filename: `YYYY-WXX.md` with zero-padded week number.

### 2. Read daily notes (Monday-Friday)

Read each existing `{daily folder}/{date}.md` for the week. Track which days are missing.

### 3. Gather git data

For each existing repo, pull the full week's commits and merge commits:

```bash
git -C /path/to/repo log --author="Alex Ong" --since="{monday}" --until="{friday} 23:59:59" --oneline --no-merges 2>/dev/null
git -C /path/to/repo log --author="Alex Ong" --since="{monday}" --until="{friday} 23:59:59" --merges --oneline 2>/dev/null
```

### 4. Synthesize

Parse each daily note's sections and aggregate. MUST synthesize themes and patterns rather than concatenating raw data. Group related items, identify trends, highlight the most impactful work.

### 5. Write the recap

Create or update `{weekly folder}/YYYY-WXX.md`:

```markdown
---
tags:
  - weekly-recap
  - work
week: YYYY-WXX
start: {monday}
end: {friday}
---

# Week of {monday} to {friday} (W{XX})

## Shipped

{Merged PRs and completed features. Synthesize from Development sections and merge commits.}
- PR/feature description — brief context

{If nothing: "Nothing shipped to production this week."}

## In Progress

{Started but not merged. Commits without corresponding merges, tickets still open.}
- Feature name — current state, what remains

## Key Decisions

{From daily notes' "Decisions & Notes" sections.}
- Decision — context and rationale

{If none: "No major decisions recorded this week."}

## Meetings Summary

{Grouped by theme, not listed individually. Highlight key outcomes.}
- **Recurring/1:1s**: Topics covered
- **Project meetings**: Key outcomes

## Tickets

| Ticket | Summary | Status |
|--------|---------|--------|
| [[PROJ-123]] | Description | Done |

## Blockers

- Blocker — impact and next steps

{If none: "No blockers this week."}

## Learnings

{From daily notes' "Learned" sections, with links to TIL notes.}

## Next Week Focus

{From Friday's "TODOs for Tomorrow" and in-progress items.}
- [ ] Focus area

## Daily Notes

- [[{monday}]] Monday
- [[{tuesday}]] Tuesday
- [[{wednesday}]] Wednesday
- [[{thursday}]] Thursday
- [[{friday}]] Friday
```

Mark missing days: `- ~~{date} DayName~~ (no note)`

#### Updating an existing recap

If the file already exists, read it first. Update sections with new data but MUST NOT remove manually-added content in "Blockers" and "Next Week Focus" because these may contain hand-written plans.

### 6. Confirm

Report:
- File path created/updated
- Stats: N daily notes found, N commits, N tickets, N PRs shipped
- Which days are missing notes

## Constraints

- Mid-week runs SHOULD note which days haven't happened yet vs. days with missing notes.
- Empty daily notes (template placeholders only) SHOULD be treated as having no data.
- Cross-week work (started last week, finished this week) SHOULD appear in "Shipped" with context.
