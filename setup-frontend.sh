#!/bin/bash

# ============================================================
#  CS-VAULT — Frontend File Setup
#  Run this from INSIDE your cs-vault-frontend/ folder
#  (where package.json lives)
# ============================================================

echo "📦 Installing dependencies..."
npm install axios js-cookie react-hot-toast lucide-react date-fns
npm install --save-dev @types/js-cookie

echo "📁 Creating folder structure..."
mkdir -p \
  app/login \
  app/profile \
  app/admin/lecturers \
  app/admin/courses \
  app/admin/students \
  app/lecturer/courses/\[courseId\] \
  app/lecturer/projects/\[projectId\] \
  app/lecturer/students/register \
  app/student/projects/\[projectId\] \
  app/student/upload \
  components \
  lib

echo "⚙️  Writing .env.local..."
cat > .env.local << 'ENV'
NEXT_PUBLIC_API_URL=http://localhost:5000/api
ENV

echo "🎨 Writing globals.css..."
cat > app/globals.css << 'EOF'
@import url('https://fonts.googleapis.com/css2?family=Syne:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;500&display=swap');
@import "tailwindcss";

:root {
  --ink: #0A0A0F;
  --surface: #111118;
  --card: #17171F;
  --border: #252530;
  --accent: #C8F135;
  --accent-dim: #9BBF1A;
  --muted: #6B6B80;
  --soft: #E8E8F0;
}

* { box-sizing: border-box; }

body {
  background-color: var(--ink);
  color: var(--soft);
  font-family: 'Syne', sans-serif;
  -webkit-font-smoothing: antialiased;
}

::-webkit-scrollbar { width: 4px; }
::-webkit-scrollbar-track { background: var(--surface); }
::-webkit-scrollbar-thumb { background: var(--border); border-radius: 4px; }

.mono { font-family: 'JetBrains Mono', monospace; }

@keyframes fadeUp {
  from { opacity: 0; transform: translateY(14px); }
  to   { opacity: 1; transform: translateY(0); }
}
@keyframes fadeIn {
  from { opacity: 0; }
  to   { opacity: 1; }
}

.fade-up { animation: fadeUp 0.45s ease forwards; }
.fade-in { animation: fadeIn 0.35s ease forwards; }
.delay-1 { animation-delay: 0.05s; opacity: 0; }
.delay-2 { animation-delay: 0.10s; opacity: 0; }
.delay-3 { animation-delay: 0.15s; opacity: 0; }
.delay-4 { animation-delay: 0.20s; opacity: 0; }
EOF

echo "🔧 Writing lib/api.ts..."
cat > lib/api.ts << 'EOF'
import axios from 'axios';
import Cookies from 'js-cookie';

const api = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_URL,
});

