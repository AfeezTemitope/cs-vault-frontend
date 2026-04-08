#!/bin/bash
# ============================================================
#  CS-VAULT — Landing Page + Color Fix + Form Fix
#  Run from INSIDE cs-vault-frontend/
# ============================================================

echo "🎨 Fixing landing page, colors, forms..."

# ── GLOBALS.CSS — Purple/Black dark, Clean light ─────────────
cat > app/globals.css << 'EOF'
@import url('https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:ital,wght@0,400;0,500;0,600;0,700;0,800;1,400&family=JetBrains+Mono:wght@400;500&display=swap');
@import "tailwindcss";

:root {
  --ink: #FAFBFF;
  --surface: #F2F4FA;
  --card: #FFFFFF;
  --border: #E2E6F0;
  --border-hover: #B8C0D8;
  --accent: #7C3AED;
  --accent-dim: #6D28D9;
  --accent-light: #F3EEFF;
  --accent-glow: rgba(124,58,237,0.15);
  --muted: #7B829A;
  --soft: #1A1B2E;
  --success: #059669;
  --warning: #D97706;
  --danger: #DC2626;
  --shadow-sm: 0 1px 3px rgba(0,0,0,0.06);
  --shadow: 0 4px 12px rgba(0,0,0,0.07);
  --shadow-md: 0 8px 24px rgba(0,0,0,0.10);
  --shadow-lg: 0 16px 48px rgba(0,0,0,0.12);
  --radius: 12px;
  --radius-lg: 18px;
}

[data-theme="dark"] {
  --ink: #0D0B14;
  --surface: #13111C;
  --card: #1A1726;
  --border: #2D2840;
  --border-hover: #4A4468;
  --accent: #A78BFA;
  --accent-dim: #8B5CF6;
  --accent-light: #1F1833;
  --accent-glow: rgba(167,139,250,0.15);
  --muted: #7B7A9A;
  --soft: #EAE8F8;
  --shadow-sm: 0 1px 3px rgba(0,0,0,0.4);
  --shadow: 0 4px 12px rgba(0,0,0,0.5);
  --shadow-md: 0 8px 24px rgba(0,0,0,0.6);
  --shadow-lg: 0 16px 48px rgba(0,0,0,0.7);
}

*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

html { scroll-behavior: smooth; }

body {
  background-color: var(--ink);
  color: var(--soft);
  font-family: 'Plus Jakarta Sans', sans-serif;
  font-size: 15px;
  line-height: 1.65;
  -webkit-font-smoothing: antialiased;
  transition: background-color 0.25s ease, color 0.25s ease;
}

.mono { font-family: 'JetBrains Mono', monospace; }

::selection { background: var(--accent-light); color: var(--accent); }
::-webkit-scrollbar { width: 5px; }
::-webkit-scrollbar-track { background: var(--surface); }
::-webkit-scrollbar-thumb { background: var(--border); border-radius: 99px; }

/* ── Animations ── */
@keyframes fadeUp {
  from { opacity: 0; transform: translateY(20px); }
  to   { opacity: 1; transform: translateY(0); }
}
@keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
@keyframes float {
  0%, 100% { transform: translateY(0px); }
  50%       { transform: translateY(-10px); }
}
@keyframes shimmer {
  0%   { background-position: -200% center; }
  100% { background-position: 200% center; }
}
@keyframes spin { to { transform: rotate(360deg); } }

.fade-up  { animation: fadeUp 0.55s cubic-bezier(.22,.68,0,1.2) forwards; }
.fade-in  { animation: fadeIn 0.4s ease forwards; }
.float    { animation: float 4s ease-in-out infinite; }
.delay-1  { animation-delay: 0.08s; opacity: 0; }
.delay-2  { animation-delay: 0.16s; opacity: 0; }
.delay-3  { animation-delay: 0.24s; opacity: 0; }
.delay-4  { animation-delay: 0.32s; opacity: 0; }
.delay-5  { animation-delay: 0.40s; opacity: 0; }

/* ── Buttons ── */
.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 12px 22px;
  font-size: 15px;
  font-weight: 600;
  font-family: 'Plus Jakarta Sans', sans-serif;
  border-radius: var(--radius);
  border: none;
  cursor: pointer;
  transition: all 0.2s ease;
  text-decoration: none;
  white-space: nowrap;
  line-height: 1;
}
.btn:disabled { opacity: 0.5; cursor: not-allowed; transform: none !important; }

.btn-primary {
  background: var(--accent);
  color: #fff;
  box-shadow: 0 2px 8px var(--accent-glow);
}
.btn-primary:hover:not(:disabled) {
  background: var(--accent-dim);
  transform: translateY(-1px);
  box-shadow: 0 6px 20px var(--accent-glow);
}

.btn-secondary {
  background: var(--card);
  color: var(--soft);
  border: 1.5px solid var(--border);
}
.btn-secondary:hover:not(:disabled) {
  border-color: var(--accent);
  color: var(--accent);
  background: var(--accent-light);
}

.btn-ghost {
  background: transparent;
  color: var(--muted);
  border: none;
  padding: 8px 12px;
}
.btn-ghost:hover { color: var(--soft); background: var(--surface); border-radius: var(--radius); }

