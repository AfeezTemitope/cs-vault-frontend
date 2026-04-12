#!/bin/bash
# ============================================================
#  CS-VAULT Fix All V3
#  Run from INSIDE cs-vault-frontend/
# ============================================================

echo "🔧 Applying all fixes..."

# ── 1. FIX INPUT STYLING IN GLOBALS ──────────────────────────
# Patch globals.css to ensure inputs work on mobile
cat >> app/globals.css << 'CSSEOF'

/* Mobile input fix */
.input, input.input, textarea.input {
  -webkit-appearance: none;
  appearance: none;
  box-sizing: border-box;
}

/* Ensure form grid is single column on small screens */
@media (max-width: 600px) {
  .form-grid-2 { grid-template-columns: 1fr !important; }
  .form-grid-3 { grid-template-columns: 1fr !important; }
}
CSSEOF

# ── 2. FIX LECTURER REGISTER - fetch courses correctly ────────
cat > "app/lecturer/students/register/page.tsx" << 'TSEOF'
'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { getUser, requireAuth } from '@/lib/auth';
import Layout from '@/components/Layout';
import PageHeader from '@/components/PageHeader';
import api from '@/lib/api';
import toast from 'react-hot-toast';
import { UserPlus, CheckCircle } from 'lucide-react';

interface Course { id: string; title: string; course_code: string; }

export default function RegisterStudents() {
  const router = useRouter();
  const [courses, setCourses] = useState<Course[]>([]);
  const [form, setForm] = useState({
    full_name: '', email: '', matric_number: '', course_ids: [] as string[]
  });
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (!requireAuth(getUser(), router, ['lecturer', 'admin'])) return;
    // Try lecturer courses first, then fall back to all courses endpoint
    api.get('/lecturer/courses')
      .then(r => {
        if (r.data && r.data.length > 0) {
          setCourses(r.data);
        } else {
          // Lecturer has no assigned courses — fetch all available
          return api.get('/projects/courses').then(r2 => setCourses(r2.data));
        }
      })
      .catch(() => {
        api.get('/projects/courses').then(r => setCourses(r.data)).catch(() => {});
      });
  }, [router]);

  const toggleCourse = (id: string) => {
    setForm(f => ({
      ...f,
      course_ids: f.course_ids.includes(id)
        ? f.course_ids.filter(c => c !== id)
        : [...f.course_ids, id]
    }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (form.course_ids.length === 0) return toast.error('Please assign the student to at least one course');
    setLoading(true);
    try {
      await api.post('/lecturer/students/register', form);
      toast.success('Student registered — credentials sent to their email!');
      setForm({ full_name: '', email: '', matric_number: '', course_ids: [] });
    } catch (err: unknown) {
      toast.error((err as { response?: { data?: { error?: string } } })?.response?.data?.error ?? 'Registration failed');
    } finally { setLoading(false); }
  };

  return (
    <Layout>
      <PageHeader title="Register Student" subtitle="Add a student and assign them to a course" />
      <div className="card" style={{ padding: 28, maxWidth: 560 }}>
        <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: 22 }}>

          <div className="field">
            <label className="label">Full Name</label>
            <input className="input" required placeholder="e.g. John Doe"
              value={form.full_name}
              onChange={e => setForm({ ...form, full_name: e.target.value })} />
          </div>

          <div className="field">
            <label className="label">Email Address</label>
            <input className="input" type="email" required placeholder="e.g. student@gmail.com"
              value={form.email}
              onChange={e => setForm({ ...form, email: e.target.value })} />
          </div>

          <div className="field">
            <label className="label">Matric Number</label>
            <input className="input mono" required placeholder="e.g. CSC/2021/001"
              value={form.matric_number}
              onChange={e => setForm({ ...form, matric_number: e.target.value })} />
          </div>

          <div className="field">
            <label className="label">
              Assign to Course(s)
              <span style={{ fontWeight: 400, color: 'var(--muted)', fontSize: 13, marginLeft: 6 }}>
                Select one or both
              </span>
            </label>
            {courses.length === 0 ? (
              <div style={{
                padding: '14px 16px', borderRadius: 10,
                background: 'var(--surface)', border: '1.5px solid var(--border)',
                color: 'var(--muted)', fontSize: 14
              }}>
                No courses available — ask admin to create courses first
              </div>
            ) : (
              <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
                {courses.map(c => {
                  const selected = form.course_ids.includes(c.id);
                  return (
                    <button type="button" key={c.id} onClick={() => toggleCourse(c.id)}
                      style={{
                        display: 'flex', alignItems: 'center', gap: 14,
                        padding: '14px 18px', borderRadius: 12, cursor: 'pointer',
                        border: `2px solid ${selected ? 'var(--accent)' : 'var(--border)'}`,
                        background: selected ? 'var(--accent-light)' : 'var(--surface)',
                        transition: 'all 0.15s', textAlign: 'left', width: '100%',
                        fontFamily: 'Plus Jakarta Sans, sans-serif',
                      }}>
                      <div style={{
                        width: 22, height: 22, borderRadius: 6, flexShrink: 0,
                        border: `2px solid ${selected ? 'var(--accent)' : 'var(--border)'}`,
                        background: selected ? 'var(--accent)' : 'transparent',
                        display: 'flex', alignItems: 'center', justifyContent: 'center',
                      }}>
                        {selected && <CheckCircle size={13} style={{ color: '#fff' }} />}
                      </div>
                      <div>
                        <div className="mono" style={{ fontSize: 12, fontWeight: 600, color: selected ? 'var(--accent)' : 'var(--muted)' }}>
                          {c.course_code}
                        </div>
                        <div style={{ fontSize: 15, fontWeight: 600, color: 'var(--soft)' }}>
                          {c.title}
                        </div>
                      </div>
                    </button>
                  );
                })}
              </div>
            )}
          </div>

          <button type="submit" className="btn btn-primary btn-full" disabled={loading}
            style={{ padding: '14px 24px', fontSize: 15, marginTop: 4 }}>
            <UserPlus size={18} />
            {loading ? 'Registering...' : 'Register Student'}
          </button>
        </form>
      </div>
    </Layout>
  );
}
TSEOF