api.interceptors.request.use((config) => {
  const token = Cookies.get('token');
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

api.interceptors.response.use(
  (res) => res,
  (err) => {
    if (err.response?.status === 401) {
      Cookies.remove('token');
      Cookies.remove('user');
      window.location.href = '/login';
    }
    return Promise.reject(err);
  }
);

export default api;
EOF

echo "🔧 Writing lib/auth.ts..."
cat > lib/auth.ts << 'EOF'
import Cookies from 'js-cookie';
import { AppRouterInstance } from 'next/dist/shared/lib/app-router-context.shared-runtime';

export interface User {
  id: string;
  name?: string;
  full_name?: string;
  email: string;
  role: 'admin' | 'lecturer' | 'student';
  matric_number: string;
  must_change_password?: boolean;
}

export const getUser = (): User | null => {
  try {
    const u = Cookies.get('user');
    return u ? JSON.parse(u) : null;
  } catch { return null; }
};

export const setAuth = (token: string, user: User) => {
  Cookies.set('token', token, { expires: 7 });
  Cookies.set('user', JSON.stringify(user), { expires: 7 });
};

export const logout = () => {
  Cookies.remove('token');
  Cookies.remove('user');
  window.location.href = '/login';
};

export const requireAuth = (
  user: User | null,
  router: AppRouterInstance,
  roles: string[] = []
): boolean => {
  if (!user) { router.push('/login'); return false; }
  if (roles.length && !roles.includes(user.role)) {
    router.push(`/${user.role}`);
    return false;
  }
  return true;
};
EOF

echo "🧩 Writing components..."

cat > components/Layout.tsx << 'EOF'
'use client';
import { useState } from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { getUser, logout } from '@/lib/auth';
import {
  LayoutDashboard, BookOpen, Upload, Search,
  Users, GraduationCap, LogOut, Menu, X, Settings, FolderOpen
} from 'lucide-react';

const navItems: Record<string, { href: string; label: string; icon: React.ElementType }[]> = {
  admin: [
    { href: '/admin', label: 'Dashboard', icon: LayoutDashboard },
    { href: '/admin/lecturers', label: 'Lecturers', icon: GraduationCap },
    { href: '/admin/courses', label: 'Courses', icon: BookOpen },
    { href: '/admin/students', label: 'Students', icon: Users },
  ],
  lecturer: [
    { href: '/lecturer', label: 'Dashboard', icon: LayoutDashboard },
    { href: '/lecturer/courses', label: 'My Courses', icon: BookOpen },
    { href: '/lecturer/projects', label: 'All Projects', icon: FolderOpen },
    { href: '/lecturer/students/register', label: 'Register', icon: Users },
  ],
  student: [
    { href: '/student', label: 'Dashboard', icon: LayoutDashboard },
    { href: '/student/projects', label: 'Browse', icon: Search },
    { href: '/student/upload', label: 'Upload', icon: Upload },
  ],
};

export default function Layout({ children }: { children: React.ReactNode }) {
  const [open, setOpen] = useState(false);
  const pathname = usePathname();
  const user = getUser();
  const items = navItems[user?.role ?? ''] ?? [];
  const displayName = user?.name ?? user?.full_name ?? '';

  return (
    <div className="min-h-screen flex flex-col" style={{ backgroundColor: 'var(--ink)' }}>
      {/* Header */}
      <header className="sticky top-0 z-50 flex items-center justify-between px-4 h-14 border-b"
        style={{ backgroundColor: 'var(--surface)', borderColor: 'var(--border)' }}>
        <div className="flex items-center gap-3">
          <button onClick={() => setOpen(!open)} className="md:hidden" style={{ color: 'var(--muted)' }}>
            {open ? <X size={20} /> : <Menu size={20} />}
          </button>
          <span className="mono font-medium tracking-tight text-sm" style={{ color: 'var(--accent)' }}>CS-VAULT</span>
        </div>
        <div className="flex items-center gap-3">
          <span className="text-xs hidden sm:block" style={{ color: 'var(--muted)' }}>{displayName}</span>
          <span className="mono text-xs px-2 py-0.5 rounded uppercase"
            style={{ backgroundColor: 'var(--border)', color: 'var(--accent)' }}>{user?.role}</span>
          <button onClick={logout} style={{ color: 'var(--muted)' }}><LogOut size={16} /></button>
        </div>
      </header>

      <div className="flex flex-1">
        {/* Sidebar desktop */}
        <aside className="hidden md:flex flex-col w-56 py-6 px-3 gap-1 sticky top-14 h-[calc(100vh-3.5rem)] border-r"
          style={{ backgroundColor: 'var(--surface)', borderColor: 'var(--border)' }}>
          {items.map(({ href, label, icon: Icon }) => {
            const active = pathname === href;
            return (
              <Link key={href} href={href}
                className="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm transition-all"
                style={active
                  ? { backgroundColor: 'var(--accent)', color: 'var(--ink)', fontWeight: 600 }
                  : { color: 'var(--muted)' }}>
                <Icon size={16} />{label}
              </Link>
            );
          })}
          <div className="mt-auto">
            <Link href="/profile"
              className="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm transition-all"
              style={pathname === '/profile'
                ? { backgroundColor: 'var(--accent)', color: 'var(--ink)', fontWeight: 600 }
                : { color: 'var(--muted)' }}>
              <Settings size={16} />Profile
            </Link>
          </div>
        </aside>

        {/* Mobile drawer */}
        {open && (
          <div className="fixed inset-0 z-40 md:hidden" onClick={() => setOpen(false)}>
            <div className="absolute inset-0" style={{ backgroundColor: 'rgba(0,0,0,0.6)' }} />
            <aside className="absolute top-14 left-0 bottom-0 w-64 flex flex-col py-6 px-3 gap-1 border-r"
              style={{ backgroundColor: 'var(--surface)', borderColor: 'var(--border)' }}
              onClick={e => e.stopPropagation()}>
              {items.map(({ href, label, icon: Icon }) => {
                const active = pathname === href;
                return (
                  <Link key={href} href={href} onClick={() => setOpen(false)}
                    className="flex items-center gap-3 px-3 py-3 rounded-lg text-sm transition-all"
                    style={active
                      ? { backgroundColor: 'var(--accent)', color: 'var(--ink)', fontWeight: 600 }
                      : { color: 'var(--muted)' }}>
                    <Icon size={16} />{label}
                  </Link>
                );
              })}
              <div className="mt-auto">
                <Link href="/profile" onClick={() => setOpen(false)}
                  className="flex items-center gap-3 px-3 py-3 rounded-lg text-sm"
                  style={{ color: 'var(--muted)' }}>
                  <Settings size={16} />Profile
                </Link>
              </div>
            </aside>
          </div>
        )}

        {/* Main */}
        <main className="flex-1 p-4 md:p-8 max-w-4xl w-full mx-auto pb-24 md:pb-8">
          {children}
        </main>
      </div>

      {/* Bottom nav mobile */}
      <nav className="md:hidden fixed bottom-0 left-0 right-0 flex justify-around py-2 z-30 border-t"
        style={{ backgroundColor: 'var(--surface)', borderColor: 'var(--border)' }}>
        {items.map(({ href, label, icon: Icon }) => (
          <Link key={href} href={href}
            className="flex flex-col items-center gap-0.5 px-3 py-1"
            style={{ color: pathname === href ? 'var(--accent)' : 'var(--muted)' }}>
            <Icon size={20} />
            <span style={{ fontSize: 10 }}>{label}</span>
          </Link>
        ))}
      </nav>
    </div>
  );
}
EOF

cat > components/StatCard.tsx << 'EOF'
import { LucideIcon } from 'lucide-react';
export default function StatCard({ label, value, icon: Icon, accent }: {
  label: string; value: string | number; icon: LucideIcon; accent?: boolean;
}) {
  return (
    <div className="rounded-xl p-4 flex items-center gap-4 border"
      style={{ backgroundColor: 'var(--card)', borderColor: accent ? 'rgba(200,241,53,0.3)' : 'var(--border)' }}>
      <div className="w-10 h-10 rounded-lg flex items-center justify-center flex-shrink-0"
        style={{ backgroundColor: accent ? 'rgba(200,241,53,0.1)' : 'var(--border)', color: accent ? 'var(--accent)' : 'var(--muted)' }}>
        <Icon size={18} />
      </div>
      <div>
        <p className="text-2xl font-bold" style={{ color: 'var(--soft)' }}>{value}</p>
        <p className="text-xs" style={{ color: 'var(--muted)' }}>{label}</p>
      </div>
    </div>
  );
}
EOF

cat > components/ProjectCard.tsx << 'EOF'
import Link from 'next/link';
import { FileText, Github, Archive, Calendar } from 'lucide-react';
import { format } from 'date-fns';

const gradeColors: Record<string, string> = {
  A: '#4ade80', B: '#C8F135', C: '#60a5fa', D: '#facc15', E: '#fb923c', F: '#f87171',
};

interface Project {
  id: string; title: string; description?: string; session?: string;
  pdf_url?: string; zip_url?: string; github_link?: string; created_at?: string;
  grades?: { grade: string } | { grade: string }[];
  courses?: { title: string; course_code: string };
  users?: { full_name: string; matric_number: string };
}

export default function ProjectCard({ project, href }: { project: Project; href?: string }) {
  const grade = Array.isArray(project.grades) ? project.grades[0]?.grade : project.grades?.grade;
  const link = href ?? `/student/projects/${project.id}`;
  return (
    <Link href={link} className="block rounded-xl p-4 border transition-all group"
      style={{ backgroundColor: 'var(--card)', borderColor: 'var(--border)' }}
      onMouseEnter={e => (e.currentTarget.style.borderColor = 'rgba(200,241,53,0.4)')}
      onMouseLeave={e => (e.currentTarget.style.borderColor = 'var(--border)')}>
      <div className="flex items-start justify-between gap-2 mb-2">
        <h3 className="font-semibold text-sm leading-snug line-clamp-2 transition-colors"
          style={{ color: 'var(--soft)' }}>{project.title}</h3>
        {grade && (
          <span className="mono text-xs font-bold px-2 py-0.5 rounded flex-shrink-0"
            style={{ color: gradeColors[grade] ?? 'var(--muted)', backgroundColor: `${gradeColors[grade] ?? '#888'}18` }}>
            {grade}
          </span>
        )}
      </div>
      {project.description && (
        <p className="text-xs line-clamp-2 mb-3" style={{ color: 'var(--muted)' }}>{project.description}</p>
      )}
      <div className="flex items-center gap-3 flex-wrap">
        {project.courses?.course_code && (
          <span className="mono text-xs px-2 py-0.5 rounded" style={{ backgroundColor: 'var(--border)', color: 'var(--muted)' }}>
            {project.courses.course_code}
          </span>
        )}
        {project.pdf_url && <FileText size={13} style={{ color: 'var(--muted)' }} />}
        {project.zip_url && <Archive size={13} style={{ color: 'var(--muted)' }} />}
        {project.github_link && <Github size={13} style={{ color: 'var(--muted)' }} />}
        {project.created_at && (
          <span className="text-xs ml-auto flex items-center gap-1" style={{ color: 'var(--muted)' }}>
            <Calendar size={11} />{format(new Date(project.created_at), 'dd MMM yyyy')}
          </span>
        )}
      </div>
      {project.users && (
        <p className="mono text-xs mt-2" style={{ color: 'var(--muted)' }}>
          {project.users.matric_number} · {project.users.full_name}
        </p>
      )}
    </Link>
  );
}
EOF

cat > components/PageHeader.tsx << 'EOF'
export default function PageHeader({ title, subtitle, action }: {
  title: string; subtitle?: string; action?: React.ReactNode;
}) {
  return (
    <div className="flex items-start justify-between mb-6 gap-4">
      <div>
        <h1 className="text-xl font-bold" style={{ color: 'var(--soft)' }}>{title}</h1>
        {subtitle && <p className="text-sm mt-0.5" style={{ color: 'var(--muted)' }}>{subtitle}</p>}
      </div>
      {action && <div className="flex-shrink-0">{action}</div>}
    </div>
  );
}
EOF

cat > components/EmptyState.tsx << 'EOF'
import { LucideIcon } from 'lucide-react';
export default function EmptyState({ icon: Icon, title, subtitle }: {
  icon: LucideIcon; title: string; subtitle: string;
}) {
  return (
    <div className="flex flex-col items-center justify-center py-16 text-center">
      <div className="w-14 h-14 rounded-full flex items-center justify-center mb-4"
        style={{ backgroundColor: 'var(--border)' }}>
        <Icon size={24} style={{ color: 'var(--muted)' }} />
      </div>
      <h3 className="font-semibold mb-1" style={{ color: 'var(--soft)' }}>{title}</h3>
      <p className="text-sm max-w-xs" style={{ color: 'var(--muted)' }}>{subtitle}</p>
    </div>
  );
}
EOF

echo "📄 Writing app pages..."

# app/layout.tsx
cat > app/layout.tsx << 'EOF'
import type { Metadata } from 'next';
import { Toaster } from 'react-hot-toast';
import './globals.css';

export const metadata: Metadata = {
  title: 'CS-Vault | School Project Repository',
  description: 'Computer Science project repository',
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        {children}
        <Toaster position="top-center" toastOptions={{
          style: { background: '#17171F', color: '#E8E8F0', border: '1px solid #252530', fontFamily: 'Syne, sans-serif', fontSize: '14px' },
          success: { iconTheme: { primary: '#C8F135', secondary: '#0A0A0F' } },
        }} />
      </body>
    </html>
  );
}
EOF

# app/page.tsx
cat > app/page.tsx << 'EOF'
'use client';
import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { getUser } from '@/lib/auth';

export default function Root() {
  const router = useRouter();
  useEffect(() => {
    const user = getUser();
    if (!user) { router.push('/login'); return; }
    router.push(`/${user.role}`);
  }, [router]);
  return (
    <div className="min-h-screen flex items-center justify-center" style={{ backgroundColor: 'var(--ink)' }}>
      <span className="mono text-sm" style={{ color: 'var(--accent)' }}>cs-vault</span>
    </div>
  );
}
EOF

# app/login/page.tsx
cat > app/login/page.tsx << 'EOF'
'use client';
import { useState } from 'react';
import { useRouter } from 'next/navigation';
import toast from 'react-hot-toast';
import api from '@/lib/api';
import { setAuth } from '@/lib/auth';
import { Eye, EyeOff, Lock, User } from 'lucide-react';

export default function LoginPage() {
  const router = useRouter();
  const [form, setForm] = useState({ matric_number: '', password: '' });
  const [show, setShow] = useState(false);
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      const { data } = await api.post('/auth/login', form);
      setAuth(data.token, data.user);
      toast.success(`Welcome, ${data.user.full_name.split(' ')[0]}!`);
      router.push(data.user.must_change_password ? '/profile?must_change=true' : `/${data.user.role}`);
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : 'Login failed';
      const axiosMsg = (err as { response?: { data?: { error?: string } } })?.response?.data?.error;
      toast.error(axiosMsg ?? msg);
    } finally { setLoading(false); }
  };

  return (
    <div className="min-h-screen flex flex-col items-center justify-center px-4 relative overflow-hidden"
      style={{ backgroundColor: 'var(--ink)' }}>
      {/* Grid bg */}
      <div className="absolute inset-0 opacity-[0.025]"
        style={{ backgroundImage: 'linear-gradient(#C8F135 1px,transparent 1px),linear-gradient(90deg,#C8F135 1px,transparent 1px)', backgroundSize: '40px 40px' }} />

      <div className="w-full max-w-sm relative z-10">
        <div className="text-center mb-10 fade-up">
          <div className="inline-flex items-center justify-center w-12 h-12 rounded-xl mb-4"
            style={{ backgroundColor: 'var(--accent)' }}>
            <span className="mono font-bold text-lg" style={{ color: 'var(--ink)' }}>CV</span>
          </div>
          <h1 className="text-2xl font-bold" style={{ color: 'var(--soft)' }}>CS-Vault</h1>
          <p className="text-sm mt-1" style={{ color: 'var(--muted)' }}>School Project Repository</p>
        </div>

        <div className="rounded-2xl p-6 border fade-up delay-2"
          style={{ backgroundColor: 'var(--card)', borderColor: 'var(--border)' }}>
          <h2 className="text-lg font-semibold mb-1" style={{ color: 'var(--soft)' }}>Sign in</h2>
          <p className="text-xs mb-6" style={{ color: 'var(--muted)' }}>Use your matric number and password</p>

          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="text-xs block mb-1.5" style={{ color: 'var(--muted)' }}>Matric Number</label>
              <div className="relative">
                <User size={15} className="absolute left-3 top-1/2 -translate-y-1/2" style={{ color: 'var(--muted)' }} />
                <input
                  className="w-full rounded-lg pl-9 pr-4 py-3 text-sm mono focus:outline-none transition-colors border"
                  style={{ backgroundColor: 'var(--surface)', borderColor: 'var(--border)', color: 'var(--soft)' }}
                  placeholder="e.g. CSC/2021/001"
                  value={form.matric_number}
                  onChange={e => setForm({ ...form, matric_number: e.target.value })}
                  onFocus={e => (e.target.style.borderColor = 'var(--accent)')}
                  onBlur={e => (e.target.style.borderColor = 'var(--border)')}
                  required />
              </div>
            </div>

            <div>
              <label className="text-xs block mb-1.5" style={{ color: 'var(--muted)' }}>Password</label>
              <div className="relative">
                <Lock size={15} className="absolute left-3 top-1/2 -translate-y-1/2" style={{ color: 'var(--muted)' }} />
                <input
                  type={show ? 'text' : 'password'}
                  className="w-full rounded-lg pl-9 pr-10 py-3 text-sm focus:outline-none transition-colors border"
                  style={{ backgroundColor: 'var(--surface)', borderColor: 'var(--border)', color: 'var(--soft)' }}
                  placeholder="Your password"
                  value={form.password}
                  onChange={e => setForm({ ...form, password: e.target.value })}
                  onFocus={e => (e.target.style.borderColor = 'var(--accent)')}
                  onBlur={e => (e.target.style.borderColor = 'var(--border)')}
                  required />
                <button type="button" onClick={() => setShow(!show)}
                  className="absolute right-3 top-1/2 -translate-y-1/2 transition-colors"
                  style={{ color: 'var(--muted)' }}>
                  {show ? <EyeOff size={15} /> : <Eye size={15} />}
                </button>
              </div>
            </div>

            <button type="submit" disabled={loading}
              className="w-full font-semibold py-3 rounded-lg text-sm transition-all mt-2 disabled:opacity-50"
              style={{ backgroundColor: 'var(--accent)', color: 'var(--ink)' }}>
              {loading ? 'Signing in...' : 'Sign in'}
            </button>
          </form>
        </div>
        <p className="text-center text-xs mt-6" style={{ color: 'var(--muted)' }}>
          Forgot your password? Contact your lecturer.
        </p>
      </div>
    </div>
  );
}
EOF

