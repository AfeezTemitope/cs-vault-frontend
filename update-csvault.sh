#!/bin/bash
# ============================================================
#  CS-VAULT — Major Update Script
#  Run this from INSIDE your cs-vault-frontend/ folder
#  (where package.json lives)
# ============================================================

echo "🚀 Starting CS-Vault major update..."

# ── 1. GLOBALS.CSS ───────────────────────────────────────────
cat > app/globals.css << 'EOF'
@import url('https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;500&display=swap');
@import "tailwindcss";

:root {
  --ink: #FFFFFF;
  --surface: #F8F9FC;
  --card: #FFFFFF;
  --border: #E4E7EF;
  --border-hover: #C5CBE0;
  --accent: #2D6BE4;
  --accent-dim: #1E55C4;
  --accent-light: #EEF3FD;
  --muted: #7B8299;
  --soft: #1A1D2E;
  --success: #16A34A;
  --warning: #D97706;
  --danger: #DC2626;
  --shadow: 0 1px 3px rgba(0,0,0,0.06), 0 1px 2px rgba(0,0,0,0.04);
  --shadow-md: 0 4px 12px rgba(0,0,0,0.08), 0 2px 4px rgba(0,0,0,0.04);
  --shadow-lg: 0 10px 30px rgba(0,0,0,0.10), 0 4px 8px rgba(0,0,0,0.06);
}

[data-theme="dark"] {
  --ink: #0D0F1A;
  --surface: #13151F;
  --card: #1A1D2E;
  --border: #252840;
  --border-hover: #363A5A;
  --accent: #4F8EF7;
  --accent-dim: #3A72D4;
  --accent-light: #1A2540;
  --muted: #7B8299;
  --soft: #E8EAF6;
  --shadow: 0 1px 3px rgba(0,0,0,0.3);
  --shadow-md: 0 4px 12px rgba(0,0,0,0.4);
  --shadow-lg: 0 10px 30px rgba(0,0,0,0.5);
}

* { box-sizing: border-box; margin: 0; padding: 0; }

body {
  background-color: var(--ink);
  color: var(--soft);
  font-family: 'Plus Jakarta Sans', sans-serif;
  font-size: 15px;
  line-height: 1.6;
  -webkit-font-smoothing: antialiased;
  transition: background-color 0.3s ease, color 0.3s ease;
}

.mono { font-family: 'JetBrains Mono', monospace; }

::-webkit-scrollbar { width: 5px; }
::-webkit-scrollbar-track { background: var(--surface); }
::-webkit-scrollbar-thumb { background: var(--border); border-radius: 4px; }

@keyframes fadeUp {
  from { opacity: 0; transform: translateY(18px); }
  to   { opacity: 1; transform: translateY(0); }
}
@keyframes fadeIn {
  from { opacity: 0; }
  to   { opacity: 1; }
}
@keyframes slideIn {
  from { opacity: 0; transform: translateX(-12px); }
  to   { opacity: 1; transform: translateX(0); }
}
@keyframes pulse-ring {
  0% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(45,107,228,0.4); }
  70% { transform: scale(1); box-shadow: 0 0 0 8px rgba(45,107,228,0); }
  100% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(45,107,228,0); }
}

.fade-up  { animation: fadeUp 0.5s ease forwards; }
.fade-in  { animation: fadeIn 0.4s ease forwards; }
.slide-in { animation: slideIn 0.4s ease forwards; }
.delay-1  { animation-delay: 0.08s; opacity: 0; }
.delay-2  { animation-delay: 0.16s; opacity: 0; }
.delay-3  { animation-delay: 0.24s; opacity: 0; }
.delay-4  { animation-delay: 0.32s; opacity: 0; }
.delay-5  { animation-delay: 0.40s; opacity: 0; }

.btn-primary {
  background: var(--accent);
  color: #fff;
  border: none;
  border-radius: 10px;
  padding: 12px 24px;
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
  display: inline-flex;
  align-items: center;
  gap: 8px;
  box-shadow: 0 2px 8px rgba(45,107,228,0.3);
}
.btn-primary:hover { background: var(--accent-dim); transform: translateY(-1px); box-shadow: 0 4px 16px rgba(45,107,228,0.4); }
.btn-primary:disabled { opacity: 0.5; cursor: not-allowed; transform: none; }

.btn-secondary {
  background: var(--surface);
  color: var(--soft);
  border: 1.5px solid var(--border);
  border-radius: 10px;
  padding: 11px 24px;
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
  display: inline-flex;
  align-items: center;
  gap: 8px;
}
.btn-secondary:hover { border-color: var(--border-hover); background: var(--accent-light); color: var(--accent); }

.card {
  background: var(--card);
  border: 1.5px solid var(--border);
  border-radius: 16px;
  box-shadow: var(--shadow);
  transition: all 0.2s ease;
}
.card:hover { box-shadow: var(--shadow-md); border-color: var(--border-hover); }

.input-field {
  width: 100%;
  background: var(--surface);
  border: 1.5px solid var(--border);
  border-radius: 10px;
  padding: 12px 16px;
  font-size: 15px;
  color: var(--soft);
  font-family: inherit;
  transition: all 0.2s ease;
  outline: none;
}
.input-field:focus { border-color: var(--accent); box-shadow: 0 0 0 3px rgba(45,107,228,0.12); }
.input-field::placeholder { color: var(--muted); }

