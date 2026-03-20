#!/usr/bin/env bash
# ============================================================
#  deploy.sh — Pull latest changes and reload nginx
#
#  Run this every time you push new photos or content:
#    sudo ./deploy.sh
#
#  Or set up a cron / webhook to run it automatically.
# ============================================================

set -euo pipefail

SITE_DIR="/var/www/mayaan"
GREEN='\033[0;32m'; BLUE='\033[0;34m'; RED='\033[0;31m'; NC='\033[0m'
info() { echo -e "${BLUE}[INFO]${NC}  $*"; }
ok()   { echo -e "${GREEN}[OK]${NC}    $*"; }
err()  { echo -e "${RED}[ERR]${NC}   $*"; exit 1; }

[[ $EUID -ne 0 ]] && err "Run as root: sudo ./deploy.sh"
[[ ! -d "$SITE_DIR/.git" ]] && err "$SITE_DIR is not a git repo. Run setup.sh first."

info "Pulling latest from origin/main..."
git -C "$SITE_DIR" fetch origin
git -C "$SITE_DIR" reset --hard origin/main

info "Fixing permissions..."
chown -R www-data:www-data "$SITE_DIR"
chmod -R 755 "$SITE_DIR"

info "Testing nginx config..."
nginx -t || err "Nginx config test failed."

info "Reloading nginx..."
systemctl reload nginx

COMMIT=$(git -C "$SITE_DIR" log -1 --format="%h — %s (%cr)")
ok "Deployed: $COMMIT"
echo ""
echo -e "  🌐 Live at: ${GREEN}https://mayaan.code2vibe.dev${NC}"
echo ""
