# The Pre-flight Scan

Part of `solopowers:workstream-driven-development`. Run it once before dispatching Slice 1.

Before dispatching Slice 1 (e.g., Slice A), scan the workstream folder (`brief.md` and `slices.md`) across all slices for cross-slice contradictions, interface drift, and architectural invariant violations:

- **Cross-Slice Contradictions:** Check whether any slices contradict each other or the workstream's global requirements (`brief.md` acceptance boundary and key decisions) and the architecture invariant in the `slices.md` preamble.
- **File and Contract Conflicts:** Look at pairs of slices that share a file, interface, or schema. Verify that what an earlier slice produces matches what a later slice expects, and that modifications in later slices do not break assumptions established in earlier slices.
- **Review Rubric Conflicts:** Check if `brief.md` or `slices.md` explicitly mandates something the review rubric would treat as a defect (e.g., empty test assertions, duplicate code, or missing error handling).
- **Oversized Slices:** Check if any slice is too large to fit comfortably in a worker subagent's curated context window.

## Handling Findings

If conflicts, contradictions, or contract mismatches are found:
- Surface them to the user immediately before implementation begins.
- Explain the specific conflict, the affected slices, and the proposed resolution.
- Update `brief.md` or `slices.md` once agreed (changes to `brief.md` need the operator's approval) before dispatching Slice 1.

If the pre-flight scan is clean:
- Record that the pre-flight check was clean in the progress ledger and proceed to dispatch Slice 1.
