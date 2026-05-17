# SECURITY-RULES.md
## vibesec — 25 Rules Reference for Medical AI Builders

> This file is read by the vibesec agent to reference specific rules by ID.
> For the full interactive guide with code examples, open `vibe-coder-security-guide.html`.

---

## 🔴 CRITICAL — Instant game-over if missed

### C-01 — API Keys Hardcoded in Frontend JS
**Severity**: CRITICAL  
**OWASP**: A02 Cryptographic Failures  
Anyone who opens browser DevTools can read your API key. AI coding tools (Cursor, Claude Code) generate this pattern constantly. Move all keys to server-side environment variables and create a backend proxy for any external API calls.

**Bad pattern**:
```js
const response = await fetch('https://api.openai.com/v1/...', {
  headers: { 'Authorization': 'Bearer sk-proj-abc123YOURKEYHERE' }
});
```
**Fix**: Key lives in `.env` server-side only. Frontend calls your own backend proxy endpoint.

---

### C-02 — .env Committed to Git (Even Once)
**Severity**: CRITICAL  
**OWASP**: A02 Cryptographic Failures  
The file is in git history even after deletion. `git log --all --full-history -- .env` finds it instantly. Rotate every key in that file immediately.

**Fix**: Add `.env`, `.env.local`, `.env.production` to `.gitignore` before the first commit. Provide `.env.example` with dummy values instead.

---

### C-03 — Admin Routes Protected Only in the Frontend
**Severity**: CRITICAL  
**OWASP**: A01 Broken Access Control  
React Router guards are UX, not security. The server doesn't know or care about frontend routing. Hit the API endpoint directly and it opens right up.

**Fix**: Every sensitive route needs `requireAuth` and `requireRole` middleware on the server — no exceptions.

---

### C-04 — SQL Injection via String Concatenation
**Severity**: CRITICAL  
**OWASP**: A03 Injection  
Building SQL queries with user-supplied strings. One crafted input (`1 OR 1=1; DROP TABLE users; --`) can expose or destroy your entire database.

**Bad pattern**: `"SELECT * FROM users WHERE id=" + userId`  
**Fix**: Parameterised queries always: `db.query("SELECT * FROM users WHERE id = $1", [userId])`

---

### C-05 — Auth Middleware Missing on Internal API Routes
**Severity**: CRITICAL  
**OWASP**: A01 Broken Access Control  
AI tools add middleware to obvious routes and skip the rest. Audit every single endpoint manually. Assume nothing is protected until verified.

**Fix**: List every route. Confirm auth middleware is applied. Test by making unauthenticated requests to each one.

---

## 🟠 HIGH — Fix before sharing a link

### H-06 — No Rate Limiting on /login
**Severity**: HIGH  
**OWASP**: A07 Identification and Authentication Failures  
Bots can attempt 10,000 password combinations while you sleep. Add rate limiting (max 5 attempts per 15 minutes) and account lockout.

**Fix**: `express-rate-limit` with `windowMs: 15 * 60 * 1000, max: 5`

---

### H-07 — CORS Set to Wildcard (*)
**Severity**: HIGH  
**OWASP**: A05 Security Misconfiguration  
Any website can make authenticated requests to your API using your users' own cookies. This enables CSRF attacks against your users.

**Bad pattern**: `app.use(cors())` or `cors({ origin: '*' })`  
**Fix**: `cors({ origin: ['https://yourapp.com'], credentials: true })`

---

### H-08 — JWTs Stored in localStorage
**Severity**: HIGH  
**OWASP**: A02 Cryptographic Failures  
localStorage is readable by any JavaScript on the page. One XSS vulnerability steals every token on your site.

**Bad pattern**: `localStorage.setItem('token', jwt)`  
**Fix**: `httpOnly`, `secure`, `sameSite: 'strict'` cookie set by the server on login.

---

