# vdufloth's Claude Code plugin marketplace

Personal [Claude Code](https://code.claude.com) plugin marketplace. Skills, MCP servers, hooks, and slash commands I use across machines and want to share.

## Install

In any Claude Code session:

```
/plugin marketplace add vdufloth/claude-plugins
/plugin install vdufloth@vdufloth-claude-plugins
```

That's it — the marketplace is public, so no authentication is needed on any machine.

To pull updates later:

```
/plugin marketplace update vdufloth-claude-plugins
/plugin update vdufloth@vdufloth-claude-plugins
```

## What's included

### `vdufloth` plugin

| Skill | Invocation | Description |
|-------|------------|-------------|
| `devils-advocate` | `/vdufloth:devils-advocate [path-to-plan.md]` | Iteratively harden a design doc or implementation plan through multiple rounds of devil's advocate critique. |
| `code-style` | `/vdufloth:code-style` (or auto-invoked when writing/editing/reviewing code) | Personal coding conventions: function/file size, naming, explicit types, dependency injection, tests, structure, formatting, logging. |

### Always-on enforcement (optional)

Skills are auto-invoked based on description matching, which is a soft guarantee. To make `code-style` apply to **every** Claude Code session on a machine, install the rules into your user-level `~/.claude/CLAUDE.md`:

```bash
curl -fsSL https://raw.githubusercontent.com/vdufloth/claude-plugins/main/scripts/install-code-style.sh | bash
```

Or from a clone:

```bash
bash scripts/install-code-style.sh
```

The script writes a self-contained, marker-delimited block into `~/.claude/CLAUDE.md`. Re-run it any time to refresh the rules in place — it's idempotent.

## Repository structure

```
.
├── .claude-plugin/
│   └── marketplace.json           # marketplace manifest
├── plugins/
│   └── vdufloth/                  # the plugin
│       ├── .claude-plugin/
│       │   └── plugin.json        # plugin manifest
│       └── skills/
│           ├── code-style/
│           │   └── SKILL.md
│           └── devils-advocate/
│               └── SKILL.md
└── scripts/
    └── install-code-style.sh      # bootstrap code-style into ~/.claude/CLAUDE.md
```

## Adding a new skill

To add a skill to the existing `vdufloth` plugin:

1. Create `plugins/vdufloth/skills/<skill-name>/SKILL.md` with YAML frontmatter:
   ```yaml
   ---
   name: <skill-name>
   description: One sentence describing when this skill applies
   ---

   Skill instructions here.
   ```
2. Bump `version` in `plugins/vdufloth/.claude-plugin/plugin.json`
3. Commit and push
4. On any machine: `/plugin update vdufloth@vdufloth-claude-plugins`

## Adding a sibling plugin

When the marketplace grows beyond one plugin's scope (e.g. a separate `dev-tools` plugin):

1. Create `plugins/<new-plugin>/.claude-plugin/plugin.json`:
   ```json
   {
     "name": "<new-plugin>",
     "version": "0.1.0",
     "description": "...",
     "author": { "name": "Vinicius Dufloth" }
   }
   ```
2. Add skills under `plugins/<new-plugin>/skills/<skill-name>/SKILL.md`
3. Optional bundle: `.mcp.json` (MCP servers), `hooks/hooks.json` (hooks), `commands/` (slash commands), `agents/` (sub-agents) at the plugin root
4. Append the new plugin to the `plugins` array in `.claude-plugin/marketplace.json`:
   ```json
   {
     "name": "<new-plugin>",
     "source": "./plugins/<new-plugin>",
     "description": "..."
   }
   ```
5. Commit and push. Install with `/plugin install <new-plugin>@vdufloth-claude-plugins`.

Plugins are independently installable — adding a sibling doesn't affect users who only want `vdufloth`.

## Sharing with teammates

Same two install commands. No managed-settings or enterprise config required for ad-hoc sharing.

## License

MIT — see [LICENSE](./LICENSE).