.badge {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 4px 10px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 600;
}
.badge-blue { background: var(--accent-light); color: var(--accent); }
.badge-green { background: #ECFDF5; color: #16A34A; }
.badge-orange { background: #FFF7ED; color: #D97706; }
.badge-red { background: #FEF2F2; color: #DC2626; }
[data-theme="dark"] .badge-green { background: #052E16; color: #4ADE80; }
[data-theme="dark"] .badge-orange { background: #1C0F00; color: #FBB03B; }
[data-theme="dark"] .badge-red { background: #1F0000; color: #F87171; }
EOF

# ── 2. THEME HOOK ─────────────────────────────────────────────
cat > lib/useTheme.ts << 'EOF'
'use client';
import { useEffect, useState } from 'react';

export function useTheme() {
  const [theme, setTheme] = useState<'light' | 'dark'>('light');

  useEffect(() => {
    const saved = localStorage.getItem('cv-theme') as 'light' | 'dark' | null;
    const preferred = saved ?? 'light';
    setTheme(preferred);
    document.documentElement.setAttribute('data-theme', preferred);
  }, []);

  const toggle = () => {
    const next = theme === 'light' ? 'dark' : 'light';
    setTheme(next);
    localStorage.setItem('cv-theme', next);
    document.documentElement.setAttribute('data-theme', next);
  };

  return { theme, toggle };
}
EOF

# ── 3. THEME TOGGLE COMPONENT ─────────────────────────────────
cat > components/ThemeToggle.tsx << 'EOF'
'use client';
import { Sun, Moon } from 'lucide-react';
import { useTheme } from '@/lib/useTheme';

export default function ThemeToggle() {
  const { theme, toggle } = useTheme();
  return (
    <button onClick={toggle} aria-label="Toggle theme"
      style={{
        width: 38, height: 38, borderRadius: 10,
        border: '1.5px solid var(--border)',
        background: 'var(--surface)',
        color: 'var(--muted)',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        cursor: 'pointer', transition: 'all 0.2s ease',
      }}
      onMouseEnter={e => {
        (e.currentTarget as HTMLButtonElement).style.borderColor = 'var(--accent)';
        (e.currentTarget as HTMLButtonElement).style.color = 'var(--accent)';
      }}
      onMouseLeave={e => {
        (e.currentTarget as HTMLButtonElement).style.borderColor = 'var(--border)';
        (e.currentTarget as HTMLButtonElement).style.color = 'var(--muted)';
      }}>
      {theme === 'light' ? <Moon size={17} /> : <Sun size={17} />}
    </button>
  );
}
EOF

# ── 4. LAYOUT.TSX ─────────────────────────────────────────────
cat > components/Layout.tsx << 'EOF'
'use client';
import { useState, useEffect } from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { getUser, logout, User } from '@/lib/auth';
import ThemeToggle from './ThemeToggle';
import {
  LayoutDashboard, BookOpen, Upload, Search,
  Users, GraduationCap, LogOut, Menu, X,
  Settings, FolderOpen, UserPlus
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
    { href: '/lecturer/projects', label: 'Projects', icon: FolderOpen },
    { href: '/lecturer/students/register', label: 'Register Student', icon: UserPlus },
  ],
  student: [
    { href: '/student', label: 'Dashboard', icon: LayoutDashboard },
    { href: '/student/projects', label: 'Browse', icon: Search },
    { href: '/student/upload', label: 'Upload', icon: Upload },
  ],
};

export default function Layout({ children }: { children: React.ReactNode }) {
  const [open, setOpen] = useState(false);
  const [user, setUser] = useState<User | null>(null);
  const [mounted, setMounted] = useState(false);
  const pathname = usePathname();

  useEffect(() => { setUser(getUser()); setMounted(true); }, []);

  const items = navItems[user?.role ?? ''] ?? [];
  const displayName = user?.name ?? user?.full_name ?? '';

  if (!mounted) return (
    <div className="min-h-screen" style={{ backgroundColor: 'var(--ink)' }}>
      <div style={{ height: 64, backgroundColor: 'var(--card)', borderBottom: '1.5px solid var(--border)' }} />
    </div>
  );

  return (
    <div className="min-h-screen" style={{ backgroundColor: 'var(--ink)' }}>
      {/* Header */}
      <header style={{
        position: 'sticky', top: 0, zIndex: 50,
        backgroundColor: 'var(--card)',
        borderBottom: '1.5px solid var(--border)',
        display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        padding: '0 20px', height: 64,
        boxShadow: 'var(--shadow)',
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
          <button onClick={() => setOpen(!open)} className="md:hidden"
            style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--muted)', padding: 4 }}>
            {open ? <X size={22} /> : <Menu size={22} />}
          </button>
          <Link href={`/${user?.role}`} style={{ display: 'flex', alignItems: 'center', gap: 10, textDecoration: 'none' }}>
            <div style={{
              width: 34, height: 34, borderRadius: 10,
              background: 'var(--accent)', display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>
              <span style={{ color: '#fff', fontWeight: 800, fontSize: 14, fontFamily: 'JetBrains Mono' }}>CV</span>
            </div>
            <span style={{ fontWeight: 800, fontSize: 17, color: 'var(--soft)', letterSpacing: '-0.3px' }}>CS-Vault</span>
          </Link>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
          <span className="hidden sm:block" style={{ fontSize: 14, color: 'var(--muted)', fontWeight: 500 }}>{displayName}</span>
          <span className="badge badge-blue" style={{ fontSize: 11 }}>{user?.role}</span>
          <ThemeToggle />
          <button onClick={logout} style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--muted)', padding: 4 }}>
            <LogOut size={18} />
          </button>
        </div>
      </header>

      <div style={{ display: 'flex' }}>
        {/* Sidebar desktop */}
        <aside className="hidden md:flex" style={{
          flexDirection: 'column', width: 240,
          backgroundColor: 'var(--card)',
          borderRight: '1.5px solid var(--border)',
          padding: '24px 12px',
          position: 'sticky', top: 64,
          height: 'calc(100vh - 64px)',
          gap: 4,
        }}>
          {items.map(({ href, label, icon: Icon }) => {
            const active = pathname === href;
            return (
              <Link key={href} href={href} style={{
                display: 'flex', alignItems: 'center', gap: 12,
                padding: '11px 14px', borderRadius: 10, fontSize: 15,
                fontWeight: active ? 600 : 500, textDecoration: 'none',
                transition: 'all 0.15s ease',
                backgroundColor: active ? 'var(--accent-light)' : 'transparent',
                color: active ? 'var(--accent)' : 'var(--muted)',
                borderLeft: active ? '3px solid var(--accent)' : '3px solid transparent',
              }}>
                <Icon size={18} />
                {label}
              </Link>
            );
          })}
          <div style={{ marginTop: 'auto' }}>
            <Link href="/profile" style={{
              display: 'flex', alignItems: 'center', gap: 12,
              padding: '11px 14px', borderRadius: 10, fontSize: 15,
              fontWeight: pathname === '/profile' ? 600 : 500, textDecoration: 'none',
              backgroundColor: pathname === '/profile' ? 'var(--accent-light)' : 'transparent',
              color: pathname === '/profile' ? 'var(--accent)' : 'var(--muted)',
              borderLeft: pathname === '/profile' ? '3px solid var(--accent)' : '3px solid transparent',
            }}>
              <Settings size={18} />Profile
            </Link>
          </div>
        </aside>

        {/* Mobile drawer */}
        {open && (
          <div style={{ position: 'fixed', inset: 0, zIndex: 40 }} onClick={() => setOpen(false)}>
            <div style={{ position: 'absolute', inset: 0, backgroundColor: 'rgba(0,0,0,0.4)' }} />
            <aside style={{
              position: 'absolute', top: 64, left: 0, bottom: 0, width: 260,
              backgroundColor: 'var(--card)', borderRight: '1.5px solid var(--border)',
              padding: '20px 12px', display: 'flex', flexDirection: 'column', gap: 4,
            }} onClick={e => e.stopPropagation()}>
              {items.map(({ href, label, icon: Icon }) => {
                const active = pathname === href;
                return (
                  <Link key={href} href={href} onClick={() => setOpen(false)} style={{
                    display: 'flex', alignItems: 'center', gap: 12,
                    padding: '13px 14px', borderRadius: 10, fontSize: 15,
                    fontWeight: active ? 600 : 500, textDecoration: 'none',
                    backgroundColor: active ? 'var(--accent-light)' : 'transparent',
                    color: active ? 'var(--accent)' : 'var(--muted)',
                    borderLeft: active ? '3px solid var(--accent)' : '3px solid transparent',
                  }}>
                    <Icon size={18} />{label}
                  </Link>
                );
              })}
              <div style={{ marginTop: 'auto' }}>
                <Link href="/profile" onClick={() => setOpen(false)} style={{
                  display: 'flex', alignItems: 'center', gap: 12,
                  padding: '13px 14px', borderRadius: 10, fontSize: 15,
                  fontWeight: 500, textDecoration: 'none', color: 'var(--muted)',
                }}>
                  <Settings size={18} />Profile
                </Link>
              </div>
            </aside>
          </div>
        )}

        {/* Main content */}
        <main style={{ flex: 1, padding: '32px 24px', maxWidth: 1000, width: '100%', margin: '0 auto', paddingBottom: 100 }}>
          {children}
        </main>
      </div>

      {/* Bottom nav mobile */}
      <nav className="md:hidden" style={{
        position: 'fixed', bottom: 0, left: 0, right: 0, zIndex: 30,
        backgroundColor: 'var(--card)', borderTop: '1.5px solid var(--border)',
        display: 'flex', justifyContent: 'space-around', padding: '8px 0',
        boxShadow: '0 -4px 12px rgba(0,0,0,0.06)',
      }}>
        {items.map(({ href, label, icon: Icon }) => {
          const active = pathname === href;
          return (
            <Link key={href} href={href} style={{
              display: 'flex', flexDirection: 'column', alignItems: 'center',
              gap: 3, padding: '4px 16px', textDecoration: 'none',
              color: active ? 'var(--accent)' : 'var(--muted)',
              fontWeight: active ? 600 : 400,
            }}>
              <Icon size={22} />
              <span style={{ fontSize: 10 }}>{label}</span>
            </Link>
          );
        })}
      </nav>
    </div>
  );
}
EOF

# ── 5. LANDING PAGE ───────────────────────────────────────────
mkdir -p app/landing
cat > app/page.tsx << 'EOF'
'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { getUser } from '@/lib/auth';
import LandingPage from './landing/LandingPage';

export default function Root() {
  const router = useRouter();
  const [ready, setReady] = useState(false);

  useEffect(() => {
    // Init theme
    const saved = localStorage.getItem('cv-theme') ?? 'light';
    document.documentElement.setAttribute('data-theme', saved);
    const user = getUser();
    if (user) { router.push(`/${user.role}`); return; }
    setReady(true);
  }, [router]);

  if (!ready) return (
    <div style={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', backgroundColor: 'var(--ink)' }}>
      <div style={{ width: 40, height: 40, borderRadius: 10, background: 'var(--accent)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <span style={{ color: '#fff', fontWeight: 800, fontSize: 16 }}>CV</span>
      </div>
    </div>
  );

  return <LandingPage />;
}
EOF

cat > app/landing/LandingPage.tsx << 'EOF'
'use client';
import { useRouter } from 'next/navigation';
import ThemeToggle from '@/components/ThemeToggle';
import {
  BookOpen, Upload, Search, Users, GraduationCap,
  Shield, ArrowRight, CheckCircle, Star, Github
} from 'lucide-react';
import { useEffect } from 'react';

export default function LandingPage() {
  const router = useRouter();

  useEffect(() => {
    const saved = localStorage.getItem('cv-theme') ?? 'light';
    document.documentElement.setAttribute('data-theme', saved);
  }, []);

  const features = [
    { icon: Upload, title: 'Project Submission', desc: 'Students submit PDF reports, source code and GitHub links all in one place. No more emailing files.' },
    { icon: Search, title: 'Smart Browsing', desc: 'Browse and search past projects by course and session. Never repeat work that has already been done.' },
    { icon: GraduationCap, title: 'Lecturer Grading', desc: 'Lecturers review, grade and leave feedback on submissions directly on the platform.' },
    { icon: Users, title: 'Course Management', desc: 'Admins assign lecturers to courses and manage student enrolments across all departments.' },
    { icon: Shield, title: 'Role Based Access', desc: 'Three distinct roles — Admin, Lecturer and Student — each with their own secure dashboard.' },
    { icon: BookOpen, title: 'Past Reference', desc: 'Students access previous session projects for reference and inspiration — building on existing knowledge.' },
  ];

  const steps = [
    { num: '01', role: 'Admin', title: 'Set Up Courses', desc: 'Admin creates CSC 497 and CSC 498, then assigns lecturers to each course.' },
    { num: '02', role: 'Lecturer', title: 'Register Students', desc: 'Lecturers register students into their course. Students receive login credentials by email.' },
    { num: '03', role: 'Student', title: 'Upload & Reference', desc: 'Students upload their projects and browse past work for reference and learning.' },
  ];

  const s: Record<string, React.CSSProperties> = {
    nav: {
      position: 'fixed', top: 0, left: 0, right: 0, zIndex: 100,
      display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      padding: '0 5%', height: 68,
      backgroundColor: 'var(--card)',
      borderBottom: '1.5px solid var(--border)',
      boxShadow: 'var(--shadow)',
    },
    logo: { display: 'flex', alignItems: 'center', gap: 10, textDecoration: 'none' },
    logoBadge: {
      width: 36, height: 36, borderRadius: 10, background: 'var(--accent)',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
    },
    logoText: { fontWeight: 800, fontSize: 18, color: 'var(--soft)', letterSpacing: '-0.3px' },
    hero: {
      minHeight: '100vh', paddingTop: 68,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      textAlign: 'center', padding: '120px 5% 80px',
      background: 'var(--ink)',
      position: 'relative', overflow: 'hidden',
    },
    heroBg: {
      position: 'absolute', inset: 0,
      backgroundImage: 'radial-gradient(circle at 20% 50%, rgba(45,107,228,0.06) 0%, transparent 50%), radial-gradient(circle at 80% 20%, rgba(45,107,228,0.04) 0%, transparent 50%)',
      pointerEvents: 'none',
    },
    pill: {
      display: 'inline-flex', alignItems: 'center', gap: 6,
      background: 'var(--accent-light)', color: 'var(--accent)',
      padding: '6px 14px', borderRadius: 20, fontSize: 13, fontWeight: 600,
      marginBottom: 24, border: '1px solid rgba(45,107,228,0.2)',
    },
    h1: {
      fontSize: 'clamp(36px, 6vw, 64px)', fontWeight: 800,
      color: 'var(--soft)', letterSpacing: '-1.5px', lineHeight: 1.1,
      marginBottom: 20,
    },
    accent: { color: 'var(--accent)' },
    sub: { fontSize: 18, color: 'var(--muted)', maxWidth: 560, margin: '0 auto 36px', lineHeight: 1.7 },
    btnGroup: { display: 'flex', gap: 12, justifyContent: 'center', flexWrap: 'wrap' },
    section: { padding: '80px 5%', maxWidth: 1100, margin: '0 auto' },
    sectionLabel: {
      display: 'inline-flex', alignItems: 'center', gap: 6,
      background: 'var(--accent-light)', color: 'var(--accent)',
      padding: '5px 12px', borderRadius: 20, fontSize: 12, fontWeight: 700,
      textTransform: 'uppercase', letterSpacing: '0.5px', marginBottom: 12,
    },
    h2: { fontSize: 'clamp(24px, 4vw, 36px)', fontWeight: 800, color: 'var(--soft)', letterSpacing: '-0.5px', marginBottom: 8 },
    h2sub: { fontSize: 16, color: 'var(--muted)', marginBottom: 48, maxWidth: 500 },
    grid3: { display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))', gap: 20 },
    featureCard: {
      background: 'var(--card)', border: '1.5px solid var(--border)',
      borderRadius: 16, padding: '28px 24px',
      transition: 'all 0.2s ease', cursor: 'default',
    },
    iconBox: {
      width: 48, height: 48, borderRadius: 12,
      background: 'var(--accent-light)', display: 'flex',
      alignItems: 'center', justifyContent: 'center', marginBottom: 16,
    },
    featureTitle: { fontSize: 17, fontWeight: 700, color: 'var(--soft)', marginBottom: 8 },
    featureDesc: { fontSize: 14, color: 'var(--muted)', lineHeight: 1.6 },
    stepCard: {
      background: 'var(--card)', border: '1.5px solid var(--border)',
      borderRadius: 16, padding: '32px 28px', position: 'relative', overflow: 'hidden',
    },
    stepNum: {
      fontSize: 56, fontWeight: 900, color: 'var(--accent-light)',
      position: 'absolute', top: 16, right: 20, lineHeight: 1,
      fontFamily: 'JetBrains Mono', letterSpacing: '-2px',
    },
    stepRole: {
      display: 'inline-block', background: 'var(--accent-light)',
      color: 'var(--accent)', padding: '3px 10px', borderRadius: 20,
      fontSize: 12, fontWeight: 700, marginBottom: 12,
    },
    stepTitle: { fontSize: 20, fontWeight: 700, color: 'var(--soft)', marginBottom: 10 },
    stepDesc: { fontSize: 14, color: 'var(--muted)', lineHeight: 1.6 },
    ctaBanner: {
      background: 'var(--accent)', borderRadius: 20,
      padding: '56px 48px', textAlign: 'center',
      margin: '0 5% 80px',
      boxShadow: '0 8px 32px rgba(45,107,228,0.3)',
    },
    footer: {
      borderTop: '1.5px solid var(--border)',
      padding: '48px 5%',
      display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 20,
      backgroundColor: 'var(--card)',
    },
  };

  return (
    <div style={{ minHeight: '100vh', backgroundColor: 'var(--ink)' }}>
      {/* NAV */}
      <nav style={s.nav}>
        <a href="/" style={s.logo}>
          <div style={s.logoBadge}>
            <span style={{ color: '#fff', fontWeight: 800, fontSize: 15, fontFamily: 'JetBrains Mono' }}>CV</span>
          </div>
          <span style={s.logoText}>CS-Vault</span>
        </a>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
          <ThemeToggle />
          <button className="btn-primary" onClick={() => router.push('/login')} style={{ padding: '9px 20px', fontSize: 14 }}>
            Sign In <ArrowRight size={15} />
          </button>
        </div>
      </nav>

      {/* HERO */}
      <section style={s.hero}>
        <div style={s.heroBg} />
        <div style={{ position: 'relative', zIndex: 1 }} className="fade-up">
          <div style={s.pill}>
            <Star size={12} fill="currentColor" /> Built for Computer Science Students
          </div>
          <h1 style={s.h1}>
            Your CS Projects,<br />
            <span style={s.accent}>Organised & Shared</span>
          </h1>
          <p style={s.sub}>
            CS-Vault is a project repository platform for Computer Science students and lecturers. Upload your work, reference past projects, and never repeat what has already been done.
          </p>
          <div style={s.btnGroup}>
            <button className="btn-primary" onClick={() => router.push('/login')} style={{ fontSize: 16, padding: '14px 32px' }}>
              Get Started <ArrowRight size={18} />
            </button>
            <button className="btn-secondary" onClick={() => document.getElementById('features')?.scrollIntoView({ behavior: 'smooth' })} style={{ fontSize: 16, padding: '14px 32px' }}>
              Learn More
            </button>
          </div>
          <div style={{ display: 'flex', gap: 24, justifyContent: 'center', marginTop: 48, flexWrap: 'wrap' }}>
            {['CSC 497', 'CSC 498', 'PDF & ZIP Support', 'Email Notifications'].map(f => (
              <div key={f} style={{ display: 'flex', alignItems: 'center', gap: 6, color: 'var(--muted)', fontSize: 14 }}>
                <CheckCircle size={15} style={{ color: 'var(--accent)' }} /> {f}
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* FEATURES */}
      <section id="features" style={{ ...s.section, borderTop: '1.5px solid var(--border)' }}>
        <div style={s.sectionLabel}><BookOpen size={12} /> Features</div>
        <h2 style={s.h2}>Everything your department needs</h2>
        <p style={s.h2sub}>A complete platform for managing, submitting and referencing Computer Science projects.</p>
        <div style={s.grid3}>
          {features.map((f, i) => (
            <div key={f.title} className={`fade-up delay-${Math.min(i + 1, 5) as 1 | 2 | 3 | 4 | 5}`} style={s.featureCard}
              onMouseEnter={e => { (e.currentTarget as HTMLDivElement).style.borderColor = 'var(--accent)'; (e.currentTarget as HTMLDivElement).style.boxShadow = 'var(--shadow-md)'; }}
              onMouseLeave={e => { (e.currentTarget as HTMLDivElement).style.borderColor = 'var(--border)'; (e.currentTarget as HTMLDivElement).style.boxShadow = 'none'; }}>
              <div style={s.iconBox}><f.icon size={22} style={{ color: 'var(--accent)' }} /></div>
              <div style={s.featureTitle}>{f.title}</div>
              <div style={s.featureDesc}>{f.desc}</div>
            </div>
          ))}
        </div>
      </section>

      {/* HOW IT WORKS */}
      <section style={{ ...s.section, backgroundColor: 'var(--surface)', maxWidth: '100%', padding: '80px 5%' }}>
        <div style={{ maxWidth: 1100, margin: '0 auto' }}>
          <div style={s.sectionLabel}><CheckCircle size={12} /> How It Works</div>
          <h2 style={s.h2}>Up and running in three steps</h2>
          <p style={s.h2sub}>Simple enough for first-year students, powerful enough for department-wide use.</p>
          <div style={s.grid3}>
            {steps.map((step, i) => (
              <div key={step.num} className={`fade-up delay-${i + 1 as 1 | 2 | 3}`} style={s.stepCard}>
                <div style={s.stepNum}>{step.num}</div>
                <div style={s.stepRole}>{step.role}</div>
                <div style={s.stepTitle}>{step.title}</div>
                <div style={s.stepDesc}>{step.desc}</div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* CTA */}
      <div style={{ padding: '80px 0 0' }}>
        <div style={s.ctaBanner}>
          <h2 style={{ fontSize: 'clamp(24px, 4vw, 36px)', fontWeight: 800, color: '#fff', marginBottom: 12, letterSpacing: '-0.5px' }}>
            Ready to get started?
          </h2>
          <p style={{ color: 'rgba(255,255,255,0.85)', fontSize: 16, marginBottom: 28, maxWidth: 440, margin: '0 auto 28px' }}>
            Join your department on CS-Vault. Contact your lecturer to get your login credentials.
          </p>
          <button onClick={() => router.push('/login')}
            style={{ background: '#fff', color: 'var(--accent)', border: 'none', borderRadius: 10, padding: '13px 28px', fontSize: 15, fontWeight: 700, cursor: 'pointer', display: 'inline-flex', alignItems: 'center', gap: 8, boxShadow: '0 4px 16px rgba(0,0,0,0.15)' }}>
            Sign In to CS-Vault <ArrowRight size={16} />
          </button>
        </div>
      </div>

      {/* FOOTER */}
      <footer style={s.footer}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
          <div style={{ width: 30, height: 30, borderRadius: 8, background: 'var(--accent)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <span style={{ color: '#fff', fontWeight: 800, fontSize: 12 }}>CV</span>
          </div>
          <span style={{ fontWeight: 700, fontSize: 16, color: 'var(--soft)' }}>CS-Vault</span>
        </div>
        <p style={{ color: 'var(--muted)', fontSize: 14, textAlign: 'center', maxWidth: 500 }}>
          A school project repository platform built for the Computer Science department. Upload, reference and manage academic projects with ease.
        </p>
        <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', justifyContent: 'center' }}>
          {['Anonymous', 'Olamide', 'Vendel'].map(name => (
            <span key={name} style={{
              padding: '6px 14px', borderRadius: 20, fontSize: 13, fontWeight: 600,
              background: 'var(--accent-light)', color: 'var(--accent)',
              border: '1px solid rgba(45,107,228,0.2)',
            }}>{name}</span>
          ))}
        </div>
        <p style={{ color: 'var(--muted)', fontSize: 13 }}>
          © {new Date().getFullYear()} CS-Vault. Built with care for CS students.
        </p>
      </footer>
    </div>
  );
}
EOF

# ── 6. UPDATED LOGIN PAGE ─────────────────────────────────────
cat > app/login/page.tsx << 'EOF'
'use client';
import { useState, useEffect } from 'react';
import toast from 'react-hot-toast';
import api from '@/lib/api';
import { setAuth } from '@/lib/auth';
import { Eye, EyeOff, Lock, CreditCard, ArrowLeft, ArrowRight } from 'lucide-react';
import ThemeToggle from '@/components/ThemeToggle';
import Link from 'next/link';

type View = 'login' | 'forgot';

export default function LoginPage() {
  const [view, setView] = useState<View>('login');
  const [form, setForm] = useState({ matric_number: '', password: '' });
  const [forgotMatric, setForgotMatric] = useState('');
  const [show, setShow] = useState(false);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    const saved = localStorage.getItem('cv-theme') ?? 'light';
    document.documentElement.setAttribute('data-theme', saved);
  }, []);

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault(); setLoading(true);
    try {
      const { data } = await api.post('/auth/login', form);
      setAuth(data.token, data.user);
      toast.success(`Welcome back, ${data.user.full_name.split(' ')[0]}!`);
      window.location.href = data.user.must_change_password ? '/profile?must_change=true' : `/${data.user.role}`;
    } catch (err: unknown) {
      toast.error((err as { response?: { data?: { error?: string } } })?.response?.data?.error ?? 'Login failed');
      setLoading(false);
    }
  };

  const handleForgot = async (e: React.FormEvent) => {
    e.preventDefault(); setLoading(true);
    try {
      await api.post('/auth/forgot-password', { matric_number: forgotMatric });
      toast.success('New password sent to your registered email!');
      setView('login'); setForgotMatric('');
    } catch (err: unknown) {
      toast.error((err as { response?: { data?: { error?: string } } })?.response?.data?.error ?? 'Something went wrong');
    } finally { setLoading(false); }
  };

  return (
    <div style={{ minHeight: '100vh', backgroundColor: 'var(--ink)', display: 'flex', flexDirection: 'column' }}>
      {/* Top bar */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '16px 24px', borderBottom: '1.5px solid var(--border)', backgroundColor: 'var(--card)' }}>
        <Link href="/" style={{ display: 'flex', alignItems: 'center', gap: 8, textDecoration: 'none' }}>
          <div style={{ width: 32, height: 32, borderRadius: 8, background: 'var(--accent)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <span style={{ color: '#fff', fontWeight: 800, fontSize: 13 }}>CV</span>
          </div>
          <span style={{ fontWeight: 700, fontSize: 16, color: 'var(--soft)' }}>CS-Vault</span>
        </Link>
        <ThemeToggle />
      </div>

      {/* Form area */}
      <div style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', padding: '40px 20px' }}>
        <div style={{ width: '100%', maxWidth: 420 }}>

          {view === 'login' && (
            <div className="fade-up">
              <div style={{ textAlign: 'center', marginBottom: 32 }}>
                <h1 style={{ fontSize: 28, fontWeight: 800, color: 'var(--soft)', letterSpacing: '-0.5px', marginBottom: 8 }}>Welcome back</h1>
                <p style={{ color: 'var(--muted)', fontSize: 15 }}>Sign in to your CS-Vault account</p>
              </div>
              <div className="card" style={{ padding: 28 }}>
                <form onSubmit={handleLogin} style={{ display: 'flex', flexDirection: 'column', gap: 20 }}>
                  <div>
                    <label style={{ display: 'block', fontSize: 14, fontWeight: 600, color: 'var(--soft)', marginBottom: 8 }}>
                      Matric No. | Staff ID
                    </label>
                    <div style={{ position: 'relative' }}>
                      <CreditCard size={16} style={{ position: 'absolute', left: 14, top: '50%', transform: 'translateY(-50%)', color: 'var(--muted)' }} />
                      <input className="input-field mono" style={{ paddingLeft: 42 }}
                        placeholder="e.g. CSC/2021/001 or STAFF001"
                        value={form.matric_number}
                        onChange={e => setForm({ ...form, matric_number: e.target.value })}
                        required />
                    </div>
                  </div>
                  <div>
                    <label style={{ display: 'block', fontSize: 14, fontWeight: 600, color: 'var(--soft)', marginBottom: 8 }}>Password</label>
                    <div style={{ position: 'relative' }}>
                      <Lock size={16} style={{ position: 'absolute', left: 14, top: '50%', transform: 'translateY(-50%)', color: 'var(--muted)' }} />
                      <input className="input-field" type={show ? 'text' : 'password'} style={{ paddingLeft: 42, paddingRight: 42 }}
                        placeholder="Your password"
                        value={form.password}
                        onChange={e => setForm({ ...form, password: e.target.value })}
                        required />
                      <button type="button" onClick={() => setShow(!show)}
                        style={{ position: 'absolute', right: 14, top: '50%', transform: 'translateY(-50%)', background: 'none', border: 'none', cursor: 'pointer', color: 'var(--muted)' }}>
                        {show ? <EyeOff size={16} /> : <Eye size={16} />}
                      </button>
                    </div>
                  </div>
                  <button type="submit" className="btn-primary" disabled={loading} style={{ width: '100%', justifyContent: 'center', padding: '13px 24px', fontSize: 15 }}>
                    {loading ? 'Signing in...' : <><span>Sign in</span><ArrowRight size={16} /></>}
                  </button>
                </form>
                <button onClick={() => setView('forgot')}
                  style={{ width: '100%', textAlign: 'center', marginTop: 16, background: 'none', border: 'none', cursor: 'pointer', color: 'var(--muted)', fontSize: 14, textDecoration: 'underline' }}>
                  Forgot your password?
                </button>
              </div>
            </div>
          )}

          {view === 'forgot' && (
            <div className="fade-up">
              <button onClick={() => setView('login')}
                style={{ display: 'flex', alignItems: 'center', gap: 6, background: 'none', border: 'none', cursor: 'pointer', color: 'var(--muted)', fontSize: 14, marginBottom: 24 }}>
                <ArrowLeft size={15} /> Back to login
              </button>
              <div style={{ textAlign: 'center', marginBottom: 32 }}>
                <h1 style={{ fontSize: 28, fontWeight: 800, color: 'var(--soft)', letterSpacing: '-0.5px', marginBottom: 8 }}>Reset Password</h1>
                <p style={{ color: 'var(--muted)', fontSize: 15 }}>Enter your ID and we'll send a new password to your email</p>
              </div>
              <div className="card" style={{ padding: 28 }}>
                <form onSubmit={handleForgot} style={{ display: 'flex', flexDirection: 'column', gap: 20 }}>
                  <div>
                    <label style={{ display: 'block', fontSize: 14, fontWeight: 600, color: 'var(--soft)', marginBottom: 8 }}>Matric No. | Staff ID</label>
                    <div style={{ position: 'relative' }}>
                      <CreditCard size={16} style={{ position: 'absolute', left: 14, top: '50%', transform: 'translateY(-50%)', color: 'var(--muted)' }} />
                      <input className="input-field mono" style={{ paddingLeft: 42 }}
                        placeholder="e.g. CSC/2021/001 or STAFF001"
                        value={forgotMatric} onChange={e => setForgotMatric(e.target.value)} required />
                    </div>
                  </div>
                  <button type="submit" className="btn-primary" disabled={loading} style={{ width: '100%', justifyContent: 'center', padding: '13px 24px', fontSize: 15 }}>
                    {loading ? 'Sending...' : 'Send New Password'}
                  </button>
                </form>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
EOF

# ── 7. STAT CARD & PAGE HEADER & EMPTY STATE ─────────────────
cat > components/StatCard.tsx << 'EOF'
import { LucideIcon } from 'lucide-react';
export default function StatCard({ label, value, icon: Icon, color = 'blue' }: {
  label: string; value: string | number; icon: LucideIcon; color?: 'blue' | 'green' | 'orange' | 'red';
}) {
  const colors = {
    blue: { bg: 'var(--accent-light)', icon: 'var(--accent)' },
    green: { bg: '#ECFDF5', icon: '#16A34A' },
    orange: { bg: '#FFF7ED', icon: '#D97706' },
    red: { bg: '#FEF2F2', icon: '#DC2626' },
  };
  const c = colors[color];
  return (
    <div className="card" style={{ padding: '20px 24px', display: 'flex', alignItems: 'center', gap: 16 }}>
      <div style={{ width: 48, height: 48, borderRadius: 12, backgroundColor: c.bg, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
        <Icon size={22} style={{ color: c.icon }} />
      </div>
      <div>
        <p style={{ fontSize: 28, fontWeight: 800, color: 'var(--soft)', lineHeight: 1 }}>{value}</p>
        <p style={{ fontSize: 14, color: 'var(--muted)', marginTop: 4, fontWeight: 500 }}>{label}</p>
      </div>
    </div>
  );
}
EOF

cat > components/PageHeader.tsx << 'EOF'
export default function PageHeader({ title, subtitle, action }: {
  title: string; subtitle?: string; action?: React.ReactNode;
}) {
  return (
    <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', marginBottom: 28, gap: 16 }}>
      <div>
        <h1 style={{ fontSize: 26, fontWeight: 800, color: 'var(--soft)', letterSpacing: '-0.4px' }}>{title}</h1>
        {subtitle && <p style={{ fontSize: 15, color: 'var(--muted)', marginTop: 4 }}>{subtitle}</p>}
      </div>
      {action && <div style={{ flexShrink: 0 }}>{action}</div>}
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
    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '64px 20px', textAlign: 'center' }}>
      <div style={{ width: 64, height: 64, borderRadius: 16, backgroundColor: 'var(--accent-light)', display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 20 }}>
        <Icon size={28} style={{ color: 'var(--accent)' }} />
      </div>
      <h3 style={{ fontSize: 18, fontWeight: 700, color: 'var(--soft)', marginBottom: 8 }}>{title}</h3>
      <p style={{ fontSize: 15, color: 'var(--muted)', maxWidth: 320, lineHeight: 1.6 }}>{subtitle}</p>
    </div>
  );
}
EOF

# ── 8. PROJECT CARD ───────────────────────────────────────────
cat > components/ProjectCard.tsx << 'EOF'
import Link from 'next/link';
import { FileText, GitBranch, Archive, Calendar, Award } from 'lucide-react';
import { format } from 'date-fns';

const gradeConfig: Record<string, { bg: string; color: string; label: string }> = {
  A: { bg: '#ECFDF5', color: '#16A34A', label: 'A' },
  B: { bg: '#EEF3FD', color: '#2D6BE4', label: 'B' },
  C: { bg: '#FFF7ED', color: '#D97706', label: 'C' },
  D: { bg: '#FFFBEB', color: '#B45309', label: 'D' },
  E: { bg: '#FEF2F2', color: '#DC2626', label: 'E' },
  F: { bg: '#FEF2F2', color: '#991B1B', label: 'F' },
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
  const gc = grade ? gradeConfig[grade] : null;
  const link = href ?? `/student/projects/${project.id}`;

  return (
    <Link href={link} style={{ textDecoration: 'none', display: 'block' }}>
      <div className="card" style={{ padding: '20px 22px', cursor: 'pointer' }}
        onMouseEnter={e => { (e.currentTarget as HTMLDivElement).style.borderColor = 'var(--accent)'; (e.currentTarget as HTMLDivElement).style.transform = 'translateY(-2px)'; }}
        onMouseLeave={e => { (e.currentTarget as HTMLDivElement).style.borderColor = 'var(--border)'; (e.currentTarget as HTMLDivElement).style.transform = 'translateY(0)'; }}>
        <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: 12, marginBottom: 10 }}>
          <h3 style={{ fontSize: 16, fontWeight: 700, color: 'var(--soft)', lineHeight: 1.4 }}>{project.title}</h3>
          {gc && (
            <div style={{ display: 'flex', alignItems: 'center', gap: 4, padding: '4px 10px', borderRadius: 20, backgroundColor: gc.bg, flexShrink: 0 }}>
              <Award size={12} style={{ color: gc.color }} />
              <span style={{ fontSize: 13, fontWeight: 700, color: gc.color }}>{gc.label}</span>
            </div>
          )}
        </div>
        {project.description && (
          <p style={{ fontSize: 14, color: 'var(--muted)', marginBottom: 14, lineHeight: 1.6, display: '-webkit-box', WebkitLineClamp: 2, WebkitBoxOrient: 'vertical', overflow: 'hidden' }}>
            {project.description}
          </p>
        )}
        <div style={{ display: 'flex', alignItems: 'center', gap: 10, flexWrap: 'wrap' }}>
          {project.courses?.course_code && (
            <span className="badge badge-blue">{project.courses.course_code}</span>
          )}
          {project.pdf_url && <FileText size={14} style={{ color: 'var(--muted)' }} />}
          {project.zip_url && <Archive size={14} style={{ color: 'var(--muted)' }} />}
          {project.github_link && <GitBranch size={14} style={{ color: 'var(--muted)' }} />}
          {project.created_at && (
            <span style={{ marginLeft: 'auto', display: 'flex', alignItems: 'center', gap: 5, fontSize: 13, color: 'var(--muted)' }}>
              <Calendar size={13} />{format(new Date(project.created_at), 'dd MMM yyyy')}
            </span>
          )}
        </div>
        {project.users && (
          <p className="mono" style={{ fontSize: 12, color: 'var(--muted)', marginTop: 10, paddingTop: 10, borderTop: '1px solid var(--border)' }}>
            {project.users.matric_number} · {project.users.full_name}
          </p>
        )}
      </div>
    </Link>
  );
}
EOF

# ── 9. ADMIN PAGES ────────────────────────────────────────────
cat > app/admin/page.tsx << 'EOF'
'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { getUser, requireAuth } from '@/lib/auth';
import Layout from '@/components/Layout';
import StatCard from '@/components/StatCard';
import PageHeader from '@/components/PageHeader';
import api from '@/lib/api';
import { Users, GraduationCap, BookOpen, TrendingUp } from 'lucide-react';

export default function AdminDashboard() {
  const router = useRouter();
  const [stats, setStats] = useState({ lecturers: 0, students: 0, courses: 0 });
  const user = getUser();

  useEffect(() => {
    if (!requireAuth(getUser(), router, ['admin'])) return;
    Promise.all([api.get('/admin/lecturers'), api.get('/admin/students'), api.get('/admin/courses')])
      .then(([l, s, c]) => setStats({ lecturers: l.data.length, students: s.data.length, courses: c.data.length }))
      .catch(() => {});
  }, [router]);

  return (
    <Layout>
      <PageHeader title={`Welcome back 👋`} subtitle="Here's what's happening on CS-Vault" />
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: 16, marginBottom: 32 }}>
        <StatCard label="Total Lecturers" value={stats.lecturers} icon={GraduationCap} color="blue" />
        <StatCard label="Total Students" value={stats.students} icon={Users} color="green" />
        <StatCard label="Active Courses" value={stats.courses} icon={BookOpen} color="orange" />
      </div>
      <div className="card" style={{ padding: '24px 28px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 8 }}>
          <TrendingUp size={20} style={{ color: 'var(--accent)' }} />
          <h2 style={{ fontSize: 17, fontWeight: 700, color: 'var(--soft)' }}>Quick Actions</h2>
        </div>
        <p style={{ color: 'var(--muted)', fontSize: 14, marginBottom: 20 }}>Manage your platform from the sidebar</p>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(180px, 1fr))', gap: 12 }}>
          {[
            { label: 'Add Lecturer', href: '/admin/lecturers' },
            { label: 'Create Course', href: '/admin/courses' },
            { label: 'Register Student', href: '/admin/students' },
          ].map(a => (
            <button key={a.href} onClick={() => router.push(a.href)} className="btn-secondary" style={{ justifyContent: 'center', width: '100%' }}>
              {a.label}
            </button>
          ))}
        </div>
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
import { GraduationCap, Plus, X, Pencil, Trash2 } from 'lucide-react';
import { format } from 'date-fns';

interface Lecturer { id: string; full_name: string; email: string; matric_number: string; department: string; created_at: string; }
interface Course { id: string; title: string; course_code: string; lecturer_id?: string; }

export default function LecturersPage() {
  const router = useRouter();
  const [lecturers, setLecturers] = useState<Lecturer[]>([]);
  const [courses, setCourses] = useState<Course[]>([]);
  const [showForm, setShowForm] = useState(false);
  const [editId, setEditId] = useState<string | null>(null);
  const [form, setForm] = useState({ full_name: '', email: '', matric_number: '', department: 'Computer Science' });
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (!requireAuth(getUser(), router, ['admin'])) return;
    loadData();
  }, [router]);

  const loadData = async () => {
    const [l, c] = await Promise.all([api.get('/admin/lecturers'), api.get('/admin/courses')]);
    setLecturers(l.data); setCourses(c.data);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault(); setLoading(true);
    try {
      if (editId) {
        await api.put(`/admin/lecturers/${editId}`, { full_name: form.full_name, email: form.email, department: form.department });
        toast.success('Lecturer updated');
      } else {
        await api.post('/admin/lecturers', form);
        toast.success('Lecturer created — credentials sent!');
      }
      setShowForm(false); setEditId(null); setForm({ full_name: '', email: '', matric_number: '', department: 'Computer Science' });
      loadData();
    } catch (err: unknown) {
      toast.error((err as { response?: { data?: { error?: string } } })?.response?.data?.error ?? 'Failed');
    } finally { setLoading(false); }
  };

  const handleDelete = async (id: string, name: string) => {
    if (!confirm(`Remove ${name}? This cannot be undone.`)) return;
    try { await api.delete(`/admin/lecturers/${id}`); toast.success('Lecturer removed'); loadData(); }
    catch { toast.error('Failed to remove'); }
  };

  const startEdit = (l: Lecturer) => {
    setForm({ full_name: l.full_name, email: l.email, matric_number: l.matric_number, department: l.department });
    setEditId(l.id); setShowForm(true);
  };

  const getAssignedCourse = (id: string) => courses.find(c => c.lecturer_id === id);

  return (
    <Layout>
      <PageHeader title="Lecturers" subtitle={`${lecturers.length} registered`}
        action={
          <button className="btn-primary" onClick={() => { setShowForm(!showForm); setEditId(null); setForm({ full_name: '', email: '', matric_number: '', department: 'Computer Science' }); }}>
            <Plus size={16} /> Add Lecturer
          </button>
        } />

      {showForm && (
        <div className="card fade-up" style={{ padding: 24, marginBottom: 24 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 20 }}>
            <h3 style={{ fontSize: 17, fontWeight: 700, color: 'var(--soft)' }}>{editId ? 'Edit Lecturer' : 'New Lecturer'}</h3>
            <button onClick={() => { setShowForm(false); setEditId(null); }} style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--muted)' }}><X size={18} /></button>
          </div>
          <form onSubmit={handleSubmit} style={{ display: 'grid', gap: 16 }}>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16 }}>
              {[['Full Name', 'full_name'], ['Email', 'email']].map(([label, key]) => (
                <div key={key}>
                  <label style={{ display: 'block', fontSize: 14, fontWeight: 600, color: 'var(--soft)', marginBottom: 6 }}>{label}</label>
                  <input className="input-field" required value={form[key as keyof typeof form]}
                    onChange={e => setForm({ ...form, [key]: e.target.value })} />
                </div>
              ))}
            </div>
            {!editId && (
              <div>
                <label style={{ display: 'block', fontSize: 14, fontWeight: 600, color: 'var(--soft)', marginBottom: 6 }}>Staff ID</label>
                <input className="input-field mono" required value={form.matric_number}
                  onChange={e => setForm({ ...form, matric_number: e.target.value })} placeholder="e.g. STAFF001" />
              </div>
            )}
            <button type="submit" className="btn-primary" disabled={loading}>
              {loading ? 'Saving...' : editId ? 'Save Changes' : 'Create & Send Credentials'}
            </button>
          </form>
        </div>
      )}

      {lecturers.length === 0
        ? <EmptyState icon={GraduationCap} title="No lecturers yet" subtitle="Add your first lecturer above" />
        : <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            {lecturers.map(l => {
              const course = getAssignedCourse(l.id);
              return (
                <div key={l.id} className="card" style={{ padding: '18px 22px' }}>
                  <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: 12 }}>
                    <div style={{ flex: 1 }}>
                      <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 4 }}>
                        <p style={{ fontSize: 16, fontWeight: 700, color: 'var(--soft)' }}>{l.full_name}</p>
                        {course && <span className="badge badge-blue">{course.course_code}</span>}
                      </div>
                      <p style={{ fontSize: 14, color: 'var(--muted)' }}>{l.email}</p>
                      <p className="mono" style={{ fontSize: 13, color: 'var(--muted)', marginTop: 4 }}>
                        {l.matric_number} · {l.created_at ? format(new Date(l.created_at), 'dd MMM yyyy') : ''}
                      </p>
                    </div>
                    <div style={{ display: 'flex', gap: 8 }}>
                      <button onClick={() => startEdit(l)} className="btn-secondary" style={{ padding: '8px 12px' }}><Pencil size={15} /></button>
                      <button onClick={() => handleDelete(l.id, l.full_name)} style={{ padding: '8px 12px', borderRadius: 10, border: '1.5px solid #FEE2E2', background: '#FEF2F2', color: '#DC2626', cursor: 'pointer' }}><Trash2 size={15} /></button>
                    </div>
                  </div>
                </div>
              );
            })}
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
import { BookOpen, Plus, X, Trash2 } from 'lucide-react';

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
    try { await api.put('/admin/courses/assign', { course_id, lecturer_id: lecturer_id || null }); toast.success(lecturer_id ? 'Lecturer assigned' : 'Lecturer removed'); loadData(); }
    catch { toast.error('Failed'); }
  };

  const handleDelete = async (id: string, title: string) => {
    if (!confirm(`Delete ${title}?`)) return;
    try { await api.delete(`/admin/courses/${id}`); toast.success('Course deleted'); loadData(); }
    catch { toast.error('Failed'); }
  };

  return (
    <Layout>
      <PageHeader title="Courses" subtitle={`${courses.length} active courses`}
        action={
          <button className="btn-primary" onClick={() => setShowForm(!showForm)}>
            <Plus size={16} /> Add Course
          </button>
        } />

      {showForm && (
        <div className="card fade-up" style={{ padding: 24, marginBottom: 24 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 20 }}>
            <h3 style={{ fontSize: 17, fontWeight: 700, color: 'var(--soft)' }}>New Course</h3>
            <button onClick={() => setShowForm(false)} style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--muted)' }}><X size={18} /></button>
          </div>
          <form onSubmit={handleCreate} style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16 }}>
            {[['Course Title', 'title'], ['Course Code', 'course_code'], ['Session', 'session']].map(([label, key]) => (
              <div key={key}>
                <label style={{ display: 'block', fontSize: 14, fontWeight: 600, color: 'var(--soft)', marginBottom: 6 }}>{label}</label>
                <input className="input-field" required value={form[key as keyof typeof form]}
                  onChange={e => setForm({ ...form, [key]: e.target.value })} />
              </div>
            ))}
            <div style={{ gridColumn: '1 / -1' }}>
              <button type="submit" className="btn-primary" disabled={loading}>
                {loading ? 'Creating...' : 'Create Course'}
              </button>
            </div>
          </form>
        </div>
      )}

      {courses.length === 0
        ? <EmptyState icon={BookOpen} title="No courses yet" subtitle="Add CSC 497 and CSC 498 above" />
        : <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            {courses.map(c => {
              const assigned = lecturers.find(l => l.id === c.lecturer_id);
              return (
                <div key={c.id} className="card" style={{ padding: '20px 22px' }}>
                  <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: 16 }}>
                    <div style={{ flex: 1 }}>
                      <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 6 }}>
                        <h3 style={{ fontSize: 16, fontWeight: 700, color: 'var(--soft)' }}>{c.title}</h3>
                        <span className="badge badge-blue">{c.course_code}</span>
                        <span style={{ fontSize: 13, color: 'var(--muted)' }}>{c.session}</span>
                      </div>
                      <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                        <label style={{ fontSize: 14, color: 'var(--muted)', fontWeight: 500, whiteSpace: 'nowrap' }}>Assigned lecturer:</label>
                        <select className="input-field" style={{ padding: '8px 12px', maxWidth: 260 }}
                          value={c.lecturer_id ?? ''} onChange={e => assign(c.id, e.target.value)}>
                          <option value="">— Unassigned —</option>
                          {lecturers.map(l => <option key={l.id} value={l.id}>{l.full_name}</option>)}
                        </select>
                      </div>
                      {assigned && <p style={{ fontSize: 13, color: 'var(--accent)', marginTop: 6, fontWeight: 500 }}>✓ {assigned.full_name}</p>}
                    </div>
                    <button onClick={() => handleDelete(c.id, c.title)} style={{ padding: '8px 12px', borderRadius: 10, border: '1.5px solid #FEE2E2', background: '#FEF2F2', color: '#DC2626', cursor: 'pointer' }}>
                      <Trash2 size={15} />
                    </button>
                  </div>
                </div>
              );
            })}
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
import toast from 'react-hot-toast';
import { Users, Plus, X, Trash2, Pencil } from 'lucide-react';
import { format } from 'date-fns';

interface Student { id: string; full_name: string; email: string; matric_number: string; created_at: string; }
interface Course { id: string; title: string; course_code: string; }
interface Enrollment { student_id: string; course_id: string; }

export default function StudentsPage() {
  const router = useRouter();
  const [students, setStudents] = useState<Student[]>([]);
  const [courses, setCourses] = useState<Course[]>([]);
  const [enrollments, setEnrollments] = useState<Enrollment[]>([]);
  const [search, setSearch] = useState('');
  const [showForm, setShowForm] = useState(false);
  const [form, setForm] = useState({ full_name: '', email: '', matric_number: '', course_ids: [] as string[] });
  const [loading, setLoading] = useState(false);
  const [editStudent, setEditStudent] = useState<Student | null>(null);

  useEffect(() => {
    if (!requireAuth(getUser(), router, ['admin'])) return;
    loadData();
  }, [router]);

  const loadData = async () => {
    const [s, c, e] = await Promise.all([
      api.get('/admin/students'),
      api.get('/admin/courses'),
      api.get('/admin/enrollments'),
    ]);
    setStudents(s.data); setCourses(c.data); setEnrollments(e.data);
  };

  const handleRegister = async (e: React.FormEvent) => {
    e.preventDefault(); setLoading(true);
    try {
      if (editStudent) {
        await api.put(`/admin/students/${editStudent.id}`, { full_name: form.full_name, email: form.email });
        if (form.course_ids.length > 0) {
          await api.put(`/admin/students/${editStudent.id}/courses`, { course_ids: form.course_ids });
        }
        toast.success('Student updated');
      } else {
        await api.post('/admin/students/register', form);
        toast.success('Student registered — credentials sent!');
      }
      setShowForm(false); setEditStudent(null);
      setForm({ full_name: '', email: '', matric_number: '', course_ids: [] });
      loadData();
    } catch (err: unknown) {
      toast.error((err as { response?: { data?: { error?: string } } })?.response?.data?.error ?? 'Failed');
    } finally { setLoading(false); }
  };

  const handleDelete = async (id: string, name: string) => {
    if (!confirm(`Remove ${name}?`)) return;
    try { await api.delete(`/admin/students/${id}`); toast.success('Student removed'); loadData(); }
    catch { toast.error('Failed'); }
  };

  const startEdit = (s: Student) => {
    const enrolled = enrollments.filter(e => e.student_id === s.id).map(e => e.course_id);
    setForm({ full_name: s.full_name, email: s.email, matric_number: s.matric_number, course_ids: enrolled });
    setEditStudent(s); setShowForm(true);
  };

  const toggleCourse = (id: string) => {
    setForm(f => ({
      ...f,
      course_ids: f.course_ids.includes(id) ? f.course_ids.filter(c => c !== id) : [...f.course_ids, id]
    }));
  };

  const getStudentCourses = (studentId: string) =>
    enrollments.filter(e => e.student_id === studentId).map(e => courses.find(c => c.id === e.course_id)).filter(Boolean) as Course[];

  const filtered = students.filter(s =>
    s.full_name.toLowerCase().includes(search.toLowerCase()) ||
    s.matric_number.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <Layout>
      <PageHeader title="Students" subtitle={`${students.length} registered`}
        action={
          <button className="btn-primary" onClick={() => { setShowForm(!showForm); setEditStudent(null); setForm({ full_name: '', email: '', matric_number: '', course_ids: [] }); }}>
            <Plus size={16} /> Register Student
          </button>
        } />

      {showForm && (
        <div className="card fade-up" style={{ padding: 24, marginBottom: 24 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 20 }}>
            <h3 style={{ fontSize: 17, fontWeight: 700, color: 'var(--soft)' }}>{editStudent ? 'Edit Student' : 'Register New Student'}</h3>
            <button onClick={() => { setShowForm(false); setEditStudent(null); }} style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--muted)' }}><X size={18} /></button>
          </div>
          <form onSubmit={handleRegister} style={{ display: 'grid', gap: 16 }}>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16 }}>
              {[['Full Name', 'full_name'], ['Email', 'email']].map(([label, key]) => (
                <div key={key}>
                  <label style={{ display: 'block', fontSize: 14, fontWeight: 600, color: 'var(--soft)', marginBottom: 6 }}>{label}</label>
                  <input className="input-field" required value={form[key as keyof typeof form] as string}
                    onChange={e => setForm({ ...form, [key]: e.target.value })} />
                </div>
              ))}
            </div>
            {!editStudent && (
              <div>
                <label style={{ display: 'block', fontSize: 14, fontWeight: 600, color: 'var(--soft)', marginBottom: 6 }}>Matric Number</label>
                <input className="input-field mono" required value={form.matric_number}
                  onChange={e => setForm({ ...form, matric_number: e.target.value })} placeholder="e.g. CSC/2021/001" />
              </div>
            )}
            <div>
              <label style={{ display: 'block', fontSize: 14, fontWeight: 600, color: 'var(--soft)', marginBottom: 10 }}>
                Assign to Course(s) <span style={{ color: 'var(--muted)', fontWeight: 400 }}>(optional)</span>
              </label>
              <div style={{ display: 'flex', gap: 12 }}>
                {courses.map(c => (
                  <button type="button" key={c.id} onClick={() => toggleCourse(c.id)}
                    style={{
                      padding: '10px 20px', borderRadius: 10, cursor: 'pointer', fontSize: 14, fontWeight: 600, transition: 'all 0.15s',
                      border: '1.5px solid', flex: 1, justifyContent: 'center',
                      backgroundColor: form.course_ids.includes(c.id) ? 'var(--accent)' : 'var(--surface)',
                      borderColor: form.course_ids.includes(c.id) ? 'var(--accent)' : 'var(--border)',
                      color: form.course_ids.includes(c.id) ? '#fff' : 'var(--soft)',
                    }}>
                    {c.course_code}
                  </button>
                ))}
              </div>
            </div>
            <button type="submit" className="btn-primary" disabled={loading}>
              {loading ? 'Saving...' : editStudent ? 'Save Changes' : 'Register Student'}
            </button>
          </form>
        </div>
      )}

      <input className="input-field" style={{ marginBottom: 16 }}
        placeholder="Search by name or matric number..."
        value={search} onChange={e => setSearch(e.target.value)} />

      {filtered.length === 0
        ? <EmptyState icon={Users} title="No students found" subtitle="Register students using the button above" />
        : <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
            {filtered.map(s => {
              const studentCourses = getStudentCourses(s.id);
              return (
                <div key={s.id} className="card" style={{ padding: '16px 20px', display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 12 }}>
                  <div style={{ flex: 1 }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 4 }}>
                      <p style={{ fontSize: 15, fontWeight: 700, color: 'var(--soft)' }}>{s.full_name}</p>
                      {studentCourses.map(c => <span key={c.id} className="badge badge-blue">{c.course_code}</span>)}
                    </div>
                    <p style={{ fontSize: 13, color: 'var(--muted)' }}>{s.email}</p>
                    <p className="mono" style={{ fontSize: 12, color: 'var(--muted)', marginTop: 2 }}>
                      {s.matric_number} · {s.created_at ? format(new Date(s.created_at), 'dd MMM yyyy') : ''}
                    </p>
                  </div>
                  <div style={{ display: 'flex', gap: 8 }}>
                    <button onClick={() => startEdit(s)} className="btn-secondary" style={{ padding: '8px 12px' }}><Pencil size={15} /></button>
                    <button onClick={() => handleDelete(s.id, s.full_name)} style={{ padding: '8px 12px', borderRadius: 10, border: '1.5px solid #FEE2E2', background: '#FEF2F2', color: '#DC2626', cursor: 'pointer' }}><Trash2 size={15} /></button>
                  </div>
                </div>
              );
            })}
          </div>
      }
    </Layout>
  );
}
EOF

