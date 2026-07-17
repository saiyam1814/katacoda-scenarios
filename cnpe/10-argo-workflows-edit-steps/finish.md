# Race condition fixed! 🎉

You made a surgical change to a pipeline you did not write - the most realistic CI/CD
task on the exam.

## Key facts to remember

- Argo Workflow `steps` = **list of lists**: outer = sequential, inner = parallel.
  The double dash `- ` is not a typo
- New step needs **two** edits: the step entry *and* the template it references
- `argo submit -n <ns> --watch` shows the node tree live; `argo logs @latest -n <ns>`
  tails the newest run
- Never rename or remove what already works - graders diff the end state
- `kubectl rollout status --timeout` inside a container = the standard "wait for ready"
  gate between deploy and test

📖 This lab is **Chapter 10** of the *CNPE Scenarios and Solutions* book.

Next lab: **11 - Finish compile-release with a kubectl-apply Task (Tekton)**.
