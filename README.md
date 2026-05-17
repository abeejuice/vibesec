# 🛡️ vibesec — Security Agent for Medical AI Builders

> One file. Zero config. Your app stops leaking API keys.

Built for medical students and doctors using **Claude Code, Cursor, and Google AI Studio** who are shipping AI tools and don't want to think about cybersecurity — but need to.

The TanStack supply chain attack (May 2025) and thousands of vibe-coded apps leaking API keys showed that AI tools generate insecure code by default. Medical builders handle sensitive health data. The stakes are higher. This agent makes secure defaults the path of least resistance.

---

## Install (30 seconds)

Paste this into your terminal from inside your project folder:

```bash
mkdir -p .claude/agents && curl -s https://raw.githubusercontent.com/abeejuice/vibesec/main/.claude/agents/security.md -o .claude/agents/security.md
```

**Done. Restart Claude Code.**

> Or use the `install.sh` script: `bash <(curl -s https://raw.githubusercontent.com/abeejuice/vibesec/main/install.sh)`

---

## What it does

- **Audits your code** against OWASP Top 10 + 25 medical-specific security rules
- **Auto-triggers** when you write auth, API key, database, or health data code — no manual invocation needed
- **Explains every finding** in plain English with clinical analogies you'll actually understand ("this is like leaving a patient chart in the waiting room")
- **Creates and maintains `project_memory.md`** — a living security chart for your app, structured like a patient notes file
- **Writes fix prompts** you paste straight back into Claude Code or Cursor to resolve issues
- **Flags PHI automatically** — symptoms, diagnoses, medications, patient data — and tells you which regulations apply (GDPR, HIPAA, India's DPDP Act 2023)

---

## Usage

### Manual audit
Type `/vibesec` in Claude Code at any time for a full security audit of your project.

### Auto-trigger
vibesec automatically activates when you're working on:

`login routes` · `API keys` · `database queries` · `file uploads` · `JWT tokens` · `CORS config` · `patient data` · `health data` · `symptoms` · `diagnoses` · `medications`

You don't have to remember to run it. It shows up when it matters.

---

## What you get from each finding

Every security issue vibesec finds comes with:

```
RULE [C-01] — API KEYS IN FRONTEND
Severity: CRITICAL
File: src/api.js:14

What's wrong: Your API key is exposed in browser JavaScript.

Clinical analogy: This is like writing your hospital login
password on the waiting room whiteboard.

Fix: Move the key to your backend .env and create a proxy route.

AI prompt to fix: "Move all API keys from frontend files to
server-side environment variables. Create a backend proxy route..."
```

---

## project_memory.md

On first run, vibesec creates `project_memory.md` in your project root — a structured security chart that tracks:

- Active vulnerabilities (with severity and file location)
- Resolved issues (with fix dates)
- Your app's PHI / health data inventory
- Audit history

It's updated automatically after every audit. You can show it to a supervisor, investor, or ethics committee as evidence you took security seriously.

---

## The full interactive guide

For a visual, interactive version of all 25 security rules with:
- Bad/good code examples
- Copy-paste fix prompts
- A live threat meter (FLATLINE → DISCHARGED)
- CODE BLUE protocol for already-shipped vulnerabilities

Open [`docs/vibe-coder-security-guide.html`](docs/vibe-coder-security-guide.html) in your browser.

---

## Why this matters for medical builders specifically

| Risk | Why it's worse for medical apps |
|------|--------------------------------|
| API key leak | Your OpenAI bill, but also potential access to patient queries |
| No PHI protection | GDPR fines up to €20M. DPDP Act fines up to ₹250 crore |
| Prompt injection | User submits symptoms designed to manipulate your AI's output |
| No rate limiting | Attackers enumerate patient records or test stolen credentials |
| Data over-collection | Every extra health field collected = extra legal liability |

---

## Repo contents

```
vibesec/
├── .claude/
│   └── agents/
│       └── security.md          ← The agent (the only file you need)
├── docs/
│   ├── vibe-coder-security-guide.html  ← Full interactive security guide
│   └── SECURITY-RULES.md        ← All 25 rules in plain markdown
├── README.md
└── install.sh
```

---

## Credits

Security rules based on:
- [Wasim @WasimShips](https://x.com/WasimShips) — 20 Security Rules for Vibe Coders (May 2026)
- r/vibecoding — Pre-launch sanity check guide
- [TanStack Supply Chain Postmortem](https://tanstack.com/blog/npm-supply-chain-compromise-postmortem) (May 2025)
- Cousin's original security agent spec (AppSec Specialist + QA Lead)

Built for the medical builder community. Security is not optional when your users trust you with their health.

---

*Not a substitute for a professional security audit before handling real patient data at scale.*
