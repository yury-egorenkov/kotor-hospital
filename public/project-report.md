# JZUOB Kotor — Website Development Report

**Project:** Public website for Javna zdravstvena ustanova opšta bolnica Kotor
**Status:** Phase 1 Complete — Production-Ready
**Date:** March 2026
**Author:** egorsky.com
**Demo:** hospital-kotor.egorsky.com

---

## 1. Overview

Full multilingual website for the General Hospital of Kotor — state healthcare institution serving 70,000+ residents across municipalities of Kotor, Tivat, and Herceg Novi (Montenegro).

**What was built:**
- Complete public website — 13 unique page types covering all hospital information
- 8 full language versions — 457 translation keys per language, 3,656 lines of translations total
- Production infrastructure — Docker, Nginx, Kubernetes, TLS, security hardening
- Custom visual identity — deconstructed cross logo, emerald/teal gradient accents, scroll-reveal animations

---

## 2. Key Numbers

| Metric | Value |
|--------|-------|
| Static HTML pages | 177 |
| Unique page types | 13 + departments (5) + clinics (6) + 404 |
| Astro components | 25 |
| Languages | 8 |
| Translation keys per language | 457 |
| Total translation lines | 3,656 |
| Lines of source code | 8,496 |
| Source files | 140+ |
| Production dependencies | 5 |
| Hospital photos | 4 |

---

## 3. Technology Stack

- **Astro 5** — static site generator, zero JS in output
- **Tailwind CSS 3** — utility-first styling
- **TypeScript** — type-safe i18n utilities
- **YAML i18n** — flat key/value translations, Vite-native imports
- **Docker** — Alpine-based Nginx image, multi-stage build
- **Kubernetes** — Deployment, Service, PVC, Ingress with cert-manager
- **Nginx** — web server, caching, rate limiting, security headers
- **Let's Encrypt** — automatic TLS certificates

---

## 4. Pages

### Core pages (8 language versions each)

1. **Home** (`/`) — emergency banner, quick access grid, departments & clinics overview, about section, leadership team, contacts with Google Maps
2. **About** (`/about`) — photo gallery, hospital stats, mission, expansion projects (€9M building + €1.1M TELE.DOC), leadership team, Meljine branch
3. **Contact** (`/contact`) — contact cards by department, working hours table, three route descriptions (from Kotor/Tivat/Herceg Novi), embedded Google Maps
4. **For Patients** (`/patients`) — required documents checklist, patient rights, visiting hours, insurance summary with link to full insurance page
5. **Insurance** (`/insurance`) — four coverage models: state fund (FZOCG), EKZO/EHIC European card, private insurance, self-pay
6. **Laboratory** (`/laboratory`) — test types, preparation instructions, blood draw hours, results turnaround, eZdravlje portal integration
7. **Meljine Branch** (`/meljine`) — rehabilitation services, location with Google Maps, working hours, phone
8. **FAQ** (`/faq`) — 7 accordion Q&A items: referrals, booking, uninsured, foreigners, parking, hours, WiFi
9. **News** (`/news`) — 3 news items: €9M expansion, TELE.DOC EU project, new equipment
10. **Prices** (`/prices`) — fund patients (free), self-pay info, how to inquire
11. **Careers** (`/careers`) — about working at JZUOB, open positions link, HR contact
12. **404** — client-side language detection, friendly error message, link home

### Dynamic slug pages (8 languages each)

**5 hospital departments** (40 pages):
- Emergency — 24/7 service, dedicated emergency phone panel
- Surgery — general, orthopedic, urological; 3-tier team hierarchy (chief, surgeons, residents)
- Gynecology — obstetrics and gynecological services
- Internal Medicine — diagnostics, cardiology, pulmonology
- Radiology — X-ray, ultrasound, CT, mammography

**6 outpatient clinics** (48 pages):
- Surgery Clinic, Internal Medicine, Dermatology, Ophthalmology, Endocrinology, Gastroenterology

---

## 5. Components (25)

### Navigation & Layout (7)
- **BaseLayout** — meta, OG tags, hreflang, Schema.org JSON-LD, font loading
- **Header** — sticky nav, deconstructed cross logo, two-line hospital name, phone, emergency CTA
- **MobileMenu** — full overlay, 8 language flags, animated transitions
- **LanguageSwitcher** — dropdown, preserves current path, sets cookie
- **Footer** — 5-column grid with all page links, contacts, credits
- **DemoBanner** — amber demo environment indicator
- **SectionBadge** — reusable pill badge with icon

### Homepage Sections (7)
- **EmergencyBanner** — pulsing red strip, 24/7 phone, click-to-call
- **QuickAccess** — hero title + 6-card service grid
- **Departments** — 5 department cards with links
- **Clinics** — 6 clinic cards with links
- **About** — text, stats grid, project highlights
- **Leadership** — 4-card team grid with roles
- **Contact** — 3-column layout: info, hours, map

### Full Page Components (11)
- **DepartmentPage** — services list, 3-tier team section, hours sidebar, CTA
- **ClinicPage** — services, hours sidebar, appointment info
- **AboutPage** — gallery, stats, mission, projects
- **ContactPage** — cards, hours, directions, maps
- **PatientsPage** — documents, rights, visiting hours
- **InsurancePage** — 4 insurance models
- **LaboratoryPage** — tests, preparation, hours, results
- **MeljinePage** — rehab services, location, hours
- **FaqPage** — static accordion Q&A
- **NewsPage** — news cards with project details
- **PricesPage** — pricing info by patient type
- **CareersPage** — employment info, positions, HR contact

