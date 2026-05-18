# File uploads — S3 presigned URLs

The boilerplate's recommended file upload pattern. Documentation in Phase 1; working code in Phase 2.

## Why presigned URLs (not API proxy)

| Approach | Trade-off |
|---|---|
| **Presigned URLs** (recommended) | API stays stateless; bytes never touch your servers; scales to large files; needs round-trip to get URL |
| API proxies bytes | Simpler client code; API memory/disk pressure; doesn't scale to large files; harder to make resumable |

## The 4-step flow

```
1. Client → POST /uploads { filename, contentType, size }
2. API → validates, generates presigned PUT URL, returns { uploadUrl, fileKey, expiresAt }
3. Client → PUT directly to S3 with the presigned URL
4. Client → POST /uploads/:key/confirm
5. API → HEAD S3 object exists, creates Upload row linked to user + organization
```

## Bucket structure

```
<bucket>/uploads/<organizationId>/<userId>/<uploadId>-<filename>
```

The `organizationId` prefix lets you set IAM policies on the per-task ECS role that restrict access to objects with the task's org prefix — defense in depth on top of app-level RLS.

## IAM scoping

The API task role's S3 policy:

```json
{
  "Effect": "Allow",
  "Action": ["s3:PutObject", "s3:GetObject", "s3:DeleteObject"],
  "Resource": "arn:aws:s3:::<bucket>/uploads/*"
}
```

For stricter isolation, use IAM session tags + ABAC to limit each request's effective permissions to one `organizationId` prefix. Phase 3 enhancement.

## Phase 2 ships

- `apps/api/src/routes/uploads.ts` — presigned URL endpoint + confirm endpoint
- `packages/shared/zod/upload.ts` — request/response schemas
- `apps/web/src/hooks/useUpload.ts` — React hook handling the 4-step flow with progress
- `infra/tofu/modules/s3-uploads/` — bucket + lifecycle policy (auto-expire abandoned uploads at 24h) + CORS

## Not bundled (deferred)

- **Image processing / thumbnails** (Sharp on a Lambda? Cloudflare Images? Imgproxy?) — varies too much per product
- **Antivirus scanning** (ClamAV? AWS GuardDuty Malware Protection?) — needed for user-generated content with social features
- **Direct integration with Docuseal / other doc services** — see those tools' integration guides