# ── 3 & 4. PRIVATE REPOSITORY PAGE (requires login) ──────────
mkdir -p app/vault
cat > app/vault/page.tsx << 'TSEOF'
'use client';
import { useEffect, useState, useRef } from 'react';
import { useRouter } from 'next/navigation';
import { getUser, requireAuth } from '@/lib/auth';
import Layout from '@/components/Layout';
import PageHeader from '@/components/PageHeader';
import api from '@/lib/api';
import toast from 'react-hot-toast';
import {
  Search, Download, Eye, BookOpen, ChevronDown,
  Check, Filter, FileText, GitBranch, Archive, Clock, CheckCircle, XCircle
} from 'lucide-react';
import { format } from 'date-fns';

interface Project {
  id: string; title: string; session: string; year?: string; supervisor?: string;
  description?: string; pdf_url?: string; zip_url?: string; github_link?: string;
  created_at?: string; download_count?: number; status?: string;
  courses?: { title: string; course_code: string };
  users?: { full_name: string; matric_number: string };
  grades?: { grade: string }[];
}

function Dropdown({ value, onChange, options, placeholder }: {
  value: string; onChange: (v: string) => void;
  options: { value: string; label: string }[]; placeholder: string;
}) {
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLDivElement>(null);
  const selected = options.find(o => o.value === value);
  useEffect(() => {
    const h = (e: MouseEvent) => {
      if (ref.current && !ref.current.contains(e.target as Node)) setOpen(false);
    };
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
          position: 'absolute', top: 'calc(100% + 6px)', left: 0, zIndex: 200, minWidth: 160,
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
              }}
              onMouseEnter={e => { if (value !== o.value) (e.currentTarget as HTMLButtonElement).style.background = 'var(--surface)'; }}
              onMouseLeave={e => { if (value !== o.value) (e.currentTarget as HTMLButtonElement).style.background = 'transparent'; }}>
              <span>{o.label}</span>
              {value === o.value && <Check size={13} />}
            </button>
          ))}
        </div>
      )}
    </div>
  );
}

