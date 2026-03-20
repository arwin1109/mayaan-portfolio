# 🚀 Mayaan Bavivaddi — Portfolio Website

A stunning space & superhero themed personal portfolio for Mayaan Bavivaddi, built with pure HTML, CSS, and vanilla JavaScript. Fully deployable on **GitHub Pages** — no build tools, no dependencies, no server needed!

---

## 📁 Project Structure

```
mayaan-portfolio/
├── index.html              ← Main entry point
├── assets/
│   ├── css/
│   │   └── style.css       ← All styles
│   ├── js/
│   │   └── main.js         ← Starfield, animations, interactions
│   └── images/             ← Drop all photos here
│       ├── mayaan.jpg          ← Hero profile photo
│       ├── run-3k.jpg          ← 3K run achievement photo
│       ├── run-5k.jpg          ← 5K run achievement photo (with Aarvi)
│       ├── gallery-1.jpg       ← Favorite painting
│       ├── gallery-2.jpg       ← LEGO build
│       ├── gallery-3.jpg       ← Dino drawing
│       ├── gallery-4.jpg       ← 3K run moment
│       ├── gallery-5.jpg       ← 5K run with Aarvi
│       └── gallery-6.jpg       ← Dance / music moment
└── README.md
```

---

## 🖼️ Adding Photos

1. Place your images inside `assets/images/`
2. Name them exactly as listed above (or update the `src` attributes in `index.html`)
3. Supported formats: `.jpg`, `.jpeg`, `.png`, `.webp`

> **Tip:** For best results, use square images (1:1) for the profile photo and landscape (4:3 or 16:9) for gallery images.

---

## 🚀 Deploy to GitHub Pages (Step by Step)

### Option A — New Repository (Recommended)

1. **Create a GitHub account** if you don't have one → https://github.com

2. **Create a new repository**
   - Go to https://github.com/new
   - Repository name: `mayaan-portfolio` (or anything you like)
   - Set to **Public**
   - Click **Create repository**

3. **Upload files**
   - On the repository page, click **"uploading an existing file"**
   - Drag and drop **all the files and folders** from this project
   - Click **Commit changes**

4. **Enable GitHub Pages**
   - Go to your repository → **Settings** tab
   - In the left sidebar click **Pages**
   - Under **Branch**, select `main` → folder `/root` → click **Save**
   - Wait 1–2 minutes

5. **Your site is live!** 🎉
   - URL: `https://<your-github-username>.github.io/mayaan-portfolio/`

---

### Option B — Using Git CLI

```bash
# 1. Initialize git in this folder
git init
git add .
git commit -m "🚀 Initial commit — Mayaan's portfolio"

# 2. Create repo on GitHub, then:
git remote add origin https://github.com/YOUR_USERNAME/mayaan-portfolio.git
git branch -M main
git push -u origin main

# 3. Enable GitHub Pages in repo Settings → Pages → Branch: main
```

---

### Option C — GitHub Desktop App (Easiest for non-devs)

1. Download GitHub Desktop → https://desktop.github.com
2. Sign in with your GitHub account
3. Click **File → Add Local Repository** → select this folder
4. Click **Publish repository** → make it Public
5. Go to repo Settings → Pages → enable from `main` branch

---

## ✏️ Customisation Tips

| What to change | Where |
|---|---|
| Name, dates, descriptions | `index.html` |
| Colors (pink/blue/green) | `assets/css/style.css` → `:root` variables |
| Photos | `assets/images/` folder |
| School map link | `index.html` → `school-map-btn` href |
| Add new gallery images | Add `<div class="gallery-item">` blocks in `index.html` |
| Dream goals / achievements | Edit the relevant sections in `index.html` |

---

## ✨ Features

- 🌌 Animated canvas starfield with shooting stars
- 🎨 Custom cursor with click particle bursts
- 📱 Fully responsive (mobile-friendly with hamburger nav)
- ♿ Semantic HTML with alt text and ARIA labels
- 🖼️ Graceful image fallbacks (placeholders shown if image missing)
- 🚀 Zero build tools — pure HTML/CSS/JS, works anywhere
- ⚡ Scroll-triggered reveal animations
- 🔗 All sections linked in sticky nav with active highlight

---

## 📝 License

Made with 💖 for Mayaan Bavivaddi — the most curious kid in the cosmos!
