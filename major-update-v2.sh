#!/bin/bash
# ============================================================
#  CS-VAULT — Major Update V2
#  Run from INSIDE cs-vault-frontend/
# ============================================================

echo "🚀 Building CS-Vault V2..."

# ── 1. UPDATE GLOBALS - add status badge colors ───────────────
cat >> app/globals.css << 'EOF'

/* Status badges */
.badge-pending  { background: #FFF7ED; color: #D97706; }
.badge-approved { background: #ECFDF5; color: #059669; }
.badge-rejected { background: #FEF2F2; color: #DC2626; }
[data-theme="dark"] .badge-pending  { background: #1C0F00; color: #FBB03B; }
[data-theme="dark"] .badge-approved { background: #052E16; color: #34D399; }
[data-theme="dark"] .badge-rejected { background: #1F0000; color: #F87171; }
EOF

# ── 2. LAYOUT - logout in sidebar, not navbar ─────────────────
cat > components/Layout.tsx << 'EOF'
'use client';
import { useState, useEffect } from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { getUser, logout, User } from '@/lib/auth';
import ThemeToggle from './ThemeToggle';
import {
  LayoutDashboard, BookOpen, Upload, Search,
  Users, GraduationCap, Menu, X,
  Settings, FolderOpen, UserPlus, LogOut
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
  const name = user?.name ?? user?.full_name ?? '';

  if (!mounted) return (
    <div style={{ minHeight: '100vh', background: 'var(--ink)' }}>
      <div style={{ height: 66, background: 'var(--card)', borderBottom: '1.5px solid var(--border)' }} />
    </div>
  );

  const SideLink = ({ href, label, Icon, onClick }: { href: string; label: string; Icon: React.ElementType; onClick?: () => void }) => {
    const active = pathname === href;
    return (
      <Link href={href} onClick={onClick} style={{
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

  const LogoutBtn = ({ onClick }: { onClick?: () => void }) => (
    <button onClick={() => { onClick?.(); logout(); }}
      style={{
        display: 'flex', alignItems: 'center', gap: 12,
        padding: '11px 14px', borderRadius: 10, fontSize: 15,
        fontWeight: 500, cursor: 'pointer', width: '100%',
        background: 'none', border: 'none', color: 'var(--muted)',
        borderLeft: '3px solid transparent', transition: 'all 0.15s',
        fontFamily: 'Plus Jakarta Sans, sans-serif',
      }}
      onMouseEnter={e => { (e.currentTarget as HTMLButtonElement).style.color = '#DC2626'; (e.currentTarget as HTMLButtonElement).style.background = '#FEF2F2'; }}
      onMouseLeave={e => { (e.currentTarget as HTMLButtonElement).style.color = 'var(--muted)'; (e.currentTarget as HTMLButtonElement).style.background = 'none'; }}>
      <LogOut size={18} /> Logout
    </button>
  );

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
          <button onClick={() => setOpen(!open)} className="mobile-only"
            style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--muted)', display: 'flex', padding: 6 }}>
            {open ? <X size={22} /> : <Menu size={22} />}
          </button>
          <Link href={`/${user?.role}`} style={{ display: 'flex', alignItems: 'center', gap: 10, textDecoration: 'none' }}>
            <div style={{ width: 34, height: 34, borderRadius: 10, background: 'var(--accent)', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
              <span style={{ color: '#fff', fontWeight: 800, fontSize: 14, fontFamily: 'JetBrains Mono' }}>CV</span>
            </div>
            <span style={{ fontWeight: 800, fontSize: 17, color: 'var(--soft)', letterSpacing: '-0.3px' }}>CS-Vault</span>
          </Link>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
          <span className="desktop-only" style={{ fontSize: 14, color: 'var(--muted)', fontWeight: 500 }}>{name}</span>
          <span className="badge badge-purple" style={{ fontSize: 11 }}>{user?.role}</span>
          <ThemeToggle size="sm" />
        </div>
      </header>

      <div style={{ display: 'flex' }}>
        {/* Desktop sidebar */}
        <aside className="sidebar-desktop" style={{
          flexDirection: 'column', width: 240,
          background: 'var(--card)', borderRight: '1.5px solid var(--border)',
          padding: '20px 12px', position: 'sticky', top: 66,
          height: 'calc(100vh - 66px)', gap: 3, overflowY: 'auto',
        }}>
          {items.map(({ href, label, icon: Icon }) => (
            <SideLink key={href} href={href} label={label} Icon={Icon} />
          ))}
          <div style={{ marginTop: 'auto', paddingTop: 12, borderTop: '1.5px solid var(--border)', display: 'flex', flexDirection: 'column', gap: 3 }}>
            <SideLink href="/profile" label="Profile" Icon={Settings} />
            <LogoutBtn />
          </div>
        </aside>

        {/* Mobile drawer */}
        {open && (
          <div style={{ position: 'fixed', inset: 0, zIndex: 40 }} onClick={() => setOpen(false)}>
            <div style={{ position: 'absolute', inset: 0, background: 'rgba(0,0,0,0.5)', backdropFilter: 'blur(2px)' }} />
            <aside style={{
              position: 'absolute', top: 66, left: 0, bottom: 0, width: 268,
              background: 'var(--card)', borderRight: '1.5px solid var(--border)',
              padding: '16px 12px', display: 'flex', flexDirection: 'column', gap: 3, overflowY: 'auto',
            }} onClick={e => e.stopPropagation()}>
              <div style={{ padding: '0 14px 16px', borderBottom: '1.5px solid var(--border)', marginBottom: 8 }}>
                <p style={{ fontSize: 16, fontWeight: 700, color: 'var(--soft)' }}>{name}</p>
                <p style={{ fontSize: 13, color: 'var(--muted)', marginTop: 2, textTransform: 'capitalize' }}>{user?.role}</p>
              </div>
              {items.map(({ href, label, icon: Icon }) => (
                <SideLink key={href} href={href} label={label} Icon={Icon} onClick={() => setOpen(false)} />
              ))}
              <div style={{ marginTop: 'auto', paddingTop: 12, borderTop: '1.5px solid var(--border)', display: 'flex', flexDirection: 'column', gap: 3 }}>
                <SideLink href="/profile" label="Profile" Icon={Settings} onClick={() => setOpen(false)} />
                <LogoutBtn onClick={() => setOpen(false)} />
              </div>
            </aside>
          </div>
        )}

        <main style={{ flex: 1, padding: '28px 20px', maxWidth: 1040, width: '100%', margin: '0 auto', paddingBottom: 100 }}>
          {children}
        </main>
      </div>

      {/* Bottom nav mobile */}
      <nav className="bottom-nav" style={{
        position: 'fixed', bottom: 0, left: 0, right: 0, zIndex: 30,
        background: 'var(--card)', borderTop: '1.5px solid var(--border)',
        justifyContent: 'space-around', padding: '6px 0 8px',
        boxShadow: '0 -4px 16px rgba(0,0,0,0.08)',
      }}>
        {items.map(({ href, label, icon: Icon }) => {
          const active = pathname === href;
          return (
            <Link key={href} href={href} style={{
              display: 'flex', flexDirection: 'column', alignItems: 'center',
              gap: 3, padding: '4px 12px', textDecoration: 'none', minWidth: 56,
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

# ── 3. UPDATED UPLOAD PAGE ────────────────────────────────────
cat > app/student/upload/page.tsx << 'EOF'
'use client';
import { useEffect, useState, useRef } from 'react';
import { useRouter } from 'next/navigation';
import { getUser, requireAuth } from '@/lib/auth';
import Layout from '@/components/Layout';
import PageHeader from '@/components/PageHeader';
import api from '@/lib/api';
import toast from 'react-hot-toast';
import { Upload, FileText, Archive, GitBranch, X, ChevronDown, Check, User, Hash } from 'lucide-react';

interface Course { id: string; title: string; course_code: string; }
const SESSIONS = ['2024/2025', '2023/2024', '2022/2023', '2021/2022'];
const YEARS = ['2026', '2025', '2024', '2023', '2022'];

function CustomSelect({ value, onChange, options, placeholder }: {
  value: string; onChange: (v: string) => void;
  options: { value: string; label: string }[]; placeholder: string;
}) {
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLDivElement>(null);
  const selected = options.find(o => o.value === value);
  useEffect(() => {
    const h = (e: MouseEvent) => { if (ref.current && !ref.current.contains(e.target as Node)) setOpen(false); };
    document.addEventListener('mousedown', h);
    return () => document.removeEventListener('mousedown', h);
  }, []);
  return (
    <div ref={ref} style={{ position: 'relative' }}>
      <button type="button" onClick={() => setOpen(!open)} style={{
        width: '100%', display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        gap: 8, padding: '12px 16px', borderRadius: 10, cursor: 'pointer',
        border: `1.5px solid ${open ? 'var(--accent)' : 'var(--border)'}`,
        background: 'var(--surface)', color: selected ? 'var(--soft)' : 'var(--muted)',
        fontSize: 15, fontFamily: 'Plus Jakarta Sans, sans-serif', fontWeight: 500,
        boxShadow: open ? '0 0 0 3px var(--accent-glow)' : 'none', transition: 'all 0.15s',
      }}>
        <span>{selected?.label ?? placeholder}</span>
        <ChevronDown size={16} style={{ flexShrink: 0, transform: open ? 'rotate(180deg)' : 'none', transition: 'transform 0.2s', color: 'var(--muted)' }} />
      </button>
      {open && (
        <div style={{
          position: 'absolute', top: 'calc(100% + 6px)', left: 0, right: 0, zIndex: 200,
          background: 'var(--card)', border: '1.5px solid var(--border)',
          borderRadius: 12, boxShadow: 'var(--shadow-md)', overflow: 'hidden', maxHeight: 220, overflowY: 'auto',
        }}>
          {options.map(o => (
            <button type="button" key={o.value} onClick={() => { onChange(o.value); setOpen(false); }}
              style={{
                width: '100%', display: 'flex', alignItems: 'center', justifyContent: 'space-between',
                gap: 8, padding: '12px 16px', cursor: 'pointer', border: 'none',
                background: value === o.value ? 'var(--accent-light)' : 'transparent',
                color: value === o.value ? 'var(--accent)' : 'var(--soft)',
                fontSize: 14, fontFamily: 'Plus Jakarta Sans, sans-serif',
                fontWeight: value === o.value ? 600 : 400, textAlign: 'left',
              }}
              onMouseEnter={e => { if (value !== o.value) (e.currentTarget as HTMLButtonElement).style.background = 'var(--surface)'; }}
              onMouseLeave={e => { if (value !== o.value) (e.currentTarget as HTMLButtonElement).style.background = 'transparent'; }}>
              <span>{o.label}</span>
              {value === o.value && <Check size={14} />}
            </button>
          ))}
        </div>
      )}
    </div>
  );
}

export default function UploadProject() {
  const router = useRouter();
  const user = getUser();
  const [courses, setCourses] = useState<Course[]>([]);
  const [form, setForm] = useState({
    title: '', abstract: '', course_id: '', session: '2024/2025',
    year: '2026', supervisor: '', github_link: '',
  });
  const [pdfFile, setPdfFile] = useState<File | null>(null);
  const [zipFile, setZipFile] = useState<File | null>(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (!requireAuth(getUser(), router, ['student'])) return;
    api.get('/projects').then(r => {
      const map: Record<string, Course> = {};
      r.data.forEach((p: { course_id: string; courses: Omit<Course, 'id'> }) => {
        if (p.courses && !map[p.course_id]) map[p.course_id] = { ...p.courses, id: p.course_id };
      });
      setCourses(Object.values(map));
    }).catch(() => {});
  }, [router]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!form.course_id) return toast.error('Please select a course');
    if (!pdfFile && !zipFile && !form.github_link) return toast.error('Attach at least one file or GitHub link');
    setLoading(true);
    try {
      const fd = new FormData();
      fd.append('title', form.title);
      fd.append('description', form.abstract);
      fd.append('course_id', form.course_id);
      fd.append('session', form.session);
      fd.append('year', form.year);
      fd.append('supervisor', form.supervisor);
      if (form.github_link) fd.append('github_link', form.github_link);
      if (pdfFile) fd.append('files', pdfFile);
      if (zipFile) fd.append('files', zipFile);
      await api.post('/projects', fd, { headers: { 'Content-Type': 'multipart/form-data' } });
      toast.success('Project submitted! Awaiting lecturer approval.');
      router.push('/student/projects');
    } catch (err: unknown) {
      toast.error((err as { response?: { data?: { error?: string } } })?.response?.data?.error ?? 'Upload failed');
    } finally { setLoading(false); }
  };

  const FileInput = ({ label, icon: Icon, file, setFile, accept, types }: {
    label: string; icon: React.ElementType; file: File | null;
    setFile: (f: File | null) => void; accept: string; types: string[];
  }) => (
    <div className="field">
      <label className="label">{label}</label>
      {file ? (
        <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '12px 16px', borderRadius: 10, border: '1.5px solid var(--accent)', background: 'var(--accent-light)' }}>
          <Icon size={16} style={{ color: 'var(--accent)', flexShrink: 0 }} />
          <span style={{ fontSize: 14, flex: 1, color: 'var(--soft)', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{file.name}</span>
          <button type="button" onClick={() => setFile(null)} style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--muted)', padding: 0, display: 'flex' }}><X size={16} /></button>
        </div>
      ) : (
        <label style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '12px 16px', borderRadius: 10, cursor: 'pointer', border: '1.5px dashed var(--border)', background: 'var(--surface)', transition: 'all 0.15s' }}
          onMouseEnter={e => { (e.currentTarget as HTMLLabelElement).style.borderColor = 'var(--accent)'; }}
          onMouseLeave={e => { (e.currentTarget as HTMLLabelElement).style.borderColor = 'var(--border)'; }}>
          <Icon size={16} style={{ color: 'var(--muted)', flexShrink: 0 }} />
          <span style={{ fontSize: 14, color: 'var(--muted)' }}>Choose {label}...</span>
          <input type="file" accept={accept} style={{ display: 'none' }}
            onChange={e => { const f = e.target.files?.[0]; if (f && types.includes(f.type)) setFile(f); else toast.error('Invalid file type'); }} />
        </label>
      )}
    </div>
  );

  return (
    <Layout>
      <PageHeader title="Upload Project" subtitle="Submit your work for lecturer review" />
      <div className="card" style={{ padding: '28px 24px', maxWidth: 680 }}>
        <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: 22 }}>

          {/* Auto-filled student info */}
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16, padding: '16px 18px', borderRadius: 12, background: 'var(--surface)', border: '1.5px solid var(--border)' }}>
            <div>
              <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 4 }}>
                <User size={13} style={{ color: 'var(--muted)' }} />
                <span style={{ fontSize: 12, color: 'var(--muted)', fontWeight: 600, textTransform: 'uppercase', letterSpacing: '0.4px' }}>Student</span>
              </div>
              <p style={{ fontSize: 15, fontWeight: 600, color: 'var(--soft)' }}>{user?.name ?? user?.full_name}</p>
            </div>
            <div>
              <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 4 }}>
                <Hash size={13} style={{ color: 'var(--muted)' }} />
                <span style={{ fontSize: 12, color: 'var(--muted)', fontWeight: 600, textTransform: 'uppercase', letterSpacing: '0.4px' }}>Matric No.</span>
              </div>
              <p className="mono" style={{ fontSize: 15, fontWeight: 600, color: 'var(--soft)' }}>{user?.matric_number}</p>
            </div>
          </div>

          <div className="field">
            <label className="label">Project Title *</label>
            <input className="input" required placeholder="e.g. Smart Attendance System"
              value={form.title} onChange={e => setForm({ ...form, title: e.target.value })} />
          </div>

          <div className="field">
            <label className="label">Abstract *</label>
            <textarea className="input" rows={4} required
              placeholder="Brief summary of your project — what it does, how it works, and what problem it solves..."
              style={{ resize: 'vertical' }}
              value={form.abstract} onChange={e => setForm({ ...form, abstract: e.target.value })} />
          </div>

          <div className="field">
            <label className="label">Supervisor *</label>
            <input className="input" required placeholder="e.g. Dr. Olamide Macfish"
              value={form.supervisor} onChange={e => setForm({ ...form, supervisor: e.target.value })} />
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 16 }}>
            <div className="field">
              <label className="label">Course *</label>
              <CustomSelect value={form.course_id} onChange={v => setForm({ ...form, course_id: v })}
                options={courses.map(c => ({ value: c.id, label: c.course_code }))}
                placeholder="Select..." />
            </div>
            <div className="field">
              <label className="label">Session *</label>
              <CustomSelect value={form.session} onChange={v => setForm({ ...form, session: v })}
                options={SESSIONS.map(s => ({ value: s, label: s }))} placeholder="Session" />
            </div>
            <div className="field">
              <label className="label">Year *</label>
              <CustomSelect value={form.year} onChange={v => setForm({ ...form, year: v })}
                options={YEARS.map(y => ({ value: y, label: y }))} placeholder="Year" />
            </div>
          </div>

          <FileInput label="PDF Report *" icon={FileText} file={pdfFile} setFile={setPdfFile}
            accept=".pdf" types={['application/pdf']} />
          <FileInput label="Source Code (ZIP)" icon={Archive} file={zipFile} setFile={setZipFile}
            accept=".zip" types={['application/zip', 'application/x-zip-compressed']} />

          <div className="field">
            <label className="label" style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
              <GitBranch size={14} /> GitHub Link <span style={{ fontWeight: 400, color: 'var(--muted)', fontSize: 13 }}>(optional)</span>
            </label>
            <input className="input mono" placeholder="https://github.com/username/repo"
              value={form.github_link} onChange={e => setForm({ ...form, github_link: e.target.value })} />
          </div>

          <div style={{ padding: '12px 16px', borderRadius: 10, background: '#FFF7ED', border: '1.5px solid #FDE68A' }}>
            <p style={{ fontSize: 13, color: '#92400E', fontWeight: 500 }}>
              ⚠️ After submission your project will be reviewed by your lecturer before appearing in the public repository.
            </p>
          </div>

          <button type="submit" className="btn btn-primary btn-full" disabled={loading} style={{ padding: '14px 24px', fontSize: 15, marginTop: 4 }}>
            <Upload size={18} />
            {loading ? 'Submitting...' : 'Submit Project'}
          </button>
        </form>
      </div>
    </Layout>
  );
}
EOF

# ── 4. PUBLIC REPOSITORY PAGE (no login required) ────────────
mkdir -p app/repository
cat > app/repository/page.tsx << 'EOF'
'use client';
import { useEffect, useState, useRef } from 'react';
import Link from 'next/link';
import ThemeToggle from '@/components/ThemeToggle';
import api from '@/lib/api';
import { Search, Download, Eye, BookOpen, ChevronDown, Check, ArrowLeft, FileText, GitBranch, Archive, Filter } from 'lucide-react';
import { format } from 'date-fns';

interface Project {
  id: string; title: string; session: string; year?: string;
  supervisor?: string; description?: string; pdf_url?: string;
  zip_url?: string; github_link?: string; created_at?: string;
  download_count?: number;
  courses?: { title: string; course_code: string };
  users?: { full_name: string; matric_number: string };
  grades?: { grade: string };
}

function Dropdown({ value, onChange, options, placeholder }: {
  value: string; onChange: (v: string) => void;
  options: { value: string; label: string }[]; placeholder: string;
}) {
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLDivElement>(null);
  const selected = options.find(o => o.value === value);
  useEffect(() => {
    const h = (e: MouseEvent) => { if (ref.current && !ref.current.contains(e.target as Node)) setOpen(false); };
    document.addEventListener('mousedown', h);
    return () => document.removeEventListener('mousedown', h);
  }, []);
  return (
    <div ref={ref} style={{ position: 'relative' }}>
      <button type="button" onClick={() => setOpen(!open)} style={{
        display: 'flex', alignItems: 'center', gap: 8, padding: '10px 14px',
        borderRadius: 10, cursor: 'pointer', whiteSpace: 'nowrap',
        border: `1.5px solid ${open ? 'var(--accent)' : 'var(--border)'}`,
        background: 'var(--card)', color: selected ? 'var(--soft)' : 'var(--muted)',
        fontSize: 14, fontFamily: 'Plus Jakarta Sans, sans-serif', fontWeight: 500,
      }}>
        {selected?.label ?? placeholder}
        <ChevronDown size={14} style={{ transform: open ? 'rotate(180deg)' : 'none', transition: 'transform 0.2s' }} />
      </button>
      {open && (
        <div style={{
          position: 'absolute', top: 'calc(100% + 6px)', left: 0, zIndex: 200, minWidth: 180,
          background: 'var(--card)', border: '1.5px solid var(--border)',
          borderRadius: 12, boxShadow: 'var(--shadow-md)', overflow: 'hidden',
        }}>
          {options.map(o => (
            <button type="button" key={o.value} onClick={() => { onChange(o.value); setOpen(false); }}
              style={{
                width: '100%', display: 'flex', alignItems: 'center', justifyContent: 'space-between',
                gap: 8, padding: '11px 16px', cursor: 'pointer', border: 'none',
                background: value === o.value ? 'var(--accent-light)' : 'transparent',
                color: value === o.value ? 'var(--accent)' : 'var(--soft)',
                fontSize: 14, fontFamily: 'Plus Jakarta Sans, sans-serif',
                fontWeight: value === o.value ? 600 : 400, textAlign: 'left',
              }}>
              <span>{o.label}</span>
              {value === o.value && <Check size={13} />}
            </button>
          ))}
        </div>
      )}
    </div>
  );
}

export default function RepositoryPage() {
  const [projects, setProjects] = useState<Project[]>([]);
  const [search, setSearch] = useState('');
  const [filterYear, setFilterYear] = useState('');
  const [filterCourse, setFilterCourse] = useState('');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Fetch approved projects only - public endpoint
    api.get('/projects/public').then(r => setProjects(r.data)).catch(() => {}).finally(() => setLoading(false));
  }, []);

  const years = [...new Set(projects.map(p => p.year ?? new Date(p.created_at ?? '').getFullYear().toString()))].filter(Boolean);
  const courses = [...new Set(projects.map(p => p.courses?.course_code).filter(Boolean))] as string[];

  const filtered = projects.filter(p => {
    const matchSearch = !search || p.title.toLowerCase().includes(search.toLowerCase()) ||
      p.users?.full_name.toLowerCase().includes(search.toLowerCase()) ||
      p.supervisor?.toLowerCase().includes(search.toLowerCase());
    const matchYear = !filterYear || (p.year ?? '') === filterYear;
    const matchCourse = !filterCourse || p.courses?.course_code === filterCourse;
    return matchSearch && matchYear && matchCourse;
  });

  const handleDownload = async (project: Project) => {
    if (project.pdf_url) {
      window.open(project.pdf_url, '_blank');
      await api.post(`/projects/${project.id}/download`).catch(() => {});
    } else {
      toast('No PDF available for this project');
    }
  };

  return (
    <div style={{ minHeight: '100vh', background: 'var(--ink)' }}>
      {/* Nav */}
      <nav style={{
        position: 'sticky', top: 0, zIndex: 100,
        display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        padding: '0 5%', height: 66, background: 'var(--card)', borderBottom: '1.5px solid var(--border)',
        boxShadow: 'var(--shadow-sm)',
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 16 }}>
          <Link href="/" style={{ display: 'flex', alignItems: 'center', gap: 6, textDecoration: 'none', color: 'var(--muted)', fontSize: 14 }}>
            <ArrowLeft size={16} /> Home
          </Link>
          <div style={{ width: 1, height: 20, background: 'var(--border)' }} />
          <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
            <div style={{ width: 32, height: 32, borderRadius: 8, background: 'var(--accent)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <span style={{ color: '#fff', fontWeight: 800, fontSize: 13, fontFamily: 'JetBrains Mono' }}>CV</span>
            </div>
            <span style={{ fontWeight: 800, fontSize: 16, color: 'var(--soft)' }}>Project Repository</span>
          </div>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
          <ThemeToggle />
          <Link href="/login" className="btn btn-primary btn-sm" style={{ textDecoration: 'none', display: 'flex', alignItems: 'center', gap: 6, padding: '8px 16px', fontSize: 14 }}>
            Sign In
          </Link>
        </div>
      </nav>

      {/* Header */}
      <div style={{ padding: '48px 5% 32px', textAlign: 'center', background: 'var(--surface)', borderBottom: '1.5px solid var(--border)' }}>
        <div style={{ display: 'inline-flex', alignItems: 'center', gap: 6, background: 'var(--accent-light)', color: 'var(--accent)', padding: '5px 14px', borderRadius: 99, fontSize: 12, fontWeight: 700, textTransform: 'uppercase', letterSpacing: '0.5px', marginBottom: 16 }}>
          <BookOpen size={12} /> Public Repository
        </div>
        <h1 style={{ fontSize: 'clamp(24px, 4vw, 40px)', fontWeight: 800, color: 'var(--soft)', letterSpacing: '-0.5px', marginBottom: 10 }}>
          CS Project Repository
        </h1>
        <p style={{ fontSize: 16, color: 'var(--muted)', maxWidth: 500, margin: '0 auto' }}>
          Browse all approved Computer Science final year projects. Download, view and learn from past work.
        </p>
        <div style={{ marginTop: 20, display: 'flex', gap: 16, justifyContent: 'center', flexWrap: 'wrap' }}>
          {[
            { label: 'Total Projects', value: projects.length },
            { label: 'CSC 497', value: projects.filter(p => p.courses?.course_code === 'CSC 497').length },
            { label: 'CSC 498', value: projects.filter(p => p.courses?.course_code === 'CSC 498').length },
          ].map(s => (
            <div key={s.label} className="card" style={{ padding: '12px 24px', textAlign: 'center' }}>
              <p style={{ fontSize: 24, fontWeight: 800, color: 'var(--accent)' }}>{s.value}</p>
              <p style={{ fontSize: 13, color: 'var(--muted)' }}>{s.label}</p>
            </div>
          ))}
        </div>
      </div>

      {/* Filters */}
      <div style={{ padding: '24px 5%', borderBottom: '1.5px solid var(--border)', background: 'var(--card)' }}>
        <div style={{ maxWidth: 1100, margin: '0 auto', display: 'flex', gap: 12, flexWrap: 'wrap', alignItems: 'center' }}>
          <div style={{ position: 'relative', flex: 1, minWidth: 200 }}>
            <Search size={16} style={{ position: 'absolute', left: 14, top: '50%', transform: 'translateY(-50%)', color: 'var(--muted)', pointerEvents: 'none' }} />
            <input className="input" style={{ paddingLeft: 44 }}
              placeholder="Search by title, student or supervisor..."
              value={search} onChange={e => setSearch(e.target.value)} />
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
            <Filter size={15} style={{ color: 'var(--muted)' }} />
            <Dropdown value={filterYear} onChange={setFilterYear}
              options={[{ value: '', label: 'All Years' }, ...years.map(y => ({ value: y, label: y }))]}
              placeholder="All Years" />
            <Dropdown value={filterCourse} onChange={setFilterCourse}
              options={[{ value: '', label: 'All Courses' }, ...courses.map(c => ({ value: c, label: c }))]}
              placeholder="All Courses" />
            {(filterYear || filterCourse || search) && (
              <button onClick={() => { setFilterYear(''); setFilterCourse(''); setSearch(''); }}
                style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--accent)', fontSize: 13, fontFamily: 'Plus Jakarta Sans', fontWeight: 600 }}>
                Clear
              </button>
            )}
          </div>
        </div>
      </div>

      {/* Projects grid */}
      <div style={{ padding: '32px 5%', maxWidth: 1100, margin: '0 auto' }}>
        {loading ? (
          <div style={{ textAlign: 'center', padding: '60px 0', color: 'var(--muted)' }}>Loading projects...</div>
        ) : filtered.length === 0 ? (
          <div style={{ textAlign: 'center', padding: '60px 0' }}>
            <div style={{ width: 64, height: 64, borderRadius: 16, background: 'var(--accent-light)', display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '0 auto 16px' }}>
              <BookOpen size={28} style={{ color: 'var(--accent)' }} />
            </div>
            <p style={{ fontSize: 18, fontWeight: 700, color: 'var(--soft)', marginBottom: 8 }}>No projects found</p>
            <p style={{ fontSize: 14, color: 'var(--muted)' }}>Try adjusting your search or filters</p>
          </div>
        ) : (
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(320px, 1fr))', gap: 20 }}>
            {filtered.map(p => (
              <div key={p.id} className="card" style={{ padding: '22px', display: 'flex', flexDirection: 'column', gap: 12 }}>
                <div>
                  <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: 8, marginBottom: 8 }}>
                    <h3 style={{ fontSize: 16, fontWeight: 700, color: 'var(--soft)', lineHeight: 1.4 }}>{p.title}</h3>
                    {p.courses?.course_code && (
                      <span className="badge badge-purple mono" style={{ flexShrink: 0 }}>{p.courses.course_code}</span>
                    )}
                  </div>
                  {p.description && (
                    <p style={{ fontSize: 13, color: 'var(--muted)', lineHeight: 1.6, display: '-webkit-box', WebkitLineClamp: 3, WebkitBoxOrient: 'vertical', overflow: 'hidden' }}>
                      {p.description}
                    </p>
                  )}
                </div>
                <div style={{ display: 'flex', flexDirection: 'column', gap: 6, padding: '12px 0', borderTop: '1px solid var(--border)', borderBottom: '1px solid var(--border)' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                    <span style={{ fontSize: 12, color: 'var(--muted)', fontWeight: 500 }}>Student</span>
                    <span style={{ fontSize: 13, color: 'var(--soft)', fontWeight: 600 }}>{p.users?.full_name}</span>
                  </div>
                  {p.supervisor && (
                    <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                      <span style={{ fontSize: 12, color: 'var(--muted)', fontWeight: 500 }}>Supervisor</span>
                      <span style={{ fontSize: 13, color: 'var(--soft)', fontWeight: 600 }}>{p.supervisor}</span>
                    </div>
                  )}
                  <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                    <span style={{ fontSize: 12, color: 'var(--muted)', fontWeight: 500 }}>Year</span>
                    <span className="mono" style={{ fontSize: 13, color: 'var(--soft)', fontWeight: 600 }}>{p.year ?? new Date(p.created_at ?? '').getFullYear()}</span>
                  </div>
                  {p.download_count !== undefined && (
                    <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                      <span style={{ fontSize: 12, color: 'var(--muted)', fontWeight: 500 }}>Downloads</span>
                      <span className="mono" style={{ fontSize: 13, color: 'var(--accent)', fontWeight: 600 }}>{p.download_count}</span>
                    </div>
                  )}
                </div>
                <div style={{ display: 'flex', gap: 10 }}>
                  {p.pdf_url && (
                    <button onClick={() => handleDownload(p)} className="btn btn-primary btn-sm" style={{ flex: 1, justifyContent: 'center' }}>
                      <Download size={14} /> Download
                    </button>
                  )}
                  <Link href={`/repository/${p.id}`} className="btn btn-secondary btn-sm" style={{ flex: 1, justifyContent: 'center', textDecoration: 'none', display: 'flex', alignItems: 'center', gap: 6 }}>
                    <Eye size={14} /> View
                  </Link>
                  {p.github_link && (
                    <a href={p.github_link} target="_blank" rel="noopener noreferrer" className="btn btn-secondary btn-sm" style={{ padding: '8px 12px' }}>
                      <GitBranch size={14} />
                    </a>
                  )}
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Footer */}
      <footer style={{ borderTop: '1.5px solid var(--border)', padding: '24px 5%', textAlign: 'center', background: 'var(--card)' }}>
        <p style={{ fontSize: 13, color: 'var(--muted)' }}>CS-Vault Project Repository · Computer Science Department · <Link href="/" style={{ color: 'var(--accent)', textDecoration: 'none' }}>Back to Home</Link></p>
      </footer>
    </div>
  );
}
EOF

# ── 5. LECTURER PROJECTS PAGE - with approval system ─────────
cat > app/lecturer/projects/page.tsx << 'EOF'
'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { getUser, requireAuth } from '@/lib/auth';
import Layout from '@/components/Layout';
import PageHeader from '@/components/PageHeader';
import EmptyState from '@/components/EmptyState';
import api from '@/lib/api';
import toast from 'react-hot-toast';
import { FolderOpen, Search, CheckCircle, XCircle, Clock, FileText, GitBranch, Archive, Download } from 'lucide-react';
import { format } from 'date-fns';

interface Project {
  id: string; title: string; session: string; year?: string; supervisor?: string;
  description?: string; pdf_url?: string; zip_url?: string; github_link?: string;
  created_at?: string; status?: string; download_count?: number;
  courses?: { title: string; course_code: string };
  users?: { full_name: string; matric_number: string };
  grades?: { grade: string }[];
}

const STATUS_CONFIG: Record<string, { label: string; badgeClass: string; icon: React.ElementType }> = {
  pending:  { label: 'Pending',  badgeClass: 'badge badge-pending',  icon: Clock },
  approved: { label: 'Approved', badgeClass: 'badge badge-approved', icon: CheckCircle },
  rejected: { label: 'Rejected', badgeClass: 'badge badge-rejected', icon: XCircle },
};

export default function LecturerProjects() {
  const router = useRouter();
  const [projects, setProjects] = useState<Project[]>([]);
  const [search, setSearch] = useState('');
  const [filter, setFilter] = useState('all');
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (!requireAuth(getUser(), router, ['lecturer', 'admin'])) return;
    fetchProjects();
  }, [router]);

  const fetchProjects = (q = '') => {
    setLoading(true);
    api.get('/lecturer/projects', { params: q ? { search: q } : {} })
      .then(r => setProjects(r.data)).catch(() => {}).finally(() => setLoading(false));
  };

  const handleApprove = async (id: string) => {
    try {
      await api.put(`/lecturer/projects/${id}/approve`);
      toast.success('Project approved — now visible in public repository');
      fetchProjects();
    } catch { toast.error('Failed to approve'); }
  };

  const handleReject = async (id: string) => {
    try {
      await api.put(`/lecturer/projects/${id}/reject`);
      toast.success('Project rejected');
      fetchProjects();
    } catch { toast.error('Failed to reject'); }
  };

  const handleGrade = async (id: string, grade: string) => {
    try {
      await api.put(`/lecturer/projects/${id}/grade`, { grade });
      toast.success('Grade saved');
      fetchProjects();
    } catch { toast.error('Failed to grade'); }
  };

  const GRADES = ['A', 'B', 'C', 'D', 'E', 'F'];
  const filtered = projects.filter(p => {
    const matchSearch = !search || p.title.toLowerCase().includes(search.toLowerCase());
    const matchFilter = filter === 'all' || p.status === filter;
    return matchSearch && matchFilter;
  });

  const counts = {
    all: projects.length,
    pending: projects.filter(p => p.status === 'pending').length,
    approved: projects.filter(p => p.status === 'approved').length,
    rejected: projects.filter(p => p.status === 'rejected').length,
  };

  return (
    <Layout>
      <PageHeader title="Projects" subtitle="Review and approve student submissions" />

      {/* Filter tabs */}
      <div style={{ display: 'flex', gap: 8, marginBottom: 20, flexWrap: 'wrap' }}>
        {(['all', 'pending', 'approved', 'rejected'] as const).map(f => (
          <button key={f} onClick={() => setFilter(f)}
            style={{
              padding: '8px 16px', borderRadius: 10, cursor: 'pointer', fontSize: 14,
              fontWeight: filter === f ? 700 : 500, border: '1.5px solid',
              fontFamily: 'Plus Jakarta Sans, sans-serif', textTransform: 'capitalize',
              transition: 'all 0.15s',
              background: filter === f ? 'var(--accent)' : 'var(--card)',
              borderColor: filter === f ? 'var(--accent)' : 'var(--border)',
              color: filter === f ? '#fff' : 'var(--muted)',
            }}>
            {f === 'all' ? 'All' : f.charAt(0).toUpperCase() + f.slice(1)} ({counts[f]})
          </button>
        ))}
      </div>

      {/* Search */}
      <div style={{ position: 'relative', marginBottom: 20 }}>
        <Search size={16} style={{ position: 'absolute', left: 14, top: '50%', transform: 'translateY(-50%)', color: 'var(--muted)', pointerEvents: 'none' }} />
        <input className="input" style={{ paddingLeft: 44 }}
          placeholder="Search by project title..."
          value={search} onChange={e => { setSearch(e.target.value); fetchProjects(e.target.value); }} />
      </div>

      {loading ? (
        <div style={{ textAlign: 'center', padding: '40px', color: 'var(--muted)' }}>Loading...</div>
      ) : filtered.length === 0 ? (
        <EmptyState icon={FolderOpen} title="No projects found" subtitle="Projects appear here once students submit" />
      ) : (
        <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
          {filtered.map(p => {
            const status = p.status ?? 'pending';
            const sc = STATUS_CONFIG[status] ?? STATUS_CONFIG.pending;
            const currentGrade = Array.isArray(p.grades) ? p.grades[0]?.grade : undefined;
            return (
              <div key={p.id} className="card" style={{ padding: '22px 24px' }}>
                <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: 12, marginBottom: 14 }}>
                  <div style={{ flex: 1 }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: 10, flexWrap: 'wrap', marginBottom: 6 }}>
                      <h3 style={{ fontSize: 17, fontWeight: 700, color: 'var(--soft)' }}>{p.title}</h3>
                      <span className={sc.badgeClass} style={{ display: 'flex', alignItems: 'center', gap: 4 }}>
                        <sc.icon size={11} /> {sc.label}
                      </span>
                      {p.courses?.course_code && <span className="badge badge-purple mono">{p.courses.course_code}</span>}
                    </div>
                    <div style={{ display: 'flex', gap: 16, flexWrap: 'wrap' }}>
                      <span style={{ fontSize: 13, color: 'var(--muted)' }}>
                        <strong style={{ color: 'var(--soft)' }}>{p.users?.full_name}</strong> · {p.users?.matric_number}
                      </span>
                      {p.supervisor && <span style={{ fontSize: 13, color: 'var(--muted)' }}>Supervisor: <strong style={{ color: 'var(--soft)' }}>{p.supervisor}</strong></span>}
                      {p.year && <span style={{ fontSize: 13, color: 'var(--muted)' }}>Year: <strong style={{ color: 'var(--soft)' }}>{p.year}</strong></span>}
                      {p.created_at && <span style={{ fontSize: 13, color: 'var(--muted)' }}>{format(new Date(p.created_at), 'dd MMM yyyy')}</span>}
                    </div>
                  </div>
                </div>

                {p.description && (
                  <p style={{ fontSize: 14, color: 'var(--muted)', lineHeight: 1.6, marginBottom: 14, padding: '12px 14px', background: 'var(--surface)', borderRadius: 8 }}>
                    {p.description}
                  </p>
                )}

                {/* Files */}
                <div style={{ display: 'flex', gap: 8, marginBottom: 14, flexWrap: 'wrap' }}>
                  {p.pdf_url && <a href={p.pdf_url} target="_blank" rel="noopener noreferrer" className="btn btn-secondary btn-sm" style={{ textDecoration: 'none' }}><FileText size={14} /> View PDF</a>}
                  {p.zip_url && <a href={p.zip_url} target="_blank" rel="noopener noreferrer" className="btn btn-secondary btn-sm" style={{ textDecoration: 'none' }}><Archive size={14} /> Source Code</a>}
                  {p.github_link && <a href={p.github_link} target="_blank" rel="noopener noreferrer" className="btn btn-secondary btn-sm" style={{ textDecoration: 'none' }}><GitBranch size={14} /> GitHub</a>}
                  {p.download_count !== undefined && (
                    <span style={{ display: 'flex', alignItems: 'center', gap: 5, fontSize: 13, color: 'var(--muted)', padding: '8px 12px' }}>
                      <Download size={13} /> {p.download_count} downloads
                    </span>
                  )}
                </div>

                {/* Actions */}
                <div style={{ display: 'flex', gap: 10, flexWrap: 'wrap', alignItems: 'center', paddingTop: 14, borderTop: '1px solid var(--border)' }}>
                  {status === 'pending' && (
                    <>
                      <button onClick={() => handleApprove(p.id)} className="btn btn-primary btn-sm">
                        <CheckCircle size={15} /> Approve
                      </button>
                      <button onClick={() => handleReject(p.id)} className="btn btn-danger btn-sm">
                        <XCircle size={15} /> Reject
                      </button>
                    </>
                  )}
                  {status === 'approved' && (
                    <button onClick={() => handleReject(p.id)} className="btn btn-secondary btn-sm">
                      <XCircle size={15} /> Revoke Approval
                    </button>
                  )}
                  {status === 'rejected' && (
                    <button onClick={() => handleApprove(p.id)} className="btn btn-secondary btn-sm">
                      <CheckCircle size={15} /> Re-approve
                    </button>
                  )}

                  {/* Grade */}
                  <div style={{ marginLeft: 'auto', display: 'flex', alignItems: 'center', gap: 8 }}>
                    <span style={{ fontSize: 13, color: 'var(--muted)', fontWeight: 500 }}>Grade:</span>
                    <div style={{ display: 'flex', gap: 4 }}>
                      {GRADES.map(g => (
                        <button key={g} onClick={() => handleGrade(p.id, g)}
                          style={{
                            width: 32, height: 32, borderRadius: 8, cursor: 'pointer',
                            border: `1.5px solid ${currentGrade === g ? 'var(--accent)' : 'var(--border)'}`,
                            background: currentGrade === g ? 'var(--accent)' : 'var(--surface)',
                            color: currentGrade === g ? '#fff' : 'var(--muted)',
                            fontSize: 13, fontWeight: 700, fontFamily: 'JetBrains Mono',
                            transition: 'all 0.15s',
                          }}>
                          {g}
                        </button>
                      ))}
                    </div>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      )}
    </Layout>
  );
}
EOF

# ── 6. ADMIN DASHBOARD with full stats ───────────────────────
cat > app/admin/page.tsx << 'EOF'
'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { getUser, requireAuth } from '@/lib/auth';
import Layout from '@/components/Layout';
import StatCard from '@/components/StatCard';
import PageHeader from '@/components/PageHeader';
import api from '@/lib/api';
import { Users, GraduationCap, BookOpen, FolderOpen, CheckCircle, Clock, Download } from 'lucide-react';
import { format } from 'date-fns';

interface Project { id: string; title: string; status?: string; created_at?: string; users?: { full_name: string }; courses?: { course_code: string }; }

export default function AdminDashboard() {
  const router = useRouter();
  const [stats, setStats] = useState({ lecturers: 0, students: 0, courses: 0, total: 0, approved: 0, pending: 0, downloads: 0 });
  const [recent, setRecent] = useState<Project[]>([]);

  useEffect(() => {
    if (!requireAuth(getUser(), router, ['admin'])) return;
    Promise.all([
      api.get('/admin/lecturers'),
      api.get('/admin/students'),
      api.get('/admin/courses'),
      api.get('/lecturer/projects'),
    ]).then(([l, s, c, p]) => {
      const projects: Project[] = p.data;
      setStats({
        lecturers: l.data.length,
        students: s.data.length,
        courses: c.data.length,
        total: projects.length,
        approved: projects.filter((x: Project) => x.status === 'approved').length,
        pending: projects.filter((x: Project) => x.status === 'pending').length,
        downloads: 0,
      });
      setRecent(projects.slice(0, 5));
    }).catch(() => {});
  }, [router]);

  return (
    <Layout>
      <PageHeader title="Dashboard" subtitle="CS-Vault overview" />

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(160px, 1fr))', gap: 14, marginBottom: 28 }}>
        <StatCard label="Lecturers" value={stats.lecturers} icon={GraduationCap} color="purple" />
        <StatCard label="Students" value={stats.students} icon={Users} color="green" />
        <StatCard label="Courses" value={stats.courses} icon={BookOpen} color="orange" />
        <StatCard label="Total Projects" value={stats.total} icon={FolderOpen} color="purple" />
        <StatCard label="Approved" value={stats.approved} icon={CheckCircle} color="green" />
        <StatCard label="Pending" value={stats.pending} icon={Clock} color="orange" />
        <StatCard label="Downloads" value={stats.downloads} icon={Download} color="purple" />
      </div>

      {recent.length > 0 && (
        <div className="card" style={{ padding: '22px 24px' }}>
          <h2 style={{ fontSize: 16, fontWeight: 700, color: 'var(--soft)', marginBottom: 16 }}>Recent Submissions</h2>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
            {recent.map(p => (
              <div key={p.id} style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 12, padding: '10px 0', borderBottom: '1px solid var(--border)' }}>
                <div>
                  <p style={{ fontSize: 14, fontWeight: 600, color: 'var(--soft)' }}>{p.title}</p>
                  <p style={{ fontSize: 12, color: 'var(--muted)', marginTop: 2 }}>{p.users?.full_name} · {p.courses?.course_code}</p>
                </div>
                <div style={{ display: 'flex', alignItems: 'center', gap: 8, flexShrink: 0 }}>
                  <span className={`badge ${p.status === 'approved' ? 'badge-approved' : p.status === 'rejected' ? 'badge-rejected' : 'badge-pending'}`} style={{ textTransform: 'capitalize' }}>
                    {p.status ?? 'pending'}
                  </span>
                  {p.created_at && <span style={{ fontSize: 12, color: 'var(--muted)' }}>{format(new Date(p.created_at), 'dd MMM')}</span>}
                </div>
              </div>
            ))}
          </div>
        </div>
      )}
    </Layout>
  );
}
EOF

# ── 7. LECTURER DASHBOARD with stats ─────────────────────────
cat > app/lecturer/page.tsx << 'EOF'
'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { getUser, requireAuth } from '@/lib/auth';
import Layout from '@/components/Layout';
import StatCard from '@/components/StatCard';
import PageHeader from '@/components/PageHeader';
import api from '@/lib/api';
import { BookOpen, FolderOpen, CheckCircle, Clock, ArrowRight } from 'lucide-react';

interface Course { id: string; title: string; course_code: string; session: string; }
interface Project { id: string; status?: string; }

export default function LecturerDashboard() {
  const router = useRouter();
  const [courses, setCourses] = useState<Course[]>([]);
  const [projects, setProjects] = useState<Project[]>([]);
  const user = getUser();

  useEffect(() => {
    if (!requireAuth(getUser(), router, ['lecturer', 'admin'])) return;
    Promise.all([api.get('/lecturer/courses'), api.get('/lecturer/projects')])
      .then(([c, p]) => { setCourses(c.data); setProjects(p.data); }).catch(() => {});
  }, [router]);

  const pending = projects.filter(p => p.status === 'pending').length;
  const approved = projects.filter(p => p.status === 'approved').length;

  return (
    <Layout>
      <PageHeader title={`Hi, ${(user?.name ?? user?.full_name ?? '').split(' ')[0]} 👋`} subtitle="Your teaching overview" />

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(160px, 1fr))', gap: 14, marginBottom: 28 }}>
        <StatCard label="My Courses" value={courses.length} icon={BookOpen} color="purple" />
        <StatCard label="Total Projects" value={projects.length} icon={FolderOpen} color="purple" />
        <StatCard label="Pending Review" value={pending} icon={Clock} color="orange" />
        <StatCard label="Approved" value={approved} icon={CheckCircle} color="green" />
      </div>

      {pending > 0 && (
        <div style={{ padding: '14px 18px', borderRadius: 12, marginBottom: 24, background: '#FFF7ED', border: '1.5px solid #FDE68A', display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 12 }}>
          <p style={{ fontSize: 14, color: '#92400E', fontWeight: 600 }}>
            ⏳ {pending} project{pending > 1 ? 's' : ''} waiting for your review
          </p>
          <button onClick={() => router.push('/lecturer/projects')}
            style={{ background: '#D97706', color: '#fff', border: 'none', borderRadius: 8, padding: '8px 14px', fontSize: 13, fontWeight: 600, cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 6, fontFamily: 'Plus Jakarta Sans' }}>
            Review Now <ArrowRight size={13} />
          </button>
        </div>
      )}

      {courses.length === 0 ? (
        <div className="card" style={{ padding: 28, textAlign: 'center' }}>
          <p style={{ color: 'var(--muted)', fontSize: 15, marginBottom: 6 }}>You haven't been assigned to any course yet.</p>
          <p style={{ color: 'var(--muted)', fontSize: 14 }}>Contact admin to get assigned to CSC 497 or CSC 498.</p>
        </div>
      ) : (
        <div>
          <h2 style={{ fontSize: 13, fontWeight: 700, color: 'var(--muted)', textTransform: 'uppercase', letterSpacing: '0.5px', marginBottom: 14 }}>Your Courses</h2>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            {courses.map(c => (
              <button key={c.id} onClick={() => router.push(`/lecturer/courses/${c.id}`)}
                className="card" style={{ padding: '20px 24px', cursor: 'pointer', textAlign: 'left', display: 'flex', alignItems: 'center', justifyContent: 'space-between', background: 'var(--card)', border: '1.5px solid var(--border)', transition: 'all 0.2s' }}
                onMouseEnter={e => { (e.currentTarget as HTMLButtonElement).style.borderColor = 'var(--accent)'; }}
                onMouseLeave={e => { (e.currentTarget as HTMLButtonElement).style.borderColor = 'var(--border)'; }}>
                <div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 4 }}>
                    <span style={{ fontSize: 16, fontWeight: 700, color: 'var(--soft)' }}>{c.title}</span>
                    <span className="badge badge-purple mono">{c.course_code}</span>
                  </div>
                  <span style={{ fontSize: 13, color: 'var(--muted)' }}>{c.session}</span>
                </div>
                <ArrowRight size={18} style={{ color: 'var(--muted)', flexShrink: 0 }} />
              </button>
            ))}
          </div>
        </div>
      )}
    </Layout>
  );
}
EOF

# ── 8. ADD REPOSITORY LINK TO LANDING PAGE NAV ───────────────
# We need to add "Repository" link to the landing page nav
# This patches the existing LandingPage component
sed -i 's|<button className="btn btn-primary btn-sm" onClick={() => router.push.*Sign In.*|<Link href="/repository" style={{ textDecoration: "none", fontSize: 14, fontWeight: 600, color: "var(--muted)", padding: "8px 14px" }}>Repository</Link>\n          <button className="btn btn-primary btn-sm" onClick={() => router.push("/login")}>\n            Sign In <ArrowRight size={15} />\n          </button>|' components/LandingPage.tsx 2>/dev/null || true

echo ""
echo "✅ MAJOR UPDATE V2 COMPLETE!"
echo ""
echo "⚠️  IMPORTANT: You also need backend changes for:"
echo "  1. Add 'status', 'year', 'supervisor' columns to projects table in Supabase"
echo "  2. Add approval/reject endpoints to backend"
echo "  3. Add public projects endpoint"
echo "  4. Add download count tracking"
echo ""
echo "Run: git add . && git commit -m 'v2: approval system, public repo, stats' && git push"
