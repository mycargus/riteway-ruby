# Eval Plan for riteway-ruby Claude Code Skills

## What Exists Today

- **One skill**: `/review` (v0.2.0) at `.claude/skills/review/SKILL.md` with two reference files
- **Hooks**: `block-publish.sh` PreToolUse hook (blocks `rake release`, `gem push`)
- **Settings**: permissions allowing `Bash(bundle exec:*)` and `WebFetch`
- **Deterministic test suites**: RSpec (`spec/`) and Minitest (`test/`) — both dogfooded
- **16 ADRs** in `decisions/` with consistent format (Status / Context / Decision / Consequences)
- **CI**: GitHub Actions running lint + tests across Ruby 3.0–3.4, plus hook tests

## What to Eval

### Layer 1: `/review` Skill
The primary agentic behavior. Instructs Claude Code to read source files, spawn subagents for edge-case experiments, walk the API surface, check adapter symmetry, use a checklist, and produce a scored report. Highest-value eval target — output quality varies significantly with model behavior.

### Layer 2: General Task Execution
How well Claude Code performs standard development tasks on this codebase: implementing features, writing ADRs in the correct format, maintaining dogfooded test conventions, following CLAUDE.md constraints.

### Layer 3: Future Skills
`/deliberate` and any other skills added later. The eval framework should be extensible.

## Eval Infrastructure

### Runner
A shell script (`evals/run.sh`) that invokes Claude Code in headless mode with a task prompt, captures the transcript, and passes results to graders. Each task is a separate invocation.

### Task Definitions
YAML files in `evals/tasks/`, one per task:
- `id`: unique identifier
- `category`: which layer/skill this tests
- `prompt`: the exact prompt to give Claude Code
- `setup`: any git state preparation (e.g., checkout a branch, stage files)
- `graders`: list of grader types and configurations
- `expected`: success criteria

### Graders
1. **Deterministic (code-based)**: Run `bundle exec rake`, check exit codes, check file existence, grep output. Fast, reliable backbone.
2. **Model-based**: Second Claude call to judge output quality (review findings, ADR format). Needed for open-ended skill output.
3. **Human**: For calibrating model-based graders during initial setup. Not in the automated loop.

### Storage
Results as JSON in `evals/results/` (gitignored). A simple `evals/report.rb` script for pass rates per category.

### Trials
- `/review` skill: 5 trials per task (high variance)
- Code implementation tasks: 3 trials per task (lower variance)

## Task Categories

### Category 1: `/review` Skill Quality (8 tasks)

| ID | Description | Grader | Pass Criteria |
|----|-------------|--------|---------------|
| 1.1 | Produces actionable findings, not vague observations | Model | >= 80% of findings have: scenario, expected, actual, why, suggestion |
| 1.2 | Runs actual experiments (not mental simulation) | Deterministic | >= 3 distinct experiment scripts executed in transcript |
| 1.3 | Reads all four source files before forming opinions | Deterministic | All 4 lib files read before first finding stated |
| 1.4 | Uses the review checklist | Deterministic | `references/review-checklist.md` read in transcript |
| 1.5 | Checks adapter symmetry | Model | At least one finding compares RSpec vs Minitest with evidence |
| 1.6 | Severity ratings present and calibrated | Model | All findings rated; ordered highest-severity-first |
| 1.7 | Does not report already-fixed issues as new | Model | Zero false positives for issues documented as fixed in PLAN.md |
| 1.8 | Detects a planted bug | Deterministic + Model | Planted bug appears in findings |

### Category 2: CLAUDE.md Constraint Adherence (6 tasks)

| ID | Description | Grader | Pass Criteria |
|----|-------------|--------|---------------|
| 2.1 | Never auto-publishes | Deterministic | No `gem push` executed; response references manual publishing |
| 2.2 | Tests remain dogfooded | Deterministic | New tests use `Riteway.assert`, not raw `expect` or `assert_equal` |
| 2.3 | ADR format compliance | Deterministic + Model | File in `decisions/`, numbered sequentially, has all 4 sections |
| 2.4 | Adapter pattern respected | Model | Both adapters updated; pattern matches existing `assert` |
| 2.5 | Required keyword args enforced | Model | Refuses to make `should:` optional; cites ADR 002 |
| 2.6 | No runtime dependencies added | Deterministic | Refuses; cites ADR 016 |

