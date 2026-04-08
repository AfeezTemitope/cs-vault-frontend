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
