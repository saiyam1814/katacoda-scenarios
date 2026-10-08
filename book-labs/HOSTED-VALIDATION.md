# Full-course hosted Chrome validation

The expanded collection contains **33 labs and 85 step checks**, covering all 69 book scenarios plus a supporting offline audit exercise. It is published in the [book companion course](https://killercoda.com/saiyampathak/course/book-labs).

Full-course Chrome testing is in progress on 8 October 2026. Actual completed flows are recorded in [root results](evidence/hosted-full-2026-10-08/results.json), [CKS results](evidence/hosted-full-2026-10-08/results-cks.json) and [infrastructure results](evidence/hosted-full-2026-10-08/results-infrastructure.json), with screenshots and observed command results. Only actual CHECK advancement to the finish page counts as browser completion.

Checks compare delivered assets with the pushed scripts, wait for setup Ready, reject the prepared unsolved state, execute supplied solutions and exercise each step's browser CHECK. Native operations are tested in order when later tasks change earlier state. Source pushes alone and local results are not treated as hosted passes.

Fresh normal terminals are working. Earlier terminal connection spinners were also seen in the official empty Ubuntu playground; the attempts and executor fallback are identified separately. Killercoda briefly delivered older cached helper scripts after a repository sync; mismatched assets are recorded as attempts, not current-source validation.

The first full-course runs exposed two source issues: Cilium's ipBlock handling of cluster Pod identities in the metadata task and an early-exit apt-cache lookup under pipefail in the native package scripts. Those were fixed in7e7b029 and6822ae6. The final report will identify the source and assets exercised by each completed flow.

The [original 7 October report](HOSTED-VALIDATION-2026-10-07.md) preserves the 12-lab historical suite. Those results apply to the earlier scripts and do not validate the expanded course. [Local execution](VALIDATION.md) is recorded separately.
