# @saas/shared/zod

API contract Zod schemas. Single source of truth for:

1. Backend request/response validation (via `defineEndpoint`)
2. OpenAPI spec generation (via samchungy/zod-openapi `.meta()`)
3. Frontend form validation (via react-hook-form Zod resolvers)
4. Worker payload validation (BullMQ job payloads)

## Naming convention

- `CreateXSchema`, `UpdateXSchema`, `XResponseSchema`, `XQuerySchema` per resource.
- Files per resource: `users.ts`, `organizations.ts`, `uploads.ts`, ...
- One default `index.ts` re-exports everything for convenience.

## OpenAPI metadata

Use Zod 4's native `.meta()` (no global Zod extension):

```ts
const UserId = z.string().uuid().meta({
  id: 'UserId',
  description: 'Unique user identifier',
  example: '00000000-0000-0000-0000-000000000000',
});
```

The `id` field makes the schema a reusable `$ref` in the generated OpenAPI spec.
