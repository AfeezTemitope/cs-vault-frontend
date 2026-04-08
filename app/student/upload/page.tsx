'use client';
import { useEffect, useState, useRef } from 'react';
import { useRouter } from 'next/navigation';
import { getUser, requireAuth } from '@/lib/auth';
import Layout from '@/components/Layout';
import PageHeader from '@/components/PageHeader';
import api from '@/lib/api';
import toast from 'react-hot-toast';
import { Upload, FileText, Archive, GitBranch, X, ChevronDown, Check } from 'lucide-react';

interface Course { id: string; title: string; course_code: string; }
const SESSIONS = ['2025/2026', '2024/2025', '2023/2024', '2022/2023', '2021/2022'];

function CustomSelect({ value, onChange, options, placeholder }: {
  value: string; onChange: (v: string) => void;
  options: { value: string; label: string }[]; placeholder: string;
}) {
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLDivElement>(null);
  const selected = options.find(o => o.value === value);

  useEffect(() => {
    const handler = (e: MouseEvent) => {
      if (ref.current && !ref.current.contains(e.target as Node)) setOpen(false);
    };
    document.addEventListener('mousedown', handler);
    return () => document.removeEventListener('mousedown', handler);
  }, []);

  return (
    <div ref={ref} style={{ position: 'relative', width: '100%' }}>
      <button type="button" onClick={() => setOpen(!open)} style={{
        width: '100%', display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        gap: 8, padding: '12px 16px', borderRadius: 10, cursor: 'pointer',
        border: `1.5px solid ${open ? 'var(--accent)' : 'var(--border)'}`,
        background: 'var(--surface)', color: selected ? 'var(--soft)' : 'var(--muted)',
        fontSize: 15, fontFamily: 'Plus Jakarta Sans, sans-serif', fontWeight: 500,
        boxShadow: open ? '0 0 0 3px var(--accent-glow)' : 'none', transition: 'all 0.15s',
      }}>
        <span>{selected ? selected.label : placeholder}</span>
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
  const [courses, setCourses] = useState<Course[]>([]);
  const [form, setForm] = useState({ title: '', description: '', course_id: '', session: '2024/2025', github_link: '' });
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
    if (!pdfFile && !zipFile && !form.github_link) return toast.error('Attach at least one file or GitHub link');
    setLoading(true);
    try {
      const fd = new FormData();
      Object.entries(form).forEach(([k, v]) => { if (v) fd.append(k, v); });
      if (pdfFile) fd.append('files', pdfFile);
      if (zipFile) fd.append('files', zipFile);
      await api.post('/projects', fd, { headers: { 'Content-Type': 'multipart/form-data' } });
      toast.success('Project uploaded successfully!');
      router.push('/student/projects');
    } catch (err: unknown) {
      toast.error((err as { response?: { data?: { error?: string } } })?.response?.data?.error ?? 'Upload failed');
    } finally { setLoading(false); }
  };

  const courseOptions = courses.map(c => ({ value: c.id, label: `${c.course_code} — ${c.title}` }));
  const sessionOptions = SESSIONS.map(s => ({ value: s, label: s }));

  const FileInput = ({ label, icon: Icon, file, setFile, accept, types }: {
    label: string; icon: React.ElementType; file: File | null;
    setFile: (f: File | null) => void; accept: string; types: string[];
  }) => (
    <div className="field">
      <label className="label">{label}</label>
      {file ? (
        <div style={{
          display: 'flex', alignItems: 'center', gap: 12,
          padding: '12px 16px', borderRadius: 10,
          border: '1.5px solid var(--accent)', background: 'var(--accent-light)',
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
          display: 'flex', alignItems: 'center', gap: 12,
          padding: '12px 16px', borderRadius: 10, cursor: 'pointer',
          border: '1.5px dashed var(--border)', background: 'var(--surface)',
          transition: 'all 0.15s',
        }}
          onMouseEnter={e => { (e.currentTarget as HTMLLabelElement).style.borderColor = 'var(--accent)'; }}
          onMouseLeave={e => { (e.currentTarget as HTMLLabelElement).style.borderColor = 'var(--border)'; }}>
          <Icon size={16} style={{ color: 'var(--muted)', flexShrink: 0 }} />
          <span style={{ fontSize: 14, color: 'var(--muted)' }}>Choose {label}...</span>
          <input type="file" accept={accept} className="hidden" style={{ display: 'none' }}
            onChange={e => {
              const f = e.target.files?.[0];
              if (f && types.includes(f.type)) setFile(f);
              else toast.error('Invalid file type');
            }} />
        </label>
      )}
    </div>
  );

  return (
    <Layout>
      <PageHeader title="Upload Project" subtitle="Submit your work to CS-Vault" />
      <div className="card" style={{ padding: '28px 24px', maxWidth: 640 }}>
        <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: 22 }}>
          <div className="field">
            <label className="label">Project Title *</label>
            <input className="input" required placeholder="e.g. Library Management System"
              value={form.title} onChange={e => setForm({ ...form, title: e.target.value })} />
          </div>

          <div className="field">
            <label className="label">Description</label>
            <textarea className="input" rows={3} placeholder="Brief description of your project..."
              style={{ resize: 'none' }}
              value={form.description} onChange={e => setForm({ ...form, description: e.target.value })} />
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16 }}>
            <div className="field">
              <label className="label">Course *</label>
              <CustomSelect
                value={form.course_id}
                onChange={v => setForm({ ...form, course_id: v })}
                options={courseOptions}
                placeholder="Select course..."
              />
            </div>
            <div className="field">
              <label className="label">Session *</label>
              <CustomSelect
                value={form.session}
                onChange={v => setForm({ ...form, session: v })}
                options={sessionOptions}
                placeholder="Select session..."
              />
            </div>
          </div>

          <FileInput label="PDF Report" icon={FileText} file={pdfFile} setFile={setPdfFile}
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

          <button type="submit" className="btn btn-primary btn-full" disabled={loading}
            style={{ padding: '14px 24px', fontSize: 15, marginTop: 4 }}>
            <Upload size={18} />
            {loading ? 'Uploading...' : 'Submit Project'}
          </button>
        </form>
      </div>
    </Layout>
  );
}