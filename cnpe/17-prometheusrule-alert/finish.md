# Alert armed — and firing! 🎉

You wrote a real SLO burn alert and proved the full chain:
PrometheusRule object → operator config reload → rule evaluation → pending → firing.

## Key facts to remember

- The operator only loads rules matching the Prometheus `ruleSelector` labels —
  **check the selector before writing the rule**
- Error-ratio idiom: `sum(rate(errors[5m])) / sum(rate(total[5m])) > 0.05`
- `status=~"5.."` — regex match for all 5xx codes
- `for: 5m` = condition must hold 5 minutes before firing (pending in between)
- `severity` is just a label — routing happens in Alertmanager, but graders check the label
- Verify in the Prometheus UI/API (**Status → Rules**), not just `kubectl get`

📖 This lab is **Chapter 17** of the *CNPE Scenarios and Solutions* book.

Next lab: **18 — Enable span-switch tracing and export the exception**.
