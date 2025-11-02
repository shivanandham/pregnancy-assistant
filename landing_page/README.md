# Luma Landing Page

A modern, responsive landing page for Luma Pregnancy Assistant built with React, Vite, and Tailwind CSS.

## Features

- ⚡️ Fast development with Vite
- ⚛️ React 18 with modern hooks
- 🎨 Tailwind CSS for styling
- 📱 Fully responsive design
- 🔄 Dynamic release info from backend API
- 🌙 Beautiful gradient animations

## Getting Started

### Prerequisites

- Node.js 18+ and npm

### Installation

1. Install dependencies:
```bash
npm install
```

2. Create a `.env` file (or copy from `.env.example`):
```bash
cp .env.example .env
```

3. Configure your backend URL in `.env`:
```env
VITE_BACKEND_URL=/api  # For relative URLs
# or
VITE_BACKEND_URL=http://localhost:3000/api  # For absolute URLs
```

### Development

Start the development server:
```bash
npm run dev
```

The app will be available at `http://localhost:5173`

### Building for Production

Build the app for production:
```bash
npm run build
```

The built files will be in the `dist` directory.

Preview the production build:
```bash
npm run preview
```

## Project Structure

```
landing_page/
├── src/
│   ├── components/
│   │   ├── Hero.jsx
│   │   ├── Features.jsx
│   │   ├── AdditionalFeatures.jsx
│   │   ├── CTASection.jsx
│   │   └── Footer.jsx
│   ├── hooks/
│   │   └── useReleaseInfo.js
│   ├── App.jsx
│   ├── main.jsx
│   └── index.css
├── index.html
├── package.json
├── vite.config.js
├── tailwind.config.js
└── postcss.config.js
```

## Environment Variables

- `VITE_BACKEND_URL`: Backend API base URL (default: `/api`)

## License

Copyright © 2024 Luma Pregnancy Assistant

