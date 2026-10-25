# Security test report · <milestone> · <date>

Tester: <agent and model, plus John for the manual sign-off> · Build: <git tag or commit> · Stack: <staging URL, compose version> · App: <APK version>

## 1. Scope and objective
What was in scope (backend, web app, Android app, parser, integrations), what was out, and why this test was run (milestone gate or pre-deployment).

## 2. Methodology
Standards: WSTG v4.2 subset <list IDs>, ASVS 5.0.0 Level 2 chapters <list>, MASVS <groups>, OWASP LLM Top 10 items <list>. Automated tools and versions: Semgrep <v>, Bandit <v>, pip-audit <v>, Trivy <v>, ZAP <v>, MobSF <v>, gitleaks <v>. Test accounts used. Dates and duration.

## 3. Summary
One paragraph: overall result, counts by severity, whether the gate passes.

| Severity | Open | Fixed | Accepted |
| --- | --- | --- | --- |
| Critical | | | |
| High | | | |
| Medium | | | |
| Low | | | |
| Informational | | | |

## 4. Findings
One block per finding, highest severity first.

### F-01 · <title> · <severity> · CVSS 3.1 <vector>
- Where: <component, URL, file>
- Standard reference: <WSTG or ASVS id>
- Evidence: <request, response, screenshot path, tool output line>
- Fix: <commit or issue>
- Retest: <date, result>

## 5. Manual checklist results
Link to the filled checklist file in this folder (Pass, Fail, N/A per item with notes).

## 6. Automated scan outputs
| Tool | File in this folder | Result summary |
| --- | --- | --- |

## 7. Residual risk and accepted findings
What stays open, why, and who accepted it.

## 8. Sign-off
Gate result: Pass / Fail. Signed: John <date>.