# app/profile/page.tsx
cat > app/profile/page.tsx << 'EOF'
'use client';
import { useState, useEffect, Suspense } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import toast from 'react-hot-toast';
import api from '@/lib/api';
import { getUser } from '@/lib/auth';
import Layout from '@/components/Layout';
import PageHeader from '@/components/PageHeader';
import { Lock } from 'lucide-react';

function ProfileInner() {
  const router = useRouter();
  const params = useSearchParams();
  const mustChange = params.get('must_change') === 'true';
  const user = getUser();
  const [form, setForm] = useState({ current_password: '', new_password: '', confirm: '' });
  const [loading, setLoading] = useState(false);

  useEffect(() => { if (!user) router.push('/login'); }, [user, router]);

  const inputStyle = {
    width: '100%', backgroundColor: 'var(--surface)', borderColor: 'var(--border)',
    color: 'var(--soft)', border: '1px solid var(--border)', borderRadius: 8,
    padding: '10px 16px', fontSize: 14, outline: 'none',
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (form.new_password !== form.confirm) return toast.error('Passwords do not match');
    if (form.new_password.length < 6) return toast.error('Min 6 characters');
    setLoading(true);
    try {
      await api.put('/auth/change-password', { current_password: form.current_password, new_password: form.new_password });
      toast.success('Password changed!');
      router.push(`/${user?.role}`);
    } catch (err: unknown) {
      const axiosMsg = (err as { response?: { data?: { error?: string } } })?.response?.data?.error;
      toast.error(axiosMsg ?? 'Failed');
    } finally { setLoading(false); }
  };

  return (
    <Layout>
      <PageHeader title="Profile" subtitle="Manage your account" />
      {mustChange && (
        <div className="rounded-xl p-4 mb-5 text-sm border" style={{ backgroundColor: 'rgba(200,241,53,0.08)', borderColor: 'rgba(200,241,53,0.3)', color: 'var(--accent)' }}>
          ⚠️ Please change your auto-generated password before continuing.
        </div>
      )}
      <div className="rounded-xl p-5 mb-5 border" style={{ backgroundColor: 'var(--card)', borderColor: 'var(--border)' }}>
        <p className="text-xs mb-1" style={{ color: 'var(--muted)' }}>Name</p>
        <p className="font-semibold" style={{ color: 'var(--soft)' }}>{user?.name ?? user?.full_name}</p>
        <p className="text-xs mt-3 mb-1" style={{ color: 'var(--muted)' }}>Matric Number</p>
        <p className="mono text-sm" style={{ color: 'var(--soft)' }}>{user?.matric_number}</p>
        <p className="text-xs mt-3 mb-1" style={{ color: 'var(--muted)' }}>Role</p>
        <span className="mono text-xs px-2 py-0.5 rounded uppercase" style={{ backgroundColor: 'var(--border)', color: 'var(--accent)' }}>{user?.role}</span>
      </div>
      <div className="rounded-xl p-5 border" style={{ backgroundColor: 'var(--card)', borderColor: 'var(--border)' }}>
        <div className="flex items-center gap-2 mb-4">
          <Lock size={16} style={{ color: 'var(--accent)' }} />
          <h2 className="font-semibold" style={{ color: 'var(--soft)' }}>Change Password</h2>
        </div>
        <form onSubmit={handleSubmit} className="space-y-4">
          {(['current_password', 'new_password', 'confirm'] as const).map(f => (
            <div key={f}>
              <label className="text-xs block mb-1.5 capitalize" style={{ color: 'var(--muted)' }}>{f.replace(/_/g, ' ')}</label>
              <input type="password" required style={inputStyle}
                value={form[f]} onChange={e => setForm({ ...form, [f]: e.target.value })}
                onFocus={e => (e.target.style.borderColor = 'var(--accent)')}
                onBlur={e => (e.target.style.borderColor = 'var(--border)')} />
            </div>
          ))}
          <button type="submit" disabled={loading}
            className="w-full font-semibold py-3 rounded-lg text-sm transition-all disabled:opacity-50"
            style={{ backgroundColor: 'var(--accent)', color: 'var(--ink)' }}>
            {loading ? 'Saving...' : 'Update Password'}
          </button>
        </form>
      </div>
    </Layout>
  );
}

export default function ProfilePage() {
  return <Suspense><ProfileInner /></Suspense>;
}
EOF

# ── ADMIN ──────────────────────────────────────────────────────
cat > app/admin/page.tsx << 'EOF'
'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { getUser, requireAuth } from '@/lib/auth';
import Layout from '@/components/Layout';
import StatCard from '@/components/StatCard';
import PageHeader from '@/components/PageHeader';
import api from '@/lib/api';
import { Users, GraduationCap, BookOpen } from 'lucide-react';

export default function AdminDashboard() {
  const router = useRouter();
  const [stats, setStats] = useState({ lecturers: 0, students: 0, courses: 0 });
  useEffect(() => {
    const user = getUser();
    if (!requireAuth(user, router, ['admin'])) return;
    Promise.all([api.get('/admin/lecturers'), api.get('/admin/students'), api.get('/admin/courses')])
      .then(([l, s, c]) => setStats({ lecturers: l.data.length, students: s.data.length, courses: c.data.length }))
      .catch(() => {});
  }, [router]);
  return (
    <Layout>
      <PageHeader title="Admin Dashboard" subtitle="CS-Vault overview" />
      <div className="grid grid-cols-2 gap-3 md:grid-cols-3 fade-up">
        <StatCard label="Lecturers" value={stats.lecturers} icon={GraduationCap} accent />
        <StatCard label="Students" value={stats.students} icon={Users} />
        <StatCard label="Courses" value={stats.courses} icon={BookOpen} />
      </div>
    </Layout>
  );
}
EOF

cat > app/admin/lecturers/page.tsx << 'EOF'
'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { getUser, requireAuth } from '@/lib/auth';
import Layout from '@/components/Layout';
import PageHeader from '@/components/PageHeader';
import EmptyState from '@/components/EmptyState';
import api from '@/lib/api';
import toast from 'react-hot-toast';
import { GraduationCap, Plus, X } from 'lucide-react';
import { format } from 'date-fns';

interface Lecturer { id: string; full_name: string; email: string; matric_number: string; department: string; created_at: string; }

export default function LecturersPage() {
  const router = useRouter();
  const [lecturers, setLecturers] = useState<Lecturer[]>([]);
  const [showForm, setShowForm] = useState(false);
  const [form, setForm] = useState({ full_name: '', email: '', matric_number: '', department: 'Computer Science' });
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (!requireAuth(getUser(), router, ['admin'])) return;
    fetch();
  }, [router]);

  const fetch = () => api.get('/admin/lecturers').then(r => setLecturers(r.data)).catch(() => {});

  const handleCreate = async (e: React.FormEvent) => {
    e.preventDefault(); setLoading(true);
    try {
      await api.post('/admin/lecturers', form);
      toast.success('Lecturer created — credentials sent!');
      setShowForm(false); setForm({ full_name: '', email: '', matric_number: '', department: 'Computer Science' });
      fetch();
    } catch (err: unknown) {
      toast.error((err as { response?: { data?: { error?: string } } })?.response?.data?.error ?? 'Failed');
    } finally { setLoading(false); }
  };

  const inp = "w-full rounded-lg px-4 py-2.5 text-sm focus:outline-none border transition-colors";
  const inpStyle = { backgroundColor: 'var(--surface)', borderColor: 'var(--border)', color: 'var(--soft)' };

  return (
    <Layout>
      <PageHeader title="Lecturers" subtitle={`${lecturers.length} registered`}
        action={
          <button onClick={() => setShowForm(!showForm)}
            className="flex items-center gap-2 px-4 py-2 rounded-lg text-sm font-semibold transition-all"
            style={{ backgroundColor: 'var(--accent)', color: 'var(--ink)' }}>
            <Plus size={15} />Add Lecturer
          </button>
        } />

      {showForm && (
        <div className="rounded-xl p-5 mb-5 border fade-up" style={{ backgroundColor: 'var(--card)', borderColor: 'var(--border)' }}>
          <div className="flex items-center justify-between mb-4">
            <h3 className="font-semibold" style={{ color: 'var(--soft)' }}>New Lecturer</h3>
            <button onClick={() => setShowForm(false)} style={{ color: 'var(--muted)' }}><X size={16} /></button>
          </div>
          <form onSubmit={handleCreate} className="space-y-3">
            {[['Full Name', 'full_name'], ['Email', 'email'], ['Staff ID', 'matric_number']].map(([label, key]) => (
              <div key={key}>
                <label className="text-xs block mb-1" style={{ color: 'var(--muted)' }}>{label}</label>
                <input required className={inp} style={inpStyle}
                  value={form[key as keyof typeof form]}
                  onChange={e => setForm({ ...form, [key]: e.target.value })}
                  onFocus={e => (e.target.style.borderColor = 'var(--accent)')}
                  onBlur={e => (e.target.style.borderColor = 'var(--border)')} />
              </div>
            ))}
            <button type="submit" disabled={loading}
              className="w-full font-semibold py-2.5 rounded-lg text-sm disabled:opacity-50"
              style={{ backgroundColor: 'var(--accent)', color: 'var(--ink)' }}>
              {loading ? 'Creating...' : 'Create & Send Credentials'}
            </button>
          </form>
        </div>
      )}

      {lecturers.length === 0
        ? <EmptyState icon={GraduationCap} title="No lecturers yet" subtitle="Add your first lecturer above" />
        : <div className="space-y-3">
            {lecturers.map((l, i) => (
              <div key={l.id} className={`rounded-xl p-4 border fade-up delay-${Math.min(i+1,4) as 1|2|3|4}`}
                style={{ backgroundColor: 'var(--card)', borderColor: 'var(--border)' }}>
                <div className="flex items-start justify-between">
                  <div>
                    <p className="font-semibold text-sm" style={{ color: 'var(--soft)' }}>{l.full_name}</p>
                    <p className="text-xs mt-0.5" style={{ color: 'var(--muted)' }}>{l.email}</p>
                  </div>
                  <span className="mono text-xs px-2 py-0.5 rounded" style={{ color: 'var(--accent)', backgroundColor: 'rgba(200,241,53,0.1)' }}>{l.matric_number}</span>
                </div>
                <p className="text-xs mt-2" style={{ color: 'var(--muted)' }}>
                  {l.department} · {l.created_at ? format(new Date(l.created_at), 'dd MMM yyyy') : ''}
                </p>
              </div>
            ))}
          </div>
      }
    </Layout>
  );
}
EOF

