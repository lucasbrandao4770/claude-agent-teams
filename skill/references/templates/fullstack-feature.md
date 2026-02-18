---
name: fullstack-feature
description: Build a full-stack feature with dedicated frontend, backend, and test writers
pattern: leader-specialist
team_size: 3
best_for: New features requiring UI, API endpoints, and tests built in parallel
token_estimate: ~800k-1M for a medium feature
---

# Full-Stack Feature Team

## When to Use

- Building a new feature that spans frontend and backend
- Feature has a clear API contract (frontend and backend can work independently)
- Tests can be written against the API contract without waiting for implementation

## When NOT to Use

- Tiny feature (add a button, fix a style) - single session
- Backend-only or frontend-only feature - no need for a team
- Heavily exploratory work where the API contract is unclear

## Team Composition

| Role | Model | Subagent Type | Purpose |
|------|-------|---------------|---------|
| Lead (Architect) | opus | general-purpose | Define API contract, coordinate, integrate |
| Frontend Developer | sonnet | general-purpose | Build UI components and pages |
| Backend Developer | sonnet | general-purpose | Build API endpoints and services |
| Test Writer | sonnet | general-purpose | Write tests against the API contract |

## File Ownership Guidelines

| Teammate | Owns (writes) | Reads (reference only) |
|----------|--------------|----------------------|
| Lead | API contract doc, integration files | All files |
| Frontend Dev | src/components/, src/pages/ (or equivalent) | API contract, backend types |
| Backend Dev | src/api/, src/services/, src/models/ (or equivalent) | API contract |
| Test Writer | tests/ | API contract, all source (read-only) |

**The lead defines the API contract first.** This is the shared interface that enables parallel work.

## Task Decomposition

### Lead Tasks
1. Analyze the feature requirements
2. Design the API contract: endpoints, request/response types, error codes
3. Write the contract document and share with all teammates
4. After all complete: wire frontend to backend, verify integration
5. Run full test suite

### Frontend Developer Tasks
1. Read the API contract
2. Build UI components for the feature
3. Use mock data matching the contract shape (don't wait for real API)
4. Implement state management and user interactions
5. Report completion with list of components created

### Backend Developer Tasks
1. Read the API contract
2. Implement API endpoints matching the contract exactly
3. Implement business logic and data layer
4. Add input validation and error handling
5. Report completion with list of endpoints created

### Test Writer Tasks
1. Read the API contract
2. Write unit tests for expected behavior
3. Write integration tests for API endpoints
4. Write edge case tests (invalid input, auth failures, empty states)
5. Report completion with test count and coverage notes

## Teammate Prompt Template

### Frontend Developer Prompt
```
You are the frontend developer for a new feature. Build the UI components.

FEATURE DESCRIPTION:
{feature_description}

API CONTRACT:
{api_contract}

YOUR FILES (you own these):
- src/components/{feature}/ (create new components here)
- src/pages/{feature}/ (create new pages here)
- Adjust paths to match the actual project structure

READ-ONLY (reference, do NOT modify):
- src/api/ (backend files)
- tests/ (test files)
- Any existing shared components (read, but create new ones in your directory)

INSTRUCTIONS:
1. Build components that match the API contract's response shapes
2. Use mock data for now (lead will wire to real API later)
3. Follow existing project UI patterns and component library
4. Handle loading, error, and empty states
5. Ensure responsive design if applicable

When done, mark task completed and message the lead with:
- Components created (list)
- Any API contract questions or change requests
```

### Backend Developer Prompt
```
You are the backend developer for a new feature. Build the API endpoints.

FEATURE DESCRIPTION:
{feature_description}

API CONTRACT:
{api_contract}

YOUR FILES (you own these):
- src/api/{feature}/ or src/routes/{feature}/
- src/services/{feature}/
- src/models/{feature}/ (if new models needed)
- Adjust paths to match the actual project structure

READ-ONLY (reference, do NOT modify):
- src/components/ (frontend files)
- tests/ (test files)

INSTRUCTIONS:
1. Implement endpoints matching the API contract EXACTLY
2. Follow existing project patterns for routing, middleware, error handling
3. Add input validation for all endpoints
4. Implement proper error responses matching the contract
5. Add database migrations if needed (own the migration files)

When done, mark task completed and message the lead with:
- Endpoints implemented (list)
- Any API contract questions or change requests
```

### Test Writer Prompt
```
You are the test writer for a new feature. Write comprehensive tests.

FEATURE DESCRIPTION:
{feature_description}

API CONTRACT:
{api_contract}

YOUR FILES (you own these):
- tests/unit/{feature}/
- tests/integration/{feature}/
- Adjust paths to match the actual project structure

READ-ONLY (reference, do NOT modify):
- All source code files (read to understand, do NOT modify)

INSTRUCTIONS:
1. Write tests AGAINST THE CONTRACT (not the implementation)
2. Unit tests: test each endpoint's expected behavior
3. Integration tests: test the API with realistic scenarios
4. Edge cases: invalid input, missing auth, empty results, pagination
5. Use project's existing test patterns and fixtures

When done, mark task completed and message the lead with:
- Number of tests written
- Coverage notes
- Any contract ambiguities found
```

## Communication Flow

```text
    Lead (Opus)
    |
    +-- defines API contract
    |
    +-- contract + frontend scope --> Frontend Dev
    +-- contract + backend scope --> Backend Dev
    +-- contract + test scope --> Test Writer
    |
    Frontend Dev --> components done --> notifies Lead
    Backend Dev --> endpoints done --> notifies Lead
    Test Writer --> tests done --> notifies Lead
    |
    Lead wires frontend to backend --> runs tests --> reports to user
```

## Success Criteria

- API contract implemented on both frontend and backend
- Frontend components render with real data from backend
- All tests pass (unit + integration)
- Error handling works (invalid input, auth failures)
- No file ownership conflicts

## Common Pitfalls

| Pitfall | Mitigation |
|---------|-----------|
| API contract is ambiguous | Lead writes detailed types with examples |
| Frontend and backend interpret contract differently | Lead reviews both against contract before integration |
| Test writer writes implementation-dependent tests | Prompt says "test against the CONTRACT" |
| Shared type/schema files modified by multiple people | Lead owns all shared type definitions |
| Feature too large for one team session | Break into sub-features, one team per sub-feature |

## Adaptation Notes

- **Python + React:** Backend Dev owns `app/` or `src/api/`, Frontend Dev owns `frontend/src/`, paths adjusted at spawn time
- **Next.js (monorepo):** Frontend owns `app/` pages, Backend owns `app/api/` routes, shared types owned by lead
- **Games (Godot):** Replace "Frontend Dev" with "Scene Developer" (owns .tscn/.tres), "Backend Dev" with "Script Developer" (owns .gd), lead owns project.godot
- **With existing UI agents:** If project has `ui-prototyper.md`, use its instructions for the Frontend Dev role
- **With existing API agents:** If project has `data-engineer.md` or similar, use for Backend Dev role
