# @saas/shared/errors

Domain error classes that the API error middleware maps to RFC 9457 problem documents.

## Phase 2 contents

```ts
export class DomainError extends Error {
  constructor(public readonly problemType: string, message: string, public readonly status: number = 400) {
    super(message);
  }
}

export class NotFoundError extends DomainError { /* status 404 */ }
export class UnauthorizedError extends DomainError { /* status 401 */ }
export class ForbiddenError extends DomainError { /* status 403 */ }
export class ConflictError extends DomainError { /* status 409 */ }
export class RateLimitError extends DomainError { /* status 429 */ }
```

Each problem `type` is a URI (`https://yourdomain.com/problems/not-found`) and is documented in OpenAPI as a response schema.