const STATUS_CONFIG: Record<string, { label: string; icon: React.ElementType; class: string }> = {
  pending:  { label: 'Pending',  icon: Clock,         class: 'badge badge-pending' },
  approved: { label: 'Approved', icon: CheckCircle,   class: 'badge badge-approved' },
  rejected: { label: 'Rejected', icon: XCircle,       class: 'badge badge-rejected' },
};

export default function VaultPage() {
  const router = useRouter();
  const user = getUser();
  const [projects, setProjects] = useState<Project[]>([]);
  const [search, setSearch] = useState('');
  const [filterYear, setFilterYear] = useState('');
  const [filterCourse, setFilterCourse] = useState('');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!requireAuth(getUser(), router)) return;
    // Admins and lecturers see all projects, students see approved only
    const endpoint = user?.role === 'student' ? '/projects/approved' : '/lecturer/projects';
    api.get(endpoint)
      .then(r => setProjects(r.data))
      .catch(() => {})
      .finally(() => setLoading(false));
  }, [router, user?.role]);

  const years = [...new Set(projects.map(p => p.year).filter(Boolean))] as string[];
  const courses = [...new Set(projects.map(p => p.courses?.course_code).filter(Boolean))] as string[];

  const filtered = projects.filter(p => {
    const matchSearch = !search ||
      p.title.toLowerCase().includes(search.toLowerCase()) ||
      p.users?.full_name.toLowerCase().includes(search.toLowerCase()) ||
      p.supervisor?.toLowerCase().includes(search.toLowerCase());
    const matchYear = !filterYear || p.year === filterYear;
    const matchCourse = !filterCourse || p.courses?.course_code === filterCourse;
    return matchSearch && matchYear && matchCourse;
  });

  const handleDownload = async (project: Project) => {
    if (project.pdf_url) {
      window.open(project.pdf_url, '_blank');
      await api.post(`/projects/${project.id}/download`).catch(() => {});
    } else {
      toast.error('No PDF available for this project');
    }
  };

  const gradeColors: Record<string, string> = {
    A: '#059669', B: '#7C3AED', C: '#D97706', D: '#B45309', E: '#DC2626', F: '#991B1B'
  };

  return (
    <Layout>
      <PageHeader
        title="Project Repository"
        subtitle={`${filtered.length} ${user?.role === 'student' ? 'approved' : ''} projects`}
      />

      {/* Stats row */}
      <div style={{ display: 'flex', gap: 12, marginBottom: 24, flexWrap: 'wrap' }}>
        {[
          { label: 'Total', value: projects.length, color: 'var(--accent)' },
          { label: 'Approved', value: projects.filter(p => p.status === 'approved').length, color: '#059669' },
          { label: 'Pending', value: projects.filter(p => p.status === 'pending').length, color: '#D97706' },
        ].map(s => (
          <div key={s.label} className="card" style={{ padding: '12px 20px', display: 'flex', alignItems: 'center', gap: 10 }}>
            <span style={{ fontSize: 22, fontWeight: 800, color: s.color }}>{s.value}</span>
            <span style={{ fontSize: 13, color: 'var(--muted)', fontWeight: 500 }}>{s.label}</span>
          </div>
        ))}
      </div>

      {/* Search & filters */}
      <div style={{ display: 'flex', gap: 10, marginBottom: 24, flexWrap: 'wrap', alignItems: 'center' }}>
        <div style={{ position: 'relative', flex: 1, minWidth: 200 }}>
          <Search size={16} style={{ position: 'absolute', left: 14, top: '50%', transform: 'translateY(-50%)', color: 'var(--muted)', pointerEvents: 'none' }} />
          <input className="input" style={{ paddingLeft: 44 }}
            placeholder="Search by title, student or supervisor..."
            value={search} onChange={e => setSearch(e.target.value)} />
        </div>
        <div style={{ display: 'flex', gap: 8, alignItems: 'center', flexWrap: 'wrap' }}>
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

      {/* Projects */}
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
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))', gap: 16 }}>
          {filtered.map(p => {
            const status = p.status ?? 'pending';
            const sc = STATUS_CONFIG[status] ?? STATUS_CONFIG.pending;
            const grade = Array.isArray(p.grades) ? p.grades[0]?.grade : undefined;
            return (
              <div key={p.id} className="card" style={{ padding: '20px', display: 'flex', flexDirection: 'column', gap: 12 }}>
                {/* Header */}
                <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: 8 }}>
                  <h3 style={{ fontSize: 15, fontWeight: 700, color: 'var(--soft)', lineHeight: 1.4, flex: 1 }}>{p.title}</h3>
                  <div style={{ display: 'flex', flexDirection: 'column', gap: 4, alignItems: 'flex-end', flexShrink: 0 }}>
                    <span className={sc.class} style={{ display: 'flex', alignItems: 'center', gap: 4, fontSize: 11 }}>
                      <sc.icon size={10} /> {sc.label}
                    </span>
                    {grade && (
                      <span style={{ fontSize: 12, fontWeight: 700, color: gradeColors[grade] ?? 'var(--muted)', background: `${gradeColors[grade] ?? '#888'}18`, padding: '2px 8px', borderRadius: 99 }}>
                        {grade}
                      </span>
                    )}
                  </div>
                </div>

                {/* Abstract */}
                {p.description && (
                  <p style={{ fontSize: 13, color: 'var(--muted)', lineHeight: 1.6, display: '-webkit-box', WebkitLineClamp: 3, WebkitBoxOrient: 'vertical', overflow: 'hidden' }}>
                    {p.description}
                  </p>
                )}

                {/* Meta */}
                <div style={{ display: 'flex', flexDirection: 'column', gap: 5, padding: '10px 0', borderTop: '1px solid var(--border)', borderBottom: '1px solid var(--border)', fontSize: 13 }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                    <span style={{ color: 'var(--muted)', fontWeight: 500 }}>Student</span>
                    <span style={{ color: 'var(--soft)', fontWeight: 600 }}>{p.users?.full_name}</span>
                  </div>
                  {p.supervisor && (
                    <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                      <span style={{ color: 'var(--muted)', fontWeight: 500 }}>Supervisor</span>
                      <span style={{ color: 'var(--soft)', fontWeight: 600 }}>{p.supervisor}</span>
                    </div>
                  )}
                  <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                    <span style={{ color: 'var(--muted)', fontWeight: 500 }}>Course</span>
                    <span className="badge badge-purple mono" style={{ fontSize: 11 }}>{p.courses?.course_code}</span>
                  </div>
                  <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                    <span style={{ color: 'var(--muted)', fontWeight: 500 }}>Year</span>
                    <span className="mono" style={{ color: 'var(--soft)', fontWeight: 600 }}>{p.year ?? new Date(p.created_at ?? '').getFullYear()}</span>
                  </div>
                  {p.download_count !== undefined && p.download_count > 0 && (
                    <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                      <span style={{ color: 'var(--muted)', fontWeight: 500 }}>Downloads</span>
                      <span className="mono" style={{ color: 'var(--accent)', fontWeight: 600 }}>{p.download_count}</span>
                    </div>
                  )}
                </div>

                {/* Actions */}
                <div style={{ display: 'flex', gap: 8 }}>
                  {p.pdf_url && (
                    <button onClick={() => handleDownload(p)} className="btn btn-primary btn-sm" style={{ flex: 1, justifyContent: 'center' }}>
                      <Download size={14} /> Download
                    </button>
                  )}
                  <button onClick={() => router.push(user?.role === 'lecturer' || user?.role === 'admin' ? `/lecturer/projects/${p.id}` : `/student/projects/${p.id}`)}
                    className="btn btn-secondary btn-sm" style={{ flex: 1, justifyContent: 'center' }}>
                    <Eye size={14} /> View
                  </button>
                  {p.github_link && (
                    <a href={p.github_link} target="_blank" rel="noopener noreferrer"
                      className="btn btn-secondary btn-sm" style={{ padding: '8px 12px', textDecoration: 'none' }}>
                      <GitBranch size={14} />
                    </a>
                  )}
                </div>
              </div>
            );
          })}
        </div>
      )}
    </Layout>
  );
}
TSEOF

