#!/usr/bin/env bash
# Idempotent Cloud Agent bootstrap for the Mnemonics Flutter app.
# Refreshes Dart/Flutter dependencies and creates the gitignored local
# config files (.env and assets/credentials.json) the app needs to build.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# Ensure the Flutter SDK is on PATH (baked into the base image at ~/flutter).
if ! command -v flutter >/dev/null 2>&1; then
  if [ -x "$HOME/flutter/bin/flutter" ]; then
    export PATH="$HOME/flutter/bin:$PATH"
  else
    echo "ERROR: flutter not found on PATH or at \$HOME/flutter/bin" >&2
    exit 1
  fi
fi

# .env and assets/credentials.json are gitignored and only needed at runtime
# for optional AI / Google Sheets features. They must exist for the build
# because pubspec.yaml lists them as bundled assets. Create safe placeholders
# only when the developer has not supplied real ones.
if [ ! -f .env ]; then
  cat > .env <<'EOF'
# Placeholder created by scripts/cloud-agent-install.sh for Cloud Agent builds.
# Provide a real key to enable optional AI (OpenRouter) features.
OPENROUTER_API_KEY=
EOF
  echo "Created placeholder .env"
fi

if [ ! -f assets/credentials.json ]; then
  cat > assets/credentials.json <<'EOF'
{
  "type": "service_account",
  "project_id": "placeholder",
  "private_key_id": "placeholder",
  "private_key": "",
  "client_email": "placeholder@placeholder.iam.gserviceaccount.com",
  "client_id": "placeholder",
  "token_uri": "https://oauth2.googleapis.com/token"
}
EOF
  echo "Created placeholder assets/credentials.json"
fi

flutter pub get
