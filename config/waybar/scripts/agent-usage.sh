#!/bin/bash
# Waybar module for AI agent plan usage.
# Shows the logo of whichever agent is currently the default, with its headline
# number: plan percentage where the provider has limits, spend where it does
# not. Reads the records omarchy-agent-usage-update writes, refreshing them
# when they go stale so the bar works whether or not the panel has been opened.

usage_dir="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/agents/usage"
agent_file="$HOME/.config/omarchy/defaults/agent"
max_age=900

export OMARCHY_PATH="${OMARCHY_PATH:-$HOME/.local/share/omarchy}"
export PATH="$OMARCHY_PATH/bin:$PATH"

agent="claude"
[ -f "$agent_file" ] && read -r agent <"$agent_file"
[ -n "$agent" ] || agent="claude"

record="$usage_dir/$agent.json"

if [ ! -f "$record" ] || [ $(($(date +%s) - $(stat -c %Y "$record" 2>/dev/null || echo 0))) -gt "$max_age" ]; then
	(omarchy-agent-usage-update >/dev/null 2>&1 &)
fi

python3 - "$record" "$agent" <<'PY'
import json, re, sys

record, agent = sys.argv[1], sys.argv[2]

# Anthropic's mark is an asterisk; OpenAI's knot is closest to md-atom. The
# Nerd Font ships no true OpenAI or opencode logo, so those are approximations.
GLYPHS = {
    "claude": "",
    "codex": "\U000f0768",
    "opencode": "",
    "copilot": "",
    "fireworks": "\U000f0768",
}
glyph = GLYPHS.get(agent, "\U000f16a1")

try:
    d = json.load(open(record))
except Exception:
    print(json.dumps({"text": glyph, "tooltip": f"{agent}: no usage data yet", "class": "idle"}))
    raise SystemExit

name = d.get("name", agent)
limits = d.get("limits") or []

percents = []
lines = [name]
for limit in limits:
    try:
        p = round(float(limit.get("percent", 0)) * 100)
    except (TypeError, ValueError):
        continue
    percents.append(p)
    lines.append(f"{limit.get('label', '?')}: {p}%")

if percents:
    worst = max(percents)
    text = f"{glyph} {worst}%"
    cls = "critical" if worst >= 90 else "warning" if worst >= 70 else "ok"
else:
    # No plan limits (pay as you go): the hero line carries the spend, and a
    # blank usageStatusText is deliberate so the panel skips its alert surface.
    status = d.get("usageStatusText") or d.get("tierLabel") or "no limits reported"
    money = re.search(r"\$[\d.,]+", status)
    headline = money.group(0) if money else status.split(" across ")[0]
    text = f"{glyph} {headline}" if d.get("ready") else glyph
    cls = "ok" if d.get("ready") else "idle"
    lines.append(status)

tier = d.get("tierLabel")
if tier and tier not in lines:
    lines.insert(1, tier)
lines.append("click: usage panel")

print(json.dumps({"text": text, "tooltip": "\n".join(lines), "class": cls}))
PY
