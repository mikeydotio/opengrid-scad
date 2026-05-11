# AGENTS.md — Project Task Management

This project uses **storyhook** for task tracking. All agents must follow the workflow below.

## Workflow

1. **Start of session**: Load project context
   ```
   story load-context
   ```

2. **Pick next task**: Get the highest-priority ready story
   ```
   story next
   ```

3. **Work on the task**: Implement the changes for the assigned story

4. **Complete the task**: Mark the story as done
   ```
   story move <id> done
   ```

5. **End of session**: Generate a handoff summary
   ```
   story handoff --since 2h
   ```

## Quick Reference

| Action | Command |
|---|---|
| List open stories | `story list` |
| Show a story | `story show OS-<n>` |
| Create a story | `story new "<title>"` |
| Move to state | `story move OS-<n> <state>` |
| Add a comment | `story comment OS-<n> "comment text"` |
| Set priority | `story prioritize OS-<n> high` |
| Assign a story | `story assign OS-<n> <member>` |
| Add a label | `story label OS-<n> <label>` |
| Block a story | `story block OS-<n> "reason"` |
| Unblock a story | `story unblock OS-<n>` |
| Add relationship | `story relate OS-1 blocks OS-2` |
| Set multiple fields | `story set OS-<n> --priority high --state in-progress` |
| Search stories | `story search "<query>"` |
| Project summary | `story summary` |
| Context (for LLM) | `story load-context` |
| Phase progress | `story phase list` |
| Session handoff | `story handoff --since 2h` |

Run `story help --compact` for the full command reference.

## Best Practices

Apply standard software design principles, adapted to OpenSCAD's declarative model:

- **Single Responsibility**: each `module`/`function` does one well-named thing. If you find yourself describing it as "X and also Y", split it.
- **DRY**: repeating geometry (corners, legs, slot patterns) belongs in a `for` loop or a parametric module. Copy-pasted point arrays drift out of sync — fix one, miss three.
- **Parametric with derived values**: expose meaningful named parameters above `/* [Hidden] */`; compute dependent values from primaries (`tray_edge_inset = outer_face_outset + lip_top_thickness`) so a single change propagates correctly.
- **YAGNI**: don't add parameters, branches, or modules you don't need yet. An unused customizer slider rots faster than code does.
- **Name your constants**: `lip_top_height = 8` is debuggable; a bare `8` in a `polyhedron` point list is not.
- **Polyhedron discipline**: consistent vertex winding (e.g. CCW viewed from outside the solid), every face closes the volume, no degenerate triangles (no duplicate vertices within a face). Comment each face with what it represents — it pays for itself the first time you debug a non-manifold warning.
- **Document the intent**: each module gets a brief docstring covering purpose and parameter semantics. Inline comments on complex point/face lists save the next reader (often future-you) a 20-minute reverse-engineering session.

## Verification

Every `.scad` file you touch must be rendered through the OpenSCAD CLI as part of
completing the work. Diff inspection and visual review are not sufficient — OpenSCAD
silently auto-repairs some classes of non-manifold geometry, so a model may look
correct in the GUI while emitting warnings on the command line.

```
openscad -o /tmp/check.stl <file>.scad
```

On Mikey's machine the CLI binary is at
`/Volumes/Code/openscad/build/OpenSCAD.app/Contents/MacOS/OpenSCAD`.

**Feature work is not considered complete until the affected `.scad` file builds
cleanly — exit code 0 with no warnings or errors on stderr.** A "WARNING:" line
from the CLI is a failure to address, not noise to skim past. This applies to
new work, bug fixes, refactors, and any change that touches the model.

**Workarounds that silence or obviate warnings are not acceptable.** Examples
of what NOT to do:

- Adding `part_overlap` or epsilon nudges to mask a non-manifold seam instead
  of fixing the polyhedron face definitions
- Running the result through `hull()` or `render()` to launder a broken mesh
  into something CGAL will accept
- Suppressing `echo()` diagnostics or removing assertions that were flagging
  a real problem
- Accepting OpenSCAD's automatic mesh repair as a substitute for correct input
  geometry (the "PolySet -> Manifold conversion failed" warning is itself the
  failure — the auto-repair just hides it from the STL)

Always fix the root cause: trace the warning back to the specific module, face,
or boolean operation that produced it, and correct the underlying geometry.

## Important

The `.storyhook/` directory is version-controlled project data. Do NOT add it to
`.gitignore`. It must be committed to git so that project state travels with the repository.
