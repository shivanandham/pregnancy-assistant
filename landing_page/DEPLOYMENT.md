# Landing Page Deployment Guide

This guide explains how to deploy the React + Vite landing page with Caddy.

## Building for Production

1. **Install dependencies** (if not already done):
```bash
cd landing_page
npm install
```

2. **Set environment variables**:
Create a `.env` file with your backend URL:
```bash
echo "VITE_BACKEND_URL=/api" > .env
```

3. **Build the production bundle**:
```bash
npm run build
```

This creates a `dist` folder with optimized production files.

## Caddy Configuration

Update your Caddyfile to serve from the `dist` folder:

```caddyfile
yourdomain.com {
	# API routes proxy to backend
	handle /api/* {
		reverse_proxy localhost:3000 {
			header_up X-Real-IP {remote_host}
		}
	}

	# Serve React app from dist folder
	handle {
		root * /var/www/pregnancy-assistant/landing_page/dist
		try_files {path} /index.html
		file_server
	}
}
```

### Key Configuration Points:

1. **Root directory**: Point to `/var/www/pregnancy-assistant/landing_page/dist` (the built `dist` folder)
2. **SPA routing**: `try_files {path} /index.html` ensures React Router (if used) and hash routing work correctly
3. **API proxy**: `/api/*` routes are proxied to your Node.js backend

## Deployment Steps

1. **Build the app**:
```bash
cd /var/www/pregnancy-assistant/landing_page
npm install
npm run build
```

2. **Update Caddy configuration**:
```bash
sudo nano /etc/caddy/Caddyfile
```
Update the root path to point to `dist` folder as shown above.

3. **Validate Caddy config**:
```bash
sudo caddy validate --config /etc/caddy/Caddyfile
```

4. **Restart Caddy**:
```bash
sudo systemctl restart caddy
sudo systemctl status caddy
```

## Automated Build Script

Create a build script for easy deployments:

```bash
#!/bin/bash
# build.sh

cd /var/www/pregnancy-assistant/landing_page
npm install
npm run build
echo "Build complete! Files are in the dist folder."
echo "Restart Caddy if needed: sudo systemctl restart caddy"
```

Make it executable:
```bash
chmod +x build.sh
./build.sh
```

## Environment Variables for Production

Set `VITE_BACKEND_URL` in your build environment:

- **For relative URLs** (same domain): `VITE_BACKEND_URL=/api`
- **For absolute URLs** (different domain): `VITE_BACKEND_URL=https://api.yourdomain.com/api`

The environment variable is embedded at build time, so make sure it's set correctly before running `npm run build`.

## Troubleshooting

### Issue: 404 errors on page refresh
**Solution**: Ensure `try_files {path} /index.html` is in your Caddy configuration.

### Issue: API calls not working
**Solution**: Check that:
1. `VITE_BACKEND_URL` is set correctly in `.env`
2. Caddy is properly proxying `/api/*` to your backend
3. The backend is running on port 3000

### Issue: Assets not loading
**Solution**: Ensure Caddy's root directory points to `dist` folder, not the parent `landing_page` folder.

## Development vs Production

- **Development**: `npm run dev` runs Vite dev server (port 5173)
- **Production**: `npm run build` creates optimized files in `dist` folder for Caddy to serve

