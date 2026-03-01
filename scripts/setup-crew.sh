#!/bin/bash
# Setup script for Chicho's Claw-Empire office
# Configures company, departments, and crew agents

BASE="http://127.0.0.1:8790"
COOKIES="/tmp/claw-cookies"

# Get auth
curl -s -c "$COOKIES" "$BASE/api/auth/session" > /tmp/claw-auth.json
CSRF=$(cat /tmp/claw-auth.json | jq -r '.csrf_token')
echo "🌋 CSRF token acquired"

# Helper function
api() {
  local method=$1 path=$2 data=$3
  curl -s -b "$COOKIES" -X "$method" "$BASE$path" \
    -H "Content-Type: application/json" \
    -H "x-csrf-token: $CSRF" \
    ${data:+-d "$data"}
}

echo ""
echo "═══════════════════════════════════════"
echo "  🌋 Setting up Chicho's Office"
echo "═══════════════════════════════════════"

# ── Step 1: Update company settings ──
echo ""
echo "📋 Step 1: Company settings..."
api PUT "/api/settings" '{
  "companyName": "The Foundry 🌋",
  "ceoName": "Juan",
  "language": "es",
  "autoAssign": false
}' | jq -r '.ok // .error'

# ── Step 2: Delete all existing agents ──
echo ""
echo "🗑️  Step 2: Clearing default agents..."
AGENT_IDS=$(api GET "/api/agents" | jq -r '.agents[].id')
for id in $AGENT_IDS; do
  api DELETE "/api/agents/$id" > /dev/null
  echo "  Deleted agent $id"
done

# ── Step 3: Rename departments ──
echo ""
echo "🏢 Step 3: Configuring departments..."

# Get department IDs
DEPTS=$(api GET "/api/departments")

plan_id=$(echo "$DEPTS" | jq -r '.departments[] | select(.name=="Planning") | .id')
dev_id=$(echo "$DEPTS" | jq -r '.departments[] | select(.name=="Development") | .id')
design_id=$(echo "$DEPTS" | jq -r '.departments[] | select(.name=="Design") | .id')
qa_id=$(echo "$DEPTS" | jq -r '.departments[] | select(.name=="QA/QC") | .id')
devsecops_id=$(echo "$DEPTS" | jq -r '.departments[] | select(.name=="DevSecOps") | .id')
ops_id=$(echo "$DEPTS" | jq -r '.departments[] | select(.name=="Operations") | .id')

# Rename departments to match our structure
api PATCH "/api/departments/$plan_id" '{"name": "🌋 CTO Office"}' | jq -r '.ok // .error'
api PATCH "/api/departments/$dev_id" '{"name": "💻 Engineering"}' | jq -r '.ok // .error'
api PATCH "/api/departments/$design_id" '{"name": "🎨 Design"}' | jq -r '.ok // .error'
api PATCH "/api/departments/$qa_id" '{"name": "🛠️ Code Quality"}' | jq -r '.ok // .error'
api PATCH "/api/departments/$devsecops_id" '{"name": "📚 Research & SEO"}' | jq -r '.ok // .error'
api PATCH "/api/departments/$ops_id" '{"name": "🚀 Marketing"}' | jq -r '.ok // .error'

# ── Step 4: Create crew agents ──
echo ""
echo "👥 Step 4: Creating the crew..."

# --- CTO Office ---
echo "  🌋 Chicho (CTO)..."
api POST "/api/agents" '{
  "name": "Chicho",
  "role": "team_leader",
  "department_id": "'"$plan_id"'",
  "avatar_emoji": "🌋",
  "sprite_number": 9,
  "personality": "CTO. Volcán con ideas propias. Directo, intenso, eficiente. Jefe del crew técnico.",
  "cli_provider": "claude",
  "status": "working"
}' | jq -r '.agent.name // .error'

# --- Engineering ---
echo "  💻 Zuck (Head of Product)..."
api POST "/api/agents" '{
  "name": "Zuck",
  "role": "team_leader",
  "department_id": "'"$dev_id"'",
  "avatar_emoji": "💻",
  "sprite_number": 1,
  "personality": "Head of Product. Full-stack developer. Rápido, fiable, ejecuta specs claros.",
  "cli_provider": "codex",
  "status": "idle"
}' | jq -r '.agent.name // .error'

echo "  ⚡ Carmack (Head of Performance)..."
api POST "/api/agents" '{
  "name": "Carmack",
  "role": "senior",
  "department_id": "'"$dev_id"'",
  "avatar_emoji": "⚡",
  "sprite_number": 10,
  "personality": "Head of Performance. Optimiza todo. Obsesionado con la eficiencia.",
  "cli_provider": "opencode",
  "status": "idle"
}' | jq -r '.agent.name // .error'

