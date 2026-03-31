cat > install.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="/opt/browser-walker"
CONFIG_DIR="$REPO_DIR/config"
LOG_DIR="$REPO_DIR/logs"
SCREENSHOT_DIR="$REPO_DIR/screenshots"

echo "[1/6] install packages"
apt update
apt install -y docker.io docker-compose-v2 git
systemctl enable --now docker

echo "[2/6] create dirs"
mkdir -p "$CONFIG_DIR" "$LOG_DIR" "$SCREENSHOT_DIR"

echo "[3/6] prepare sites file"
if [ ! -f "$CONFIG_DIR/sites.txt" ]; then
  if [ -f "$CONFIG_DIR/sites.example.txt" ]; then
    cp "$CONFIG_DIR/sites.example.txt" "$CONFIG_DIR/sites.txt"
  else
    cat > "$CONFIG_DIR/sites.txt" <<'SITES'
https://example.com
https://example.org
SITES
  fi
fi

echo "[4/6] stop old stack"
cd "$REPO_DIR"
docker compose down || true

echo "[5/6] build and start"
docker compose up -d --build --scale browser-walker=3

echo "[6/6] done"
echo
echo "Project: $REPO_DIR"
echo "Sites:   $CONFIG_DIR/sites.txt"
echo "Logs:    $LOG_DIR/walker.log"
echo
echo "Useful commands:"
echo "  cd $REPO_DIR && docker compose ps"
echo "  cd $REPO_DIR && docker compose logs -f"
echo "  tail -f $LOG_DIR/walker.log"
echo "  cd $REPO_DIR && docker compose up -d --scale browser-walker=3"
echo "  cd $REPO_DIR && docker compose down"
EOF
