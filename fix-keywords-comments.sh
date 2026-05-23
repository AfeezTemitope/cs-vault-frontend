#!/bin/bash
# ============================================================
#  CS-VAULT — Add Keywords + Lecturer Comments/Feedback
#  Run from INSIDE cs-vault-frontend/
# ============================================================

echo "🔧 Adding keywords field and lecturer feedback..."

# ── 1. UPDATED UPLOAD PAGE - add keywords field ───────────────
cat > app/student/upload/page.tsx << 'TSEOF'
'use client';
import { useEffect, useState, useRef } from 'react';
import { useRouter } from 'next/navigation';
import { getUser, requireAuth } from '@/lib/auth';
import Layout from '@/components/Layout';
import PageHeader from '@/components/PageHeader';
import api from '@/lib/api';
import toast from 'react-hot-toast';
import { Upload, FileText, Archive, GitBranch, X, ChevronDown, Check, User, Hash, Tag } from 'lucide-react';

interface Course { id: string; title: string; course_code: string; }
interface Lecturer { id: string; full_name: string; }

const SESSIONS = ['2024/2025', '2025/2026', '2023/2024', '2022/2023'];
const YEARS = ['2026', '2025', '2024', '2023', '2022'];

function CustomSelect({ value, onChange, options, placeholder }: {
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

// Keyword tag input component
function KeywordInput({ keywords, onChange }: { keywords: string[]; onChange: (k: string[]) => void }) {
  const [input, setInput] = useState('');

  const addKeyword = (val: string) => {
    const trimmed = val.trim().toLowerCase();
    if (trimmed && !keywords.includes(trimmed) && keywords.length < 8) {
      onChange([...keywords, trimmed]);
    }
    setInput('');
  };

  const handleKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Enter' || e.key === ',') {
      e.preventDefault();
      addKeyword(input);
    }
    if (e.key === 'Backspace' && !input && keywords.length > 0) {
      onChange(keywords.slice(0, -1));
    }
  };

  const remove = (k: string) => onChange(keywords.filter(x => x !== k));

  return (
    <div style={{
      display: 'flex', flexWrap: 'wrap', gap: 8, padding: '10px 14px',
      borderRadius: 10, border: '1.5px solid var(--border)',
      background: 'var(--surface)', minHeight: 48, alignItems: 'center',
      transition: 'all 0.15s',
    }}
      onClick={() => document.getElementById('keyword-input')?.focus()}
      onFocus={e => (e.currentTarget as HTMLDivElement).style.borderColor = 'var(--accent)'}
      onBlur={e => (e.currentTarget as HTMLDivElement).style.borderColor = 'var(--border)'}>
      {keywords.map(k => (
        <span key={k} style={{
          display: 'inline-flex', alignItems: 'center', gap: 5,
          background: 'var(--accent-light)', color: 'var(--accent)',
          padding: '3px 10px', borderRadius: 99, fontSize: 13, fontWeight: 600,
        }}>
          {k}
          <button type="button" onClick={() => remove(k)}
            style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--accent)', padding: 0, display: 'flex', lineHeight: 1 }}>
            <X size={12} />
          </button>
        </span>
      ))}
      <input
        id="keyword-input"
        value={input}
        onChange={e => setInput(e.target.value)}
        onKeyDown={handleKeyDown}
        onBlur={() => { if (input.trim()) addKeyword(input); }}
        placeholder={keywords.length === 0 ? 'Type a keyword and press Enter or comma...' : keywords.length < 8 ? 'Add more...' : 'Max 8 keywords'}
        disabled={keywords.length >= 8}
        style={{
          border: 'none', outline: 'none', background: 'transparent',
          fontSize: 14, color: 'var(--soft)', fontFamily: 'Plus Jakarta Sans, sans-serif',
          flex: 1, minWidth: 160,
        }} />
    </div>
  );
}

