# Race condition fixed! 🎉

You added a readiness check to an existing workflow while preserving its deploy
and test behavior.

## Key facts to remember

- Argo Workflow `steps` = **list of lists**: outer = sequential, inner = parallel.
  The double dash `- ` is not a typo
- New step needs **two** edits: the step entry *and* the template it references
- `argo submit -n <ns> --watch` shows the node tree live; `argo logs @latest -n <ns>`
  tails the newest run
- Never rename or remove what already works - verify that existing behavior is preserved
- `kubectl rollout status --timeout` inside a container = the standard "wait for ready"
  gate between deploy and test

📖 This lab is **Chapter 10** of the *CNPE Scenarios and Solutions* book.

Next lab: **11 - Finish compile-release with a kubectl-apply Task (Tekton)**.
