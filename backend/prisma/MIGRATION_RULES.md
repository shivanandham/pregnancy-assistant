# Database Migration Rules

## ⚠️ CRITICAL RULE

**ALL schema changes MUST go through Prisma migrations. Direct database modifications are STRICTLY PROHIBITED.**

## Migration Workflow

### Environment Setup
- **Development**: Local laptop (NODE_ENV=development)
- **Production**: DigitalOcean droplet (NODE_ENV=production)
- **Development Database**: Local PostgreSQL on laptop
- **Production Database**: PostgreSQL on DigitalOcean droplet
- **Note**: Databases are separate - migrations must be applied to both environments

### 1. Making Schema Changes (Development - Local Laptop)

```bash
# 1. Edit prisma/schema.prisma with your changes
# 2. Generate and apply migration
npx prisma migrate dev --name descriptive_change_name

# This command will:
# - Generate the migration file at prisma/migrations/<timestamp>_<name>/migration.sql
# - Apply the migration to your local database
# - Regenerate Prisma Client

# 3. Review the generated migration file
# Located at: prisma/migrations/<timestamp>_<name>/migration.sql

# 4. Commit both schema.prisma and migration files
```

### 2. Applying Migrations (Production - Droplet)

After deploying code to droplet:

```bash
# 1. Create database backup before applying
# 2. Apply existing migrations to production database
npx prisma migrate deploy

# This will apply all migrations that haven't been applied yet
# to the production database on the droplet

# 3. Verify migration status
npx prisma migrate status
```

### 3. Verifying Migrations

```bash
# Check migration status
npx prisma migrate status

# Verify schema matches database
npx prisma db pull --print
```

## ✅ DO's

- ✅ Always use Prisma migrations for schema changes
- ✅ Use descriptive migration names (e.g., `add_user_email_verification`)
- ✅ Review generated migration files carefully before committing
- ✅ Create database backups before applying migrations (especially before major changes)
- ✅ Review SQL carefully to ensure no data loss or unintended changes
- ✅ Commit both `schema.prisma` and migration files together
- ✅ Create migrations for any direct database changes that were made

## ❌ DON'Ts

- ❌ NEVER modify database schema directly via SQL
- ❌ NEVER use CREATE TABLE, ALTER TABLE, DROP TABLE directly
- ❌ NEVER edit migration files after they've been committed
- ❌ NEVER skip or revert migrations
- ❌ NEVER use `prisma db push` (only use migrations)
- ❌ NEVER modify database via psql, pgAdmin, or other tools directly
- ❌ NEVER apply migrations without reviewing the generated SQL first
- ❌ NEVER drop or recreate the database (data loss risk)

## Emergency Procedures

If a direct schema change was made (emergency only):

1. Document the change immediately
2. Use `prisma migrate diff` to generate a migration matching current state:
   ```bash
   npx prisma migrate diff --from-schema-datamodel prisma/schema.prisma --to-schema-datasource prisma/schema.prisma --script > migration.sql
   ```
3. Create a new migration file with the generated SQL
4. Mark it as applied if it matches current database state


## Migration File Structure

Migrations are stored in `prisma/migrations/`:
```
prisma/migrations/
├── migration_lock.toml
└── <timestamp>_<name>/
    └── migration.sql
```

Each migration file should be:
- Self-contained (can be applied independently)
- Reversible when possible
- Tested before committing
- Reviewed for correctness

## Common Commands

**Development (Local Laptop):**
```bash
# Generate and apply migration from schema changes
npx prisma migrate dev --name change_description

# Check migration status
npx prisma migrate status

# Generate Prisma Client after schema changes
npx prisma generate

# Open Prisma Studio to view database
npx prisma studio
```

**Production (Droplet):**
```bash
# Apply existing migrations (after deploying code)
npx prisma migrate deploy

# Check migration status
npx prisma migrate status

# Generate Prisma Client
npx prisma generate
```

## Questions?

Refer to:
- Project root `.cursorrules` for complete migration guidelines
- [Prisma Migration Docs](https://www.prisma.io/docs/concepts/components/prisma-migrate)
- Backend README.md for quick reference