export default function UploadProject() {
  const router = useRouter();
  const user = getUser();
  const [courses, setCourses] = useState<Course[]>([]);
  const [lecturers, setLecturers] = useState<Lecturer[]>([]);
  const [form, setForm] = useState({
    title: '', abstract: '', course_id: '', session: '2024/2025',
    year: '2026', supervisor: '', github_link: '', keywords: [] as string[],
  });
  const [pdfFile, setPdfFile] = useState<File | null>(null);
  const [zipFile, setZipFile] = useState<File | null>(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (!requireAuth(getUser(), router, ['student'])) return;
    api.get('/projects/courses').then(r => setCourses(r.data)).catch(() => {});
    api.get('/projects/lecturers').then(r => setLecturers(r.data)).catch(() => {});
  }, [router]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!form.course_id) return toast.error('Please select a course');
    if (!form.supervisor) return toast.error('Please select a supervisor');
    if (!pdfFile) return toast.error('Please attach a PDF report');
    if (form.keywords.length === 0) return toast.error('Please add at least one keyword');
    setLoading(true);
    try {
      const fd = new FormData();
      fd.append('title', form.title);
      fd.append('description', form.abstract);
      fd.append('course_id', form.course_id);
      fd.append('session', form.session);
      fd.append('year', form.year);
      fd.append('supervisor', form.supervisor);
      fd.append('keywords', form.keywords.join(','));
      if (form.github_link) fd.append('github_link', form.github_link);
      if (pdfFile) fd.append('files', pdfFile);
      if (zipFile) fd.append('files', zipFile);
      await api.post('/projects', fd, { headers: { 'Content-Type': 'multipart/form-data' } });
      toast.success('Project submitted! Awaiting lecturer approval.');
      router.push('/vault');
    } catch (err: unknown) {
      toast.error((err as { response?: { data?: { error?: string } } })?.response?.data?.error ?? 'Upload failed');
    } finally { setLoading(false); }
  };

  const FileInput = ({ label, icon: Icon, file, setFile, accept, types, required }: {
    label: string; icon: React.ElementType; file: File | null;
    setFile: (f: File | null) => void; accept: string; types: string[]; required?: boolean;
  }) => (
    <div className="field">
      <label className="label">{label}{required && ' *'}</label>
      {file ? (
        <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '12px 16px', borderRadius: 10, border: '1.5px solid var(--accent)', background: 'var(--accent-light)' }}>
          <Icon size={16} style={{ color: 'var(--accent)', flexShrink: 0 }} />
          <span style={{ fontSize: 14, flex: 1, color: 'var(--soft)', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{file.name}</span>
          <button type="button" onClick={() => setFile(null)}
            style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--muted)', padding: 0, display: 'flex' }}>
            <X size={16} />
          </button>
        </div>
      ) : (
        <label style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '12px 16px', borderRadius: 10, cursor: 'pointer', border: '1.5px dashed var(--border)', background: 'var(--surface)', transition: 'all 0.15s' }}
          onMouseEnter={e => { (e.currentTarget as HTMLLabelElement).style.borderColor = 'var(--accent)'; }}
          onMouseLeave={e => { (e.currentTarget as HTMLLabelElement).style.borderColor = 'var(--border)'; }}>
          <Icon size={16} style={{ color: 'var(--muted)', flexShrink: 0 }} />
          <span style={{ fontSize: 14, color: 'var(--muted)' }}>Choose {label}...</span>
          <input type="file" accept={accept} style={{ display: 'none' }}
            onChange={e => {
              const f = e.target.files?.[0];
              if (f && types.some(t => f.name.toLowerCase().endsWith(t))) setFile(f);
              else toast.error('Invalid file type');
            }} />
        </label>
      )}
    </div>
  );

  const lecturerOptions = lecturers.map(l => ({ value: l.full_name, label: l.full_name }));
  const courseOptions = courses.map(c => ({ value: c.id, label: `${c.course_code} — ${c.title}` }));

  return (
    <Layout>
      <PageHeader title="Upload Project" subtitle="Submit your final year project for lecturer review" />
      <div className="card" style={{ padding: '28px 24px', maxWidth: 700 }}>
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
            <input className="input" required placeholder="e.g. Smart Attendance System Using Face Recognition"
              value={form.title} onChange={e => setForm({ ...form, title: e.target.value })} />
          </div>

          <div className="field">
            <label className="label">Abstract *</label>
            <textarea className="input" rows={5} required
              placeholder="Brief summary of your project — what it does, the problem it solves, the methodology used, and its significance..."
              style={{ resize: 'vertical' }}
              value={form.abstract} onChange={e => setForm({ ...form, abstract: e.target.value })} />
          </div>

          {/* Keywords */}
          <div className="field">
            <label className="label" style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
              <Tag size={14} /> Keywords *
              <span style={{ fontWeight: 400, color: 'var(--muted)', fontSize: 13 }}>Press Enter or comma to add (max 8)</span>
            </label>
            <KeywordInput
              keywords={form.keywords}
              onChange={k => setForm({ ...form, keywords: k })}
            />
            {form.keywords.length > 0 && (
              <p style={{ fontSize: 12, color: 'var(--muted)', marginTop: 6 }}>{form.keywords.length}/8 keywords added</p>
            )}
          </div>

          {/* Supervisor dropdown */}
          <div className="field">
            <label className="label">Supervisor *</label>
            {lecturerOptions.length > 0 ? (
              <CustomSelect
                value={form.supervisor}
                onChange={v => setForm({ ...form, supervisor: v })}
                options={lecturerOptions}
                placeholder="Select your supervisor..."
              />
            ) : (
              <input className="input" required placeholder="e.g. Dr. Olamide Macfish"
                value={form.supervisor} onChange={e => setForm({ ...form, supervisor: e.target.value })} />
            )}
          </div>

          {/* Course radio selection */}
          <div className="field">
            <label className="label">Course *</label>
            {courses.length === 0 ? (
              <div style={{ padding: '14px 16px', borderRadius: 10, background: 'var(--surface)', border: '1.5px solid var(--border)', color: 'var(--muted)', fontSize: 14 }}>
                No courses available
              </div>
            ) : (
              <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
                {courses.map(c => {
                  const selected = form.course_id === c.id;
                  return (
                    <button type="button" key={c.id} onClick={() => setForm({ ...form, course_id: c.id })}
                      style={{
                        display: 'flex', alignItems: 'center', gap: 14,
                        padding: '14px 18px', borderRadius: 12, cursor: 'pointer',
                        border: `2px solid ${selected ? 'var(--accent)' : 'var(--border)'}`,
                        background: selected ? 'var(--accent-light)' : 'var(--surface)',
                        transition: 'all 0.15s', textAlign: 'left', width: '100%',
                        fontFamily: 'Plus Jakarta Sans, sans-serif',
                      }}>
                      <div style={{
                        width: 20, height: 20, borderRadius: '50%', flexShrink: 0,
                        border: `2px solid ${selected ? 'var(--accent)' : 'var(--border)'}`,
                        background: selected ? 'var(--accent)' : 'transparent',
                        display: 'flex', alignItems: 'center', justifyContent: 'center',
                      }}>
                        {selected && <div style={{ width: 8, height: 8, borderRadius: '50%', background: '#fff' }} />}
                      </div>
                      <div>
                        <div className="mono" style={{ fontSize: 12, fontWeight: 600, color: selected ? 'var(--accent)' : 'var(--muted)' }}>{c.course_code}</div>
                        <div style={{ fontSize: 15, fontWeight: 600, color: 'var(--soft)' }}>{c.title}</div>
                      </div>
                    </button>
                  );
                })}
              </div>
            )}
          </div>

          {/* Session and Year */}
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16 }}>
            <div className="field">
              <label className="label">Session *</label>
              <CustomSelect value={form.session} onChange={v => setForm({ ...form, session: v })}
                options={SESSIONS.map(s => ({ value: s, label: s }))} placeholder="Select session..." />
            </div>
            <div className="field">
              <label className="label">Year *</label>
              <CustomSelect value={form.year} onChange={v => setForm({ ...form, year: v })}
                options={YEARS.map(y => ({ value: y, label: y }))} placeholder="Select year..." />
            </div>
          </div>

          <FileInput label="PDF Report" icon={FileText} file={pdfFile} setFile={setPdfFile}
            accept=".pdf" types={['.pdf']} required />
          <FileInput label="Source Code (ZIP)" icon={Archive} file={zipFile} setFile={setZipFile}
            accept=".zip" types={['.zip']} />

          <div className="field">
            <label className="label" style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
              <GitBranch size={14} /> GitHub Link
              <span style={{ fontWeight: 400, color: 'var(--muted)', fontSize: 13 }}>(optional)</span>
            </label>
            <input className="input mono" placeholder="https://github.com/username/repo"
              value={form.github_link} onChange={e => setForm({ ...form, github_link: e.target.value })} />
          </div>

          <button type="submit" className="btn btn-primary btn-full" disabled={loading}
            style={{ padding: '14px 24px', fontSize: 15, marginTop: 4 }}>
            <Upload size={18} />
            {loading ? 'Submitting...' : 'Submit Project'}
          </button>
        </form>
      </div>
    </Layout>
  );
}
TSEOF

