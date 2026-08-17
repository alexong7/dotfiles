---
name: daily-notes
description: "Use when the user wants to generate or update their daily note, asks what they did today, says end of day, daily dump, or daily notes."
allowed-tools: Bash, Read, Write, Edit, Agent, mcp__claude_ai_Google_Calendar__list_events, mcp__claude_ai_Google_Calendar__list_calendars, mcp__atlassian__jira_search_issues, mcp__atlassian__jira_get_current_user
user-invocable: true
---

# Daily Notes

Generate or update today's Obsidian daily note by aggregating git activity, calendar events, Jira tickets, and Claude Code session work.

## Parameters

| Name | Default | Description |
|------|---------|-------------|
| date | today | ISO date (`YYYY-MM-DD`) to generate the note for |

## Constants

- **Vault**: `/Users/alexong/Documents/Obsidian Notes/Obsidian Notes/Vault`
- **Daily folder**: `{vault}/Daily/`
- **Filename**: `{date}.md`
- **Git author**: `Alex Ong` / `alex.ong@workiva.com`
- **Timezone**: `America/Chicago` (display times in 12-hour format)
- **Repos** (skip silently if missing):
  - `~/workspace/go/src/github.com/Workiva/grc-evergreen2`
  - `~/workspace/go/src/github.com/Workiva/ts-grc`
  - `~/workspace/go/src/github.com/Workiva/grc-evergreen3`

## Steps

### 1. Determine date

Run `date +%Y-%m-%d` and `date +%A` (or use the provided date parameter). These values are used throughout.

### 2. Check existing note

Read `{daily folder}/{date}.md` if it exists. This determines create vs. update behavior in Step 7.

### 3. Gather data (parallel)

Run these three data-gathering steps in parallel. Each source is independent. If any source fails, log the failure and continue with available data.

#### 3a. Git commits

For each repo that exists:
```bash
git -C /path/to/repo log --author="Alex Ong" --since="{date}T00:00:00" --until="{date}T23:59:59" --oneline --no-merges 2>/dev/null
```

#### 3b. Calendar events

1. Call `mcp__claude_ai_Google_Calendar__list_calendars` to find calendars.
2. Call `mcp__claude_ai_Google_Calendar__list_events` with today's date range for the primary calendar.
3. Extract: title, start/end time, attendees.

#### 3c. Jira tickets

1. Call `mcp__atlassian__jira_get_current_user` for the account ID.
2. Call `mcp__atlassian__jira_search_issues` with JQL: `assignee = currentUser() AND updated >= "{date}" ORDER BY updated DESC`.
3. Extract: ticket key, summary, status.

### 4. Check session context

Summarize the current conversation's work if running interactively. For previous sessions, infer from commit messages.

### 5. Write the note

#### New note template

```markdown
---
tags:
  - daily-note
  - work
date: {date}
day: {DayOfWeek}
---

# {date} - {DayOfWeek}

## Meetings

{For each event:}
- **HH:MM AM/PM - HH:MM AM/PM** — Event Title
  - Attendees: Name1, Name2

{If none: "No meetings today."}

## Development

{For each repo with commits:}
### repo-name
- `short-hash` — commit message

{If none across all repos: "No commits today."}

## Tickets

- **PROJ-123** — Summary (Status: In Progress)

{If none: "No ticket activity today."}

## Claude Sessions

- Session work summary bullets

{If none: "No Claude sessions recorded."}

## Learned

{Empty — populated by /learned skill}

## Decisions & Notes

{Empty — for manual additions}

## TODOs for Tomorrow

- [ ] {Empty — for manual additions}
```

#### Updating an existing note

1. For each section (Meetings, Development, Tickets, Claude Sessions): if placeholder text exists, replace it with real data.
2. If a section already has content, append only new items. Deduplicate by commit hash, ticket key, or meeting title.
3. MUST NOT remove content from "Decisions & Notes", "Learned", or "TODOs for Tomorrow" because these contain manual entries.
4. For "Claude Sessions", append a new sub-bullet for this session rather than replacing.

### 6. Confirm

Report to the user:
- File path created/updated
- Counts: N meetings, N commits across N repos, N tickets
- Any unavailable data sources

## Constraints

- Weekend dates SHOULD include `weekend` in frontmatter tags.
- MCP failures MUST NOT block note creation. Log unavailable sources as an HTML comment at the bottom: `<!-- Data sources unavailable: Calendar, Jira -->`.
- Jira tickets SHOULD use wikilinks: `[[PROJ-123]]`.
- An empty-data note is still valuable for manual entries — always create the file.
