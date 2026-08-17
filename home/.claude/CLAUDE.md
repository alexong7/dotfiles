# Global Rules

## Workflow

### Plan First
- Enter plan mode for ANY non-trivial task (3+ steps or architectural decisions).
- If something goes sideways, STOP and re-plan immediately - don't keep pushing.
- Write detailed specs upfront to reduce ambiguity. Get user sign-off before writing code.
- Use plan mode for verification steps, not just building.

### Subagent Strategy
- Use subagents liberally to keep main context window clean.
- Offload research, exploration, and parallel analysis to subagents.
- For complex problems, throw more compute at it via subagents.
- One task per subagent for focused execution.
- Before using dynamic workflows, ultracode, or any feature that spawns a large swarm of subagents, explain the tradeoffs and ask for explicit approval first.

### Verification Before Done
- Never mark a task complete without proving it works (compile check, test run, build).
- Diff behavior between main and your changes when relevant.
- Ask yourself: "Would a staff engineer approve this?"
- Run tests, check logs, demonstrate correctness.

### Demand Elegance (Balanced)
- For non-trivial changes: pause and ask "is there a more elegant way?"
- If a fix feels hacky: "Knowing everything I know now, implement the elegant solution."
- Skip this for simple, obvious fixes - don't over-engineer.
- Challenge your own work before presenting it.

### Autonomous Bug Fixing
- When given a bug report: just fix it. Don't ask for hand-holding.
- Always start with reproducing the bug in an end-to-end setting as closely aligned with how a user would experience it as possible. Then fix it.
- Point at logs, errors, failing tests - then resolve them.
- Zero context switching required from the user.
- Go fix failing CI tests without being told how.

## Task Management

1. **Plan First**: Write plan to checkable items. Check in before starting implementation.
2. **Track Progress**: Mark items complete as you go.
3. **Explain Changes**: High-level summary at each milestone - not after every file edit.
4. **Capture Lessons**: When corrected, save the pattern to memory so the same mistake doesn't happen twice.

## Core Principles

- **Simplicity First**: Make every change as simple as possible. Minimal code, minimal impact.
- **No Laziness**: Find root causes. No temporary fixes. Senior developer standards.
- **Minimal Impact**: Changes should only touch what's necessary. Avoid introducing bugs.
- **Read Before Writing**: Always read existing code before modifying. Understand the pattern before changing it.
- **No Cleanup Creep**: A bug fix is just a bug fix. Don't refactor surrounding code, add types to untouched functions, or "improve" things that weren't asked for.
- **Simplest Path for One-Offs**: For infrequent operational work, use the simplest direct end-to-end path. Don't build wrappers, control planes, or automation unless the direct path exposes a concrete blocker or repeated need.

## Formatting

- Never use the em dash. Use a plain dash instead.
- When writing commit messages, never auto-add your agent name as co-author.
- Never manually modify CHANGELOG.md files or any files that are marked as auto-generated.

## Pull Request Descriptions

Write PR descriptions as short, human-readable prose - not bullet points or verbose markdown templates. A good PR description reads like a quick explanation to a teammate.

Structure:
- A short paragraph describing the problem/need and what this PR does (2-4 sentences max). Header of # Problem
- Optionally a brief "Solution" section if the approach isn't obvious from context. Header of # Solution
- Skip "Design decisions" sections - those belong in design docs, not PRs.
- QA notes should be short bullet points describing manual testing steps, not paragraphs or test names. If the only way to validate is automated tests, just say "CI passing" is sufficient.

Avoid: bullet-point heavy formats for the summary/solution sections, restating every file changed, "Generated with Claude Code" footers, emoji, and anything that makes the description noisy enough that reviewers skip it.
