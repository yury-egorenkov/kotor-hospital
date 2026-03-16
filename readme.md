# Kotor Hospital Website

Public website for **Javna zdravstvena ustanova opšta bolnica Kotor** (JZUOB Kotor) — a general hospital serving Kotor, Tivat, and Herceg Novi municipalities in Montenegro.

**Live demo:** [hospital-kotor.egorsky.com](https://hospital-kotor.egorsky.com)

## Tech Stack

- [Astro 5](https://astro.build) — static site generator
- [Tailwind CSS 3](https://tailwindcss.com) — utility-first CSS
- [Inter](https://rsms.me/inter/) — typeface via Google Fonts
- YAML-based i18n — flat key/value translations per language
- Docker + Nginx — production deployment
- Kubernetes — orchestration

## Languages

| Code | Language | URL |
|------|----------|-----|
| `cnr` | Crnogorski (default) | `/` |
| `en` | English | `/en/` |
| `ru` | Русский | `/ru/` |
| `uk` | Українська | `/uk/` |
| `tr` | Türkçe | `/tr/` |
| `de` | Deutsch | `/de/` |
| `es` | Español | `/es/` |
| `fr` | Français | `/fr/` |

Browser language auto-detection on first visit with cookie-based preference.

## Pages

- **Home** — emergency banner, quick access grid, departments, outpatient clinics, about, leadership, contact with map
- **Department pages** (5) — Emergency, Surgery, Gynecology, Internal Medicine, Radiology
- **Clinic pages** (6) — Surgery, Internal Medicine, Dermatology, Ophthalmology, Endocrinology, Gastroenterology
- **Patients** — documents, rights, visiting hours, insurance
- **404** — client-side i18n, auto-detects language

Total: **105 static pages** across 8 languages.

## Project Structure

```
src/
├── components/       # 16 Astro components
├── i18n/             # 8 YAML translation files + utils.ts
├── layouts/          # BaseLayout with meta, schema.org, scripts
├── pages/            # Route files per locale
│   ├── index.astro           # cnr (default)
│   ├── en/index.astro        # English
│   ├── departments/[slug].astro
│   ├── clinics/[slug].astro
│   ├── patients/index.astro
│   └── 404.astro
└── styles/
    └── global.css    # Animations (reveal, accordion, mobile overlay)
```

## Getting Started

```bash
npm install
npm run dev        # http://localhost:4321
npm run build      # Static output in dist/
npm run preview    # Preview built site
```

## Deployment

Docker + Nginx:

```bash
docker build -t kotor-hospital .
docker run -p 8080:80 kotor-hospital
```

Kubernetes:

```bash
kubectl apply -f k8s.yaml
```

## License

Dual license — see [LICENSE](LICENSE):

1. **JZUOB Kotor** — perpetual, irrevocable, unrestricted, royalty-free. No conditions, no obligations. Provided as-is with no warranty or support commitment.
2. **Everyone else** — MIT License.

## Author

[egorsky.com](https://egorsky.com)
