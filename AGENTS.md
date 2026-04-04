# CS-Vault Frontend — Agent Guide

This is the CS-Vault frontend built with Next.js 16 App Router + TypeScript + Tailwind CSS v4.

## What This Project Is

A school project repository platform for Computer Science departments. Three roles: Admin, Lecturer, Student.

## Important Rules for AI Agents

- This uses **Next.js 16 App Router** — all pages are in `app/` as `page.tsx`
- This uses **Tailwind CSS v4** — imported via `@import "tailwindcss"` in globals.css, no `tailwind.config.js` needed
- Colors are CSS variables, not Tailwind color utilities — use `style={{ color: 'var(--accent)' }}`
- All pages are `'use client'` components
- Auth reads from cookies via `js-cookie` — always gate behind `mounted` state to prevent hydration errors
- Use `window.location.href` for navigation after auth actions, not `router.push`
- The backend runs on port 5000 — `NEXT_PUBLIC_API_URL=http://localhost:5000/api`

## File Locations

- Pages → `app/[role]/page.tsx`
- Shared components → `components/`
- API client → `lib/api.ts`
- Auth helpers → `lib/auth.ts`
- Global styles + CSS vars → `app/globals.css`

## Do Not

- Do not add a `tailwind.config.js` — Tailwind v4 doesn't use it
- Do not use `router.push` after setting cookies
- Do not read cookies outside of `useEffect` or client components
- Do not use hardcoded hex colors — use CSS variables