# Popsink public skills

Public [Claude Code skills](https://docs.claude.com/en/docs/claude-code/skills)
for working with a [Popsink](https://popsink.com) data plane. One directory per
skill under `skills/`, each holding a `SKILL.md` with YAML frontmatter
(`name`, `description`).

A Popsink deployment is reachable at its own URL — for example
`https://<tenant>.<region>.popsink.com` — and exposes a REST API under `/api`,
documented live at `/api/docs`. Calls are authenticated with an organization
API key created in the control plane.

## Skills

| Skill | What it does |
|---|---|
| [`popsink-api`](skills/popsink-api/SKILL.md) | Authenticate against a Popsink instance and drive it through its REST API — connectors, datamodels, subscriptions, status, logs, metrics. |

## Install

Symlink the skills you want into your personal skills directory:

```bash
git clone https://github.com/Popsink/public-skills.git ~/src/popsink-public-skills
for s in ~/src/popsink-public-skills/skills/*/; do
  ln -sfn "$s" ~/.claude/skills/"$(basename "$s")"
done
```

Symlinking (rather than copying) means `git pull` updates every installed skill.

Or scope them to a single project with `.claude/skills/` instead of
`~/.claude/skills/`.

## Adding a skill

1. `mkdir skills/<name>` and write `SKILL.md`.
2. Frontmatter needs a `name` matching the directory and a `description` that
   says *what it does* **and** *when to use it* — that description is the only
   thing the model sees when deciding whether to load the skill.
3. Supporting files — reference docs, scripts, templates — go in subdirectories
   of the skill (`reference/`, `scripts/`), referenced by relative path from
   `SKILL.md`.
4. Add a row to the table above.

## Conventions

This repository is **public**. Everything in it must be safe for anyone to
read:

- No client names, hostnames, schema or table names, connector IDs, or any
  other tenant-identifying detail. Use placeholders (`<host>`, `<schema>.<table>`,
  `<connector-id>`).
- No credentials, API keys, or tokens — not even expired ones.
- No internal-only URLs, dashboards, or ticket links.
- English only, in every file.

The first three are enforced on every pull request by
[`.github/scripts/check-public-safety.sh`](.github/scripts/check-public-safety.sh)
and a gitleaks pass. Run it yourself before pushing:

```bash
.github/scripts/check-public-safety.sh
```

A skill that drives a live deployment carries the same obligation the other
way: see [SECURITY.md](SECURITY.md) for how to report a vulnerability, what
never to paste into an issue, and the two refusals built into the `popsink`
helper.

## License

[Apache-2.0](LICENSE).