# ── 2. UPDATED LECTURER PROJECTS PAGE - with feedback/comments ─
cat > app/lecturer/projects/page.tsx << 'TSEOF'
'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { getUser, requireAuth } from '@/lib/auth';
import Layout from '@/components/Layout';
import PageHeader from '@/components/PageHeader';
import EmptyState from '@/components/EmptyState';
import api from '@/lib/api';
import toast from 'react-hot-toast';
import {
  FolderOpen, Search, CheckCircle, XCircle, Clock,
  FileText, GitBranch, Archive, Download, MessageSquare, Send, Tag
} from 'lucide-react';
import { format } from 'date-fns';

interface Project {
  id: string; title: string; session: string; year?: string; supervisor?: string;
  description?: string; keywords?: string; pdf_url?: string; zip_url?: string;
  github_link?: string; created_at?: string; status?: string; download_count?: number;
  courses?: { title: string; course_code: string };
  users?: { full_name: string; matric_number: string };
  grades?: { grade: string }[];
  comments?: { id: string; text: string; created_at: string; users?: { full_name: string } }[];
}

const STATUS_CONFIG: Record<string, { label: string; badgeClass: string; icon: React.ElementType }> = {
  pending:  { label: 'Pending',  badgeClass: 'badge badge-pending',  icon: Clock },
  approved: { label: 'Approved', badgeClass: 'badge badge-approved', icon: CheckCircle },
  rejected: { label: 'Rejected', badgeClass: 'badge badge-rejected', icon: XCircle },
};

