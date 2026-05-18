-- Run once per database before any Prisma migration.
-- Creates the two roles used for RLS-based multi-tenancy.

-- The application role: RLS policies apply. Used by apps/api and apps/workers
-- at runtime. Cannot bypass RLS, cannot create/drop tables.
CREATE ROLE app_user LOGIN PASSWORD 'CHANGE_ME_BEFORE_PROD';
GRANT CONNECT ON DATABASE postgres TO app_user;
GRANT USAGE ON SCHEMA public TO app_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO app_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO app_user;

-- The migration / admin role: BYPASSRLS. Used by Prisma migrations and
-- explicit admin endpoints. Never used in the request path of normal app code.
CREATE ROLE app_admin LOGIN PASSWORD 'CHANGE_ME_BEFORE_PROD' BYPASSRLS;
GRANT ALL PRIVILEGES ON DATABASE postgres TO app_admin;
GRANT ALL PRIVILEGES ON SCHEMA public TO app_admin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO app_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO app_admin;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO app_admin;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO app_admin;

-- Verify
SELECT rolname, rolbypassrls FROM pg_roles WHERE rolname IN ('app_user', 'app_admin');
