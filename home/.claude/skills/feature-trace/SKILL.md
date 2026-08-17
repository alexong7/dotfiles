---
name: feature-trace
description: "Use when the user wants to trace a feature across codebases, understand data flows, analyze cross-cutting impacts, or visualize full-stack architecture. Triggers on: 'trace', 'data flow', 'how does X work end-to-end', 'impact analysis', 'what touches X', 'architecture of X'."
allowed-tools: Bash, Read, Write, Agent
user-invocable: true
arguments:
  - name: feature
    description: "Feature name, file path, GraphQL operation, API endpoint, DB table, permission, or concept to trace"
    required: true
  - name: scope
    description: "'backend' (grc-evergreen2), 'frontend' (ts-grc), or 'full-stack' (both). Default: auto-detect."
    required: false
---

# Feature Trace

Trace a feature end-to-end through the codebase, mapping data flows, dependencies, authorization gates, and cross-cutting concerns. Produces a structured analysis with Mermaid architecture diagrams.

## Parameters

| Name | Required | Default | Description |
|------|----------|---------|-------------|
| `feature` | Yes | -- | GraphQL operation, file path, DB table, permission, concept, or API endpoint |
| `scope` | No | Auto-detect | `backend`, `frontend`, or `full-stack` |

## Repo Paths

| Repo | Language | Path |
|------|----------|------|
| grc-evergreen2 | Kotlin/Spring | `~/workspace/go/src/github.com/Workiva/grc-evergreen2` |
| ts-grc | TypeScript/React | `~/workspace/go/src/github.com/Workiva/ts-grc` |
| grc-evergreen3 | Kotlin | `~/workspace/go/src/github.com/Workiva/grc-evergreen3` |

## Steps

### 1. Identify Entry Points

Use `subagent_type: Explore` subagents to search in parallel based on the feature identifier type:

| Input Type | Search Strategy |
|------------|----------------|
| GraphQL operation | `grep -r` in `.graphqls` for schema def; grep `@DgsQuery/@DgsMutation/@DgsData` in `.kt` files |
| File path | Start from the file, trace outward (callers and callees) |
| DB table | Find `CREATE TABLE` in `.sql` migrations; find jOOQ references in `.kt` |
| Permission | `grep -r` in `.kt` and `.graphqls` files |
| Concept | Broad search across class names, package names, schema definitions |
| Frontend | `grep -r` in `.tsx`/`.ts` under ts-grc `src/` |

### 2. Trace Backend Layers (grc-evergreen2)

Use `subagent_type: Explore` subagents to trace each SDS layer in parallel:

**GraphQL Schema + Manager**: Schema definitions, DataFetcher classes, `grantsAccess`/`@requiredAccess` directives, Manager service method calls, input/return types, validation.

**Engine** (if applicable): Business logic, orchestration, prompt engine / ML integration.

**Access**: IPA interfaces, Access service implementations, repository calls, transaction boundaries (`@Transactional`, `useAndCommit`), event publishing.

**Database**: Tables, migration files, relationships, indexes, constraints, soft delete behavior.

**Cross-cutting concerns**: Authorization (`RequestContext`, `@AllowMembershipId`, `@AllowPrimaryRead`), events/messages, CDC audit, DataLoaders, `ComposedWorkpaperValidator`.

### 3. Trace Frontend (ts-grc)

If scope includes frontend:

**UI**: React components, routing, component hierarchy, permission checks.

**Data**: GraphQL queries/mutations (`.graphql` or inline), hooks, state management, optimistic updates, cache invalidation.

**Types**: Generated GraphQL codegen types, shared interfaces.

### 4. Produce Trace Output

**Required sections:**

**Overview** -- 2-4 sentences: what the feature does, who uses it, primary entry points.

**Data Flow** -- Step-by-step numbered flow through each layer with file paths and line references:
```
1. GraphQL schema defines `createAssessment` mutation
   -> path/to/schema.graphqls:L42

2. DataFetcher receives request, validates auth
   -> path/to/AssessmentDataFetcher.kt:L85
   - grantsAccess: FULL: ["Assessment"], DIGEST: ["User"]
   - Calls AssessmentManager.createAssessment()
...
```

**Architecture Diagram** -- A Mermaid `graph TD` diagram showing the flow across layers. For full-stack, include frontend connecting to backend via GraphQL.

**Dependencies** -- "Depends on" (modules, services, tables, permissions) and "Depended on by" (other features, DataLoaders, event handlers).

**Permission / Auth Gates** -- Every authorization check in the path: `grantsAccess`, `@requiredAccess`, `RequestContext` usage, `@AllowMembershipId`, `@AllowPrimaryRead`, frontend permission checks.

**Test Coverage** -- Relevant unit, integration, scenario, and frontend test files. Note obvious gaps.

**Cross-cutting Concerns** -- Events published/consumed, CDC/audit tracking, caching/DataLoader batching, soft delete interaction.

### 5. Offer Obsidian Save

After presenting the trace, ask if the user wants it saved. If yes, write to `/Users/alexong/Documents/Obsidian Notes/Obsidian Notes/Vault/Architecture/` with filename: `YYYY-MM-DD-trace-<feature-slug>.md`.

## Adaptation

- **Single mutation**: Trace deeply through every layer with line-level detail.
- **Broad concept** (e.g., "assessments"): Trace primary CRUD operations, note secondary flows, map overall module structure. MUST NOT trace every single operation.
- **Permission trace**: Focus on auth gates; skip business logic details.
- **DB table trace**: Start from bottom, trace upward to all consumers.
- **Full-stack**: Prioritize connection points (GraphQL schema is the seam); trace the most important flow in each direction.

## Edge Cases

- **Feature only exists in one scope**: Note this and trace only where it exists.
- **Generated code**: MUST NOT trace into generated code (jOOQ, GraphQL codegen) because it obscures the actual design. Reference the source (schema, migration) instead.
- **Spans multiple modules**: Trace the primary module deeply; note connections to others.
- **ts-grc not available locally**: Note this, skip frontend trace, suggest cloning.
