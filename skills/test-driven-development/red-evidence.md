# RED Evidence: New Code, Contracts, Persistence

Part of `solopowers:test-driven-development`. Read it before writing the first test for a new module or export, for a slice with several contracts, or when you take over work whose RED is not saved.

Session audit, not theory: workers repeatedly reported "RED" that was a load error dressed as an assertion, hid several contracts behind one failing assertion, or edited the tests after the failure so the saved output no longer matched them. Each rule below closes one of those.

## New module or export: RED against a stub

A missing module is an execution error, not RED. Do not convert it into an assertion:

```js
// WRONG: turns ERR_MODULE_NOT_FOUND into an AssertionError
let mod; try { mod = await import('../dist/x.js'); } catch { mod = undefined; }
assert.ok(mod, 'the module must exist');
```

Instead:

1. Create the smallest stub that compiles and loads, with the public names and signatures the tests use. It must not implement behavior: return a sentinel with the shape the tests read (for example `{ kind: 'unimplemented' }` where tests read `.kind`) so the assertions fail on values. Never `undefined`, which makes `result.kind` throw a `TypeError`, and never `throw new Error('not implemented')`; both are execution errors again.
2. Build, run the tests, and confirm every failure is an assertion on a behavior value. Fix any failure that is a load, import, type or setup error and rerun.
3. Commit or save the stub with the tests; it is test scaffolding until the implementation edit replaces it.

## Negative contracts need a positive control

A "never calls the transport", "never submits" or "rejects X" test passes against a stub that does nothing, so on its own it proves no RED. It is valid RED only if it also asserts an outcome the stub does not produce (for example the specific `{ kind: 'unsupported', reason }` value). When the slice has an allowed path, also add a positive control that fails against the stub: the same setup with every gate open must show the call happening. A slice that is fail-closed by design and has no open path needs only the outcome assertion.

## One test per contract

Assert one contract per test, so each fails on its own. A test that checks several contracts stops at the first failing assertion and hides the rest; the log then says "early assertions masked other contracts". If the slice lists N contracts, the RED run shows N independent failures.

## Save RED before the implementation edit

1. Run the RED command with output redirected to a file in the workstream workspace (`<cmd> > red-<slice>-<contract>.out 2>&1`) and read it from there. Terminal wrappers can truncate or compact output; the file is the evidence.
2. Copy the command and the failing assertion lines into the report before the first implementation edit. The workspace directory is gitignored on purpose; do not force-add it.
3. If the tests change after that RED, reset the implementation files to the pre-implementation state (the base plus your compiling stub, never a state where the module is missing), rerun, and save a new RED before going to GREEN. A RED that no longer matches the final tests is not evidence for them.

## Taking over uncommitted implementation

If the tree holds implementation written before any saved RED, do not extend it and call the result test-first. Set the implementation files aside, put the base versions plus a compiling stub for any new module in their place, write or restore the tests, run and save RED, then restore the implementation and verify GREEN. If that cannot isolate the behavior, report it as evidence you could not establish; the controller then follows the unrecoverable-RED ladder in `solopowers:workstream-driven-development` (`references/cannot-verify.md`).
