'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { getUser, requireAuth } from '@/lib/auth';
import Layout from '@/components/Layout';
import PageHeader from '@/components/PageHeader';
import EmptyState from '@/components/EmptyState';
import api from '@/lib/api';
import toast from 'react-hot-toast';
import { BookOpen, Plus, X } from 'lucide-react';

interface Course { id: string; title: string; course_code: string; session: string; lecturer_id?: string; }
interface Lecturer { id: string; full_name: string; }

export default function CoursesPage() {
  const router = useRouter();
  const [courses, setCourses] = useState<Course[]>([]);
  const [lecturers, setLecturers] = useState<Lecturer[]>([]);
  const [showForm, setShowForm] = useState(false);
  const [form, setForm] = useState({ title: '', course_code: '', description: '', session: '2024/2025' });
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (!requireAuth(getUser(), router, ['admin'])) return;
    loadData();
  }, [router]);

  const loadData = () =>
    Promise.all([api.get('/admin/courses'), api.get('/admin/lecturers')])
      .then(([c, l]) => { setCourses(c.data); setLecturers(l.data); }).catch(() => {});

  const handleCreate = async (e: React.FormEvent) => {
    e.preventDefault(); setLoading(true);
    try { await api.post('/admin/courses', form); toast.success('Course created'); setShowForm(false); loadData(); }
    catch (err: unknown) { toast.error((err as { response?: { data?: { error?: string } } })?.response?.data?.error ?? 'Failed'); }
    finally { setLoading(false); }
  };

  const assign = async (course_id: string, lecturer_id: string) => {
    try { await api.put('/admin/courses/assign', { course_id, lecturer_id }); toast.success('Assigned!'); loadData(); }
    catch { toast.error('Failed'); }
  };

  const inp = "w-full rounded-lg px-4 py-2.5 text-sm border focus:outline-none";
  const inpStyle = { backgroundColor: 'var(--surface)', borderColor: 'var(--border)', color: 'var(--soft)' };

  return (
    <Layout>
      <PageHeader title="Courses" subtitle={`${courses.length} courses`}
        action={
          <button onClick={() => setShowForm(!showForm)}
            className="flex items-center gap-2 px-4 py-2 rounded-lg text-sm font-semibold"
            style={{ backgroundColor: 'var(--accent)', color: 'var(--ink)' }}>
            <Plus size={15} />Add Course
          </button>
        } />

      {showForm && (
        <div className="rounded-xl p-5 mb-5 border fade-up" style={{ backgroundColor: 'var(--card)', borderColor: 'var(--border)' }}>
          <div className="flex items-center justify-between mb-4">
            <h3 className="font-semibold" style={{ color: 'var(--soft)' }}>New Course</h3>
            <button onClick={() => setShowForm(false)} style={{ color: 'var(--muted)' }}><X size={16} /></button>
          </div>
          <form onSubmit={handleCreate} className="space-y-3">
            {[['Course Title', 'title'], ['Course Code', 'course_code'], ['Session', 'session']].map(([label, key]) => (
              <div key={key}>
                <label className="text-xs block mb-1" style={{ color: 'var(--muted)' }}>{label}</label>
                <input required className={inp} style={inpStyle}
                  value={form[key as keyof typeof form]}
                  onChange={e => setForm({ ...form, [key]: e.target.value })}
                  onFocus={e => (e.target.style.borderColor = 'var(--accent)')}
                  onBlur={e => (e.target.style.borderColor = 'var(--border)')} />
              </div>
            ))}
            <button type="submit" disabled={loading}
              className="w-full font-semibold py-2.5 rounded-lg text-sm disabled:opacity-50"
              style={{ backgroundColor: 'var(--accent)', color: 'var(--ink)' }}>
              {loading ? 'Creating...' : 'Create Course'}
            </button>
          </form>
        </div>
      )}

      {courses.length === 0
        ? <EmptyState icon={BookOpen} title="No courses yet" subtitle="Add your first course" />
        : <div className="space-y-3">
            {courses.map(c => (
              <div key={c.id} className="rounded-xl p-4 border" style={{ backgroundColor: 'var(--card)', borderColor: 'var(--border)' }}>
                <div className="flex items-start justify-between mb-3">
                  <div>
                    <p className="font-semibold text-sm" style={{ color: 'var(--soft)' }}>{c.title}</p>
                    <p className="text-xs mt-0.5" style={{ color: 'var(--muted)' }}>{c.session}</p>
                  </div>
                  <span className="mono text-xs px-2 py-0.5 rounded" style={{ color: 'var(--accent)', backgroundColor: 'rgba(200,241,53,0.1)' }}>{c.course_code}</span>
                </div>
                <select className="w-full rounded-lg px-3 py-2 text-sm border focus:outline-none"
                  style={{ backgroundColor: 'var(--surface)', borderColor: 'var(--border)', color: 'var(--soft)' }}
                  value={c.lecturer_id ?? ''} onChange={e => assign(c.id, e.target.value)}>
                  <option value="">— Assign lecturer —</option>
                  {lecturers.map(l => <option key={l.id} value={l.id}>{l.full_name}</option>)}
                </select>
              </div>
            ))}
          </div>
      }
    </Layout>
  );
}
