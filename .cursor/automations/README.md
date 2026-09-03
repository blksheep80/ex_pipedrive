# Cursor Automations (ExPipedrive)

Import these via **Agents Window → `/automate`**, or paste `prefillWorkflowData` when
opening the Automations editor. Requires the [cloud environment](../environment.json)
so agents can run `mix test`.

| File | Trigger | Purpose |
|---|---|---|
| [pr-quality-pass.json](pr-quality-pass.json) | PR opened / pushed | Review for real bugs and style issues; comment only |
| [ci-failure-triage.json](ci-failure-triage.json) | CI completed (failure) | Read failing job, propose fix PR or explain root cause |
| [weekly-coverage-quick-wins.json](weekly-coverage-quick-wins.json) | Cron Mondays 09:00 UTC | Coverage skill → ≤2 modules → draft PR if green |

## Setup checklist

1. Cloud environment Build green (`.cursor/environment.json` + Dockerfile).
2. GitHub integration connected for `blksheep80/ex_pipedrive`.
3. Enable **Comment on pull request** and **Pull request creation** tools.
4. Enable **Memories** on the weekly coverage automation.

## Prompt sources

Automation prompts reference committed skills:

- `.cursor/skills/improve-test-coverage/SKILL.md`
- `.cursor/skills/ex-pipedrive-session/SKILL.md`

Only reference these paths when the automation runs in `blksheep80/ex_pipedrive`.
