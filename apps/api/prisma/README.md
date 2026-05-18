# apps/api/prisma

Prisma schema, migrations, and the one-time DB role bootstrap script.

## Files

- `schema.prisma` — main schema. BetterAuth tables + Organization plugin tables + domain models.
- `init.sql` — **run once per database** before migrations. Creates two Postgres roles: `app_user` (RLS active) and `app_admin` (BYPASSRLS). Migrations and admin endpoints connect as `app_admin`; the app connects as `app_user`.
- `migrations/` — Prisma-managed schema migrations, plus custom SQL files for RLS policies.

## RLS policy convention

For each new domain model added to `schema.prisma`, you must:

1. Run `prisma migrate dev --name add_<model>` to generate the schema migration.
2. Create a sibling SQL migration `prisma/migrations/<ts>_<model>_rls/migration.sql` that:
   - `ALTER TABLE "<Model>" ENABLE ROW LEVEL SECURITY;`
   - `CREATE POLICY org_isolation ON "<Model>" USING (...) WITH CHECK (...);`
3. CI's `lint:rls` task fails the build if any domain table lacks an RLS policy.

A scaffolding script `pnpm db:add-rls <ModelName>` will generate both atomically in Phase 2.
