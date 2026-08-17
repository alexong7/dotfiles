---
name: session-summary
description: "Use when the user wants to capture what was worked on in this session, summarize the session, or says what did I work on."
allowed-tools: Bash, Read, Write, Edit
user-invocable: true
---

# Session Summary

Summarize the current Claude Code session and append it to today's Obsidian daily note.

## Constants

- **Vault**: `/Users/alexong/Documents/Obsidian Notes/Obsidian Notes/Vault`
- **Daily folder**: `{vault}/Daily/`
- **Git author**: `Alex Ong` / `alex.ong@workiva.com`
- **Repos** (skip silently if missing):
  - `~/workspace/go/src/github.com/Workiva/grc-evergreen2`
  - `~/workspace/go/src/github.com/Workiva/ts-grc`
  - `~/workspace/go/src/github.com/Workiva/grc-evergreen3`

## Steps

### 1. Get date and time

```bash
date +%Y-%m-%d
date +%A
date +"%I:%M %p"
```

### 2. Summarize the session

Review the current conversation and extract:

- **What was worked on**: features, bugs, investigations, skills created
- **Key decisions**: architecture choices, design trade-offs
- **Outcomes**: completed? follow-ups needed?
- **Key files changed**: only the important ones, not every file

Write as concise bullet points. MUST be specific (PR numbers, feature names, ticket IDs) rather than generic.

### 3. Gather supplemental git data

```bash
for repo in \
  ~/workspace/go/src/github.com/Workiva/grc-evergreen2 \
  ~/workspace/go/src/github.com/Workiva/ts-grc \
  ~/workspace/go/src/github.com/Workiva/grc-evergreen3; do
  if [ -d "$repo" ]; then
    echo "=== $(basename $repo) ==="
    git -C "$repo" log --author="Alex Ong" --since="$(date +%Y-%m-%d)T00:00:00" --until="$(date +%Y-%m-%d)T23:59:59" --oneline --no-merges 2>/dev/null
  fi
done
```

### 4. Append to daily note

Read `{daily folder}/{date}.md`.

#### If the daily note exists

1. Find the `## Claude Sessions` section.
2. If it has placeholder text ("No Claude sessions recorded."), replace with the new content.
3. If it has existing content, append a new timestamped sub-section.
4. If the section does not exist, add it before "Decisions & Notes" (or at the end).

Session entry format:
```markdown
### ~{time}
- Specific work item
- Key decision made
- Outcome or follow-up
```

#### If the daily note does NOT exist

Create a minimal note:
```markdown
---
tags:
  - daily-note
  - work
date: {date}
day: {DayOfWeek}
---

# {date} - {DayOfWeek}

## Claude Sessions

### ~{time}
- Work items here

## Decisions & Notes



## TODOs for Tomorrow

- [ ] 
```

This minimal note MAY be filled later by `/daily-notes`.

### 5. Confirm

Report:
- What was captured
- File path updated/created
- Suggest `/daily-notes` for a full note with calendar and Jira data

## Writing Guidelines

- **Specific over generic**: "Implemented composed workpaper validation for assessment entities" not "Worked on validation code"
- **Include numbers**: "Created 5 skill files" not "Created skill files"
- **Name tools and technologies**: "Added Flyway migration for `assessment_type` column" not "Changed the database"
- **Note open questions**: capture unresolved items
- **One thought per bullet**: scannable, not prose
- **Approximate time**: use `~` prefix, current time as session end

## Constraints

- Very short sessions (quick question or lookup) SHOULD still be logged because even "Investigated X, confirmed Y" is useful.
- Sessions spanning midnight MUST use the current date.
- MUST NOT overwrite existing Claude Sessions content — always append.
