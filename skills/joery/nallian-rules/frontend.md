---
paths:
  - "**/*.ts"
  - "**/*.tsx"
---

# Frontend (React / TypeScript)

Typical Nallian stack: React 19, React Router 8, Formik + Yup, Radix UI, TanStack Query v5, nuqs,
Tailwind CSS 4, Vite, Vitest.

- **Authorization**: check `rights[]` via `hasRight('some-right')` from the auth context — never
  compare role strings. The auth endpoint returns both `role` and `rights[]`; only `rights[]` drives
  UI visibility.
- Component tests: `@testing-library/react` + Vitest.
