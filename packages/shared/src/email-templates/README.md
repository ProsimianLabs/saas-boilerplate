# @saas/shared/email-templates

React Email components. Resend renders these natively:

```ts
await resend.emails.send({
  from: env.EMAIL_FROM,
  to: user.email,
  subject: 'Welcome to Acme',
  react: WelcomeEmail({ name: user.name }),
});
```

## Phase 2 templates

| File | When sent | Required by |
|---|---|---|
| `WelcomeEmail.tsx` | After signup | UX, not legally required |
| `PasswordResetEmail.tsx` | BetterAuth password reset request | Security |
| `MagicLinkEmail.tsx` | BetterAuth magic link auth (if enabled) | Auth |
| `OrgInvitationEmail.tsx` | BetterAuth org plugin invitation | Org plugin |
| `EmailVerificationEmail.tsx` | Email verification on signup | Anti-fraud |

Each template extends a shared `EmailLayout` component with the company logo, brand colors, and footer containing the required CAN-SPAM physical address + unsubscribe link.