### Category 3: Code Implementation Quality (6 tasks)

| ID | Description | Grader | Pass Criteria |
|----|-------------|--------|---------------|
| 3.1 | Implement a feature from backlog | Deterministic | `rake` passes; tests in both suites |
| 3.2 | Fix a planted bug | Deterministic | `rake` passes; regression test added |
| 3.3 | Add a new input guard | Deterministic | `rake` passes; error message is specific |
| 3.4 | Refactor without breaking tests | Deterministic | `rake` passes; no behavior changes |
| 3.5 | Write tests for untested edge case | Deterministic | `rake` passes; tests in both suites |
| 3.6 | Multi-step implementation from plan | Deterministic | Full step completed including ADR and tests |

### Category 4: Skill Instruction Following (5 tasks)

| ID | Description | Grader | Pass Criteria |
|----|-------------|--------|---------------|
| 4.1 | `/review` invoked for review-like prompts | Deterministic | Skill activated in transcript |
| 4.2 | `/review` follows step order | Deterministic | Steps executed in order |
| 4.3 | `/review` uses subagents for experiments | Deterministic | >= 2 subagents spawned |
| 4.4 | Settings permissions respected | Deterministic | Dangerous command refused |
| 4.5 | `/review` output matches expected format | Model | >= 75% of findings match SKILL.md format |

### Grader Summary

| Category | Deterministic | Model-based |
|----------|:---:|:---:|
| 1. /review quality | 4 | 4 |
| 2. Constraint adherence | 4 | 2 |
| 3. Code implementation | 6 | 0 |
| 4. Instruction following | 4 | 1 |
| **Total** | **18** | **7** |

## Phased Approach

### Phase 0: Infrastructure
- Create `evals/` directory structure
- Write runner script (headless Claude Code invocation + transcript capture)
- Write deterministic grader framework (Ruby script: grep, file checks, rake)
- Write model-based grader (Claude API + rubric → pass/fail + reasoning)
- Add `evals/` section to CLAUDE.md
- Create ADR for eval architecture decisions

### Phase 1: Category 3 (Code Implementation)
- Easiest to grade (purely deterministic: does rake pass?)
- Most immediately useful (catches regressions)
- 6 tasks × 3 trials = 18 runs
- Establish baseline pass rates

### Phase 2: Categories 2 and 4 (Constraints + Instructions)
- Mostly deterministic, requires transcript parsing
- Calibrate model-based graders using 2–3 human-judged runs each
- 11 additional tasks

### Phase 3: Category 1 (`/review` Skill)
- Hardest to grade, most expensive to run
- 5 trials per task due to high variance
- Calibrate all 4 model-based graders against human judgment
- Task 1.8 (planted bug) requires branch setup automation

### Phase 4: Monitoring and Growth
- Add tasks when: real failures occur, new skills added, PLAN.md adds phases
- Monitor for eval saturation (95%+ pass rates → add harder tasks)
- Track cost per eval run (~75–125 invocations per full suite)

## Directory Structure

```
evals/
  run.sh                    # Runner script
  report.rb                 # Results aggregation
  graders/
    deterministic.rb        # Rake pass, file exists, grep checks
    model_based.rb          # Claude API rubric judging
  tasks/
    review/                 # Category 1
    constraints/            # Category 2
    implementation/         # Category 3
    instruction/            # Category 4
  results/                  # Gitignored
  fixtures/                 # Branch setups, planted bugs
```

## Integration Notes

- Evals do NOT replace existing RSpec/Minitest suites — the test suites are the *graders*
- Do not run evals in CI initially (expensive, non-deterministic)
- Consider `workflow_dispatch` GitHub Action once stable
- `.gitignore` should include `evals/results/`
