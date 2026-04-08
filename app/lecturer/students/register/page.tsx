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
  const [form, setForm] = useState({ full_name: '', email: '', matric_number: '', course_ids: [] as string[] });
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (!requireAuth(getUser(), router, ['lecturer', 'admin'])) return;
    // Fetch ALL courses so lecturer can assign even if not yet assigned to them
    api.get('/admin/courses')
      .then(r => setCourses(r.data))
      .catch(() => {
        // fallback to lecturer courses
        api.get('/lecturer/courses').then(r => setCourses(r.data)).catch(() => {});
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
              value={form.full_name} onChange={e => setForm({ ...form, full_name: e.target.value })} />
          </div>

          <div className="field">
            <label className="label">Email Address</label>
            <input className="input" type="email" required placeholder="e.g. student@gmail.com"
              value={form.email} onChange={e => setForm({ ...form, email: e.target.value })} />
          </div>

          <div className="field">
            <label className="label">Matric Number</label>
            <input className="input mono" required placeholder="e.g. CSC/2021/001"
              value={form.matric_number} onChange={e => setForm({ ...form, matric_number: e.target.value })} />
          </div>

          <div className="field">
            <label className="label">
              Assign to Course(s)
              <span style={{ fontWeight: 400, color: 'var(--muted)', fontSize: 13, marginLeft: 6 }}>Select one or both</span>
            </label>
            {courses.length === 0 ? (
              <div style={{ padding: '14px 16px', borderRadius: 10, background: 'var(--surface)', border: '1.5px solid var(--border)', color: 'var(--muted)', fontSize: 14 }}>
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
                        transition: 'all 0.15s ease', textAlign: 'left',
                      }}>
                      <div style={{
                        width: 22, height: 22, borderRadius: 6, flexShrink: 0,
                        border: `2px solid ${selected ? 'var(--accent)' : 'var(--border)'}`,
                        background: selected ? 'var(--accent)' : 'transparent',
                        display: 'flex', alignItems: 'center', justifyContent: 'center',
                      }}>
                        {selected && <CheckCircle size={14} style={{ color: '#fff' }} />}
                      </div>
                      <div>
                        <div className="mono" style={{ fontSize: 13, fontWeight: 600, color: selected ? 'var(--accent)' : 'var(--muted)' }}>{c.course_code}</div>
                        <div style={{ fontSize: 15, fontWeight: 600, color: 'var(--soft)' }}>{c.title}</div>
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