cat > app/admin/courses/page.tsx << 'EOF'
'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { getUser, requireAuth } from '@/lib/auth';
import Layout from '@/components/Layout';
import PageHeader from '@/components/PageHeader';
import EmptyState from '@/components/EmptyState';
import api from '@/lib/api';
import toast from 'react-hot-toast';
import { BookOpen, Plus, X } from 'lucide-react';

interface Course { id: string; title: string; course_code: string; session: string; lecturer_id?: string; }
interface Lecturer { id: string; full_name: string; }

export default function CoursesPage() {
  const router = useRouter();
  const [courses, setCourses] = useState<Course[]>([]);
  const [lecturers, setLecturers] = useState<Lecturer[]>([]);
  const [showForm, setShowForm] = useState(false);
  const [form, setForm] = useState({ title: '', course_code: '', description: '', session: '2024/2025' });
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (!requireAuth(getUser(), router, ['admin'])) return;
    loadData();
  }, [router]);

  const loadData = () =>
    Promise.all([api.get('/admin/courses'), api.get('/admin/lecturers')])
      .then(([c, l]) => { setCourses(c.data); setLecturers(l.data); }).catch(() => {});

  const handleCreate = async (e: React.FormEvent) => {
    e.preventDefault(); setLoading(true);
    try { await api.post('/admin/courses', form); toast.success('Course created'); setShowForm(false); loadData(); }
    catch (err: unknown) { toast.error((err as { response?: { data?: { error?: string } } })?.response?.data?.error ?? 'Failed'); }
    finally { setLoading(false); }
  };

  const assign = async (course_id: string, lecturer_id: string) => {
    try { await api.put('/admin/courses/assign', { course_id, lecturer_id }); toast.success('Assigned!'); loadData(); }
    catch { toast.error('Failed'); }
  };

  const inp = "w-full rounded-lg px-4 py-2.5 text-sm border focus:outline-none";
  const inpStyle = { backgroundColor: 'var(--surface)', borderColor: 'var(--border)', color: 'var(--soft)' };

  return (
    <Layout>
      <PageHeader title="Courses" subtitle={`${courses.length} courses`}
        action={
          <button onClick={() => setShowForm(!showForm)}
            className="flex items-center gap-2 px-4 py-2 rounded-lg text-sm font-semibold"
            style={{ backgroundColor: 'var(--accent)', color: 'var(--ink)' }}>
            <Plus size={15} />Add Course
          </button>
        } />

      {showForm && (
        <div className="rounded-xl p-5 mb-5 border fade-up" style={{ backgroundColor: 'var(--card)', borderColor: 'var(--border)' }}>
          <div className="flex items-center justify-between mb-4">
            <h3 className="font-semibold" style={{ color: 'var(--soft)' }}>New Course</h3>
            <button onClick={() => setShowForm(false)} style={{ color: 'var(--muted)' }}><X size={16} /></button>
          </div>
          <form onSubmit={handleCreate} className="space-y-3">
            {[['Course Title', 'title'], ['Course Code', 'course_code'], ['Session', 'session']].map(([label, key]) => (
              <div key={key}>
                <label className="text-xs block mb-1" style={{ color: 'var(--muted)' }}>{label}</label>
                <input required className={inp} style={inpStyle}
                  value={form[key as keyof typeof form]}
                  onChange={e => setForm({ ...form, [key]: e.target.value })}
                  onFocus={e => (e.target.style.borderColor = 'var(--accent)')}
                  onBlur={e => (e.target.style.borderColor = 'var(--border)')} />
              </div>
            ))}
            <button type="submit" disabled={loading}
              className="w-full font-semibold py-2.5 rounded-lg text-sm disabled:opacity-50"
              style={{ backgroundColor: 'var(--accent)', color: 'var(--ink)' }}>
              {loading ? 'Creating...' : 'Create Course'}
            </button>
          </form>
        </div>
      )}

      {courses.length === 0
        ? <EmptyState icon={BookOpen} title="No courses yet" subtitle="Add your first course" />
        : <div className="space-y-3">
            {courses.map(c => (
              <div key={c.id} className="rounded-xl p-4 border" style={{ backgroundColor: 'var(--card)', borderColor: 'var(--border)' }}>
                <div className="flex items-start justify-between mb-3">
                  <div>
                    <p className="font-semibold text-sm" style={{ color: 'var(--soft)' }}>{c.title}</p>
                    <p className="text-xs mt-0.5" style={{ color: 'var(--muted)' }}>{c.session}</p>
                  </div>
                  <span className="mono text-xs px-2 py-0.5 rounded" style={{ color: 'var(--accent)', backgroundColor: 'rgba(200,241,53,0.1)' }}>{c.course_code}</span>
                </div>
                <select className="w-full rounded-lg px-3 py-2 text-sm border focus:outline-none"
                  style={{ backgroundColor: 'var(--surface)', borderColor: 'var(--border)', color: 'var(--soft)' }}
                  value={c.lecturer_id ?? ''} onChange={e => assign(c.id, e.target.value)}>
                  <option value="">— Assign lecturer —</option>
                  {lecturers.map(l => <option key={l.id} value={l.id}>{l.full_name}</option>)}
                </select>
              </div>
            ))}
          </div>
      }
    </Layout>
  );
}
EOF

cat > app/admin/students/page.tsx << 'EOF'
'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { getUser, requireAuth } from '@/lib/auth';
import Layout from '@/components/Layout';
import PageHeader from '@/components/PageHeader';
import EmptyState from '@/components/EmptyState';
import api from '@/lib/api';
import { Users } from 'lucide-react';
import { format } from 'date-fns';

interface Student { id: string; full_name: string; email: string; matric_number: string; created_at: string; }

export default function StudentsPage() {
  const router = useRouter();
  const [students, setStudents] = useState<Student[]>([]);
  const [search, setSearch] = useState('');

  useEffect(() => {
    if (!requireAuth(getUser(), router, ['admin'])) return;
    api.get('/admin/students').then(r => setStudents(r.data)).catch(() => {});
  }, [router]);

  const filtered = students.filter(s =>
    s.full_name.toLowerCase().includes(search.toLowerCase()) ||
    s.matric_number.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <Layout>
      <PageHeader title="Students" subtitle={`${students.length} registered`} />
      <input className="w-full rounded-xl px-4 py-3 text-sm mb-4 border focus:outline-none"
        style={{ backgroundColor: 'var(--card)', borderColor: 'var(--border)', color: 'var(--soft)' }}
        placeholder="Search by name or matric number..."
        value={search} onChange={e => setSearch(e.target.value)}
        onFocus={e => (e.target.style.borderColor = 'var(--accent)')}
        onBlur={e => (e.target.style.borderColor = 'var(--border)')} />
      {filtered.length === 0
        ? <EmptyState icon={Users} title="No students found" subtitle="Students appear once registered by a lecturer" />
        : <div className="space-y-2">
            {filtered.map((s, i) => (
              <div key={s.id} className={`rounded-xl p-4 border flex items-center justify-between fade-up delay-${Math.min(i+1,4) as 1|2|3|4}`}
                style={{ backgroundColor: 'var(--card)', borderColor: 'var(--border)' }}>
                <div>
                  <p className="font-semibold text-sm" style={{ color: 'var(--soft)' }}>{s.full_name}</p>
                  <p className="text-xs mt-0.5" style={{ color: 'var(--muted)' }}>{s.email}</p>
                </div>
                <div className="text-right">
                  <p className="mono text-xs" style={{ color: 'var(--accent)' }}>{s.matric_number}</p>
                  <p className="text-xs mt-0.5" style={{ color: 'var(--muted)' }}>{s.created_at ? format(new Date(s.created_at), 'dd MMM yy') : ''}</p>
                </div>
              </div>
            ))}
          </div>
      }
    </Layout>
  );
}
EOF

# ── LECTURER ────────────────────────────────────────────────────
cat > app/lecturer/page.tsx << 'EOF'
'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { getUser, requireAuth } from '@/lib/auth';
import Layout from '@/components/Layout';
import StatCard from '@/components/StatCard';
import PageHeader from '@/components/PageHeader';
import api from '@/lib/api';
import { BookOpen } from 'lucide-react';

interface Course { id: string; title: string; course_code: string; session: string; }