---

## 6. Internationalization (i18n)

| Language | Code | URL Prefix | Keys | Status |
|----------|------|-----------|------|--------|
| Crnogorski (Montenegrin) | `cnr` | `/` (default) | 457 | Complete |
| English | `en` | `/en/` | 457 | Complete |
| Russian | `ru` | `/ru/` | 457 | Complete |
| Ukrainian | `uk` | `/uk/` | 457 | Complete |
| Turkish | `tr` | `/tr/` | 457 | Complete |
| German | `de` | `/de/` | 457 | Complete |
| Spanish | `es` | `/es/` | 457 | Complete |
| French | `fr` | `/fr/` | 457 | Complete |

**Features:**
- Browser language auto-detection on first visit (Serbian, Bosnian, Croatian → Montenegrin)
- Cookie-based preference (1 year)
- Hreflang alternate links on every page
- Flat YAML files imported via Vite `import.meta.glob` — zero runtime overhead, resolved at build time

---

## 7. SEO & Performance

**Technical SEO:**
- Schema.org JSON-LD structured data (`@type: Hospital`)
- Open Graph meta tags (title, description, type, locale)
- Hreflang alternate links for all 8 locales
- Auto-generated XML sitemap (`@astrojs/sitemap`)
- Clean URLs with semantic paths (`/departments/emergency`)
- Configurable `X-Robots-Tag` header for demo/production mode

**Performance:**
- 100% static HTML — zero JavaScript frameworks, instant page loads
- Gzip compression (level 6) for text assets
- 30-day cache for static assets, 1-hour cache for HTML with revalidation
- Font preconnect for Google Fonts (Inter 400–800)
- Fully responsive: mobile, tablet, desktop
- ARIA attributes on interactive elements

---

## 8. Visual Design (Latest)

- **Logo** — deconstructed cross: four separate emerald/teal squares forming a cross with gaps
- **Header** — two-line text: hospital name + "opšta bolnica Kotor" subtitle, gradient underline accent
- **Color palette** — emerald-600/teal-600 gradients, stone backgrounds, white cards
- **Scroll-reveal animations** — sections fade up on scroll via IntersectionObserver
- **Department pages** — redesigned Surgery team section with 3-tier hierarchy: department chief → surgeons → residents
- **Footer** — all pages linked, 5-column layout
- **FAQ** — static page (no JS accordion), white background

---

## 9. Infrastructure

### Docker
Alpine-based Nginx image (`nginx:1.25-alpine`). Multi-stage build with rsync for atomic deploys. Environment-driven `ROBOTS_NOINDEX` flag for demo/production toggle.

### Kubernetes
Full manifest: Deployment, Service (ClusterIP), PersistentVolumeClaim (5Gi), Ingress with cert-manager for Let's Encrypt TLS. WWW-to-non-WWW redirect. Environment variables via Secrets.

### Nginx
Clean URL routing (`try_files $uri $uri.html $uri/ /index.html`). Tiered caching: 30-day immutable for assets, 1-hour revalidate for HTML. Rate limiting: 10 req/s for HTML, 30 req/s for static. Server tokens disabled.

### Security
- `X-Frame-Options: SAMEORIGIN`
- `X-Content-Type-Options: nosniff`
- `Referrer-Policy: strict-origin-when-cross-origin`
- `Permissions-Policy: camera=(), microphone=(), geolocation=()`
- Bot blocklist: 15+ bots (GPTBot, ChatGPT, CCBot, Bytespider, anthropic-ai, AhrefsBot, SemrushBot, Scrapy, python-requests)
- Dotfiles access blocked
- Rate limiting with burst protection

### TLS & DNS
Automatic certificates via cert-manager + Let's Encrypt. WWW-to-non-WWW permanent redirect. Domain: `jzuobkotor.me`.

---

## 10. Dependencies

| Package | Version |
|---------|---------|
| astro | ^5.7.0 |
| @astrojs/tailwind | ^6.0.2 |
| @astrojs/sitemap | ^3.7.1 |
| tailwindcss | ^3.4.0 |
| js-yaml | ^4.1.1 |

5 production dependencies total.

---

## 11. License

Dual license:
1. **JZUOB Kotor** — perpetual, irrevocable, unrestricted, royalty-free. No conditions, no obligations. Provided as-is with no warranty or support.
2. **Everyone else** — MIT License.

---

## 12. Phase 2 Roadmap

- **Online Appointment Booking** — patient registration, clinic/department selection, time slot picker, confirmation, SMS/email reminders
- **Patient Portal** — personal medical records, lab results via eZdravlje, appointment history, document management
- **Staff Directory** — doctor profiles with photos, specializations, qualifications, schedules; searchable by department
- **News & Announcements CMS** — admin panel for publishing news, schedule changes; multilingual content management
- **Analytics Dashboard** — visitor stats, language distribution, device breakdown; privacy-friendly, GDPR-compliant
- **TELE.DOC Integration** — video consultations via €1.1M EU-funded Montenegro-Croatia telemedicine project
