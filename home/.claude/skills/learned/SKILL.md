---
name: learned
description: "Use when the user wants to capture a TIL, today I learned, technical insight, lesson learned, or knowledge nugget as a permanent note."
allowed-tools: Bash, Read, Write, Edit
user-invocable: true
arguments:
  - name: topic
    description: "What was learned — a brief description or the full insight"
    required: false
---

# Learned (TIL)

Capture a technical insight or lesson learned as a permanent, tagged, and cross-linked Obsidian note.

## Constants

- **Vault**: `/Users/alexong/Documents/Obsidian Notes/Obsidian Notes/Vault`
- **TIL folder**: `{vault}/TIL/`
- **Daily folder**: `{vault}/Daily/`
- **Filename**: `{date}-{slug}.md`

## Steps

### 1. Get topic and date

Use the `topic` argument, user message, or conversation context. If nothing is available, ask: "What did you learn?"

```bash
date +%Y-%m-%d
date +%A
mkdir -p "/Users/alexong/Documents/Obsidian Notes/Obsidian Notes/Vault/TIL"
```

### 2. Generate slug

Create a URL-friendly slug from the topic:
- Lowercase, replace spaces with hyphens, remove special characters
- Keep only alphanumeric and hyphens
- Truncate to ~50 characters at a word boundary, strip trailing hyphens

Examples:
- "jOOQ array columns can't use domain types" -> `jooq-array-columns-cant-use-domain-types`
- "Kotlin compiler lies about DataLoader null safety" -> `kotlin-compiler-lies-about-dataloader-null-safety`

### 3. Check for duplicates

```bash
ls "{TIL folder}/{date}-"* 2>/dev/null
```

If a very similar file exists, warn the user and ask whether to create new or update existing.

### 4. Determine tags

Always include `til`. Add 2-4 relevant tags from:

- **Language/framework**: `kotlin`, `java`, `typescript`, `graphql`, `sql`, `postgresql`, `jooq`, `spring`, `dgs`, `flyway`, `gradle`
- **Concept**: `architecture`, `debugging`, `testing`, `performance`, `security`, `concurrency`, `null-safety`, `type-system`, `database`, `migrations`, `api-design`
- **Domain**: `grc`, `workiva`, `service-design-system`

### 5. Write the TIL note

Create `{TIL folder}/{date}-{slug}.md`:

```markdown
---
tags:
  - til
  - {tag1}
  - {tag2}
date: {date}
---

# {Topic Title}

## What I Learned

{Clear explanation of the insight, understandable on its own. Include code examples when relevant with language-tagged fenced blocks.}

## Context

{Why this came up. What was being worked on.}

## Key Takeaway

{1-2 sentences distilling the core insight — the "remember one thing" summary.}

## Related

- [[related-note-or-project]]
```

### 6. Update daily note

Read `{daily folder}/{date}.md`.

#### If exists

Find `## Learned` section. Append:
```markdown
- [[{date}-{slug}]] -- {one-line summary}
```
If the section does not exist, add it before "Decisions & Notes" (or at the end).

#### If does not exist

Create a minimal daily note:
```markdown
---
tags:
  - daily-note
  - work
date: {date}
day: {DayOfWeek}
---

# {date} - {DayOfWeek}

## Learned

- [[{date}-{slug}]] -- {one-line summary}

## Decisions & Notes



## TODOs for Tomorrow

- [ ] 
```

### 7. Confirm

Report: file path, tags assigned, daily note cross-reference, key takeaway for verification.

## Writing Guidelines

- **Teach, not just note**: write as if explaining to a colleague who hit the same issue
- **Include code when relevant**: examples make TILs actionable later
- **Explain the "why"**: not just "X doesn't work, use Y" but why X fails
- **Link generously**: wikilink related projects, tickets, other TILs
- **One insight per TIL**: multiple learnings SHOULD be multiple notes

## Constraints

- Non-technical insights are valid — process learnings, tool tips, team dynamics.
- If user just says "/learned" mid-conversation, infer the topic from conversation context.
- Very long input SHOULD become the "What I Learned" body with a shorter generated title.
- Multiple TILs on the same day each get their own file; all append to the same daily note.