export default function LecturerDashboard() {
  const router = useRouter();
  const [courses, setCourses] = useState<Course[]>([]);
  const user = getUser();

  useEffect(() => {
    if (!requireAuth(getUser(), router, ['lecturer', 'admin'])) return;
    api.get('/lecturer/courses').then(r => setCourses(r.data)).catch(() => {});
  }, [router]);

  return (
    <Layout>
      <PageHeader title={`Hi, ${(user?.name ?? user?.full_name ?? '').split(' ')[0]} 👋`} subtitle="Your teaching overview" />
      <div className="grid grid-cols-2 gap-3 mb-6">
        <StatCard label="My Courses" value={courses.length} icon={BookOpen} accent />
      </div>
      <h2 className="text-xs font-semibold uppercase tracking-widest mb-3" style={{ color: 'var(--muted)' }}>Your Courses</h2>
      <div className="space-y-3">
        {courses.map(c => (
          <button key={c.id} onClick={() => router.push(`/lecturer/courses/${c.id}`)}
            className="w-full rounded-xl p-4 border text-left transition-all group"
            style={{ backgroundColor: 'var(--card)', borderColor: 'var(--border)' }}
            onMouseEnter={e => (e.currentTarget.style.borderColor = 'rgba(200,241,53,0.4)')}
            onMouseLeave={e => (e.currentTarget.style.borderColor = 'var(--border)')}>
            <div className="flex items-center justify-between">
              <p className="font-semibold text-sm" style={{ color: 'var(--soft)' }}>{c.title}</p>
              <span className="mono text-xs px-2 py-0.5 rounded" style={{ color: 'var(--accent)', backgroundColor: 'rgba(200,241,53,0.1)' }}>{c.course_code}</span>
            </div>
            <p className="text-xs mt-1" style={{ color: 'var(--muted)' }}>{c.session}</p>
          </button>
        ))}
      </div>
    </Layout>
  );
}
EOF

mkdir -p "app/lecturer/courses/[courseId]"
cat > "app/lecturer/courses/[courseId]/page.tsx" << 'EOF'
'use client';
import { useEffect, useState } from 'react';
import { useRouter, useParams } from 'next/navigation';
import { getUser, requireAuth } from '@/lib/auth';
import Layout from '@/components/Layout';
import PageHeader from '@/components/PageHeader';
import ProjectCard from '@/components/ProjectCard';
import EmptyState from '@/components/EmptyState';
import api from '@/lib/api';
import { FolderOpen, Users } from 'lucide-react';

export default function CourseDetail() {
  const router = useRouter();
  const { courseId } = useParams<{ courseId: string }>();
  const [data, setData] = useState<{ course?: { title: string; course_code: string; session: string }; projects?: unknown[]; students?: { id: string; full_name: string; email: string; matric_number: string }[] } | null>(null);
  const [tab, setTab] = useState<'projects' | 'students'>('projects');

  useEffect(() => {
    if (!requireAuth(getUser(), router, ['lecturer', 'admin'])) return;
    api.get(`/lecturer/courses/${courseId}`).then(r => setData(r.data)).catch(() => {});
  }, [courseId, router]);

  if (!data) return <Layout><p className="text-sm" style={{ color: 'var(--muted)' }}>Loading...</p></Layout>;

  return (
    <Layout>
      <button onClick={() => router.back()} className="text-xs mb-4" style={{ color: 'var(--muted)' }}>← Back</button>
      <PageHeader title={data.course?.title ?? ''} subtitle={`${data.course?.course_code} · ${data.course?.session}`} />
      <div className="flex gap-2 mb-5">
        {(['projects', 'students'] as const).map(t => (
          <button key={t} onClick={() => setTab(t)}
            className="px-4 py-2 rounded-lg text-sm font-medium capitalize transition-all border"
            style={tab === t
              ? { backgroundColor: 'var(--accent)', color: 'var(--ink)', borderColor: 'var(--accent)' }
              : { backgroundColor: 'transparent', color: 'var(--muted)', borderColor: 'var(--border)' }}>
            {t} ({t === 'projects' ? data.projects?.length ?? 0 : data.students?.length ?? 0})
          </button>
        ))}
      </div>
      {tab === 'projects' && (
        !data.projects?.length
          ? <EmptyState icon={FolderOpen} title="No projects yet" subtitle="Students haven't submitted yet" />
          : <div className="space-y-3">{(data.projects as Parameters<typeof ProjectCard>[0]['project'][]).map((p: Parameters<typeof ProjectCard>[0]['project']) => <ProjectCard key={(p as {id:string}).id} project={p} href={`/lecturer/projects/${(p as {id:string}).id}`} />)}</div>
      )}
      {tab === 'students' && (
        !data.students?.length
          ? <EmptyState icon={Users} title="No students enrolled" subtitle="Register students from the sidebar" />
          : <div className="space-y-2">
              {data.students?.map(s => (
                <div key={s.id} className="rounded-xl p-4 border flex items-center justify-between"
                  style={{ backgroundColor: 'var(--card)', borderColor: 'var(--border)' }}>
                  <div>
                    <p className="font-semibold text-sm" style={{ color: 'var(--soft)' }}>{s.full_name}</p>
                    <p className="text-xs" style={{ color: 'var(--muted)' }}>{s.email}</p>
                  </div>
                  <span className="mono text-xs" style={{ color: 'var(--accent)' }}>{s.matric_number}</span>
                </div>
              ))}
            </div>
      )}
    </Layout>
  );
}
EOF

cat > app/lecturer/projects/page.tsx << 'EOF'
'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { getUser, requireAuth } from '@/lib/auth';
import Layout from '@/components/Layout';
import PageHeader from '@/components/PageHeader';
import ProjectCard from '@/components/ProjectCard';
import EmptyState from '@/components/EmptyState';
import api from '@/lib/api';
import { FolderOpen, Search } from 'lucide-react';

export default function LecturerProjects() {
  const router = useRouter();
  const [projects, setProjects] = useState<unknown[]>([]);
  const [search, setSearch] = useState('');

  useEffect(() => {
    if (!requireAuth(getUser(), router, ['lecturer', 'admin'])) return;
    fetchProjects();
  }, [router]);

  const fetchProjects = (q = '') =>
    api.get('/lecturer/projects', { params: q ? { search: q } : {} })
      .then(r => setProjects(r.data)).catch(() => {});

  return (
    <Layout>
      <PageHeader title="All Projects" subtitle="Browse and grade submissions" />
      <div className="relative mb-5">
        <Search size={15} className="absolute left-4 top-1/2 -translate-y-1/2" style={{ color: 'var(--muted)' }} />
        <input className="w-full rounded-xl pl-10 pr-4 py-3 text-sm border focus:outline-none"
          style={{ backgroundColor: 'var(--card)', borderColor: 'var(--border)', color: 'var(--soft)' }}
          placeholder="Search by project title..."
          value={search}
          onChange={e => { setSearch(e.target.value); fetchProjects(e.target.value); }}
          onFocus={e => (e.target.style.borderColor = 'var(--accent)')}
          onBlur={e => (e.target.style.borderColor = 'var(--border)')} />
      </div>
      {projects.length === 0
        ? <EmptyState icon={FolderOpen} title="No projects found" subtitle="Projects appear here once students submit" />
        : <div className="space-y-3">{projects.map((p: unknown) => <ProjectCard key={(p as {id:string}).id} project={p as Parameters<typeof ProjectCard>[0]['project']} href={`/lecturer/projects/${(p as {id:string}).id}`} />)}</div>
      }
    </Layout>
  );
}
EOF

mkdir -p "app/lecturer/projects/[projectId]"
cat > "app/lecturer/projects/[projectId]/page.tsx" << 'EOF'
'use client';
import { useEffect, useState } from 'react';
import { useRouter, useParams } from 'next/navigation';
import { getUser, requireAuth } from '@/lib/auth';
import Layout from '@/components/Layout';
import PageHeader from '@/components/PageHeader';
import api from '@/lib/api';
import toast from 'react-hot-toast';
import { FileText, Archive, Github, Send, ExternalLink } from 'lucide-react';
import { format } from 'date-fns';

const GRADES = ['A','B','C','D','E','F'];
const gradeColors: Record<string,(s:string)=>React.CSSProperties> = {
  A: () => ({ color:'#4ade80', backgroundColor:'rgba(74,222,128,0.1)', borderColor:'rgba(74,222,128,0.3)' }),
  B: () => ({ color:'var(--accent)', backgroundColor:'rgba(200,241,53,0.1)', borderColor:'rgba(200,241,53,0.3)' }),
  C: () => ({ color:'#60a5fa', backgroundColor:'rgba(96,165,250,0.1)', borderColor:'rgba(96,165,250,0.3)' }),
  D: () => ({ color:'#facc15', backgroundColor:'rgba(250,204,21,0.1)', borderColor:'rgba(250,204,21,0.3)' }),
  E: () => ({ color:'#fb923c', backgroundColor:'rgba(251,146,60,0.1)', borderColor:'rgba(251,146,60,0.3)' }),
  F: () => ({ color:'#f87171', backgroundColor:'rgba(248,113,113,0.1)', borderColor:'rgba(248,113,113,0.3)' }),
};

interface Project {
  title: string; description?: string; session: string; pdf_url?: string; zip_url?: string; github_link?: string; created_at?: string;
  courses?: { course_code: string }; users?: { full_name: string; matric_number: string };
  grades?: { grade: string }; comments?: { id:string; content:string; created_at:string; users?: { full_name:string; role:string } }[];
}

