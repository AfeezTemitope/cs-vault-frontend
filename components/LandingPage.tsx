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
