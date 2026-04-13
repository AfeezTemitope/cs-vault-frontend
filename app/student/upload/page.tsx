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

export default function UploadProject() {
  const router = useRouter();
  const user = getUser();
  const [courses, setCourses] = useState<Course[]>([]);
  const [lecturers, setLecturers] = useState<Lecturer[]>([]);
  const [form, setForm] = useState({
    title: '', abstract: '', course_id: '', session: '2024/2025',
    year: '2026', supervisor: '', github_link: '',
  });
  const [pdfFile, setPdfFile] = useState<File | null>(null);
  const [zipFile, setZipFile] = useState<File | null>(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (!requireAuth(getUser(), router, ['student'])) return;
    // Fetch courses
    api.get('/projects/courses')
      .then(r => setCourses(r.data))
      .catch(() => {});
    // Fetch lecturers for supervisor dropdown
    api.get('/projects/courses')
      .then(() => {
        // Get lecturers from public endpoint
        fetch(`${process.env.NEXT_PUBLIC_API_URL}/api/admin/lecturers`, {
          headers: { Authorization: `Bearer ${localStorage.getItem('cv_token')}` }
        })
          .then(r => r.json())
          .then(data => { if (Array.isArray(data)) setLecturers(data); })
          .catch(() => {});
      });
    // Try fetching lecturers via api
    api.get('/admin/lecturers')
      .then(r => setLecturers(r.data))
      .catch(() => {});
  }, [router]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!form.course_id) return toast.error('Please select a course');
    if (!form.supervisor) return toast.error('Please select a supervisor');
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
        <div style={{
          display: 'flex', alignItems: 'center', gap: 12, padding: '12px 16px',
          borderRadius: 10, border: '1.5px solid var(--accent)', background: 'var(--accent-light)',
        }}>
          <Icon size={16} style={{ color: 'var(--accent)', flexShrink: 0 }} />
          <span style={{ fontSize: 14, flex: 1, color: 'var(--soft)', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{file.name}</span>
          <button type="button" onClick={() => setFile(null)}
            style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--muted)', padding: 0, display: 'flex' }}>
            <X size={16} />
          </button>
        </div>
      ) : (
        <label style={{
          display: 'flex', alignItems: 'center', gap: 12, padding: '12px 16px',
          borderRadius: 10, cursor: 'pointer', border: '1.5px dashed var(--border)',
          background: 'var(--surface)', transition: 'all 0.15s',
        }}
          onMouseEnter={e => { (e.currentTarget as HTMLLabelElement).style.borderColor = 'var(--accent)'; }}
          onMouseLeave={e => { (e.currentTarget as HTMLLabelElement).style.borderColor = 'var(--border)'; }}>
          <Icon size={16} style={{ color: 'var(--muted)', flexShrink: 0 }} />
          <span style={{ fontSize: 14, color: 'var(--muted)' }}>Choose {label}...</span>
          <input type="file" accept={accept} style={{ display: 'none' }}
            onChange={e => {
              const f = e.target.files?.[0];
              if (f && types.some(t => f.type.includes(t) || f.name.endsWith(t))) setFile(f);
              else toast.error('Invalid file type');
            }} />
        </label>
      )}
    </div>
  );

  const lecturerOptions = lecturers.map(l => ({ value: l.full_name, label: l.full_name }));
  const courseOptions = courses.map(c => ({ value: c.id, label: `${c.course_code} — ${c.title}` }));
  const sessionOptions = SESSIONS.map(s => ({ value: s, label: s }));
  const yearOptions = YEARS.map(y => ({ value: y, label: y }));

  return (
    <Layout>
      <PageHeader title="Upload Project" subtitle="Submit your work for lecturer review" />
      <div className="card" style={{ padding: '28px 24px', maxWidth: 680 }}>
        <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: 22 }}>

          {/* Auto-filled student info */}
          <div style={{
            display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16,
            padding: '16px 18px', borderRadius: 12,
            background: 'var(--surface)', border: '1.5px solid var(--border)',
          }}>
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

          {/* Course checkboxes */}
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
                        width: 22, height: 22, borderRadius: '50%', flexShrink: 0,
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
                options={sessionOptions} placeholder="Select session..." />
            </div>
            <div className="field">
              <label className="label">Year *</label>
              <CustomSelect value={form.year} onChange={v => setForm({ ...form, year: v })}
                options={yearOptions} placeholder="Select year..." />
            </div>
          </div>

          <FileInput label="PDF Report" icon={FileText} file={pdfFile} setFile={setPdfFile}
            accept=".pdf" types={['pdf']} required />

          <FileInput label="Source Code (ZIP)" icon={Archive} file={zipFile} setFile={setZipFile}
            accept=".zip" types={['zip']} />

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