export default function LecturerProjectDetail() {
  const router = useRouter();
  const { projectId } = useParams<{ projectId: string }>();
  const [project, setProject] = useState<Project | null>(null);
  const [comment, setComment] = useState('');
  const [grade, setGrade] = useState('');

  useEffect(() => {
    if (!requireAuth(getUser(), router, ['lecturer', 'admin'])) return;
    load();
  }, [projectId, router]);

  const load = () => api.get(`/projects/${projectId}`)
    .then(r => { setProject(r.data); setGrade(r.data.grades?.grade ?? ''); })
    .catch(() => { toast.error('Not found'); router.back(); });

  const saveGrade = () => api.put(`/lecturer/projects/${projectId}/grade`, { grade })
    .then(() => { toast.success('Grade saved'); load(); }).catch(() => toast.error('Failed'));

  const postComment = async () => {
    if (!comment.trim()) return;
    try { await api.post(`/projects/${projectId}/comments`, { content: comment }); setComment(''); load(); }
    catch { toast.error('Failed'); }
  };

  if (!project) return <Layout><p className="text-sm" style={{ color:'var(--muted)' }}>Loading...</p></Layout>;

  const card = "rounded-xl p-4 border";
  const cardStyle = { backgroundColor:'var(--card)', borderColor:'var(--border)' };

  return (
    <Layout>
      <button onClick={() => router.back()} className="text-xs mb-4" style={{ color:'var(--muted)' }}>← Back</button>
      <PageHeader title={project.title} subtitle={`${project.courses?.course_code} · ${project.session}`} />
      <div className="space-y-4">
        <div className={card} style={cardStyle}>
          <p className="text-xs mb-1" style={{ color:'var(--muted)' }}>Submitted by</p>
          <p className="font-semibold" style={{ color:'var(--soft)' }}>{project.users?.full_name}</p>
          <p className="mono text-xs" style={{ color:'var(--accent)' }}>{project.users?.matric_number}</p>
          {project.created_at && <p className="text-xs mt-1" style={{ color:'var(--muted)' }}>{format(new Date(project.created_at),'dd MMM yyyy · HH:mm')}</p>}
        </div>

        {project.description && (
          <div className={card} style={cardStyle}>
            <p className="text-xs mb-2" style={{ color:'var(--muted)' }}>Description</p>
            <p className="text-sm leading-relaxed" style={{ color:'var(--soft)' }}>{project.description}</p>
          </div>
        )}

        <div className={card} style={cardStyle}>
          <p className="text-xs mb-3" style={{ color:'var(--muted)' }}>Files & Links</p>
          <div className="flex flex-wrap gap-2">
            {project.pdf_url && <a href={project.pdf_url} target="_blank" rel="noopener noreferrer" className="flex items-center gap-2 px-3 py-2 rounded-lg text-sm border transition-all" style={{ backgroundColor:'var(--surface)', borderColor:'var(--border)', color:'var(--soft)' }}><FileText size={14} style={{ color:'var(--accent)' }} />PDF <ExternalLink size={12} style={{ color:'var(--muted)' }} /></a>}
            {project.zip_url && <a href={project.zip_url} target="_blank" rel="noopener noreferrer" className="flex items-center gap-2 px-3 py-2 rounded-lg text-sm border transition-all" style={{ backgroundColor:'var(--surface)', borderColor:'var(--border)', color:'var(--soft)' }}><Archive size={14} style={{ color:'var(--accent)' }} />ZIP <ExternalLink size={12} style={{ color:'var(--muted)' }} /></a>}
            {project.github_link && <a href={project.github_link} target="_blank" rel="noopener noreferrer" className="flex items-center gap-2 px-3 py-2 rounded-lg text-sm border transition-all" style={{ backgroundColor:'var(--surface)', borderColor:'var(--border)', color:'var(--soft)' }}><Github size={14} style={{ color:'var(--accent)' }} />GitHub <ExternalLink size={12} style={{ color:'var(--muted)' }} /></a>}
          </div>
        </div>

        <div className={card} style={cardStyle}>
          <p className="text-xs mb-3" style={{ color:'var(--muted)' }}>Grade</p>
          <div className="flex gap-2 flex-wrap mb-3">
            {GRADES.map(g => (
              <button key={g} onClick={() => setGrade(g)}
                className="w-10 h-10 rounded-lg border mono font-bold text-sm transition-all"
                style={grade===g ? gradeColors[g]?.(g) ?? {} : { backgroundColor:'var(--surface)', borderColor:'var(--border)', color:'var(--muted)' }}>
                {g}
              </button>
            ))}
          </div>
          <button onClick={saveGrade} disabled={!grade}
            className="px-4 py-2 rounded-lg text-sm font-semibold disabled:opacity-40"
            style={{ backgroundColor:'var(--accent)', color:'var(--ink)' }}>Save Grade</button>
        </div>

        <div className={card} style={cardStyle}>
          <p className="text-xs mb-3" style={{ color:'var(--muted)' }}>Comments ({project.comments?.length ?? 0})</p>
          <div className="space-y-3 mb-4 max-h-64 overflow-y-auto">
            {project.comments?.map(c => (
              <div key={c.id} className="rounded-lg p-3 border" style={{ backgroundColor:'var(--surface)', borderColor:'var(--border)' }}>
                <div className="flex items-center gap-2 mb-1">
                  <span className="text-xs font-semibold" style={{ color:'var(--soft)' }}>{c.users?.full_name}</span>
                  <span className="mono text-xs px-1.5 py-0.5 rounded" style={c.users?.role==='lecturer' ? { backgroundColor:'rgba(200,241,53,0.1)', color:'var(--accent)' } : { backgroundColor:'var(--border)', color:'var(--muted)' }}>{c.users?.role}</span>
                </div>
                <p className="text-sm" style={{ color:'var(--soft)' }}>{c.content}</p>
                {c.created_at && <p className="text-xs mt-1" style={{ color:'var(--muted)' }}>{format(new Date(c.created_at),'dd MMM · HH:mm')}</p>}
              </div>
            ))}
          </div>
          <div className="flex gap-2">
            <input className="flex-1 rounded-lg px-4 py-2.5 text-sm border focus:outline-none"
              style={{ backgroundColor:'var(--surface)', borderColor:'var(--border)', color:'var(--soft)' }}
              placeholder="Leave a comment..." value={comment}
              onChange={e => setComment(e.target.value)}
              onKeyDown={e => e.key==='Enter' && postComment()}
              onFocus={e => (e.target.style.borderColor='var(--accent)')}
              onBlur={e => (e.target.style.borderColor='var(--border)')} />
            <button onClick={postComment} disabled={!comment.trim()}
              className="p-2.5 rounded-lg disabled:opacity-40" style={{ backgroundColor:'var(--accent)', color:'var(--ink)' }}>
              <Send size={16} />
            </button>
          </div>
        </div>
      </div>
    </Layout>
  );
}
EOF

mkdir -p "app/lecturer/students/register"
cat > "app/lecturer/students/register/page.tsx" << 'EOF'
'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { getUser, requireAuth } from '@/lib/auth';
import Layout from '@/components/Layout';
import PageHeader from '@/components/PageHeader';
import api from '@/lib/api';
import toast from 'react-hot-toast';
import { UserPlus, Upload } from 'lucide-react';

interface Course { id: string; title: string; course_code: string; }

export default function RegisterStudents() {
  const router = useRouter();
  const [courses, setCourses] = useState<Course[]>([]);
  const [tab, setTab] = useState<'single'|'bulk'>('single');
  const [form, setForm] = useState({ full_name:'', email:'', matric_number:'', course_id:'' });
  const [csvFile, setCsvFile] = useState<File|null>(null);
  const [courseId, setCourseId] = useState('');
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (!requireAuth(getUser(), router, ['lecturer','admin'])) return;
    api.get('/lecturer/courses').then(r => setCourses(r.data)).catch(() => {});
  }, [router]);

  const inp = "w-full rounded-lg px-4 py-2.5 text-sm border focus:outline-none";
  const inpStyle = { backgroundColor:'var(--surface)', borderColor:'var(--border)', color:'var(--soft)' };

  const handleSingle = async (e: React.FormEvent) => {
    e.preventDefault(); setLoading(true);
    try { await api.post('/lecturer/students/register', form); toast.success('Student registered!'); setForm({ full_name:'', email:'', matric_number:'', course_id:'' }); }
    catch (err: unknown) { toast.error((err as {response?:{data?:{error?:string}}})?.response?.data?.error ?? 'Failed'); }
    finally { setLoading(false); }
  };

  const handleBulk = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!csvFile || !courseId) return toast.error('Select course and upload CSV');
    setLoading(true);
    const fd = new FormData(); fd.append('file', csvFile); fd.append('course_id', courseId);
    try {
      const { data } = await api.post('/lecturer/students/bulk', fd);
      toast.success(`${data.registered} students registered!`);
      if (data.errors?.length) toast.error(`${data.errors.length} failed`);
      setCsvFile(null); setCourseId('');
    } catch { toast.error('Bulk upload failed'); }
    finally { setLoading(false); }
  };

  const CourseSelect = ({ value, onChange }: { value: string; onChange: (v:string)=>void }) => (
    <div>
      <label className="text-xs block mb-1" style={{ color:'var(--muted)' }}>Course</label>
      <select required className="w-full rounded-lg px-4 py-2.5 text-sm border focus:outline-none"
        style={inpStyle} value={value} onChange={e => onChange(e.target.value)}>
        <option value="">— Select course —</option>
        {courses.map(c => <option key={c.id} value={c.id}>{c.title} ({c.course_code})</option>)}
      </select>
    </div>
  );

  return (
    <Layout>
      <PageHeader title="Register Students" subtitle="Add students to your courses" />
      <div className="flex gap-2 mb-5">
        {(['single','bulk'] as const).map(t => (
          <button key={t} onClick={() => setTab(t)}
            className="px-4 py-2 rounded-lg text-sm font-medium border transition-all"
            style={tab===t ? { backgroundColor:'var(--accent)', color:'var(--ink)', borderColor:'var(--accent)' } : { backgroundColor:'transparent', color:'var(--muted)', borderColor:'var(--border)' }}>
            {t==='single' ? '+ Single' : '⬆ Bulk CSV'}
          </button>
        ))}
      </div>

      {tab==='single' && (
        <div className="rounded-xl p-5 border" style={{ backgroundColor:'var(--card)', borderColor:'var(--border)' }}>
          <form onSubmit={handleSingle} className="space-y-4">
            {[['Full Name','full_name'],['Email','email'],['Matric Number','matric_number']].map(([label,key]) => (
              <div key={key}>
                <label className="text-xs block mb-1" style={{ color:'var(--muted)' }}>{label}</label>
                <input required className={inp} style={inpStyle}
                  value={form[key as keyof typeof form]} onChange={e => setForm({...form,[key]:e.target.value})}
                  onFocus={e=>(e.target.style.borderColor='var(--accent)')} onBlur={e=>(e.target.style.borderColor='var(--border)')} />
              </div>
            ))}
            <CourseSelect value={form.course_id} onChange={v => setForm({...form,course_id:v})} />
            <button type="submit" disabled={loading}
              className="w-full font-semibold py-3 rounded-lg text-sm flex items-center justify-center gap-2 disabled:opacity-50"
              style={{ backgroundColor:'var(--accent)', color:'var(--ink)' }}>
              <UserPlus size={15} />{loading ? 'Registering...' : 'Register Student'}
            </button>
          </form>
        </div>
      )}

      {tab==='bulk' && (
        <div className="rounded-xl p-5 border" style={{ backgroundColor:'var(--card)', borderColor:'var(--border)' }}>
          <div className="rounded-xl p-4 mb-4 text-center border border-dashed" style={{ backgroundColor:'var(--surface)', borderColor:'var(--border)' }}>
            <p className="text-xs mb-1" style={{ color:'var(--muted)' }}>CSV format:</p>
            <p className="mono text-xs" style={{ color:'var(--accent)' }}>full_name, email, matric_number</p>
          </div>
          <form onSubmit={handleBulk} className="space-y-4">
            <CourseSelect value={courseId} onChange={setCourseId} />
            <div>
              <label className="text-xs block mb-1" style={{ color:'var(--muted)' }}>Upload CSV</label>
              <label className="flex items-center gap-3 w-full rounded-lg px-4 py-3 border cursor-pointer transition-all"
                style={{ backgroundColor:'var(--surface)', borderColor:'var(--border)' }}
                onMouseEnter={e=>(e.currentTarget.style.borderColor='rgba(200,241,53,0.4)')}
                onMouseLeave={e=>(e.currentTarget.style.borderColor='var(--border)')}>
                <Upload size={15} style={{ color:'var(--muted)' }} />
                <span className="text-sm" style={{ color:'var(--muted)' }}>{csvFile ? csvFile.name : 'Choose CSV file...'}</span>
                <input type="file" accept=".csv" className="hidden" onChange={e => setCsvFile(e.target.files?.[0] ?? null)} />
              </label>
            </div>
            <button type="submit" disabled={loading}
              className="w-full font-semibold py-3 rounded-lg text-sm disabled:opacity-50"
              style={{ backgroundColor:'var(--accent)', color:'var(--ink)' }}>
              {loading ? 'Uploading...' : 'Bulk Register'}
            </button>
          </form>
        </div>
      )}
    </Layout>
  );
}
EOF

