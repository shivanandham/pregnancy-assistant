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

## Database Migrations

**IMPORTANT**: All schema changes MUST go through Prisma migrations. Direct database modifications are prohibited.

### Environment Setup
- **Development**: Local laptop (NODE_ENV=development)
- **Production**: DigitalOcean droplet (NODE_ENV=production)
- **Development Database**: Local PostgreSQL on laptop
- **Production Database**: PostgreSQL on DigitalOcean droplet
- **Note**: Databases are separate - migrations must be applied to both environments

### Creating a Migration (Development - Local Laptop)

1. Modify `prisma/schema.prisma` with your changes
2. Generate and apply migration: `npx prisma migrate dev --name <descriptive-name>`
   - This creates the migration file and applies it to your local database
3. Carefully review the generated migration SQL file in `prisma/migrations/`
4. Commit both `schema.prisma` and migration files together

### Applying Migrations (Production - Droplet)

After deploying code to droplet:

1. Create database backup before applying migrations
2. Apply existing migrations: `npx prisma migrate deploy`
   - This applies all pending migrations to the production database on the droplet
3. Verify migration status: `npx prisma migrate status`

### Migration Rules

- ✅ DO: Use migrations for all schema changes
- ✅ DO: Use descriptive migration names
- ✅ DO: Review generated migration SQL carefully before committing
- ✅ DO: Create database backups before major schema changes
- ✅ DO: Commit both `schema.prisma` and migration files together
- ❌ DON'T: Modify database directly via SQL
- ❌ DON'T: Edit migration files after committing
- ❌ DON'T: Skip or revert migrations
- ❌ DON'T: Use `prisma db push` (always use migrations)
- ❌ DON'T: Drop or recreate the database (data loss risk)

See `.cursorrules` in project root for complete migration guidelines.

## Environment Variables

- `PERPLEXITY_API_KEY`: Your Perplexity API key (required)
- `PORT`: Server port (optional, defaults to 3000)
- `DATABASE_URL`: PostgreSQL connection string (required)
