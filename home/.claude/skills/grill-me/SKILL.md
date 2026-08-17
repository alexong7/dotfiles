---
name: grill-me
description: "Use when the user wants to quiz themselves, test understanding, prepare for a review, or check knowledge. Triggers on: 'grill me', 'quiz me', 'test my understanding', 'knowledge check', 'review prep', 'do I understand this'."
allowed-tools: Bash, Read, AskUserQuestion, Agent
user-invocable: true
arguments:
  - name: target
    description: "What to quiz on: 'branch' for current branch changes, a PR URL/number, or a topic/concept"
    required: false
---

# Grill Me

Generate progressively harder questions about code changes, a PR, or a technical topic. Present one at a time via `AskUserQuestion`, evaluate answers, and produce a final score with knowledge gap analysis.

**Tone**: Challenging but supportive -- like a senior engineer in a 1:1 who wants you to grow. Give credit when earned, point out gaps directly. Never condescending, never soft-pedaling.

## Parameters

| Name | Required | Default | Description |
|------|----------|---------|-------------|
| `target` | No | `branch` | `branch` or omitted: current branch diff. PR URL or number: that PR's changes. Any other string: topic-based quiz in context of current codebase. |

## Steps

### 1. Gather Material

**Branch changes (default):**
```bash
BASE=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@refs/remotes/origin/@@' || echo "master")
git diff "$BASE"...HEAD
git log "$BASE"...HEAD --oneline
git diff "$BASE"...HEAD --stat
```
If the diff is empty, tell the user and ask for a different target.

**PR:** Fetch via `gh pr view` and `gh pr diff` (same pattern as explain-pr).

**Topic/concept:** Use `subagent_type: Explore` subagents to search the codebase for relevant files, tests, schemas, ADRs, and docs.

### 2. Analyze Material

Before generating questions, build a mental model:
- Core purpose/change
- Key design decisions
- Edge cases and error handling
- Dependencies and interactions
- Production failure modes
- Patterns and conventions followed
- Testing strategies used

### 3. Generate Questions

Create questions with progressive difficulty. MUST have a pre-written expert answer for each before presenting. SHOULD target 6-8 questions, but adapt:

- **Small diffs (< 100 lines)**: 5 questions, lean toward reasoning/extension.
- **Large diffs (500+ lines)**: 8 questions, include more comprehension first.
- **Topic-based**: Start concrete (specific code in repo), progress to conceptual.

**Difficulty levels:**

| Level | Focus | Example Stems |
|-------|-------|---------------|
| 1: Comprehension | What does it do? | "Walk me through the data flow from X to Y" |
| 2: Reasoning | Why this approach? | "Why was X chosen over Y?" |
| 3: Edge Cases | What could go wrong? | "What happens if X fails?" |
| 4: Architecture | System interactions | "How does this interact with [module]?" |
| 5: Improvement | Think beyond current | "What would you change about this?" |

**Constraints:**
- Questions MUST be specific to the actual code/changes, not generic textbook questions.
- Each question MUST have a clear, defensible answer.
- MUST NOT ask about trivial details (formatting, import order).
- SHOULD include file paths or code snippets when they add clarity.

### 4. Present Questions Interactively

For each question, use `AskUserQuestion` with:
- Question number and difficulty level (e.g., "Question 3/7 -- Edge Cases")
- The question
- Any relevant code snippet or file reference (keep short)
- "Take your time. Think about it before answering."

After each answer, evaluate immediately as text output:
- **Score**: Strong / Partial / Missed
- **What was right**: Acknowledge correct points specifically
- **What was missed**: Key points not covered
- **Expert answer**: The full answer, explained clearly
- **Why it matters**: Brief practical importance

Then present the next question via `AskUserQuestion` in the same turn. MUST NOT wait for user to say "next."

**Adaptive behavior:**
- If user gets first 3 all Strong: skip ahead to harder questions. Say "You clearly know the basics. Let me jump to the harder stuff."
- If user struggles early: provide more context and hints on subsequent questions.

### 5. Final Report

After all questions (or if user stops early), present:

```
## Results: X/Y Questions Strong

### Scores
1. [Level] Question summary -- Strong/Partial/Missed
...

### Strengths
- Areas of solid understanding

### Knowledge Gaps
- Specific areas to study, with concrete suggestions (files to read, code to trace, concepts to review)

### Recommended Next Steps
- Actionable items for improvement
```

## Edge Cases

- **No changes on branch and no target**: Tell the user; suggest a PR number or topic.
- **User says "I don't know" or "skip"**: Provide expert answer, count as Missed, no judgment.
- **User asks for a hint**: Give one nudge without revealing the answer. One hint per question max.
- **User wants to stop early**: Respect it. Give summary based on questions answered so far.