### H-09 — Weak or Default JWT Secret
**Severity**: HIGH  
**OWASP**: A02 Cryptographic Failures  
"secret", "password", "jwt_secret" are on every attacker wordlist. Attackers brute-force common secrets first.

**Fix**: Generate with `node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"` and store in `.env`.

---

### H-10 — IDOR: No Ownership Validation on Resources
**Severity**: HIGH  
**OWASP**: A01 Broken Access Control  
Change the ID in the URL. Can you access another user's data? In most vibe-coded apps: yes.

**Bad pattern**: `const record = await db.find(req.params.id)` — returns any user's record.  
**Fix**: Check `record.userId === req.user.id` before returning. Return 403 Forbidden if mismatch.

---

### H-11 — Passwords Hashed with MD5 or SHA1
**Severity**: HIGH  
**OWASP**: A02 Cryptographic Failures  
Rainbow tables crack MD5 in seconds. No salt means identical passwords produce identical hashes.

**Fix**: `bcrypt.hash(password, 12)` — cost factor 12 minimum. Use `bcrypt.compare()` for verification.

---

### H-12 — Auth Tokens That Never Expire
**Severity**: HIGH  
**OWASP**: A07 Identification and Authentication Failures  
A stolen token grants permanent access forever. Set short expiry on access tokens (15 minutes) with refresh token rotation (7 days, stored in DB for revocability).

---

## 🟡 MEDIUM — Clean before you publicise

### M-13 — No HTTPS Enforcement
**Severity**: MEDIUM  
**OWASP**: A02 Cryptographic Failures  
Credentials sent over plain HTTP can be intercepted on any public network. Redirect all HTTP to HTTPS at server level. Add HSTS header (`max-age=31536000`).

---

### M-14 — Sessions Not Invalidated on Logout
**Severity**: MEDIUM  
**OWASP**: A07 Identification and Authentication Failures  
Clearing the client-side cookie does not invalidate the session server-side. The old token still works after logout.

**Fix**: Delete session from DB or add token to a blocklist on every logout event.

---

### M-15 — Error Responses Exposing Stack Traces or DB Info
**Severity**: MEDIUM  
**OWASP**: A09 Security Logging and Monitoring Failures  
Stack traces, database table names, and file paths give attackers a map of your infrastructure.

**Bad pattern**: `res.status(500).json({ error: err.stack })`  
**Fix**: `console.error(err)` server-side only. Return `{ error: 'Something went wrong' }` to client.

---

### M-16 — File Uploads With No MIME Type Validation
**Severity**: MEDIUM  
**OWASP**: A03 Injection  
Extension checks alone don't protect you — rename a PHP script to `.jpg`. Validate MIME type from the file buffer server-side.

**Fix**: Use `file-type` npm package to check actual MIME type from buffer, not the `Content-Type` header or filename extension.

---

### M-17 — Server Running as Root
**Severity**: MEDIUM  
**OWASP**: A05 Security Misconfiguration  
One exploit grants full system access. Running as a non-privileged user limits the blast radius.

**Fix**: In Dockerfile: `RUN adduser -S appuser && USER appuser`

---

### M-18 — Database Port Exposed to the Internet
**Severity**: MEDIUM  
**OWASP**: A05 Security Misconfiguration  
PostgreSQL (5432), MySQL (3306), MongoDB (27017) should never have public IPs. Place behind a firewall or private network. Only your app server should reach the database.

---

### M-19 — Open Redirects in Callback URLs
**Severity**: MEDIUM  
**OWASP**: A01 Broken Access Control  
`?redirect=https://evil.com` through your trusted domain enables phishing.

**Fix**: Whitelist allowed redirect destinations. Reject any redirect to an external domain.

---

### M-20 — Security Headers Missing
**Severity**: MEDIUM  
**OWASP**: A05 Security Misconfiguration  
Content-Security-Policy, Strict-Transport-Security, X-Frame-Options, X-Content-Type-Options, Referrer-Policy.

