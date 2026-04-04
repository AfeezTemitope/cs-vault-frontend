'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { getUser, requireAuth } from '@/lib/auth';
import Layout from '@/components/Layout';
import PageHeader from '@/components/PageHeader';
import api from '@/lib/api';
import toast from 'react-hot-toast';
import { UserPlus, Upload } from 'lucide-react';

interface Course { id: string; title: string; course_code: string; }

export default function RegisterStudents() {
  const router = useRouter();
  const [courses, setCourses] = useState<Course[]>([]);
  const [tab, setTab] = useState<'single'|'bulk'>('single');
  const [form, setForm] = useState({ full_name:'', email:'', matric_number:'', course_id:'' });
  const [csvFile, setCsvFile] = useState<File|null>(null);
  const [courseId, setCourseId] = useState('');
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (!requireAuth(getUser(), router, ['lecturer','admin'])) return;
    api.get('/lecturer/courses').then(r => setCourses(r.data)).catch(() => {});
  }, [router]);

  const inp = "w-full rounded-lg px-4 py-2.5 text-sm border focus:outline-none";
  const inpStyle = { backgroundColor:'var(--surface)', borderColor:'var(--border)', color:'var(--soft)' };

  const handleSingle = async (e: React.FormEvent) => {
    e.preventDefault(); setLoading(true);
    try { await api.post('/lecturer/students/register', form); toast.success('Student registered!'); setForm({ full_name:'', email:'', matric_number:'', course_id:'' }); }
    catch (err: unknown) { toast.error((err as {response?:{data?:{error?:string}}})?.response?.data?.error ?? 'Failed'); }
    finally { setLoading(false); }
  };

  const handleBulk = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!csvFile || !courseId) return toast.error('Select course and upload CSV');
    setLoading(true);
    const fd = new FormData(); fd.append('file', csvFile); fd.append('course_id', courseId);
    try {
      const { data } = await api.post('/lecturer/students/bulk', fd);
      toast.success(`${data.registered} students registered!`);
      if (data.errors?.length) toast.error(`${data.errors.length} failed`);
      setCsvFile(null); setCourseId('');
    } catch { toast.error('Bulk upload failed'); }
    finally { setLoading(false); }
  };

  const CourseSelect = ({ value, onChange }: { value: string; onChange: (v:string)=>void }) => (
    <div>
      <label className="text-xs block mb-1" style={{ color:'var(--muted)' }}>Course</label>
      <select required className="w-full rounded-lg px-4 py-2.5 text-sm border focus:outline-none"
        style={inpStyle} value={value} onChange={e => onChange(e.target.value)}>
        <option value="">— Select course —</option>
        {courses.map(c => <option key={c.id} value={c.id}>{c.title} ({c.course_code})</option>)}
      </select>
    </div>
  );

  return (
    <Layout>
      <PageHeader title="Register Students" subtitle="Add students to your courses" />
      <div className="flex gap-2 mb-5">
        {(['single','bulk'] as const).map(t => (
          <button key={t} onClick={() => setTab(t)}
            className="px-4 py-2 rounded-lg text-sm font-medium border transition-all"
            style={tab===t ? { backgroundColor:'var(--accent)', color:'var(--ink)', borderColor:'var(--accent)' } : { backgroundColor:'transparent', color:'var(--muted)', borderColor:'var(--border)' }}>
            {t==='single' ? '+ Single' : '⬆ Bulk CSV'}
          </button>
        ))}
      </div>

      {tab==='single' && (
        <div className="rounded-xl p-5 border" style={{ backgroundColor:'var(--card)', borderColor:'var(--border)' }}>
          <form onSubmit={handleSingle} className="space-y-4">
            {[['Full Name','full_name'],['Email','email'],['Matric Number','matric_number']].map(([label,key]) => (
              <div key={key}>
                <label className="text-xs block mb-1" style={{ color:'var(--muted)' }}>{label}</label>
                <input required className={inp} style={inpStyle}
                  value={form[key as keyof typeof form]} onChange={e => setForm({...form,[key]:e.target.value})}
                  onFocus={e=>(e.target.style.borderColor='var(--accent)')} onBlur={e=>(e.target.style.borderColor='var(--border)')} />
              </div>
            ))}
            <CourseSelect value={form.course_id} onChange={v => setForm({...form,course_id:v})} />
            <button type="submit" disabled={loading}
              className="w-full font-semibold py-3 rounded-lg text-sm flex items-center justify-center gap-2 disabled:opacity-50"
              style={{ backgroundColor:'var(--accent)', color:'var(--ink)' }}>
              <UserPlus size={15} />{loading ? 'Registering...' : 'Register Student'}
            </button>
          </form>
        </div>
      )}

      {tab==='bulk' && (
        <div className="rounded-xl p-5 border" style={{ backgroundColor:'var(--card)', borderColor:'var(--border)' }}>
          <div className="rounded-xl p-4 mb-4 text-center border border-dashed" style={{ backgroundColor:'var(--surface)', borderColor:'var(--border)' }}>
            <p className="text-xs mb-1" style={{ color:'var(--muted)' }}>CSV format:</p>
            <p className="mono text-xs" style={{ color:'var(--accent)' }}>full_name, email, matric_number</p>
          </div>
          <form onSubmit={handleBulk} className="space-y-4">
            <CourseSelect value={courseId} onChange={setCourseId} />
            <div>
              <label className="text-xs block mb-1" style={{ color:'var(--muted)' }}>Upload CSV</label>
              <label className="flex items-center gap-3 w-full rounded-lg px-4 py-3 border cursor-pointer transition-all"
                style={{ backgroundColor:'var(--surface)', borderColor:'var(--border)' }}
                onMouseEnter={e=>(e.currentTarget.style.borderColor='rgba(200,241,53,0.4)')}
                onMouseLeave={e=>(e.currentTarget.style.borderColor='var(--border)')}>
                <Upload size={15} style={{ color:'var(--muted)' }} />
                <span className="text-sm" style={{ color:'var(--muted)' }}>{csvFile ? csvFile.name : 'Choose CSV file...'}</span>
                <input type="file" accept=".csv" className="hidden" onChange={e => setCsvFile(e.target.files?.[0] ?? null)} />
              </label>
            </div>
            <button type="submit" disabled={loading}
              className="w-full font-semibold py-3 rounded-lg text-sm disabled:opacity-50"
              style={{ backgroundColor:'var(--accent)', color:'var(--ink)' }}>
              {loading ? 'Uploading...' : 'Bulk Register'}
            </button>
          </form>
        </div>
      )}
    </Layout>
  );
}
