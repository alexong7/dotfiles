# Build Feature Pipeline -- Phase Execution

Detailed per-phase, per-mode instructions. Referenced from [SKILL.md](SKILL.md).

## Contents

- [Phase 1: Gather Context (all modes)](#phase-1-gather-context-all-modes)
- [Phase 2: Design](#phase-2-design)
- [Phase 3: Write Implementation Plan](#phase-3-write-implementation-plan)
- [Phase 4: Implement](#phase-4-implement)
- [Phase 5: Code Review (all modes)](#phase-5-code-review-all-modes)
- [Phase 6: Finish (all modes)](#phase-6-finish-all-modes)

---

## Phase 1: Gather Context (all modes)

### Jira ticket input

If the input matches a Jira pattern (`GRC-1234`, `GRCAI-567`, or contains `atlassian.net`):

1. Extract the ticket key from the input.
2. Fetch ticket details via `mcp__atlassian__jira_batch_get_issues`.
3. Fetch discussion context via `mcp__atlassian__jira_get_comments`.
4. Summarize: title, description, acceptance criteria, relevant comments.
5. Present the summary and confirm this is what the user wants to build.

### Freeform description input

1. Acknowledge the description.
2. If it is vague (under ~20 words with no clear deliverable), ask ONE clarifying question.
3. Otherwise, proceed directly.

### Always at this stage

1. Identify the repo and its architecture (check CLAUDE.md, project structure).
2. Quick-scan relevant code areas with `grep` or `find` to understand current state.
3. Summarize understanding back to the user in 2-3 sentences.
4. Select the pipeline mode (unless user overrode it) and announce the choice with rationale.

**CHECKPOINT:** You MUST wait for user confirmation of understanding and mode before proceeding to Phase 2.

---

## Phase 2: Design

### superpowers mode: sp-brainstorming

Invoke:
```
Skill: sp-brainstorming
```

Pass the gathered context. The brainstorming skill will:
- Explore the user's intent and requirements
- Propose 2-3 design approaches with tradeoffs
- Collaborate with the user to refine the design
- Produce a spec document

Let the skill run its full process. The user approves the design within its flow.

### sop mode: sop-pdd

Invoke:
```
Skill: sop-pdd
```

Pass the gathered context. PDD will:
- Capture the rough idea
- Ask clarifying questions one at a time (recorded in `idea-honing.md`)
- Conduct targeted research on the codebase (saved to `research/` folder)
- Iterate between clarification and research until the design is solid
- Create a detailed design document (`design/detailed-design.md`)
- Develop a step-by-step implementation plan (`implementation/plan.md`)

PDD produces both the design AND a preliminary implementation plan. In sop mode, Phase 3 refines this into task files.

### blend mode: sop-pdd

Same as sop mode. In blend mode, Phase 3 uses Superpowers' writing-plans to reformat the PDD output into a subagent-friendly plan.

---

## Phase 3: Write Implementation Plan

### superpowers mode: sp-writing-plans

Invoke:
```
Skill: sp-writing-plans
```

Pass the approved spec/design. The skill will:
- Break the design into bite-sized tasks (2-5 minutes each)
- Include exact file paths, complete code blocks, verification commands
- Produce a self-contained implementation plan

### sop mode: sop-code-task-generator

Invoke:
```
Skill: sop-code-task-generator
```

Pass the PDD implementation plan from Phase 2. The skill will:
- Process one step at a time from the PDD plan
- Generate structured task files with Given-When-Then acceptance criteria
- Each task file includes Description, Background, Technical Requirements, Dependencies, Implementation Approach

### blend mode: sp-writing-plans

Same invocation as superpowers mode, but pass the PDD design document from Phase 2 as the spec input. This reformats the thorough PDD design into an execution-optimized plan with exact file paths and code blocks.

### CHECKPOINT (all modes)

After the plan is written, you MUST present a summary:
- Total number of tasks
- High-level overview of what each task does
- Estimated scope (small/medium/large)

Ask: "Ready to implement, or want to adjust the plan?"

You MUST NOT proceed to Phase 4 until the user confirms because implementation is expensive and hard to undo.

---

## Phase 4: Implement

### superpowers mode / blend mode: sp-subagent-driven-development

Invoke:
```
Skill: sp-subagent-driven-development
```

This will:
- Dispatch a fresh subagent for each task in the plan
- Each subagent implements using TDD (write failing test -> make it pass -> refactor)
- After each task, a spec compliance review subagent checks the work
- Then a code quality review subagent checks engineering quality
- Issues are fixed in loops until both reviewers pass

You MUST NOT pause between tasks or ask "should I continue?" because the user already approved the plan.

### sop mode: sop-code-assist

Invoke:
```
Skill: sop-code-assist
```

For each task file generated in Phase 3, code-assist follows:
1. **Explore** -- analyze requirements, research patterns, create context.md
2. **Plan** -- design test strategy and implementation plan
3. **Code** -- write tests first (TDD), implement to pass, refactor, validate
4. **Commit** -- conventional commits

### Blockers (all modes)

If implementation encounters a blocker that cannot be resolved autonomously:
1. Stop and report the issue to the user with specific details.
2. Ask for guidance.
3. Resume once resolved.

You MUST NOT stop for non-blocking issues; resolve them and continue.

---

## Phase 5: Code Review (all modes)

Invoke:
```
Skill: sp-requesting-code-review
```

This dispatches a reviewer subagent that:
- Reviews all changes made during implementation
- Categorizes issues as critical, important, or minor

**Fix protocol:**
- Critical issues MUST be fixed before proceeding.
- Important issues SHOULD be fixed before proceeding.
- Minor issues MAY be noted for later.

If there are critical or important issues:
1. Fix them (use subagents if multiple independent fixes needed).
2. Re-run the review to confirm fixes.
3. Only proceed to Phase 6 when the review passes.

You MUST NOT ask the user whether to fix critical/important issues because they always need fixing.

---

## Phase 6: Finish (all modes)

Invoke:
```
Skill: sp-finishing-a-development-branch
```

This will:
- Verify all tests pass
- Present the user with options: merge locally, push and create PR, keep branch, or discard
- Execute the chosen option
- Clean up worktree if applicable

You MUST let the user choose the finish option because this determines how the work integrates.
