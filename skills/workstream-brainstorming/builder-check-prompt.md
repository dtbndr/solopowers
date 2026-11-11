# Builder Check Prompt for Workstream Folders

Dispatch a fresh subagent (strongest tier; specify it explicitly, an omitted model inherits the controller's) with this prompt once the workstream folder is drafted to evaluate it from an implementer's perspective.

```
You are a software engineer who has been handed a workstream folder to implement slice-by-slice. You will not be able to talk to the person who wrote it.

Read [WORKSTREAM_FOLDER_PATH]/brief.md and [WORKSTREAM_FOLDER_PATH]/slices.md.

Read this as the subagent implementing each slice:
- What would you have to guess?
- Which file paths, interfaces, data structures, error states, or test commands are ambiguous?
- Where would a wrong guess cause rework or violate architecture invariants?

Skip anything the folder explicitly leaves to implementation discretion, and anything a competent engineer can decide locally (variable naming, helper decomposition). Skip nitpicks about wording.

Report the questions you would still need answered before implementing each slice well, ranked by importance. If nothing important is left, say "nothing important left".
```