# ── 10. LECTURER REGISTER PAGE (single only, no bulk) ─────────
cat > "app/lecturer/students/register/page.tsx" << 'EOF'
'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { getUser, requireAuth } from '@/lib/auth';
import Layout from '@/components/Layout';
import PageHeader from '@/components/PageHeader';
import api from '@/lib/api';
import toast from 'react-hot-toast';
import { UserPlus } from 'lucide-react';

interface Course { id: string; title: string; course_code: string; }

export default function RegisterStudents() {
  const router = useRouter();
  const [courses, setCourses] = useState<Course[]>([]);
  const [form, setForm] = useState({ full_name: '', email: '', matric_number: '', course_ids: [] as string[] });
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (!requireAuth(getUser(), router, ['lecturer', 'admin'])) return;
    api.get('/lecturer/courses').then(r => setCourses(r.data)).catch(() => {});
  }, [router]);

  const toggleCourse = (id: string) => {
    setForm(f => ({
      ...f,
      course_ids: f.course_ids.includes(id) ? f.course_ids.filter(c => c !== id) : [...f.course_ids, id]
    }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (form.course_ids.length === 0) return toast.error('Select at least one course');
    setLoading(true);
    try {
      await api.post('/lecturer/students/register', form);
      toast.success('Student registered — credentials sent!');
      setForm({ full_name: '', email: '', matric_number: '', course_ids: [] });
    } catch (err: unknown) {
      toast.error((err as { response?: { data?: { error?: string } } })?.response?.data?.error ?? 'Failed');
    } finally { setLoading(false); }
  };

  return (
    <Layout>
      <PageHeader title="Register Student" subtitle="Add a student to your course" />
      <div className="card" style={{ padding: 28, maxWidth: 560 }}>
        <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: 20 }}>
          {[['Full Name', 'full_name', 'text', 'e.g. John Doe'], ['Email Address', 'email', 'email', 'e.g. student@gmail.com'], ['Matric Number', 'matric_number', 'text', 'e.g. CSC/2021/001']].map(([label, key, type, placeholder]) => (
            <div key={key}>
              <label style={{ display: 'block', fontSize: 14, fontWeight: 600, color: 'var(--soft)', marginBottom: 8 }}>{label}</label>
              <input type={type} required className={`input-field${key === 'matric_number' ? ' mono' : ''}`}
                placeholder={placeholder}
                value={form[key as keyof typeof form] as string}
                onChange={e => setForm({ ...form, [key]: e.target.value })} />
            </div>
          ))}

          <div>
            <label style={{ display: 'block', fontSize: 14, fontWeight: 600, color: 'var(--soft)', marginBottom: 10 }}>
              Assign to Course(s)
            </label>
            <div style={{ display: 'flex', gap: 12 }}>
              {courses.map(c => (
                <button type="button" key={c.id} onClick={() => toggleCourse(c.id)}
                  style={{
                    flex: 1, padding: '12px 16px', borderRadius: 10, cursor: 'pointer',
                    fontSize: 15, fontWeight: 600, transition: 'all 0.15s', border: '1.5px solid',
                    backgroundColor: form.course_ids.includes(c.id) ? 'var(--accent)' : 'var(--surface)',
                    borderColor: form.course_ids.includes(c.id) ? 'var(--accent)' : 'var(--border)',
                    color: form.course_ids.includes(c.id) ? '#fff' : 'var(--soft)',
                  }}>
                  {c.course_code}
                  <div style={{ fontSize: 12, fontWeight: 400, opacity: 0.8, marginTop: 2 }}>{c.title}</div>
                </button>
              ))}
            </div>
          </div>

          <button type="submit" className="btn-primary" disabled={loading} style={{ justifyContent: 'center', padding: '13px 24px' }}>
            <UserPlus size={17} /> {loading ? 'Registering...' : 'Register Student'}
          </button>
        </form>
      </div>
    </Layout>
  );
}
EOF

# ── 11. SQL SCRIPT ────────────────────────────────────────────
cat > /tmp/update-courses.sql << 'SQLEOF'
-- Remove all existing courses
DELETE FROM enrollments;
DELETE FROM projects;
DELETE FROM grades;
DELETE FROM comments;
DELETE FROM courses;

-- Add CSC 497 and CSC 498
INSERT INTO courses (id, title, course_code, session)
VALUES
  (uuid_generate_v4(), 'Final Year Project I', 'CSC 497', '2024/2025'),
  (uuid_generate_v4(), 'Final Year Project II', 'CSC 498', '2024/2025');
SQLEOF

echo ""
echo "✅ CS-VAULT MAJOR UPDATE COMPLETE!"
echo ""
echo "⚠️  IMPORTANT: Run this SQL in Supabase SQL Editor:"
cat /tmp/update-courses.sql
echo ""
