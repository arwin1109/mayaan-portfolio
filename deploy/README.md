# 🚀 Mayaan Portfolio — Proxmox Self-Hosted Deployment Guide

**Stack:** Nginx · Git · Cloudflare Tunnel · `mayaan.code2vibe.dev`

---

## 📁 What's in this package

```
mayaan-portfolio/           ← The actual website (push this to GitHub)
│   index.html
│   assets/css/style.css
│   assets/js/main.js
│   assets/images/          ← Drop real photos here
│
mayaan-deploy/              ← Server config & scripts (keep locally / on VM)
    nginx/
    │   mayaan               ← Nginx server block
    cloudflare/
    │   config.yml           ← Cloudflare Tunnel ingress snippet
    scripts/
        setup.sh             ← Run ONCE to bootstrap the VM
        deploy.sh            ← Run on every update (git pull + reload)
```

---

## 🛠️ Step-by-Step Setup

### Step 1 — Push the website to GitHub

```bash
# On your local machine
cd mayaan-portfolio/
git init
git add .
git commit -m "🚀 Mayaan portfolio initial commit"

# Create a repo on github.com, then:
git remote add origin https://github.com/YOUR_USERNAME/mayaan-portfolio.git
git branch -M main
git push -u origin main
```

---

### Step 2 — SSH into your Proxmox VM

```bash
ssh user@vm017.code2vibe.dev     # or whichever VM you're deploying to
```

---

### Step 3 — Copy the deploy config to the VM

From your local machine (or paste files in via your SSH client):

```bash
# Copy just the deploy configs (not the website itself — git will pull that)
scp -r mayaan-deploy/ user@vm017.code2vibe.dev:~/mayaan-deploy/
```

---

### Step 4 — Edit setup.sh with your repo URL

```bash
# On the VM
nano ~/mayaan-deploy/scripts/setup.sh
```

Change this line at the top:
```bash
REPO_URL="https://github.com/YOUR_USERNAME/mayaan-portfolio.git"
```

Optionally fill in the Cloudflare fields for automated DNS:
```bash
CF_API_TOKEN=""     # From dash.cloudflare.com → My Profile → API Tokens
CF_ZONE_ID=""       # From dash.cloudflare.com → code2vibe.dev → Overview (right sidebar)
CF_TUNNEL_ID=""     # From: cloudflared tunnel list
```

---

### Step 5 — Run the setup script

```bash
cd ~/mayaan-deploy/scripts/
chmod +x setup.sh deploy.sh
sudo ./setup.sh
```

This will:
- Install **nginx** and **git**
- Clone the repo to `/var/www/mayaan`
- Drop and enable the nginx config
- Optionally create the Cloudflare DNS CNAME
- Reload nginx

---

### Step 6 — Add the Cloudflare Tunnel ingress rule

Open your existing cloudflared config:

```bash
sudo nano /etc/cloudflared/config.yml
# OR if running as user:
nano ~/.cloudflared/config.yml
```

Add this block **before** the catch-all `service: http_status:404` line:

```yaml
- hostname: mayaan.code2vibe.dev
  service: http://localhost:80
```

Then restart cloudflared:

```bash
sudo systemctl restart cloudflared

# Verify it's running:
sudo systemctl status cloudflared
```

---

### Step 7 — Add the Cloudflare DNS CNAME (if not done by script)

1. Go to [dash.cloudflare.com](https://dash.cloudflare.com)
2. Select **code2vibe.dev**
3. Go to **DNS → Records → Add record**

| Field   | Value                                    |
|---------|------------------------------------------|
| Type    | CNAME                                    |
| Name    | `mayaan`                                 |
| Target  | `<YOUR_TUNNEL_ID>.cfargotunnel.com`      |
| Proxied | ✅ Yes (orange cloud)                    |
| TTL     | Auto                                     |

Get your tunnel ID with:
```bash
cloudflared tunnel list
```

---

### Step 8 — Verify 🎉

```bash
# On the VM — test nginx responds
curl -I http://localhost

# From your browser:
# https://mayaan.code2vibe.dev
```

---

## 🔄 Updating the site (add photos, edit content)

Every time you push changes to GitHub:

```bash
# On your local machine — push changes
git add .
git commit -m "Added Mayaan's photos"
git push

# On the VM — pull and reload
sudo ~/mayaan-deploy/scripts/deploy.sh
```

---

## 📸 Adding Mayaan's real photos

1. Put the photos in `mayaan-portfolio/assets/images/`
2. Use these filenames (or update `index.html` to match yours):

| Filename        | Used for                    |
|-----------------|-----------------------------|
| `mayaan.jpg`    | Hero profile photo          |
| `run-3k.jpg`    | 3K run achievement          |
| `run-5k.jpg`    | 5K run with Aarvi           |
| `gallery-1.jpg` | Favorite painting           |
| `gallery-2.jpg` | LEGO build                  |
| `gallery-3.jpg` | Dino drawing                |
| `gallery-4.jpg` | 3K run moment               |
| `gallery-5.jpg` | 5K run with Aarvi           |
| `gallery-6.jpg` | Dance / music performance   |

3. `git add . && git commit -m "Added photos" && git push`
4. `sudo ~/mayaan-deploy/scripts/deploy.sh` on the VM

---

## ⚙️ Optional: Auto-deploy via Cron

To auto-pull from GitHub every 10 minutes:

```bash
sudo crontab -e
```

Add:
```
*/10 * * * * /root/mayaan-deploy/scripts/deploy.sh >> /var/log/mayaan-deploy.log 2>&1
```

---

## 🔍 Troubleshooting

| Problem | Fix |
|---|---|
| `nginx -t` fails | Check `/etc/nginx/sites-enabled/` for conflicting configs |
| Site shows nginx default page | `sudo rm /etc/nginx/sites-enabled/default && sudo systemctl reload nginx` |
| Tunnel not routing | Run `cloudflared tunnel info <TUNNEL_ID>` and check ingress |
| CNAME not resolving | Wait up to 5 min for Cloudflare DNS propagation |
| 403 Forbidden | `sudo chown -R www-data:www-data /var/www/mayaan` |
| Images not loading | Check filenames exactly match — Linux is case-sensitive |

---

## 📋 Nginx Config Location Summary

```
/etc/nginx/sites-available/mayaan    ← Config file
/etc/nginx/sites-enabled/mayaan      ← Symlink to above
/var/www/mayaan/                     ← Website root (git repo)
/var/log/nginx/mayaan.access.log     ← Access logs
/var/log/nginx/mayaan.error.log      ← Error logs
```