# ── 5. UPDATE NAV ITEMS to include Repository ─────────────────
cat > components/Layout.tsx << 'TSEOF'
'use client';
import { useState, useEffect } from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { getUser, logout, User } from '@/lib/auth';
import ThemeToggle from './ThemeToggle';
import {
  LayoutDashboard, BookOpen, Upload, Search,
  Users, GraduationCap, Menu, X,
  Settings, FolderOpen, UserPlus, LogOut, Library
} from 'lucide-react';

const navItems: Record<string, { href: string; label: string; icon: React.ElementType }[]> = {
  admin: [
    { href: '/admin', label: 'Dashboard', icon: LayoutDashboard },
    { href: '/admin/lecturers', label: 'Lecturers', icon: GraduationCap },
    { href: '/admin/courses', label: 'Courses', icon: BookOpen },
    { href: '/admin/students', label: 'Students', icon: Users },
    { href: '/vault', label: 'Repository', icon: Library },
  ],
  lecturer: [
    { href: '/lecturer', label: 'Dashboard', icon: LayoutDashboard },
    { href: '/lecturer/projects', label: 'Projects', icon: FolderOpen },
    { href: '/vault', label: 'Repository', icon: Library },
    { href: '/lecturer/students/register', label: 'Register Student', icon: UserPlus },
  ],
  student: [
    { href: '/student', label: 'Dashboard', icon: LayoutDashboard },
    { href: '/vault', label: 'Repository', icon: Library },
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

  const SideLink = ({ href, label, Icon, onClick }: {
    href: string; label: string; Icon: React.ElementType; onClick?: () => void;
  }) => {
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
      onMouseEnter={e => {
        (e.currentTarget as HTMLButtonElement).style.color = '#DC2626';
        (e.currentTarget as HTMLButtonElement).style.background = '#FEF2F2';
      }}
      onMouseLeave={e => {
        (e.currentTarget as HTMLButtonElement).style.color = 'var(--muted)';
        (e.currentTarget as HTMLButtonElement).style.background = 'none';
      }}>
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

        <main style={{ flex: 1, padding: '28px 20px', maxWidth: 1040, width: '100%', margin: '0 auto', paddingBottom: 60 }}>
          {children}
        </main>
      </div>
    </div>
  );
}
TSEOF

echo ""
echo "✅ ALL FIXES APPLIED!"
echo ""
echo "⚠️  Also add this backend endpoint — open src/routes/project.routes.js and add:"
echo "  router.get('/approved', authenticate, getApprovedProjects);"
echo ""
echo "And in projectController.js add:"
echo "  const getApprovedProjects = async (req, res) => {"
echo "    const { data, error } = await supabase.from('projects')"
echo "      .select('*, users(full_name, matric_number), courses(title, course_code), grades(grade)')"
echo "      .eq('status', 'approved').order('created_at', { ascending: false });"
echo "    if (error) return res.status(500).json({ error: error.message });"
echo "    res.json(data);"
echo "  };"
echo ""
echo "Run: git add . && git commit -m 'fix forms, private repo, lecturer course fetch' && git push"