# ── STUDENT ─────────────────────────────────────────────────────
cat > app/student/page.tsx << 'EOF'
'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { getUser, requireAuth } from '@/lib/auth';
import Layout from '@/components/Layout';
import PageHeader from '@/components/PageHeader';
import ProjectCard from '@/components/ProjectCard';
import api from '@/lib/api';
import { Upload } from 'lucide-react';

export default function StudentDashboard() {
  const router = useRouter();
  const [projects, setProjects] = useState<unknown[]>([]);
  const user = getUser();

  useEffect(() => {
    if (!requireAuth(getUser(), router, ['student'])) return;
    api.get('/projects').then(r => setProjects(r.data.slice(0,5))).catch(()=>{});
  }, [router]);

  return (
    <Layout>
      <PageHeader title={`Hi, ${(user?.name??user?.full_name??'').split(' ')[0]} 👋`} subtitle="Your project hub" />
      <div className="rounded-xl p-4 border mb-6 flex items-center gap-4"
        style={{ backgroundColor:'var(--card)', borderColor:'rgba(200,241,53,0.2)' }}>
        <div className="w-10 h-10 rounded-lg flex items-center justify-center flex-shrink-0"
          style={{ backgroundColor:'rgba(200,241,53,0.1)' }}>
          <Upload size={18} style={{ color:'var(--accent)' }} />
        </div>
        <div className="flex-1">
          <p className="font-semibold text-sm" style={{ color:'var(--soft)' }}>Submit your project</p>
          <p className="text-xs" style={{ color:'var(--muted)' }}>Help others by sharing your work</p>
        </div>
        <button onClick={() => router.push('/student/upload')}
          className="flex-shrink-0 px-4 py-2 rounded-lg text-sm font-semibold"
          style={{ backgroundColor:'var(--accent)', color:'var(--ink)' }}>Upload</button>
      </div>
      <h2 className="text-xs font-semibold uppercase tracking-widest mb-3" style={{ color:'var(--muted)' }}>Recent Projects</h2>
      <div className="space-y-3 pb-20">
        {projects.map((p:unknown) => <ProjectCard key={(p as {id:string}).id} project={p as Parameters<typeof ProjectCard>[0]['project']} />)}
      </div>
    </Layout>
  );
}
EOF

cat > app/student/projects/page.tsx << 'EOF'
'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { getUser, requireAuth } from '@/lib/auth';
import Layout from '@/components/Layout';
import PageHeader from '@/components/PageHeader';
import ProjectCard from '@/components/ProjectCard';
import EmptyState from '@/components/EmptyState';
import api from '@/lib/api';
import { Search, FolderOpen } from 'lucide-react';

const SESSIONS = ['2024/2025','2023/2024','2022/2023','2021/2022'];

export default function BrowseProjects() {
  const router = useRouter();
  const [projects, setProjects] = useState<unknown[]>([]);
  const [search, setSearch] = useState('');
  const [session, setSession] = useState('');

  useEffect(() => {
    if (!requireAuth(getUser(), router, ['student'])) return;
    load();
  }, [session, router]);

  const load = (q='') => {
    const endpoint = q ? '/projects/search' : '/projects';
    const params = q ? { q } : (session ? { session } : {});
    api.get(endpoint, { params }).then(r => setProjects(r.data)).catch(()=>{});
  };

  return (
    <Layout>
      <PageHeader title="Browse Projects" subtitle="Reference past work from your courses" />
      <div className="flex gap-2 mb-4">
        <div className="relative flex-1">
          <Search size={15} className="absolute left-4 top-1/2 -translate-y-1/2" style={{ color:'var(--muted)' }} />
          <input className="w-full rounded-xl pl-10 pr-4 py-3 text-sm border focus:outline-none"
            style={{ backgroundColor:'var(--card)', borderColor:'var(--border)', color:'var(--soft)' }}
            placeholder="Search project titles..."
            value={search}
            onChange={e => { setSearch(e.target.value); load(e.target.value); }}
            onFocus={e=>(e.target.style.borderColor='var(--accent)')}
            onBlur={e=>(e.target.style.borderColor='var(--border)')} />
        </div>
        <select className="rounded-xl px-3 py-2 text-sm border focus:outline-none"
          style={{ backgroundColor:'var(--card)', borderColor:'var(--border)', color:'var(--soft)' }}
          value={session} onChange={e => setSession(e.target.value)}>
          <option value="">All sessions</option>
          {SESSIONS.map(s => <option key={s} value={s}>{s}</option>)}
        </select>
      </div>
      {projects.length===0
        ? <EmptyState icon={FolderOpen} title="No projects found" subtitle="Try a different search or filter" />
        : <div className="space-y-3 pb-20">{projects.map((p:unknown) => <ProjectCard key={(p as {id:string}).id} project={p as Parameters<typeof ProjectCard>[0]['project']} />)}</div>
      }
    </Layout>
  );
}
EOF

mkdir -p "app/student/projects/[projectId]"
cat > "app/student/projects/[projectId]/page.tsx" << 'EOF'
'use client';
import { useEffect, useState } from 'react';
import { useRouter, useParams } from 'next/navigation';
import { getUser, requireAuth } from '@/lib/auth';
import Layout from '@/components/Layout';
import PageHeader from '@/components/PageHeader';
import api from '@/lib/api';
import toast from 'react-hot-toast';
import { FileText, Archive, Github, Send, ExternalLink } from 'lucide-react';
import { format } from 'date-fns';

const gradeColors: Record<string,React.CSSProperties> = {
  A:{color:'#4ade80',backgroundColor:'rgba(74,222,128,0.1)'},
  B:{color:'#C8F135',backgroundColor:'rgba(200,241,53,0.1)'},
  C:{color:'#60a5fa',backgroundColor:'rgba(96,165,250,0.1)'},
  D:{color:'#facc15',backgroundColor:'rgba(250,204,21,0.1)'},
  E:{color:'#fb923c',backgroundColor:'rgba(251,146,60,0.1)'},
  F:{color:'#f87171',backgroundColor:'rgba(248,113,113,0.1)'},
};

interface Project {
  title:string; description?:string; session:string; pdf_url?:string; zip_url?:string; github_link?:string; created_at?:string;
  courses?:{course_code:string}; users?:{full_name:string;matric_number:string};
  grades?:{grade:string}; comments?:{id:string;content:string;created_at:string;users?:{full_name:string;role:string}}[];
}

