# Builder Check Prompt for Workstream Documents

Dispatch a fresh subagent with this prompt once the Workstream Document is drafted to evaluate it from an implementer's perspective.

```
You are a software engineer who has been handed a Workstream Document to implement slice-by-slice. You will not be able to talk to the person who wrote it.

Read [WORKSTREAM_DOCUMENT_PATH].

Read this as the subagent implementing each slice:
- What would you have to guess?
- Which file paths, interfaces, data structures, error states, or test commands are ambiguous?
- Where would a wrong guess cause rework or violate architecture invariants?

Skip anything the document explicitly leaves to implementation discretion, and anything a competent engineer can decide locally (variable naming, helper decomposition). Skip nitpicks about wording.

Report the questions you would still need answered before implementing each slice well, ranked by importance. If nothing important is left, say "nothing important left".
```