.btn-danger {
  background: #FEF2F2;
  color: #DC2626;
  border: 1.5px solid #FEE2E2;
}
.btn-danger:hover { background: #FEE2E2; }
[data-theme="dark"] .btn-danger { background: #2D0808; border-color: #5C1010; color: #F87171; }
[data-theme="dark"] .btn-danger:hover { background: #3D1010; }

.btn-sm { padding: 8px 14px; font-size: 13px; }
.btn-lg { padding: 15px 32px; font-size: 16px; }
.btn-full { width: 100%; }

/* ── Cards ── */
.card {
  background: var(--card);
  border: 1.5px solid var(--border);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-sm);
  transition: border-color 0.2s, box-shadow 0.2s, transform 0.2s;
}
.card-hover:hover {
  border-color: var(--accent);
  box-shadow: var(--shadow-md);
  transform: translateY(-2px);
}

/* ── Inputs ── */
.input {
  width: 100%;
  background: var(--surface);
  border: 1.5px solid var(--border);
  border-radius: var(--radius);
  padding: 12px 16px;
  font-size: 15px;
  color: var(--soft);
  font-family: 'Plus Jakarta Sans', sans-serif;
  transition: all 0.2s ease;
  outline: none;
  -webkit-appearance: none;
  appearance: none;
}
.input:focus {
  border-color: var(--accent);
  background: var(--card);
  box-shadow: 0 0 0 3px var(--accent-glow);
}
.input::placeholder { color: var(--muted); }
.input-icon { padding-left: 44px; }

.label {
  display: block;
  font-size: 14px;
  font-weight: 600;
  color: var(--soft);
  margin-bottom: 7px;
}

.field { display: flex; flex-direction: column; gap: 0; }

/* ── Badges ── */
.badge {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 3px 10px;
  border-radius: 99px;
  font-size: 12px;
  font-weight: 600;
  line-height: 1.4;
}
.badge-purple { background: var(--accent-light); color: var(--accent); }
.badge-green  { background: #ECFDF5; color: #059669; }
.badge-orange { background: #FFF7ED; color: #D97706; }
.badge-red    { background: #FEF2F2; color: #DC2626; }
[data-theme="dark"] .badge-green  { background: #052E16; color: #34D399; }
[data-theme="dark"] .badge-orange { background: #1C0F00; color: #FBB03B; }
[data-theme="dark"] .badge-red    { background: #1F0000; color: #F87171; }

/* ── Section utility ── */
.section { padding: 80px 5%; }
.container { max-width: 1100px; margin: 0 auto; }
.grid-2 { display: grid; grid-template-columns: repeat(auto-fit, minmax(260px, 1fr)); gap: 20px; }
.grid-3 { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 20px; }

/* ── Divider ── */
.divider { border: none; border-top: 1.5px solid var(--border); margin: 24px 0; }
EOF

# ── THEME HOOK ────────────────────────────────────────────────
cat > lib/useTheme.ts << 'EOF'
'use client';
import { useEffect, useState } from 'react';

export function useTheme() {
  const [theme, setTheme] = useState<'light' | 'dark'>('light');
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    const saved = (localStorage.getItem('cv-theme') as 'light' | 'dark') ?? 'light';
    setTheme(saved);
    document.documentElement.setAttribute('data-theme', saved);
    setMounted(true);
  }, []);

  const toggle = () => {
    const next = theme === 'light' ? 'dark' : 'light';
    setTheme(next);
    localStorage.setItem('cv-theme', next);
    document.documentElement.setAttribute('data-theme', next);
  };

  return { theme, toggle, mounted };
}
EOF

# ── THEME TOGGLE ──────────────────────────────────────────────
cat > components/ThemeToggle.tsx << 'EOF'
'use client';
import { Sun, Moon } from 'lucide-react';
import { useTheme } from '@/lib/useTheme';

export default function ThemeToggle({ size = 'md' }: { size?: 'sm' | 'md' }) {
  const { theme, toggle, mounted } = useTheme();
  if (!mounted) return <div style={{ width: size === 'sm' ? 32 : 38, height: size === 'sm' ? 32 : 38 }} />;
  return (
    <button onClick={toggle} aria-label="Toggle theme" className="btn-ghost"
      style={{ width: size === 'sm' ? 32 : 38, height: size === 'sm' ? 32 : 38, padding: 0, borderRadius: 10, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
      {theme === 'light' ? <Moon size={size === 'sm' ? 16 : 18} /> : <Sun size={size === 'sm' ? 16 : 18} />}
    </button>
  );
}
EOF

# ── APP LAYOUT ────────────────────────────────────────────────
cat > app/layout.tsx << 'EOF'
import type { Metadata, Viewport } from 'next';
import { Toaster } from 'react-hot-toast';
import './globals.css';

export const metadata: Metadata = {
  metadataBase: new URL('https://csvault.xyz'),
  title: { default: 'CS-Vault | School Project Repository', template: '%s | CS-Vault' },
  description: 'CS-Vault is a school project repository platform for Computer Science students and lecturers.',
  manifest: '/manifest.json',
  appleWebApp: { capable: true, statusBarStyle: 'default', title: 'CS-Vault' },
  icons: {
    icon: [{ url: '/favicon-16x16.png', sizes: '16x16' }, { url: '/favicon-32x32.png', sizes: '32x32' }, { url: '/favicon.ico' }],
    apple: [{ url: '/apple-touch-icon.png', sizes: '180x180' }],
  },
};

export const viewport: Viewport = {
  themeColor: [{ media: '(prefers-color-scheme: light)', color: '#7C3AED' }, { media: '(prefers-color-scheme: dark)', color: '#A78BFA' }],
  width: 'device-width', initialScale: 1, maximumScale: 1,
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <head>
        <script dangerouslySetInnerHTML={{
          __html: `(function(){var t=localStorage.getItem('cv-theme')||'light';document.documentElement.setAttribute('data-theme',t);})();`
        }} />
      </head>
      <body>
        {children}
        <Toaster position="top-center" toastOptions={{
          style: { background: 'var(--card)', color: 'var(--soft)', border: '1.5px solid var(--border)', fontFamily: "'Plus Jakarta Sans', sans-serif", fontSize: '14px', borderRadius: '12px', boxShadow: 'var(--shadow-md)' },
          success: { iconTheme: { primary: '#7C3AED', secondary: '#fff' } },
        }} />
      </body>
    </html>
  );
}
EOF

# ── ROOT PAGE ─────────────────────────────────────────────────
cat > app/page.tsx << 'EOF'
'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { getUser } from '@/lib/auth';
import LandingPage from '@/components/LandingPage';

export default function Root() {
  const router = useRouter();
  const [show, setShow] = useState(false);

  useEffect(() => {
    const user = getUser();
    if (user) { router.push(`/${user.role}`); return; }
    setShow(true);
  }, [router]);

  if (!show) return (
    <div style={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', background: 'var(--ink)' }}>
      <div style={{ width: 44, height: 44, borderRadius: 12, background: 'var(--accent)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <span style={{ color: '#fff', fontWeight: 800, fontSize: 16, fontFamily: 'JetBrains Mono' }}>CV</span>
      </div>
    </div>
  );

  return <LandingPage />;
}
EOF

# ── LANDING PAGE COMPONENT ────────────────────────────────────
cat > components/LandingPage.tsx << 'EOF'
'use client';
import { useRouter } from 'next/navigation';
import ThemeToggle from '@/components/ThemeToggle';
import {
  BookOpen, Upload, Search, Users, GraduationCap,
  Shield, ArrowRight, CheckCircle, Star,
  FolderOpen, MessageSquare, Award, Layers
} from 'lucide-react';

export default function LandingPage() {
  const router = useRouter();

  const features = [
    {
      icon: Upload,
      title: 'Project Submission',
      desc: 'Students upload PDF reports, ZIP source code and GitHub links — all from one clean interface. No more emailing attachments.',
      color: '#7C3AED',
    },
    {
      icon: Search,
      title: 'Browse Past Work',
      desc: 'Search and filter projects by course and session. See what has already been built so you never repeat work unnecessarily.',
      color: '#059669',
    },
    {
      icon: Award,
      title: 'Grades & Feedback',
      desc: 'Lecturers review submissions, assign letter grades (A–F), and leave comments. Students see feedback instantly.',
      color: '#D97706',
    },
    {
      icon: Users,
      title: 'Student Management',
      desc: 'Admins and lecturers register students with one click. Login credentials are automatically sent to their email.',
      color: '#DC2626',
    },
    {
      icon: Shield,
      title: 'Role Based Access',
      desc: 'Three secure roles — Admin, Lecturer, Student. Each person only sees and does what their role allows.',
      color: '#0891B2',
    },
    {
      icon: MessageSquare,
      title: 'Open Discussion',
      desc: 'Everyone can comment on projects. Students ask questions, lecturers give feedback, knowledge flows freely.',
      color: '#7C3AED',
    },
  ];

  const steps = [
    {
      num: '01',
      icon: GraduationCap,
      role: 'Admin',
      title: 'Set Up The Platform',
      desc: 'Admin creates courses (CSC 497 and CSC 498), adds lecturers, and assigns them to their courses. Takes under 5 minutes.',
      color: '#7C3AED',
    },
    {
      num: '02',
      icon: Users,
      role: 'Lecturer',
      title: 'Register Your Students',
      desc: 'Lecturers add students to their course. Each student automatically receives an email with their login credentials.',
      color: '#059669',
    },
    {
      num: '03',
      icon: FolderOpen,
      role: 'Student',
      title: 'Upload & Explore',
      desc: 'Students log in, submit their project, browse past work for reference, and receive grades and feedback from lecturers.',
      color: '#D97706',
    },
  ];

  const courses = [
    { code: 'CSC 497', title: 'Final Year Project I', desc: 'First semester capstone project submission and review.' },
    { code: 'CSC 498', title: 'Final Year Project II', desc: 'Second semester continuation and final project defence.' },
  ];

  return (
    <div style={{ minHeight: '100vh', background: 'var(--ink)' }}>

      {/* ── NAV ── */}
      <nav style={{
        position: 'fixed', top: 0, left: 0, right: 0, zIndex: 100,
        display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        padding: '0 5%', height: 66,
        background: 'var(--card)',
        borderBottom: '1.5px solid var(--border)',
        boxShadow: 'var(--shadow-sm)',
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
          <div style={{ width: 36, height: 36, borderRadius: 10, background: 'var(--accent)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <span style={{ color: '#fff', fontWeight: 800, fontSize: 14, fontFamily: 'JetBrains Mono' }}>CV</span>
          </div>
          <span style={{ fontWeight: 800, fontSize: 18, color: 'var(--soft)', letterSpacing: '-0.3px' }}>CS-Vault</span>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
          <ThemeToggle />
          <button className="btn btn-primary btn-sm" onClick={() => router.push('/login')}>
            Sign In <ArrowRight size={15} />
          </button>
        </div>
      </nav>

      {/* ── HERO ── */}
      <section style={{
        minHeight: '100vh', paddingTop: 66,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        textAlign: 'center', padding: '130px 5% 80px',
        background: 'var(--ink)',
        position: 'relative', overflow: 'hidden',
      }}>
        {/* Decorative blobs */}
        <div style={{
          position: 'absolute', width: 500, height: 500, borderRadius: '50%',
          background: 'var(--accent-glow)', filter: 'blur(80px)',
          top: '10%', left: '50%', transform: 'translateX(-50%)',
          pointerEvents: 'none',
        }} />
        <div style={{
          position: 'absolute', width: 300, height: 300, borderRadius: '50%',
          background: 'var(--accent-glow)', filter: 'blur(60px)',
          bottom: '15%', right: '10%',
          pointerEvents: 'none',
        }} />

        <div style={{ position: 'relative', zIndex: 1, maxWidth: 720 }}>
          {/* Pill */}
          <div className="fade-up" style={{
            display: 'inline-flex', alignItems: 'center', gap: 6,
            background: 'var(--accent-light)', color: 'var(--accent)',
            padding: '6px 16px', borderRadius: 99, fontSize: 13, fontWeight: 600,
            marginBottom: 28, border: '1px solid var(--border)',
          }}>
            <Star size={12} fill="currentColor" />
            Built for Computer Science Final Year Students
          </div>

          {/* Headline */}
          <h1 className="fade-up delay-1" style={{
            fontSize: 'clamp(36px, 6vw, 68px)', fontWeight: 800,
            color: 'var(--soft)', letterSpacing: '-2px', lineHeight: 1.08,
            marginBottom: 22,
          }}>
            Your CS Projects,<br />
            <span style={{
              background: 'linear-gradient(135deg, var(--accent) 0%, #C084FC 100%)',
              WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent',
            }}>
              All in One Place
            </span>
          </h1>

          {/* Sub */}
          <p className="fade-up delay-2" style={{
            fontSize: 18, color: 'var(--muted)', maxWidth: 560, margin: '0 auto 40px',
            lineHeight: 1.75,
          }}>
            CS-Vault is the official project repository for the Computer Science department. Submit your work, reference past projects, get graded — all from one platform.
          </p>

          {/* CTAs */}
          <div className="fade-up delay-3" style={{ display: 'flex', gap: 14, justifyContent: 'center', flexWrap: 'wrap', marginBottom: 56 }}>
            <button className="btn btn-primary btn-lg" onClick={() => router.push('/login')}>
              Get Started <ArrowRight size={20} />
            </button>
            <button className="btn btn-secondary btn-lg"
              onClick={() => document.getElementById('features')?.scrollIntoView({ behavior: 'smooth' })}>
              See How It Works
            </button>
          </div>

          {/* Trust row */}
          <div className="fade-up delay-4" style={{ display: 'flex', gap: 28, justifyContent: 'center', flexWrap: 'wrap' }}>
            {['CSC 497', 'CSC 498', 'PDF & ZIP Upload', 'Auto Email Credentials', 'Letter Grading'].map(f => (
              <div key={f} style={{ display: 'flex', alignItems: 'center', gap: 6, color: 'var(--muted)', fontSize: 14, fontWeight: 500 }}>
                <CheckCircle size={15} style={{ color: 'var(--accent)', flexShrink: 0 }} /> {f}
              </div>
            ))}
          </div>

          {/* Hero visual */}
          <div className="fade-up delay-5 float" style={{
            marginTop: 56, display: 'flex', gap: 16, justifyContent: 'center', flexWrap: 'wrap',
          }}>
            {[
              { icon: BookOpen, label: 'CSC 497', sub: '12 Projects', color: '#7C3AED' },
              { icon: FolderOpen, label: 'CSC 498', sub: '8 Projects', color: '#059669' },
              { icon: Award, label: 'Grades', sub: 'A – F Scale', color: '#D97706' },
            ].map(card => (
              <div key={card.label} className="card" style={{
                padding: '20px 24px', display: 'flex', alignItems: 'center', gap: 14, minWidth: 180,
              }}>
                <div style={{ width: 44, height: 44, borderRadius: 12, background: `${card.color}18`, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
                  <card.icon size={22} style={{ color: card.color }} />
                </div>
                <div style={{ textAlign: 'left' }}>
                  <div style={{ fontWeight: 700, fontSize: 15, color: 'var(--soft)' }}>{card.label}</div>
                  <div style={{ fontSize: 13, color: 'var(--muted)' }}>{card.sub}</div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ── COURSES ── */}
      <section style={{ background: 'var(--surface)', padding: '72px 5%', borderTop: '1.5px solid var(--border)' }}>
        <div className="container" style={{ textAlign: 'center' }}>
          <div style={{ display: 'inline-flex', alignItems: 'center', gap: 6, background: 'var(--accent-light)', color: 'var(--accent)', padding: '5px 14px', borderRadius: 99, fontSize: 12, fontWeight: 700, textTransform: 'uppercase', letterSpacing: '0.5px', marginBottom: 16 }}>
            <Layers size={12} /> Supported Courses
          </div>
          <h2 style={{ fontSize: 'clamp(22px, 3.5vw, 32px)', fontWeight: 800, color: 'var(--soft)', letterSpacing: '-0.5px', marginBottom: 10 }}>
            Two courses, one platform
          </h2>
          <p style={{ color: 'var(--muted)', fontSize: 16, marginBottom: 40, maxWidth: 440, margin: '0 auto 40px' }}>
            CS-Vault is purpose-built for final year project management.
          </p>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))', gap: 20, maxWidth: 700, margin: '0 auto' }}>
            {courses.map((c, i) => (
              <div key={c.code} className={`card fade-up delay-${i + 1 as 1 | 2}`} style={{ padding: '28px 24px', textAlign: 'left' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 14 }}>
                  <div style={{ width: 48, height: 48, borderRadius: 14, background: 'var(--accent-light)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                    <BookOpen size={24} style={{ color: 'var(--accent)' }} />
                  </div>
                  <div>
                    <div className="mono" style={{ fontSize: 13, color: 'var(--accent)', fontWeight: 600 }}>{c.code}</div>
                    <div style={{ fontSize: 16, fontWeight: 700, color: 'var(--soft)' }}>{c.title}</div>
                  </div>
                </div>
                <p style={{ fontSize: 14, color: 'var(--muted)', lineHeight: 1.6 }}>{c.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ── FEATURES ── */}
      <section id="features" style={{ padding: '80px 5%' }}>
        <div className="container">
          <div style={{ textAlign: 'center', marginBottom: 56 }}>
            <div style={{ display: 'inline-flex', alignItems: 'center', gap: 6, background: 'var(--accent-light)', color: 'var(--accent)', padding: '5px 14px', borderRadius: 99, fontSize: 12, fontWeight: 700, textTransform: 'uppercase', letterSpacing: '0.5px', marginBottom: 16 }}>
              <Star size={12} /> Features
            </div>
            <h2 style={{ fontSize: 'clamp(22px, 3.5vw, 36px)', fontWeight: 800, color: 'var(--soft)', letterSpacing: '-0.5px', marginBottom: 10 }}>
              Everything your department needs
            </h2>
            <p style={{ color: 'var(--muted)', fontSize: 16, maxWidth: 480, margin: '0 auto' }}>
              A complete platform built specifically for managing, submitting, and reviewing Computer Science final year projects.
            </p>
          </div>
          <div className="grid-3">
            {features.map((f, i) => (
              <div key={f.title} className={`card card-hover fade-up delay-${Math.min(i + 1, 5) as 1|2|3|4|5}`} style={{ padding: '28px 24px' }}>
                <div style={{ width: 52, height: 52, borderRadius: 14, background: `${f.color}15`, display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 18 }}>
                  <f.icon size={26} style={{ color: f.color }} />
                </div>
                <h3 style={{ fontSize: 17, fontWeight: 700, color: 'var(--soft)', marginBottom: 10 }}>{f.title}</h3>
                <p style={{ fontSize: 14, color: 'var(--muted)', lineHeight: 1.7 }}>{f.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ── HOW IT WORKS ── */}
      <section style={{ background: 'var(--surface)', padding: '80px 5%', borderTop: '1.5px solid var(--border)' }}>
        <div className="container">
          <div style={{ textAlign: 'center', marginBottom: 56 }}>
            <div style={{ display: 'inline-flex', alignItems: 'center', gap: 6, background: 'var(--accent-light)', color: 'var(--accent)', padding: '5px 14px', borderRadius: 99, fontSize: 12, fontWeight: 700, textTransform: 'uppercase', letterSpacing: '0.5px', marginBottom: 16 }}>
              <CheckCircle size={12} /> How It Works
            </div>
            <h2 style={{ fontSize: 'clamp(22px, 3.5vw, 36px)', fontWeight: 800, color: 'var(--soft)', letterSpacing: '-0.5px', marginBottom: 10 }}>
              Up and running in three steps
            </h2>
            <p style={{ color: 'var(--muted)', fontSize: 16, maxWidth: 440, margin: '0 auto' }}>
              Simple enough for any user, powerful enough for the whole department.
            </p>
          </div>
          <div className="grid-3">
            {steps.map((step, i) => (
              <div key={step.num} className={`card fade-up delay-${i + 1 as 1|2|3}`} style={{ padding: '32px 28px', position: 'relative', overflow: 'hidden' }}>
                <div style={{ position: 'absolute', top: 20, right: 20, fontFamily: 'JetBrains Mono', fontSize: 52, fontWeight: 900, color: 'var(--border)', lineHeight: 1, pointerEvents: 'none' }}>
                  {step.num}
                </div>
                <div style={{ width: 52, height: 52, borderRadius: 14, background: `${step.color}15`, display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 16 }}>
                  <step.icon size={26} style={{ color: step.color }} />
                </div>
                <span className="badge badge-purple" style={{ marginBottom: 12 }}>{step.role}</span>
                <h3 style={{ fontSize: 18, fontWeight: 700, color: 'var(--soft)', marginBottom: 10 }}>{step.title}</h3>
                <p style={{ fontSize: 14, color: 'var(--muted)', lineHeight: 1.7 }}>{step.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ── CTA BANNER ── */}
      <section style={{ padding: '80px 5%' }}>
        <div className="container">
          <div style={{
            background: 'linear-gradient(135deg, var(--accent) 0%, #9333EA 100%)',
            borderRadius: 24, padding: '56px 48px', textAlign: 'center',
            position: 'relative', overflow: 'hidden',
            boxShadow: '0 16px 48px var(--accent-glow)',
          }}>
            <div style={{ position: 'absolute', width: 300, height: 300, borderRadius: '50%', background: 'rgba(255,255,255,0.06)', top: -80, right: -60, pointerEvents: 'none' }} />
            <div style={{ position: 'absolute', width: 200, height: 200, borderRadius: '50%', background: 'rgba(255,255,255,0.04)', bottom: -60, left: -40, pointerEvents: 'none' }} />
            <h2 style={{ fontSize: 'clamp(22px, 3.5vw, 36px)', fontWeight: 800, color: '#fff', letterSpacing: '-0.5px', marginBottom: 14, position: 'relative' }}>
              Ready to get started?
            </h2>
            <p style={{ color: 'rgba(255,255,255,0.82)', fontSize: 16, marginBottom: 32, maxWidth: 420, margin: '0 auto 32px', position: 'relative', lineHeight: 1.7 }}>
              Contact your lecturer to get your login credentials, then sign in to CS-Vault and start uploading.
            </p>
            <button onClick={() => router.push('/login')}
              style={{
                background: '#fff', color: 'var(--accent)', border: 'none', borderRadius: 12,
                padding: '14px 32px', fontSize: 15, fontWeight: 700, cursor: 'pointer',
                display: 'inline-flex', alignItems: 'center', gap: 8,
                boxShadow: '0 4px 16px rgba(0,0,0,0.15)', transition: 'all 0.2s',
                position: 'relative',
              }}
              onMouseEnter={e => { (e.currentTarget as HTMLButtonElement).style.transform = 'translateY(-2px)'; }}
              onMouseLeave={e => { (e.currentTarget as HTMLButtonElement).style.transform = 'translateY(0)'; }}>
              Sign In to CS-Vault <ArrowRight size={17} />
            </button>
          </div>
        </div>
      </section>

      {/* ── FOOTER ── */}
      <footer style={{ borderTop: '1.5px solid var(--border)', background: 'var(--card)', padding: '48px 5%' }}>
        <div className="container" style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 24, textAlign: 'center' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
            <div style={{ width: 34, height: 34, borderRadius: 10, background: 'var(--accent)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <span style={{ color: '#fff', fontWeight: 800, fontSize: 13 }}>CV</span>
            </div>
            <span style={{ fontWeight: 800, fontSize: 17, color: 'var(--soft)' }}>CS-Vault</span>
          </div>
          <p style={{ color: 'var(--muted)', fontSize: 14, maxWidth: 480, lineHeight: 1.7 }}>
            A school project repository platform built for the Computer Science department. Upload, reference, and manage academic projects with ease.
          </p>
          <div>
            <p style={{ fontSize: 13, color: 'var(--muted)', marginBottom: 12, fontWeight: 600, textTransform: 'uppercase', letterSpacing: '0.5px' }}>Developed by</p>
            <div style={{ display: 'flex', gap: 10, flexWrap: 'wrap', justifyContent: 'center' }}>
              {['Anonymous', 'Olamide', 'Vendel'].map(name => (
                <span key={name} className="badge badge-purple" style={{ padding: '7px 16px', fontSize: 13 }}>{name}</span>
              ))}
            </div>
          </div>
          <p style={{ color: 'var(--muted)', fontSize: 13 }}>© {new Date().getFullYear()} CS-Vault · Computer Science Department</p>
        </div>
      </footer>
    </div>
  );
}
EOF

# ── LAYOUT COMPONENT ──────────────────────────────────────────
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
    { href: '/lecturer/projects', label: 'All Projects', icon: FolderOpen },
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
  const name = user?.name ?? user?.full_name ?? '';

  if (!mounted) return (
    <div style={{ minHeight: '100vh', background: 'var(--ink)' }}>
      <div style={{ height: 66, background: 'var(--card)', borderBottom: '1.5px solid var(--border)' }} />
    </div>
  );

  const navLink = (href: string, label: string, Icon: React.ElementType, onClick?: () => void) => {
    const active = pathname === href;
    return (
      <Link key={href} href={href} onClick={onClick} style={{
        display: 'flex', alignItems: 'center', gap: 12,
        padding: '11px 14px', borderRadius: 10, fontSize: 15,
        fontWeight: active ? 700 : 500, textDecoration: 'none',
        transition: 'all 0.15s ease',
        background: active ? 'var(--accent-light)' : 'transparent',
        color: active ? 'var(--accent)' : 'var(--muted)',
        borderLeft: `3px solid ${active ? 'var(--accent)' : 'transparent'}`,
      }}>
        <Icon size={18} />{label}
      </Link>
    );
  };

  return (
    <div style={{ minHeight: '100vh', background: 'var(--ink)' }}>
      {/* Header */}
      <header style={{
        position: 'sticky', top: 0, zIndex: 50,
        background: 'var(--card)', borderBottom: '1.5px solid var(--border)',
        display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        padding: '0 20px', height: 66, boxShadow: 'var(--shadow-sm)',
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
          <button onClick={() => setOpen(!open)} className="btn-ghost" style={{ display: 'flex' }}
            aria-label="Menu">
            {open ? <X size={22} /> : <Menu size={22} />}
          </button>
          <Link href={`/${user?.role}`} style={{ display: 'flex', alignItems: 'center', gap: 10, textDecoration: 'none' }}>
            <div style={{ width: 34, height: 34, borderRadius: 10, background: 'var(--accent)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <span style={{ color: '#fff', fontWeight: 800, fontSize: 14, fontFamily: 'JetBrains Mono' }}>CV</span>
            </div>
            <span className="hidden-mobile" style={{ fontWeight: 800, fontSize: 17, color: 'var(--soft)', letterSpacing: '-0.3px' }}>CS-Vault</span>
          </Link>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
          <span style={{ fontSize: 14, color: 'var(--muted)', fontWeight: 500, display: 'none' }} className="sm-show">{name}</span>
          <span className="badge badge-purple" style={{ fontSize: 11 }}>{user?.role}</span>
          <ThemeToggle size="sm" />
          <button onClick={logout} className="btn-ghost" aria-label="Logout"><LogOut size={18} /></button>
        </div>
      </header>

      <div style={{ display: 'flex' }}>
        {/* Desktop sidebar */}
        <aside style={{
          display: 'none', flexDirection: 'column', width: 240,
          background: 'var(--card)', borderRight: '1.5px solid var(--border)',
          padding: '20px 12px', position: 'sticky', top: 66,
          height: 'calc(100vh - 66px)', gap: 3, overflowY: 'auto',
        }} className="sidebar-desktop">
          {items.map(({ href, label, icon: Icon }) => navLink(href, label, Icon))}
          <div style={{ marginTop: 'auto', paddingTop: 12, borderTop: '1.5px solid var(--border)' }}>
            {navLink('/profile', 'Profile', Settings)}
          </div>
        </aside>

        {/* Mobile drawer */}
        {open && (
          <div style={{ position: 'fixed', inset: 0, zIndex: 40 }} onClick={() => setOpen(false)}>
            <div style={{ position: 'absolute', inset: 0, background: 'rgba(0,0,0,0.5)', backdropFilter: 'blur(2px)' }} />
            <aside style={{
              position: 'absolute', top: 66, left: 0, bottom: 0, width: 268,
              background: 'var(--card)', borderRight: '1.5px solid var(--border)',
              padding: '16px 12px', display: 'flex', flexDirection: 'column', gap: 3,
              overflowY: 'auto',
            }} onClick={e => e.stopPropagation()}>
              <div style={{ padding: '0 14px 16px', borderBottom: '1.5px solid var(--border)', marginBottom: 8 }}>
                <p style={{ fontSize: 16, fontWeight: 700, color: 'var(--soft)' }}>{name}</p>
                <p style={{ fontSize: 13, color: 'var(--muted)', marginTop: 2 }}>{user?.role}</p>
              </div>
              {items.map(({ href, label, icon: Icon }) => navLink(href, label, Icon, () => setOpen(false)))}
              <div style={{ marginTop: 'auto', paddingTop: 12, borderTop: '1.5px solid var(--border)' }}>
                {navLink('/profile', 'Profile', Settings, () => setOpen(false))}
              </div>
            </aside>
          </div>
        )}

        {/* Main */}
        <main style={{ flex: 1, padding: '28px 20px', maxWidth: 1040, width: '100%', margin: '0 auto', paddingBottom: 80 }}>
          {children}
        </main>
      </div>

      {/* Mobile bottom nav */}
      <nav style={{
        position: 'fixed', bottom: 0, left: 0, right: 0, zIndex: 30,
        background: 'var(--card)', borderTop: '1.5px solid var(--border)',
        display: 'flex', justifyContent: 'space-around', padding: '6px 0 8px',
        boxShadow: '0 -4px 16px rgba(0,0,0,0.08)',
      }} className="bottom-nav">
        {items.map(({ href, label, icon: Icon }) => {
          const active = pathname === href;
          return (
            <Link key={href} href={href} style={{
              display: 'flex', flexDirection: 'column', alignItems: 'center',
              gap: 3, padding: '4px 16px', textDecoration: 'none', minWidth: 60,
              color: active ? 'var(--accent)' : 'var(--muted)',
            }}>
              <Icon size={22} />
              <span style={{ fontSize: 10, fontWeight: active ? 700 : 500 }}>{label}</span>
            </Link>
          );
        })}
      </nav>
    </div>
  );
}
EOF

# ── SHARED COMPONENTS ─────────────────────────────────────────
cat > components/PageHeader.tsx << 'EOF'
export default function PageHeader({ title, subtitle, action }: {
  title: string; subtitle?: string; action?: React.ReactNode;
}) {
  return (
    <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', marginBottom: 28, gap: 16, flexWrap: 'wrap' }}>
      <div>
        <h1 style={{ fontSize: 26, fontWeight: 800, color: 'var(--soft)', letterSpacing: '-0.4px', lineHeight: 1.2 }}>{title}</h1>
        {subtitle && <p style={{ fontSize: 15, color: 'var(--muted)', marginTop: 5, fontWeight: 400 }}>{subtitle}</p>}
      </div>
      {action && <div style={{ flexShrink: 0 }}>{action}</div>}
    </div>
  );
}
EOF

cat > components/StatCard.tsx << 'EOF'
import { LucideIcon } from 'lucide-react';
export default function StatCard({ label, value, icon: Icon, color = 'purple' }: {
  label: string; value: string | number; icon: LucideIcon; color?: 'purple' | 'green' | 'orange' | 'red';
}) {
  const colors = {
    purple: { bg: 'var(--accent-light)', icon: 'var(--accent)' },
    green:  { bg: '#ECFDF5', icon: '#059669' },
    orange: { bg: '#FFF7ED', icon: '#D97706' },
    red:    { bg: '#FEF2F2', icon: '#DC2626' },
  };
  const c = colors[color];
  return (
    <div className="card" style={{ padding: '22px 24px', display: 'flex', alignItems: 'center', gap: 18 }}>
      <div style={{ width: 52, height: 52, borderRadius: 14, background: c.bg, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
        <Icon size={24} style={{ color: c.icon }} />
      </div>
      <div>
        <p style={{ fontSize: 30, fontWeight: 800, color: 'var(--soft)', lineHeight: 1 }}>{value}</p>
        <p style={{ fontSize: 14, color: 'var(--muted)', marginTop: 5, fontWeight: 500 }}>{label}</p>
      </div>
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
    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '72px 20px', textAlign: 'center' }}>
      <div style={{ width: 72, height: 72, borderRadius: 20, background: 'var(--accent-light)', display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 20 }}>
        <Icon size={32} style={{ color: 'var(--accent)' }} />
      </div>
      <h3 style={{ fontSize: 19, fontWeight: 700, color: 'var(--soft)', marginBottom: 8 }}>{title}</h3>
      <p style={{ fontSize: 15, color: 'var(--muted)', maxWidth: 340, lineHeight: 1.65 }}>{subtitle}</p>
    </div>
  );
}
EOF

cat > components/ProjectCard.tsx << 'EOF'
import Link from 'next/link';
import { FileText, GitBranch, Archive, Calendar, Award } from 'lucide-react';
import { format } from 'date-fns';

const gradeConfig: Record<string, { bg: string; color: string }> = {
  A: { bg: '#ECFDF5', color: '#059669' },
  B: { bg: 'var(--accent-light)', color: 'var(--accent)' },
  C: { bg: '#FFF7ED', color: '#D97706' },
  D: { bg: '#FFFBEB', color: '#B45309' },
  E: { bg: '#FEF2F2', color: '#DC2626' },
  F: { bg: '#FEF2F2', color: '#991B1B' },
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

  return (
    <Link href={href ?? `/student/projects/${project.id}`} style={{ textDecoration: 'none', display: 'block' }}>
      <div className="card card-hover" style={{ padding: '20px 22px', cursor: 'pointer' }}>
        <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: 12, marginBottom: 10 }}>
          <h3 style={{ fontSize: 16, fontWeight: 700, color: 'var(--soft)', lineHeight: 1.4 }}>{project.title}</h3>
          {gc && (
            <div style={{ display: 'flex', alignItems: 'center', gap: 4, padding: '4px 10px', borderRadius: 99, background: gc.bg, flexShrink: 0 }}>
              <Award size={12} style={{ color: gc.color }} />
              <span style={{ fontSize: 13, fontWeight: 700, color: gc.color }}>{grade}</span>
            </div>
          )}
        </div>
        {project.description && (
          <p style={{ fontSize: 14, color: 'var(--muted)', marginBottom: 14, lineHeight: 1.65, display: '-webkit-box', WebkitLineClamp: 2, WebkitBoxOrient: 'vertical', overflow: 'hidden' }}>
            {project.description}
          </p>
        )}
        <div style={{ display: 'flex', alignItems: 'center', gap: 10, flexWrap: 'wrap' }}>
          {project.courses?.course_code && (
            <span className="badge badge-purple">{project.courses.course_code}</span>
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
          <p className="mono" style={{ fontSize: 12, color: 'var(--muted)', marginTop: 12, paddingTop: 12, borderTop: '1px solid var(--border)' }}>
            {project.users.matric_number} · {project.users.full_name}
          </p>
        )}
      </div>
    </Link>
  );
}
EOF

# ── LOGIN PAGE ────────────────────────────────────────────────
cat > app/login/page.tsx << 'EOF'
'use client';
import { useState, useEffect } from 'react';
import toast from 'react-hot-toast';
import api from '@/lib/api';
import { setAuth } from '@/lib/auth';
import { Eye, EyeOff, Lock, CreditCard, ArrowLeft, ArrowRight, BookOpen } from 'lucide-react';
import ThemeToggle from '@/components/ThemeToggle';
import Link from 'next/link';

type View = 'login' | 'forgot';

export default function LoginPage() {
  const [view, setView] = useState<View>('login');
  const [form, setForm] = useState({ matric_number: '', password: '' });
  const [forgotMatric, setForgotMatric] = useState('');
  const [show, setShow] = useState(false);
  const [loading, setLoading] = useState(false);

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
      toast.error((err as { response?: { data?: { error?: string } } })?.response?.data?.error ?? 'Failed');
    } finally { setLoading(false); }
  };

  return (
    <div style={{ minHeight: '100vh', background: 'var(--ink)', display: 'flex', flexDirection: 'column' }}>
      {/* Topbar */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '14px 24px', borderBottom: '1.5px solid var(--border)', background: 'var(--card)' }}>
        <Link href="/" style={{ display: 'flex', alignItems: 'center', gap: 8, textDecoration: 'none' }}>
          <div style={{ width: 32, height: 32, borderRadius: 8, background: 'var(--accent)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <span style={{ color: '#fff', fontWeight: 800, fontSize: 13, fontFamily: 'JetBrains Mono' }}>CV</span>
          </div>
          <span style={{ fontWeight: 800, fontSize: 16, color: 'var(--soft)' }}>CS-Vault</span>
        </Link>
        <ThemeToggle />
      </div>

      <div style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', padding: '40px 20px' }}>
        <div style={{ width: '100%', maxWidth: 420 }}>

          {view === 'login' && (
            <div className="fade-up">
              <div style={{ textAlign: 'center', marginBottom: 32 }}>
                <div style={{ width: 56, height: 56, borderRadius: 16, background: 'var(--accent-light)', display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '0 auto 16px' }}>
                  <BookOpen size={28} style={{ color: 'var(--accent)' }} />
                </div>
                <h1 style={{ fontSize: 27, fontWeight: 800, color: 'var(--soft)', letterSpacing: '-0.5px', marginBottom: 8 }}>Welcome back</h1>
                <p style={{ color: 'var(--muted)', fontSize: 15 }}>Sign in to your CS-Vault account</p>
              </div>

              <div className="card" style={{ padding: '28px 28px' }}>
                <form onSubmit={handleLogin} style={{ display: 'flex', flexDirection: 'column', gap: 20 }}>
                  <div className="field">
                    <label className="label">Matric No. | Staff ID</label>
                    <div style={{ position: 'relative' }}>
                      <CreditCard size={16} style={{ position: 'absolute', left: 14, top: '50%', transform: 'translateY(-50%)', color: 'var(--muted)', pointerEvents: 'none' }} />
                      <input className="input input-icon mono"
                        placeholder="e.g. CSC/2021/001 or STAFF001"
                        value={form.matric_number}
                        onChange={e => setForm({ ...form, matric_number: e.target.value })}
                        required />
                    </div>
                  </div>

                  <div className="field">
                    <label className="label">Password</label>
                    <div style={{ position: 'relative' }}>
                      <Lock size={16} style={{ position: 'absolute', left: 14, top: '50%', transform: 'translateY(-50%)', color: 'var(--muted)', pointerEvents: 'none' }} />
                      <input className="input input-icon" type={show ? 'text' : 'password'}
                        style={{ paddingRight: 44 }}
                        placeholder="Your password"
                        value={form.password}
                        onChange={e => setForm({ ...form, password: e.target.value })}
                        required />
                      <button type="button" onClick={() => setShow(!show)}
                        style={{ position: 'absolute', right: 14, top: '50%', transform: 'translateY(-50%)', background: 'none', border: 'none', cursor: 'pointer', color: 'var(--muted)', display: 'flex', padding: 0 }}>
                        {show ? <EyeOff size={16} /> : <Eye size={16} />}
                      </button>
                    </div>
                  </div>

                  <button type="submit" className="btn btn-primary btn-full" disabled={loading}>
                    {loading ? 'Signing in...' : <><span>Sign In</span><ArrowRight size={17} /></>}
                  </button>
                </form>

                <button onClick={() => setView('forgot')}
                  style={{ width: '100%', textAlign: 'center', marginTop: 18, background: 'none', border: 'none', cursor: 'pointer', color: 'var(--muted)', fontSize: 14, fontFamily: 'Plus Jakarta Sans' }}>
                  Forgot your password?
                </button>
              </div>
            </div>
          )}

          {view === 'forgot' && (
            <div className="fade-up">
              <button onClick={() => setView('login')}
                style={{ display: 'flex', alignItems: 'center', gap: 6, background: 'none', border: 'none', cursor: 'pointer', color: 'var(--muted)', fontSize: 14, marginBottom: 24, fontFamily: 'Plus Jakarta Sans' }}>
                <ArrowLeft size={15} /> Back to login
              </button>
              <div style={{ textAlign: 'center', marginBottom: 32 }}>
                <h1 style={{ fontSize: 27, fontWeight: 800, color: 'var(--soft)', letterSpacing: '-0.5px', marginBottom: 8 }}>Reset Password</h1>
                <p style={{ color: 'var(--muted)', fontSize: 15 }}>Enter your ID and we'll send a new password to your email</p>
              </div>
              <div className="card" style={{ padding: '28px 28px' }}>
                <form onSubmit={handleForgot} style={{ display: 'flex', flexDirection: 'column', gap: 20 }}>
                  <div className="field">
                    <label className="label">Matric No. | Staff ID</label>
                    <div style={{ position: 'relative' }}>
                      <CreditCard size={16} style={{ position: 'absolute', left: 14, top: '50%', transform: 'translateY(-50%)', color: 'var(--muted)', pointerEvents: 'none' }} />
                      <input className="input input-icon mono"
                        placeholder="e.g. CSC/2021/001 or STAFF001"
                        value={forgotMatric} onChange={e => setForgotMatric(e.target.value)} required />
                    </div>
                  </div>
                  <button type="submit" className="btn btn-primary btn-full" disabled={loading}>
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

echo ""
echo "✅ LANDING PAGE + COLORS + FORMS FIXED!"
echo ""
echo "Now run:"
echo "  git add ."
echo "  git commit -m 'fix landing page, purple theme, forms'"
echo "  git push"