export default function StudentProjectDetail() {
  const router = useRouter();
  const { projectId } = useParams<{ projectId:string }>();
  const [project, setProject] = useState<Project|null>(null);
  const [comment, setComment] = useState('');

  useEffect(() => {
    if (!requireAuth(getUser(), router, ['student'])) return;
    api.get(`/projects/${projectId}`).then(r => setProject(r.data)).catch(()=>{ toast.error('Not found'); router.back(); });
  }, [projectId, router]);

  const postComment = async () => {
    if (!comment.trim()) return;
    try { await api.post(`/projects/${projectId}/comments`,{content:comment}); setComment(''); const {data}=await api.get(`/projects/${projectId}`); setProject(data); }
    catch { toast.error('Failed'); }
  };

  if (!project) return <Layout><p className="text-sm" style={{color:'var(--muted)'}}>Loading...</p></Layout>;
  const grade = project.grades?.grade;
  const card = "rounded-xl p-4 border";
  const cardStyle = { backgroundColor:'var(--card)', borderColor:'var(--border)' };

  return (
    <Layout>
      <button onClick={()=>router.back()} className="text-xs mb-4" style={{color:'var(--muted)'}}>← Back</button>
      <div className="flex items-start gap-2 mb-1">
        <h1 className="text-xl font-bold flex-1" style={{color:'var(--soft)'}}>{project.title}</h1>
        {grade && <span className="mono text-sm font-bold px-3 py-1 rounded-lg flex-shrink-0" style={gradeColors[grade]}>{grade}</span>}
      </div>
      <p className="text-sm mb-5" style={{color:'var(--muted)'}}>{project.courses?.course_code} · {project.session}</p>
      <div className="space-y-4 pb-20">
        <div className={card} style={cardStyle}>
          <p className="text-xs mb-1" style={{color:'var(--muted)'}}>Submitted by</p>
          <p className="font-semibold" style={{color:'var(--soft)'}}>{project.users?.full_name}</p>
          <p className="mono text-xs" style={{color:'var(--accent)'}}>{project.users?.matric_number}</p>
          {project.created_at && <p className="text-xs mt-1" style={{color:'var(--muted)'}}>{format(new Date(project.created_at),'dd MMM yyyy')}</p>}
        </div>
        {project.description && (
          <div className={card} style={cardStyle}>
            <p className="text-xs mb-2" style={{color:'var(--muted)'}}>About this project</p>
            <p className="text-sm leading-relaxed" style={{color:'var(--soft)'}}>{project.description}</p>
          </div>
        )}
        <div className={card} style={cardStyle}>
          <p className="text-xs mb-3" style={{color:'var(--muted)'}}>Files & Links</p>
          <div className="flex flex-wrap gap-2">
            {project.pdf_url && <a href={project.pdf_url} target="_blank" rel="noopener noreferrer" className="flex items-center gap-2 px-3 py-2 rounded-lg text-sm border" style={{backgroundColor:'var(--surface)',borderColor:'var(--border)',color:'var(--soft)'}}><FileText size={14} style={{color:'var(--accent)'}}/> PDF <ExternalLink size={12} style={{color:'var(--muted)'}}/></a>}
            {project.zip_url && <a href={project.zip_url} target="_blank" rel="noopener noreferrer" className="flex items-center gap-2 px-3 py-2 rounded-lg text-sm border" style={{backgroundColor:'var(--surface)',borderColor:'var(--border)',color:'var(--soft)'}}><Archive size={14} style={{color:'var(--accent)'}}/> ZIP <ExternalLink size={12} style={{color:'var(--muted)'}}/></a>}
            {project.github_link && <a href={project.github_link} target="_blank" rel="noopener noreferrer" className="flex items-center gap-2 px-3 py-2 rounded-lg text-sm border" style={{backgroundColor:'var(--surface)',borderColor:'var(--border)',color:'var(--soft)'}}><Github size={14} style={{color:'var(--accent)'}}/> GitHub <ExternalLink size={12} style={{color:'var(--muted)'}}/></a>}
          </div>
        </div>
        <div className={card} style={cardStyle}>
          <p className="text-xs mb-3" style={{color:'var(--muted)'}}>Discussion ({project.comments?.length??0})</p>
          <div className="space-y-3 mb-4 max-h-64 overflow-y-auto">
            {project.comments?.map(c=>(
              <div key={c.id} className="rounded-lg p-3 border" style={{backgroundColor:'var(--surface)',borderColor:'var(--border)'}}>
                <div className="flex items-center gap-2 mb-1">
                  <span className="text-xs font-semibold" style={{color:'var(--soft)'}}>{c.users?.full_name}</span>
                  <span className="mono text-xs px-1.5 py-0.5 rounded" style={c.users?.role==='lecturer'?{backgroundColor:'rgba(200,241,53,0.1)',color:'var(--accent)'}:{backgroundColor:'var(--border)',color:'var(--muted)'}}>{c.users?.role}</span>
                </div>
                <p className="text-sm" style={{color:'var(--soft)'}}>{c.content}</p>
                {c.created_at && <p className="text-xs mt-1" style={{color:'var(--muted)'}}>{format(new Date(c.created_at),'dd MMM · HH:mm')}</p>}
              </div>
            ))}
          </div>
          <div className="flex gap-2">
            <input className="flex-1 rounded-lg px-4 py-2.5 text-sm border focus:outline-none"
              style={{backgroundColor:'var(--surface)',borderColor:'var(--border)',color:'var(--soft)'}}
              placeholder="Add to discussion..." value={comment}
              onChange={e=>setComment(e.target.value)}
              onKeyDown={e=>e.key==='Enter'&&postComment()}
              onFocus={e=>(e.target.style.borderColor='var(--accent)')}
              onBlur={e=>(e.target.style.borderColor='var(--border)')} />
            <button onClick={postComment} disabled={!comment.trim()}
              className="p-2.5 rounded-lg disabled:opacity-40" style={{backgroundColor:'var(--accent)',color:'var(--ink)'}}>
              <Send size={16}/>
            </button>
          </div>
        </div>
      </div>
    </Layout>
  );
}
EOF

cat > app/student/upload/page.tsx << 'EOF'
'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { getUser, requireAuth } from '@/lib/auth';
import Layout from '@/components/Layout';
import PageHeader from '@/components/PageHeader';
import api from '@/lib/api';
import toast from 'react-hot-toast';
import { Upload, FileText, Archive, Github, X } from 'lucide-react';

interface Course { id:string; title:string; course_code:string; }
const SESSIONS = ['2024/2025','2023/2024','2022/2023','2021/2022'];

export default function UploadProject() {
  const router = useRouter();
  const [courses, setCourses] = useState<Course[]>([]);
  const [form, setForm] = useState({ title:'', description:'', course_id:'', session:'2024/2025', github_link:'' });
  const [pdfFile, setPdfFile] = useState<File|null>(null);
  const [zipFile, setZipFile] = useState<File|null>(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (!requireAuth(getUser(), router, ['student'])) return;
    // Load enrolled courses via enrollments
    api.get('/projects').then(r => {
      const map: Record<string,Course> = {};
      r.data.forEach((p: {course_id:string; courses:Course}) => {
        if (p.courses && !map[p.course_id]) map[p.course_id] = { id:p.course_id, ...p.courses };
      });
      setCourses(Object.values(map));
    }).catch(()=>{});
  }, [router]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!pdfFile && !zipFile && !form.github_link) return toast.error('Attach at least one file or GitHub link');
    setLoading(true);
    try {
      const fd = new FormData();
      Object.entries(form).forEach(([k,v]) => { if (v) fd.append(k,v); });
      if (pdfFile) fd.append('files', pdfFile);
      if (zipFile) fd.append('files', zipFile);
      await api.post('/projects', fd, { headers:{'Content-Type':'multipart/form-data'} });
      toast.success('Project uploaded!');
      router.push('/student/projects');
    } catch (err: unknown) {
      toast.error((err as {response?:{data?:{error?:string}}})?.response?.data?.error ?? 'Upload failed');
    } finally { setLoading(false); }
  };

  const inp = "w-full rounded-xl px-4 py-3 text-sm border focus:outline-none";
  const inpStyle = { backgroundColor:'var(--card)', borderColor:'var(--border)', color:'var(--soft)' };

  const FileInput = ({ label, icon:Icon, file, setFile, accept, types }:
    { label:string; icon:React.ElementType; file:File|null; setFile:(f:File|null)=>void; accept:string; types:string[] }) => (
    <div>
      <label className="text-xs block mb-1" style={{color:'var(--muted)'}}>{label}</label>
      {file ? (
        <div className="flex items-center gap-3 rounded-lg px-4 py-3 border" style={{backgroundColor:'var(--surface)',borderColor:'rgba(200,241,53,0.3)'}}>
          <Icon size={15} style={{color:'var(--accent)'}} />
          <span className="text-sm flex-1 truncate" style={{color:'var(--soft)'}}>{file.name}</span>
          <button type="button" onClick={()=>setFile(null)} style={{color:'var(--muted)'}}><X size={15}/></button>
        </div>
      ) : (
        <label className="flex items-center gap-3 w-full rounded-lg px-4 py-3 border cursor-pointer transition-all"
          style={{backgroundColor:'var(--surface)',borderColor:'var(--border)'}}
          onMouseEnter={e=>(e.currentTarget.style.borderColor='rgba(200,241,53,0.4)')}
          onMouseLeave={e=>(e.currentTarget.style.borderColor='var(--border)')}>
          <Icon size={15} style={{color:'var(--muted)'}} />
          <span className="text-sm" style={{color:'var(--muted)'}}>Choose {label}...</span>
          <input type="file" accept={accept} className="hidden"
            onChange={e => { const f=e.target.files?.[0]; if(f&&types.includes(f.type)) setFile(f); else toast.error('Invalid type'); }} />
        </label>
      )}
    </div>
  );

  return (
    <Layout>
      <PageHeader title="Upload Project" subtitle="Submit your work to CS-Vault" />
      <form onSubmit={handleSubmit} className="space-y-4 pb-24">
        <div>
          <label className="text-xs block mb-1" style={{color:'var(--muted)'}}>Project Title *</label>
          <input required className={inp} style={inpStyle} placeholder="e.g. Library Management System"
            value={form.title} onChange={e=>setForm({...form,title:e.target.value})}
            onFocus={e=>(e.target.style.borderColor='var(--accent)')} onBlur={e=>(e.target.style.borderColor='var(--border)')} />
        </div>
        <div>
          <label className="text-xs block mb-1" style={{color:'var(--muted)'}}>Description</label>
          <textarea rows={3} className={inp + ' resize-none'} style={inpStyle} placeholder="Brief description..."
            value={form.description} onChange={e=>setForm({...form,description:e.target.value})}
            onFocus={e=>(e.target.style.borderColor='var(--accent)')} onBlur={e=>(e.target.style.borderColor='var(--border)')} />
        </div>
        <div className="grid grid-cols-2 gap-3">
          <div>
            <label className="text-xs block mb-1" style={{color:'var(--muted)'}}>Course *</label>
            <select required className={inp} style={inpStyle}
              value={form.course_id} onChange={e=>setForm({...form,course_id:e.target.value})}>
              <option value="">Select...</option>
              {courses.map(c=><option key={c.id} value={c.id}>{c.course_code||c.title}</option>)}
            </select>
          </div>
          <div>
            <label className="text-xs block mb-1" style={{color:'var(--muted)'}}>Session *</label>
            <select required className={inp} style={inpStyle}
              value={form.session} onChange={e=>setForm({...form,session:e.target.value})}>
              {SESSIONS.map(s=><option key={s} value={s}>{s}</option>)}
            </select>
          </div>
        </div>
        <FileInput label="PDF Report" icon={FileText} file={pdfFile} setFile={setPdfFile}
          accept=".pdf" types={['application/pdf']} />
        <FileInput label="Source Code (ZIP)" icon={Archive} file={zipFile} setFile={setZipFile}
          accept=".zip" types={['application/zip','application/x-zip-compressed']} />
        <div>
          <label className="text-xs block mb-1 flex items-center gap-1" style={{color:'var(--muted)'}}><Github size={12}/> GitHub Link (optional)</label>
          <input className={inp + ' mono'} style={inpStyle} placeholder="https://github.com/username/repo"
            value={form.github_link} onChange={e=>setForm({...form,github_link:e.target.value})}
            onFocus={e=>(e.target.style.borderColor='var(--accent)')} onBlur={e=>(e.target.style.borderColor='var(--border)')} />
        </div>
        <button type="submit" disabled={loading}
          className="w-full font-bold py-4 rounded-xl text-sm flex items-center justify-center gap-2 disabled:opacity-50"
          style={{backgroundColor:'var(--accent)',color:'var(--ink)'}}>
          <Upload size={16}/>{loading ? 'Uploading...' : 'Submit Project'}
        </button>
      </form>
    </Layout>
  );
}
EOF

echo ""
echo "✅ ALL FILES CREATED SUCCESSFULLY!"
echo ""
echo "Now run:"
echo "  npm run dev"
echo ""
echo "Open http://localhost:3000"
echo "Login with ADMIN001 / Admin@123"
