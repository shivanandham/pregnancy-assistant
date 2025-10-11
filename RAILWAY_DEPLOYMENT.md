# Railway Deployment Guide

## Prerequisites
- GitHub repository: `shivanandham/pregnancy-assistant`
- Railway account (free tier available)
- Gemini API key

## Deployment Steps

### 1. Create Railway Account
1. Go to [railway.app](https://railway.app)
2. Sign up with GitHub
3. Connect your GitHub account

### 2. Deploy from GitHub
1. Click "New Project"
2. Select "Deploy from GitHub repo"
3. Choose `shivanandham/pregnancy-assistant`
4. Select the `backend` folder as the root directory

### 3. Configure Environment Variables
In Railway dashboard, go to Variables tab and add:

```
GEMINI_API_KEY=your_gemini_api_key_here
NODE_ENV=production
PORT=3000
```

### 4. Deploy
1. Railway will automatically detect it's a Node.js app
2. It will run `npm install` and `npm start`
3. The app will be available at a Railway-provided URL

### 5. Update Flutter App
After deployment, update the API config in Flutter:

```dart
// In luma/lib/config/api_config.dart
static String get baseUrl => Platform.isAndroid 
  ? 'https://your-railway-url.railway.app'  // Replace with actual URL
  : 'https://your-railway-url.railway.app';
```

## Railway Features Used
- **Automatic HTTPS**: Railway provides SSL certificates
- **Environment Variables**: Secure storage of API keys
- **Health Checks**: Automatic monitoring at `/health` endpoint
- **Auto-restart**: Restarts on failure
- **Custom Domain**: Can add custom domain later

## Monitoring
- Check logs in Railway dashboard
- Monitor health at `https://your-url.railway.app/health`
- View metrics and usage in Railway dashboard

## Cost
- **Free Tier**: $5 credit monthly (usually enough for small apps)
- **Pro**: $5/month for additional resources
- **Usage**: Pay for what you use beyond free tier
