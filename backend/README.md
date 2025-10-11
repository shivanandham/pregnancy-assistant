# Pregnancy Assistant Backend

A simple Node.js/Express API proxy for the Pregnancy Assistant app that securely handles Perplexity AI API calls.

## Setup

1. Install dependencies:
```bash
npm install
```

2. Create a `.env` file from the example:
```bash
cp .env.example .env
```

3. Add your Perplexity API key to the `.env` file:
```
PERPLEXITY_API_KEY=your_actual_api_key_here
```

## Running Locally

Development mode (with auto-restart):
```bash
npm run dev
```

Production mode:
```bash
npm start
```

The server will run on `http://localhost:3000`

## API Endpoints

### Health Check
- **GET** `/health`
- Returns server status

### Chat
- **POST** `/chat`
- Body: `{ "message": "user question", "week": 20, "context": "additional context" }`
- Returns AI response from Perplexity

## Deployment

### Railway
1. Connect your GitHub repository to Railway
2. Add environment variable `PERPLEXITY_API_KEY`
3. Deploy automatically

### Render
1. Create new Web Service on Render
2. Connect your repository
3. Add environment variable `PERPLEXITY_API_KEY`
4. Deploy

### Vercel
1. Install Vercel CLI: `npm i -g vercel`
2. Run `vercel` in the backend directory
3. Add environment variable in Vercel dashboard

## Environment Variables

- `PERPLEXITY_API_KEY`: Your Perplexity API key (required)
- `PORT`: Server port (optional, defaults to 3000)
