# Pipeline complete! 🎉

`compile-release` now builds, packages, **and ships** - and you learned how Tekton
passes data between tasks.

## Key facts to remember

- Task **results** are small strings written to `$(results.<name>.path)`;
  consume them with `$(tasks.<task>.results.<name>)`
- `runAfter: [a, b]` = explicit ordering; without it, Tekton runs tasks in parallel
- Params reach scripts as `$(params.<name>)` - use `printf '%s\n'` for multi-line values
- TaskRun pods run under a ServiceAccount (default: `default`) - RBAC errors mean the
  SA, not you, lacks permissions
- `tkn pipeline start <name> --showlog` = create a run + stream logs in one command

📖 This lab is **Chapter 11** of the *CNPE Scenarios and Solutions* book.

Next lab: **12 - Trigger a Tekton Pipeline from a webhook**.
