# Task Management with Storyhook

This project uses **storyhook** (`story` CLI) for work tracking.

**Important:** The `.storyhook/` directory is version-controlled project data. Do NOT add it to `.gitignore`.

## Session lifecycle

1. Run `story load-context` at the start of every session to understand project state.
2. Run `story next` to find the highest-priority ready task.
3. Update story status as you work: `story move OS-<n> in-progress`
4. Add progress notes: `story comment OS-<n> "what changed and why"`
5. Mark complete: `story move OS-<n> done "summary of what was delivered"`
6. Run `story handoff --since 2h` at end of session.

## Planning mode

When creating implementation plans, create a story for each discrete work item, phase, or issue:

```
story new "Phase 1: Set up database schema"
story new "Phase 2: Implement API endpoints"
story new "Phase 3: Add authentication middleware"
```

### Decompose workflow

For larger specs, use `story decompose` to parse a markdown or YAML file into stories
with relationships, priorities, and labels automatically:

```
story decompose spec.md --dry-run    # Preview without creating
story decompose spec.md              # Create stories from spec
cat spec.md | story decompose --stdin
```

### Relationship types

Define relationships between stories to express dependencies and structure:

| Relation | Inverse | Purpose |
|---|---|---|
| `blocks` | `blocked-by` | Task dependencies — `story next` respects these |
| `parent-of` | `child-of` | Hierarchy — group subtasks under a parent |
| `relates-to` | `relates-to` | General link between related stories |
| `duplicate-of` | `duplicate-of` | Mark a story as a duplicate |
| `obviates` | `obviated-by` | One story makes another unnecessary |

```
story relate OS-1 parent-of OS-2
story relate OS-2 blocks OS-3
story relate OS-5 relates-to OS-2
story relate OS-6 obviates OS-7
```

### Dependency graph

Visualize relationships and spot bottlenecks:

```
story graph                           # Full dependency overview
story graph --blocked-by OS-1   # Trace why a story is blocked
```

Set priority on each story so `story next` surfaces the right work:

```
story prioritize OS-1 critical
story prioritize OS-4 high
story prioritize OS-6 medium
```

## During execution

- Before starting a story: `story move OS-<n> in-progress`
- When blocked: `story block OS-<n> "reason"`
- When unblocked: `story unblock OS-<n>`
- When done: `story move OS-<n> done "what was delivered"`
- To check what's ready: `story next --count 5`
- To see blocked work: `story list --blocked`
- To see the dependency graph: `story graph`

## Commands

| Action | Command |
|---|---|
| Project overview | `story load-context` |
| Next ready task | `story next` |
| List open stories | `story list` |
| Show a story | `story show OS-<n>` |
| Create a story | `story new "<title>"` |
| Add a comment | `story comment OS-<n> "comment text"` |
| Move to state | `story move OS-<n> <state>` |
| Set priority | `story prioritize OS-<n> high` |
| Assign a story | `story assign OS-<n> <member>` |
| Add a label | `story label OS-<n> <label>` |
| Set multiple fields | `story set OS-<n> --priority high --state in-progress` |
| Add relationship | `story relate OS-1 blocks OS-2` |
| Decompose a spec | `story decompose spec.md` |
| Search | `story search "<query>"` |
| Summary stats | `story summary` |
| Dependency graph | `story graph` |
| Interactive TUI | `story tui` |
| Session handoff | `story handoff --since 2h` |

Run `story help <command>` for detailed usage on any command, or `story help --compact` for the full reference.