**Fix**: `app.use(helmet())` in Express. Two-minute fix. From the Reddit vibe-coding guide: "Review my app as a security specialist and make sure I have strong security headers."

---

## 🟢 LEGAL / COMPLIANCE — Protect yourself, not just your app

### L-21 — No Privacy Policy When Collecting User Data
**Severity**: COMPLIANCE  
**Regulation**: GDPR, DPDP Act 2023, App Store requirements  
If you collect any user data, a privacy policy is required by law in most jurisdictions — even for a student project with real users.

**Fix**: Publish a privacy policy. Minimum: what you collect, why, how you store it, how users can request deletion, and a contact email.

---

### L-22 — Collecting More Data Than Needed
**Severity**: COMPLIANCE  
**Regulation**: GDPR Article 5(1)(c) — Data Minimisation  
Only collect data strictly necessary for your stated purpose. Every extra field is extra liability.

---

### L-23 — API Responses Returning Too Much User Data
**Severity**: COMPLIANCE  
**Regulation**: GDPR Article 5 — Data Minimisation  
Your `/me` endpoint probably returns the full database row including password hash, internal IDs, and admin flags. Strip it down to only what the frontend needs.

---

### L-24 — Secrets Appearing in Server Logs
**Severity**: COMPLIANCE  
**Regulation**: GDPR, HIPAA  
API keys, tokens, and patient data logged during debugging end up in your logging service, accessible to anyone with log access.

**Fix**: Never log request bodies containing auth headers or health data. Scrub sensitive fields from logs explicitly.

---

## ⚠️ SUPPLY CHAIN — The TanStack lesson

### S-25 — npm Packages Not Audited
**Severity**: SUPPLY CHAIN  
**OWASP**: A06 Vulnerable and Outdated Components  
**Real incident**: TanStack supply chain compromise, May 2025 — malicious code injected into a trusted npm package. Apps that ran `npm install` pulled in the backdoor automatically.

**Fix**:
```bash
npm audit                          # see all vulnerabilities
npm audit --audit-level=critical   # use in CI/deploy scripts
npm audit fix                      # auto-fix patchable issues
```
Add `npm audit --audit-level=critical` to your deploy script. Enable GitHub Dependabot alerts.

---

## CODE BLUE PROTOCOL — Already shipped a vulnerability?

Work through these in order. Speed matters more than perfection.

1. **Rotate the leaked key immediately** — go to your API provider and revoke it now. Do not just delete the file.
2. **Find all commits containing secrets**: `git log --all --full-history -- .env` and `git log --all -S "YOUR_KEY_VALUE" --source --all`
3. **Purge git history**: use `git filter-repo` or BFG Repo Cleaner. Force-push the cleaned history.
4. **Audit API usage logs** for requests you didn't make — unusual volumes, unknown endpoints, unexpected geographies.
5. **Assess data exposure**: what was accessible, to whom, for how long?
6. **Notify affected users if required**: GDPR requires notification within 72 hours if personal data was likely exposed.
7. **Patch and re-deploy** — run the full pre-deploy checklist before the new version goes live.

---

## Pre-Deploy Checklist (10 checks)

- [ ] `npm audit` — zero critical vulnerabilities
- [ ] Grep for hardcoded secrets: `grep -r "sk-\|AKIA\|Bearer " . --include="*.js" --include="*.ts"`
- [ ] `.env` is in `.gitignore` and has never been committed: `git log --all -- .env`
- [ ] Every API route has appropriate server-side auth middleware
- [ ] Rate limiting tested on auth endpoints (5 attempts → blocked)
- [ ] CORS origins are whitelisted (no wildcard `*` in production)
- [ ] Error messages return generic text to client, full details logged server-side only
- [ ] HTTPS redirect is active — `http://` automatically redirects to `https://`
- [ ] API responses reviewed — no password hashes or unnecessary fields returned
- [ ] OWASP audit prompt run against full codebase
