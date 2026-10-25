# adhd-manager: one-time GitHub settings

About 15 minutes. Do them in order. Anything not listed here: leave it as it is.
All pages are under github.com/jcallahanp/adhd-manager > **Settings** (top tab).

## Step 0. General > Danger Zone > Change visibility > Public (D-004). Done 2026-10-25.

## Step 1. General > Pull Requests section
| Setting | Set to |
| --- | --- |
| Allow merge commits | Unchecked |
| Allow squash merging | Checked. Default commit message: **Pull request title and description** |
| Allow rebase merging | Unchecked |
| Always suggest updating pull request branches | Checked |
| Allow auto-merge | Unchecked |
| Automatically delete head branches | Checked |

## Step 2. Left sidebar > Advanced Security
Go down the page in this order. Anything not listed: leave as is.
| Item | Do this |
| --- | --- |
| Private vulnerability reporting | Click **Enable** |
| Dependency graph | Leave **On** |
| Automatic dependency submission | Leave as is (not used for pnpm) |
| Dependabot alerts, Malware alerts | Leave **On** |
| Dependabot auto-triage rules | Leave as is |
| Dependabot security updates | Leave **On** |
| Grouped security updates | Leave **On** |
| Dependabot version updates | Nothing (`.github/dependabot.yml` configures it) |
| Other tools | Nothing |
| AI Scan for pull requests | Leave **Off** (the Claude security review covers it) |
| Copilot Autofix | Leave **On** |
| Agentic autofix | Leave **Off** (uses paid credits) |
| Check runs failure threshold | Security alerts: **High or higher** · Other alerts: **Only errors** |
| Secret Protection > Push protection | **On** if the toggle is shown; public repos have it on already |

## Step 3. Same page > Code Security > Tools > CodeQL analysis
1. Click **Set up**, choose **Default**.
2. In the box that opens, leave languages and query suite as shown, click **Enable CodeQL**.
3. Left sidebar > **Secrets and variables > Actions** > **Variables** tab > **New repository variable**.
   Name: `CODE_SCANNING` · Value: `true` · **Add variable**.

## Step 4. Left sidebar > Rules > Rulesets > New ruleset > New branch ruleset
| Field | Set to |
| --- | --- |
| Ruleset name | `main` |
| Enforcement status | Active |
| Bypass list | Leave empty |
| Target branches | **Add target > Include default branch** |
| Restrict creations | Unchecked |
| Restrict updates | Unchecked |
| Restrict deletions | Checked |
| Require linear history | Checked |
| Require deployments to succeed | Unchecked |
| Require signed commits | Unchecked |
| Require a pull request before merging | Checked. Required approvals: **0**. Check **Require conversation resolution before merging**. Leave the other boxes in it unchecked. Allowed merge methods: **Squash** only |
| Require status checks to pass | Checked. Check **Require branches to be up to date before merging**. Click **Add checks** and add these five, one at a time: `Ledger updated with code changes`, `Lint, test, build`, `Secret scan`, `Trivy filesystem and config`, `Workflow audit (zizmor)` |
| Block force pushes | Checked |
| Require code scanning results | Checked. Add tool **CodeQL**, Security alerts: **High or higher**, Alerts: **Errors** |
| Everything else | Unchecked |

Click **Create**.

## Step 5. Left sidebar > Actions > General
| Setting | Set to |
| --- | --- |
| Actions permissions | Allow all actions and reusable workflows |
| Require actions to be pinned to a full-length commit SHA | Checked |
| Approval for running fork pull request workflows | Require approval for all external contributors |
| Workflow permissions | Read repository contents and packages permissions |
| Allow GitHub Actions to create and approve pull requests | Unchecked |

Click **Save** under each section you changed.

## Step 6. API key for the PR security review
1. Go to console.anthropic.com > **Settings > Workspaces > Create workspace**. Name: `adhd-manager-ci`. Set its monthly spend limit to **$20**.
2. In that workspace: **API keys > Create key**, name `github-actions`. Copy it.
3. Back in GitHub: **Settings > Secrets and variables > Actions > Secrets** tab > **New repository secret**.
   Name: `ANTHROPIC_API_KEY` · Secret: paste the key · **Add secret**.

No local setup is needed: the project is cloud-only. CI runs the same secret and workflow checks the pre-commit hooks would, and Superpowers loads from `.claude/settings.json`.

When done, tell Claude in the thread "settings done".
