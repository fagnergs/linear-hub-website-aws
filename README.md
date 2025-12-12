# Linear Hub Website

Website institucional moderno, responsivo e multilíngue para a Linear Hub.

## 🚀 Stack

- **Next.js 14** - React framework
- **TypeScript** - Type safety
- **Tailwind CSS** - Styling
- **Framer Motion** - Animations
- **i18n** - Multilingual support (PT, EN, ES)
- **Resend API** - Email service

## 📋 Requirements

- Node.js 18+
- npm
- Git

## 🛠️ Local Setup

```bash
# Clone
git clone https://github.com/fagnergs/linear-hub-website-aws.git
cd linear-hub-website-aws

# Install & Run
npm install
npm run dev
# Open http://localhost:3000
```

## 🌍 Languages

- 🇧🇷 Portuguese (default)
- 🇺🇸 English
- 🇪🇸 Spanish

Translation files: `public/locales/{locale}/common.json`

## 📦 Build & Deploy

```bash
# Build for production
npm run build

# Run production server
npm start

# Lint code
npm run lint
```

## 🏗️ Project Structure

```
components/          # React components
├── layout/         # Header, Footer, Layout
└── sections/       # Hero, About, Services, Projects, Clients, Contact

pages/              # Next.js routes & API
├── api/contact.ts  # Email API endpoint
└── index.tsx       # Main page

public/
├── locales/        # Translation JSON files
└── images/         # Static assets

lib/i18n.tsx        # i18n provider & hooks

styles/             # Global CSS
```

## 🔧 Configuration

### Environment Variables

Copy `.env.example` to `.env.local`:

```bash
# Required for email form
RESEND_API_KEY=re_your_api_key_here
NODE_ENV=production
```

Get your Resend API key at: https://resend.com/api-tokens

### API Routes

**POST /api/contact** - Form submission
- Sends email via Resend
- Validates required fields: name, email, subject, message
- Optional: company

## 📱 Responsive Design

Optimized for:
- Desktop (1920px+)
- Laptop (1024px - 1919px)
- Tablet (768px - 1023px)
- Mobile (< 768px)

## 🎨 Features

- Fast loading with SSG
- Smooth animations & transitions
- Multilingual support
- Functional contact form
- Fully accessible
- SEO optimized (sitemap, robots.txt)

## 📧 Contact

**Linear Hub**
- Email: contato@linear-hub.com.br
- Website: linear-hub.com.br
- Location: Jaguariúna - SP, Brazil

## 📄 License

© 2024 Linear Hub. All rights reserved.