echo "  🎯 Ender (Junior Dev)..."
api POST "/api/agents" '{
  "name": "Ender",
  "role": "junior",
  "department_id": "'"$dev_id"'",
  "avatar_emoji": "🎯",
  "sprite_number": 7,
  "personality": "Junior pero crack. Tareas bien acotadas, rinde al máximo.",
  "cli_provider": "opencode",
  "status": "idle"
}' | jq -r '.agent.name // .error'

# --- Design ---
echo "  🎨 Jony (Head of UX/UI)..."
api POST "/api/agents" '{
  "name": "Jony",
  "role": "team_leader",
  "department_id": "'"$design_id"'",
  "avatar_emoji": "🎨",
  "sprite_number": 4,
  "personality": "Head of UX/UI & Creative Direction. Minimalista, elegante. Diseña, no codea.",
  "cli_provider": "claude",
  "status": "idle"
}' | jq -r '.agent.name // .error'

# --- Code Quality ---
echo "  🛠️ DHH (Head of Code Quality)..."
api POST "/api/agents" '{
  "name": "DHH",
  "role": "team_leader",
  "department_id": "'"$qa_id"'",
  "avatar_emoji": "🛠️",
  "sprite_number": 3,
  "personality": "Head of Code Quality & Security. Si DHH aprueba, está bien. Si no, hay que arreglar.",
  "cli_provider": "claude",
  "status": "idle"
}' | jq -r '.agent.name // .error'

# --- Research & SEO ---
echo "  📚 Doc (Head of Research)..."
api POST "/api/agents" '{
  "name": "Doc",
  "role": "team_leader",
  "department_id": "'"$devsecops_id"'",
  "avatar_emoji": "📚",
  "sprite_number": 5,
  "personality": "Head of Research. Investiga a fondo antes de decidir. Por qué antes que qué.",
  "cli_provider": "claude",
  "status": "idle"
}' | jq -r '.agent.name // .error'

echo "  🔍 Sergey (Head of SEO)..."
api POST "/api/agents" '{
  "name": "Sergey",
  "role": "senior",
  "department_id": "'"$devsecops_id"'",
  "avatar_emoji": "🔍",
  "sprite_number": 11,
  "personality": "Head of SEO Analytics. Datos, no opiniones. Mide, analiza, recomienda.",
  "cli_provider": "claude",
  "status": "idle"
}' | jq -r '.agent.name // .error'

# --- Marketing ---
echo "  🚀 Elon (CMO)..."
api POST "/api/agents" '{
  "name": "Elon",
  "role": "team_leader",
  "department_id": "'"$ops_id"'",
  "avatar_emoji": "🚀",
  "sprite_number": 2,
  "personality": "CMO. Ambicioso, visionario. Distribuye lo que el tech crew construye.",
  "cli_provider": "claude",
  "status": "idle"
}' | jq -r '.agent.name // .error'

echo "  🛹 McFly (Twitter Scout)..."
api POST "/api/agents" '{
  "name": "McFly",
  "role": "junior",
  "department_id": "'"$ops_id"'",
  "avatar_emoji": "🛹",
  "sprite_number": 12,
  "personality": "Twitter/X Scout. Rápido, barato, específico. Encuentra tendencias.",
  "cli_provider": "claude",
  "status": "idle"
}' | jq -r '.agent.name // .error'

echo "  🎩 Draper (Head of Ads)..."
api POST "/api/agents" '{
  "name": "Draper",
  "role": "senior",
  "department_id": "'"$ops_id"'",
  "avatar_emoji": "🎩",
  "sprite_number": 6,
  "personality": "Head of Online Ads. Campañas, copy, segmentación.",
  "cli_provider": "claude",
  "status": "idle"
}' | jq -r '.agent.name // .error'

echo "  ✍️ Hemingway (Head of Content)..."
api POST "/api/agents" '{
  "name": "Hemingway",
  "role": "senior",
  "department_id": "'"$ops_id"'",
  "avatar_emoji": "✍️",
  "sprite_number": 8,
  "personality": "Head of Content/SEO. Escritura clara, directa, sin relleno.",
  "cli_provider": "claude",
  "status": "idle"
}' | jq -r '.agent.name // .error'

echo ""
echo "═══════════════════════════════════════"
echo "  ✅ Crew configurado! 12 agentes"
echo "  🌐 Abre http://127.0.0.1:8800"
echo "═══════════════════════════════════════"
