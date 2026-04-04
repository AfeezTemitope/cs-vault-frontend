# CS-Vault Frontend — Claude Guide

This is the CS-Vault frontend, a Next.js 16 App Router project written in TypeScript.

## Project Purpose

CS-Vault is a school project repository platform for Computer Science students and lecturers. It has three user roles: Admin, Lecturer, and Student — each with their own access-controlled dashboard.

## Key Conventions

- All pages are in `app/` using the Next.js App Router
- All components are in `components/` as `.tsx` files
- API calls go through `lib/api.ts` (Axios with JWT interceptor)
- Auth helpers (getUser, setAuth, logout) are in `lib/auth.ts`
- Colors use CSS variables defined in `app/globals.css` — never hardcode hex values
- Use `style={{ color: 'var(--soft)' }}` pattern, not Tailwind color classes
- Every protected page must call `requireAuth(getUser(), router, ['role'])` in `useEffect`
- Use `window.location.href` instead of `router.push` for post-login redirects
- All Layout-wrapped pages read user from cookies — always use `mounted` state to avoid hydration errors

## CSS Variables

```
--ink        page background
--surface    header + sidebar
--card       card backgrounds
--border     all borders
--accent     #C8F135 lime green — primary actions
--muted      secondary text
--soft       primary text
```

## Backend API

Base URL from `NEXT_PUBLIC_API_URL` env variable.
Default local: `http://localhost:5000/api`

Main endpoints:
- `POST /auth/login`
- `GET /projects`
- `POST /projects`
- `GET /lecturer/courses`
- `POST /lecturer/students/register`
- `POST /admin/lecturers`
- `POST /admin/courses`