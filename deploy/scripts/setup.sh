#!/usr/bin/env bash
# ============================================================
#  setup.sh — Run ONCE on the Proxmox VM to bootstrap
#  the Mayaan portfolio site
#
#  Usage:
#    chmod +x setup.sh
#    sudo ./setup.sh
#
#  What it does:
#    1. Installs nginx & git (if not present)
#    2. Clones your portfolio repo into /var/www/mayaan
#    3. Drops the nginx config in place & enables it
#    4. Adds a DNS CNAME in Cloudflare via API
#    5. Reloads nginx
# ============================================================

set -euo pipefail

# ── CONFIG — Edit these before running ──────────────────────
REPO_URL="https://github.com/YOUR_USERNAME/mayaan-portfolio.git"
# ^ Replace with your actual GitHub repo URL
# If it's a private repo use SSH: git@github.com:YOUR_USERNAME/mayaan-portfolio.git

SITE_DIR="/var/www/mayaan"
NGINX_CONF_SRC="$(dirname "$0")/../nginx/mayaan"
NGINX_CONF_DEST="/etc/nginx/sites-available/mayaan"
DOMAIN="mayaan.code2vibe.dev"

# Cloudflare — fill these in or leave blank to skip DNS step
CF_API_TOKEN=""          # Cloudflare API token (Zone:DNS:Edit)
CF_ZONE_ID=""            # Your code2vibe.dev zone ID
CF_TUNNEL_ID=""          # Your tunnel ID (for the CNAME target)

# ── COLOURS ─────────────────────────────────────────────────
GREEN='\033[0;32m'; BLUE='\033[0;34m'; RED='\033[0;31m'; NC='\033[0m'
info()  { echo -e "${BLUE}[INFO]${NC}  $*"; }
ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
err()   { echo -e "${RED}[ERR]${NC}   $*"; exit 1; }

# ── CHECKS ──────────────────────────────────────────────────
[[ $EUID -ne 0 ]] && err "Run as root: sudo ./setup.sh"
[[ -z "$REPO_URL" || "$REPO_URL" == *"YOUR_USERNAME"* ]] && \
  err "Set REPO_URL at the top of this script first."

# ── 1. INSTALL DEPS ─────────────────────────────────────────
info "Installing nginx and git..."
apt-get update -qq
apt-get install -y --no-install-recommends nginx git curl
ok "nginx and git installed."

# ── 2. CLONE REPO ───────────────────────────────────────────
if [[ -d "$SITE_DIR/.git" ]]; then
  info "Repo already cloned. Pulling latest..."
  git -C "$SITE_DIR" pull --ff-only
else
  info "Cloning repo into $SITE_DIR..."
  git clone "$REPO_URL" "$SITE_DIR"
fi
chown -R www-data:www-data "$SITE_DIR"
chmod -R 755 "$SITE_DIR"
ok "Files are at $SITE_DIR"

# ── 3. NGINX CONFIG ─────────────────────────────────────────
info "Installing nginx config..."
cp "$NGINX_CONF_SRC" "$NGINX_CONF_DEST"
ln -sf "$NGINX_CONF_DEST" /etc/nginx/sites-enabled/mayaan

# Remove default site if still linked
[[ -f /etc/nginx/sites-enabled/default ]] && \
  rm -f /etc/nginx/sites-enabled/default && \
  info "Removed nginx default site."

nginx -t || err "Nginx config test failed — check the config."
systemctl reload nginx
ok "Nginx reloaded."

# ── 4. CLOUDFLARE DNS (optional) ────────────────────────────
if [[ -n "$CF_API_TOKEN" && -n "$CF_ZONE_ID" && -n "$CF_TUNNEL_ID" ]]; then
  info "Creating Cloudflare CNAME: $DOMAIN → ${CF_TUNNEL_ID}.cfargotunnel.com ..."
  CNAME_TARGET="${CF_TUNNEL_ID}.cfargotunnel.com"
  HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
    -X POST "https://api.cloudflare.com/client/v4/zones/${CF_ZONE_ID}/dns_records" \
    -H "Authorization: Bearer ${CF_API_TOKEN}" \
    -H "Content-Type: application/json" \
    --data "{
      \"type\":    \"CNAME\",
      \"name\":    \"mayaan\",
      \"content\": \"${CNAME_TARGET}\",
      \"proxied\": true,
      \"ttl\":     1
    }")
  if [[ "$HTTP_STATUS" == "200" ]]; then
    ok "CNAME created: mayaan.code2vibe.dev → ${CNAME_TARGET}"
  else
    info "DNS API returned HTTP $HTTP_STATUS — record may already exist or check your token."
  fi
else
  info "CF_API_TOKEN / CF_ZONE_ID / CF_TUNNEL_ID not set — skipping DNS step."
  info "Add the CNAME manually in Cloudflare dashboard:"
  info "  Type:    CNAME"
  info "  Name:    mayaan"
  info "  Target:  <TUNNEL_ID>.cfargotunnel.com"
  info "  Proxied: Yes"
fi

# ── 5. CLOUDFLARED TUNNEL INGRESS REMINDER ──────────────────
echo ""
echo -e "${BLUE}════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Setup complete! 🚀${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════${NC}"
echo ""
echo "  Next: add this ingress rule to your cloudflared config"
echo "  (usually /etc/cloudflared/config.yml or ~/.cloudflared/config.yml):"
echo ""
echo "    - hostname: mayaan.code2vibe.dev"
echo "      service: http://localhost:80"
echo ""
echo "  Then restart cloudflared:"
echo "    sudo systemctl restart cloudflared"
echo ""
echo "  Site will be live at: https://mayaan.code2vibe.dev"
echo ""
