# Supabase Backend - Quartier Project

Simple Supabase backend using the official Supabase CLI - no manual configuration needed!

## Quick Start

```bash
# Install dependencies
npm install

# Start Supabase (first time may take a few minutes)
npm start

# Check status
npm run status
```

## Services

Once started, access your services at:

- **Studio (Admin UI)**: http://127.0.0.1:54323
- **REST API**: http://127.0.0.1:54321/rest/v1
- **GraphQL API**: http://127.0.0.1:54321/graphql/v1
- **Database**: postgresql://postgres:postgres@127.0.0.1:54322/postgres
- **Mailpit (Email Testing)**: http://127.0.0.1:54324

## Available Commands

```bash
npm start              # Start all Supabase services
npm stop               # Stop all services
npm restart            # Restart all services
npm run status         # Show service status and URLs
npm run db:reset       # Reset database (⚠️ deletes all data)
npm run db:import      # Import data from CSV files
npm run studio         # Show Studio URL
```

## Database Schema

The database includes two main tables:

- **haushalte** (households)
- **personen** (people)

Migrations are in `supabase/migrations/` and run automatically on startup.

## Development

The Supabase CLI automatically handles:
- ✅ Database initialization
- ✅ Authentication setup
- ✅ Storage configuration
- ✅ API Gateway (Kong)
- ✅ Email service (Mailpit)
- ✅ All required schemas and roles

No manual SQL setup needed!

## Documentation

- [Official Supabase Local Development Guide](https://supabase.com/docs/guides/local-development)
- [Supabase CLI Reference](https://supabase.com/docs/reference/cli)

## Notes

- All services run in Docker containers managed by the Supabase CLI
- Database data is persisted in Docker volumes
- Configuration is in `supabase/config.toml`
