'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { getUser, requireAuth } from '@/lib/auth';
import Layout from '@/components/Layout';
import PageHeader from '@/components/PageHeader';
import api from '@/lib/api';
import toast from 'react-hot-toast';
import { Upload, FileText, Archive, GitBranch, X } from 'lucide-react';

interface Course { id: string; title: string; course_code: string; }
const SESSIONS = ['2024/2025', '2023/2024', '2022/2023', '2021/2022'];

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
        if (p.courses && !map[p.course_id]) {
          map[p.course_id] = { ...p.courses, id: p.course_id };
        }
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
      toast.success('Project uploaded!');
      router.push('/student/projects');
    } catch (err: unknown) {
      toast.error((err as { response?: { data?: { error?: string } } })?.response?.data?.error ?? 'Upload failed');
    } finally { setLoading(false); }
  };

  const inp = 'w-full rounded-xl px-4 py-3 text-sm border focus:outline-none';
  const inpStyle = { backgroundColor: 'var(--card)', borderColor: 'var(--border)', color: 'var(--soft)' };

  const FileInput = ({
    label, icon: Icon, file, setFile, accept, types
  }: {
    label: string; icon: React.ElementType; file: File | null;
    setFile: (f: File | null) => void; accept: string; types: string[];
  }) => (
    <div>
      <label className="text-xs block mb-1" style={{ color: 'var(--muted)' }}>{label}</label>
      {file ? (
        <div className="flex items-center gap-3 rounded-lg px-4 py-3 border"
          style={{ backgroundColor: 'var(--surface)', borderColor: 'rgba(200,241,53,0.3)' }}>
          <Icon size={15} style={{ color: 'var(--accent)' }} />
          <span className="text-sm flex-1 truncate" style={{ color: 'var(--soft)' }}>{file.name}</span>
          <button type="button" onClick={() => setFile(null)} style={{ color: 'var(--muted)' }}><X size={15} /></button>
        </div>
      ) : (
        <label className="flex items-center gap-3 w-full rounded-lg px-4 py-3 border cursor-pointer transition-all"
          style={{ backgroundColor: 'var(--surface)', borderColor: 'var(--border)' }}
          onMouseEnter={e => (e.currentTarget.style.borderColor = 'rgba(200,241,53,0.4)')}
          onMouseLeave={e => (e.currentTarget.style.borderColor = 'var(--border)')}>
          <Icon size={15} style={{ color: 'var(--muted)' }} />
          <span className="text-sm" style={{ color: 'var(--muted)' }}>Choose {label}...</span>
          <input type="file" accept={accept} className="hidden"
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
      <form onSubmit={handleSubmit} className="space-y-4 pb-24">
        <div>
          <label className="text-xs block mb-1" style={{ color: 'var(--muted)' }}>Project Title *</label>
          <input required className={inp} style={inpStyle}
            placeholder="e.g. Library Management System"
            value={form.title} onChange={e => setForm({ ...form, title: e.target.value })}
            onFocus={e => (e.target.style.borderColor = 'var(--accent)')}
            onBlur={e => (e.target.style.borderColor = 'var(--border)')} />
        </div>

        <div>
          <label className="text-xs block mb-1" style={{ color: 'var(--muted)' }}>Description</label>
          <textarea rows={3} className={inp + ' resize-none'} style={inpStyle}
            placeholder="Brief description of your project..."
            value={form.description} onChange={e => setForm({ ...form, description: e.target.value })}
            onFocus={e => (e.target.style.borderColor = 'var(--accent)')}
            onBlur={e => (e.target.style.borderColor = 'var(--border)')} />
        </div>

        <div className="grid grid-cols-2 gap-3">
          <div>
            <label className="text-xs block mb-1" style={{ color: 'var(--muted)' }}>Course *</label>
            <select required className={inp} style={inpStyle}
              value={form.course_id} onChange={e => setForm({ ...form, course_id: e.target.value })}>
              <option value="">Select...</option>
              {courses.map(c => <option key={c.id} value={c.id}>{c.course_code || c.title}</option>)}
            </select>
          </div>
          <div>
            <label className="text-xs block mb-1" style={{ color: 'var(--muted)' }}>Session *</label>
            <select required className={inp} style={inpStyle}
              value={form.session} onChange={e => setForm({ ...form, session: e.target.value })}>
              {SESSIONS.map(s => <option key={s} value={s}>{s}</option>)}
            </select>
          </div>
        </div>

        <FileInput label="PDF Report" icon={FileText} file={pdfFile} setFile={setPdfFile}
          accept=".pdf" types={['application/pdf']} />

        <FileInput label="Source Code (ZIP)" icon={Archive} file={zipFile} setFile={setZipFile}
          accept=".zip" types={['application/zip', 'application/x-zip-compressed']} />

        <div>
          <label className="text-xs block mb-1 flex items-center gap-1" style={{ color: 'var(--muted)' }}>
            <GitBranch size={12} /> GitHub Link (optional)
          </label>
          <input className={inp + ' mono'} style={inpStyle}
            placeholder="https://github.com/username/repo"
            value={form.github_link} onChange={e => setForm({ ...form, github_link: e.target.value })}
            onFocus={e => (e.target.style.borderColor = 'var(--accent)')}
            onBlur={e => (e.target.style.borderColor = 'var(--border)')} />
        </div>

        <button type="submit" disabled={loading}
          className="w-full font-bold py-4 rounded-xl text-sm flex items-center justify-center gap-2 disabled:opacity-50"
          style={{ backgroundColor: 'var(--accent)', color: 'var(--ink)' }}>
          <Upload size={16} />
          {loading ? 'Uploading...' : 'Submit Project'}
        </button>
      </form>
    </Layout>
  );
}