const GRADES = ['A', 'B', 'C', 'D', 'E', 'F'];

export default function LecturerProjects() {
  const router = useRouter();
  const [projects, setProjects] = useState<Project[]>([]);
  const [search, setSearch] = useState('');
  const [filter, setFilter] = useState('all');
  const [loading, setLoading] = useState(false);
  const [feedbackText, setFeedbackText] = useState<Record<string, string>>({});
  const [expandedId, setExpandedId] = useState<string | null>(null);

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
      toast.success('Project approved — now visible in repository');
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
      toast.success(`Grade ${grade} saved`);
      fetchProjects();
    } catch { toast.error('Failed to save grade'); }
  };

  const handleComment = async (projectId: string) => {
    const text = feedbackText[projectId]?.trim();
    if (!text) return toast.error('Please write your feedback first');
    try {
      await api.post(`/projects/${projectId}/comments`, { text });
      toast.success('Feedback sent to student');
      setFeedbackText(prev => ({ ...prev, [projectId]: '' }));
      fetchProjects();
    } catch { toast.error('Failed to send feedback'); }
  };

  const filtered = projects.filter(p => {
    const matchSearch = !search || p.title.toLowerCase().includes(search.toLowerCase()) ||
      p.users?.full_name.toLowerCase().includes(search.toLowerCase());
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
      <PageHeader title="Projects" subtitle="Review, approve and give feedback on student submissions" />

      {/* Filter tabs */}
      <div style={{ display: 'flex', gap: 8, marginBottom: 20, flexWrap: 'wrap' }}>
        {(['all', 'pending', 'approved', 'rejected'] as const).map(f => (
          <button key={f} onClick={() => setFilter(f)}
            style={{
              padding: '8px 16px', borderRadius: 10, cursor: 'pointer', fontSize: 14,
              fontWeight: filter === f ? 700 : 500, border: '1.5px solid',
              fontFamily: 'Plus Jakarta Sans, sans-serif',
              transition: 'all 0.15s',
              background: filter === f ? 'var(--accent)' : 'var(--card)',
              borderColor: filter === f ? 'var(--accent)' : 'var(--border)',
              color: filter === f ? '#fff' : 'var(--muted)',
            }}>
            {f.charAt(0).toUpperCase() + f.slice(1)} ({counts[f]})
          </button>
        ))}
      </div>

      {/* Search */}
      <div style={{ position: 'relative', marginBottom: 20 }}>
        <Search size={16} style={{ position: 'absolute', left: 14, top: '50%', transform: 'translateY(-50%)', color: 'var(--muted)', pointerEvents: 'none' }} />
        <input className="input" style={{ paddingLeft: 44 }}
          placeholder="Search by title or student name..."
          value={search}
          onChange={e => { setSearch(e.target.value); fetchProjects(e.target.value); }} />
      </div>

      {loading ? (
        <div style={{ textAlign: 'center', padding: '40px', color: 'var(--muted)' }}>Loading...</div>
      ) : filtered.length === 0 ? (
        <EmptyState icon={FolderOpen} title="No projects found" subtitle="Projects appear here once students submit" />
      ) : (
        <div style={{ display: 'flex', flexDirection: 'column', gap: 20 }}>
          {filtered.map(p => {
            const status = p.status ?? 'pending';
            const sc = STATUS_CONFIG[status] ?? STATUS_CONFIG.pending;
            const currentGrade = Array.isArray(p.grades) ? p.grades[0]?.grade : undefined;
            const isExpanded = expandedId === p.id;
            const keywords = p.keywords ? p.keywords.split(',').map(k => k.trim()).filter(Boolean) : [];

            return (
              <div key={p.id} className="card" style={{ padding: '24px' }}>
                {/* Header */}
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
                        <strong style={{ color: 'var(--soft)' }}>{p.users?.full_name}</strong>
                        <span className="mono"> · {p.users?.matric_number}</span>
                      </span>
                      {p.supervisor && <span style={{ fontSize: 13, color: 'var(--muted)' }}>Supervisor: <strong style={{ color: 'var(--soft)' }}>{p.supervisor}</strong></span>}
                      {p.year && <span style={{ fontSize: 13, color: 'var(--muted)' }}>Year: <strong style={{ color: 'var(--soft)' }}>{p.year}</strong></span>}
                      {p.created_at && <span style={{ fontSize: 13, color: 'var(--muted)' }}>{format(new Date(p.created_at), 'dd MMM yyyy')}</span>}
                    </div>
                  </div>
                </div>

                {/* Abstract */}
                {p.description && (
                  <p style={{ fontSize: 14, color: 'var(--muted)', lineHeight: 1.7, marginBottom: 12, padding: '12px 14px', background: 'var(--surface)', borderRadius: 8 }}>
                    {p.description}
                  </p>
                )}

                {/* Keywords */}
                {keywords.length > 0 && (
                  <div style={{ display: 'flex', alignItems: 'center', gap: 8, flexWrap: 'wrap', marginBottom: 14 }}>
                    <Tag size={13} style={{ color: 'var(--muted)' }} />
                    {keywords.map(k => (
                      <span key={k} className="badge badge-purple" style={{ fontSize: 11 }}>{k}</span>
                    ))}
                  </div>
                )}

                {/* Files */}
                <div style={{ display: 'flex', gap: 8, marginBottom: 16, flexWrap: 'wrap' }}>
                  {p.pdf_url && (
                    <a href={p.pdf_url} target="_blank" rel="noopener noreferrer"
                      className="btn btn-secondary btn-sm" style={{ textDecoration: 'none' }}>
                      <FileText size={14} /> View PDF
                    </a>
                  )}
                  {p.zip_url && (
                    <a href={p.zip_url} target="_blank" rel="noopener noreferrer"
                      className="btn btn-secondary btn-sm" style={{ textDecoration: 'none' }}>
                      <Archive size={14} /> Source Code
                    </a>
                  )}
                  {p.github_link && (
                    <a href={p.github_link} target="_blank" rel="noopener noreferrer"
                      className="btn btn-secondary btn-sm" style={{ textDecoration: 'none' }}>
                      <GitBranch size={14} /> GitHub
                    </a>
                  )}
                  {p.download_count !== undefined && p.download_count > 0 && (
                    <span style={{ display: 'flex', alignItems: 'center', gap: 5, fontSize: 13, color: 'var(--muted)', padding: '8px 12px' }}>
                      <Download size={13} /> {p.download_count} downloads
                    </span>
                  )}
                </div>

                {/* Actions row */}
                <div style={{ display: 'flex', gap: 10, flexWrap: 'wrap', alignItems: 'center', paddingTop: 14, borderTop: '1px solid var(--border)', marginBottom: 16 }}>
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

                {/* Feedback / Comments section */}
                <div style={{ borderTop: '1px solid var(--border)', paddingTop: 16 }}>
                  <button
                    onClick={() => setExpandedId(isExpanded ? null : p.id)}
                    style={{
                      display: 'flex', alignItems: 'center', gap: 8, background: 'none', border: 'none',
                      cursor: 'pointer', color: 'var(--muted)', fontSize: 14, fontFamily: 'Plus Jakarta Sans',
                      fontWeight: 600, padding: 0, marginBottom: isExpanded ? 14 : 0,
                    }}>
                    <MessageSquare size={15} />
                    Feedback & Comments
                    {p.comments && p.comments.length > 0 && (
                      <span style={{ background: 'var(--accent)', color: '#fff', borderRadius: 99, fontSize: 11, fontWeight: 700, padding: '1px 7px' }}>
                        {p.comments.length}
                      </span>
                    )}
                    <span style={{ fontSize: 12, color: 'var(--muted)', marginLeft: 4 }}>{isExpanded ? '▲' : '▼'}</span>
                  </button>

                  {isExpanded && (
                    <div className="fade-in">
                      {/* Existing comments */}
                      {p.comments && p.comments.length > 0 && (
                        <div style={{ display: 'flex', flexDirection: 'column', gap: 10, marginBottom: 14 }}>
                          {p.comments.map(c => (
                            <div key={c.id} style={{ padding: '12px 14px', borderRadius: 10, background: 'var(--surface)', border: '1px solid var(--border)' }}>
                              <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 6 }}>
                                <span style={{ fontSize: 13, fontWeight: 600, color: 'var(--accent)' }}>
                                  {c.users?.full_name ?? 'Lecturer'}
                                </span>
                                <span style={{ fontSize: 12, color: 'var(--muted)' }}>
                                  {c.created_at ? format(new Date(c.created_at), 'dd MMM yyyy · HH:mm') : ''}
                                </span>
                              </div>
                              <p style={{ fontSize: 14, color: 'var(--soft)', lineHeight: 1.6 }}>{c.text}</p>
                            </div>
                          ))}
                        </div>
                      )}

                      {/* New feedback input */}
                      <div style={{ display: 'flex', gap: 10, alignItems: 'flex-end' }}>
                        <div style={{ flex: 1 }}>
                          <textarea
                            className="input"
                            rows={3}
                            placeholder="Write feedback for the student... (e.g. The abstract needs more detail. Please revise the methodology section.)"
                            style={{ resize: 'none' }}
                            value={feedbackText[p.id] ?? ''}
                            onChange={e => setFeedbackText(prev => ({ ...prev, [p.id]: e.target.value }))}
                          />
                        </div>
                        <button
                          onClick={() => handleComment(p.id)}
                          className="btn btn-primary"
                          style={{ padding: '12px 16px', flexShrink: 0 }}>
                          <Send size={16} />
                        </button>
                      </div>
                      <p style={{ fontSize: 12, color: 'var(--muted)', marginTop: 6 }}>
                        Feedback is visible to the student on their project page.
                      </p>
                    </div>
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

echo ""
echo "✅ Keywords + Feedback fixes applied!"
echo ""
echo "⚠️  Also add these two backend endpoints:"
echo "  1. POST /api/projects/:projectId/comments"
echo "  2. GET /api/projects/lecturers (already done)"
echo ""
echo "Run: git add . && git commit -m 'add keywords field and lecturer feedback system' && git push"
