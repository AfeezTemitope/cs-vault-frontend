'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { getUser, requireAuth } from '@/lib/auth';
import Layout from '@/components/Layout';
import PageHeader from '@/components/PageHeader';
import EmptyState from '@/components/EmptyState';
import api from '@/lib/api';
import toast from 'react-hot-toast';
import { BookOpen, Plus, X, Trash2 } from 'lucide-react';

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
    try { await api.put('/admin/courses/assign', { course_id, lecturer_id: lecturer_id || null }); toast.success(lecturer_id ? 'Lecturer assigned' : 'Lecturer removed'); loadData(); }
    catch { toast.error('Failed'); }
  };

  const handleDelete = async (id: string, title: string) => {
    if (!confirm(`Delete ${title}?`)) return;
    try { await api.delete(`/admin/courses/${id}`); toast.success('Course deleted'); loadData(); }
    catch { toast.error('Failed'); }
  };

  return (
    <Layout>
      <PageHeader title="Courses" subtitle={`${courses.length} active courses`}
        action={
          <button className="btn-primary" onClick={() => setShowForm(!showForm)}>
            <Plus size={16} /> Add Course
          </button>
        } />

      {showForm && (
        <div className="card fade-up" style={{ padding: 24, marginBottom: 24 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 20 }}>
            <h3 style={{ fontSize: 17, fontWeight: 700, color: 'var(--soft)' }}>New Course</h3>
            <button onClick={() => setShowForm(false)} style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--muted)' }}><X size={18} /></button>
          </div>
          <form onSubmit={handleCreate} style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16 }}>
            {[['Course Title', 'title'], ['Course Code', 'course_code'], ['Session', 'session']].map(([label, key]) => (
              <div key={key}>
                <label style={{ display: 'block', fontSize: 14, fontWeight: 600, color: 'var(--soft)', marginBottom: 6 }}>{label}</label>
                <input className="input-field" required value={form[key as keyof typeof form]}
                  onChange={e => setForm({ ...form, [key]: e.target.value })} />
              </div>
            ))}
            <div style={{ gridColumn: '1 / -1' }}>
              <button type="submit" className="btn-primary" disabled={loading}>
                {loading ? 'Creating...' : 'Create Course'}
              </button>
            </div>
          </form>
        </div>
      )}

      {courses.length === 0
        ? <EmptyState icon={BookOpen} title="No courses yet" subtitle="Add CSC 497 and CSC 498 above" />
        : <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            {courses.map(c => {
              const assigned = lecturers.find(l => l.id === c.lecturer_id);
              return (
                <div key={c.id} className="card" style={{ padding: '20px 22px' }}>
                  <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: 16 }}>
                    <div style={{ flex: 1 }}>
                      <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 6 }}>
                        <h3 style={{ fontSize: 16, fontWeight: 700, color: 'var(--soft)' }}>{c.title}</h3>
                        <span className="badge badge-blue">{c.course_code}</span>
                        <span style={{ fontSize: 13, color: 'var(--muted)' }}>{c.session}</span>
                      </div>
                      <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                        <label style={{ fontSize: 14, color: 'var(--muted)', fontWeight: 500, whiteSpace: 'nowrap' }}>Assigned lecturer:</label>
                        <select className="input-field" style={{ padding: '8px 12px', maxWidth: 260 }}
                          value={c.lecturer_id ?? ''} onChange={e => assign(c.id, e.target.value)}>
                          <option value="">— Unassigned —</option>
                          {lecturers.map(l => <option key={l.id} value={l.id}>{l.full_name}</option>)}
                        </select>
                      </div>
                      {assigned && <p style={{ fontSize: 13, color: 'var(--accent)', marginTop: 6, fontWeight: 500 }}>✓ {assigned.full_name}</p>}
                    </div>
                    <button onClick={() => handleDelete(c.id, c.title)} style={{ padding: '8px 12px', borderRadius: 10, border: '1.5px solid #FEE2E2', background: '#FEF2F2', color: '#DC2626', cursor: 'pointer' }}>
                      <Trash2 size={15} />
                    </button>
                  </div>
                </div>
              );
            })}
          </div>
      }
    </Layout>
  );
}
