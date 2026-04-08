'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { getUser, requireAuth } from '@/lib/auth';
import Layout from '@/components/Layout';
import PageHeader from '@/components/PageHeader';
import api from '@/lib/api';
import toast from 'react-hot-toast';
import { UserPlus } from 'lucide-react';

interface Course { id: string; title: string; course_code: string; }

export default function RegisterStudents() {
  const router = useRouter();
  const [courses, setCourses] = useState<Course[]>([]);
  const [form, setForm] = useState({ full_name: '', email: '', matric_number: '', course_ids: [] as string[] });
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (!requireAuth(getUser(), router, ['lecturer', 'admin'])) return;
    api.get('/lecturer/courses').then(r => setCourses(r.data)).catch(() => {});
  }, [router]);

  const toggleCourse = (id: string) => {
    setForm(f => ({
      ...f,
      course_ids: f.course_ids.includes(id) ? f.course_ids.filter(c => c !== id) : [...f.course_ids, id]
    }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (form.course_ids.length === 0) return toast.error('Select at least one course');
    setLoading(true);
    try {
      await api.post('/lecturer/students/register', form);
      toast.success('Student registered — credentials sent!');
      setForm({ full_name: '', email: '', matric_number: '', course_ids: [] });
    } catch (err: unknown) {
      toast.error((err as { response?: { data?: { error?: string } } })?.response?.data?.error ?? 'Failed');
    } finally { setLoading(false); }
  };

  return (
    <Layout>
      <PageHeader title="Register Student" subtitle="Add a student to your course" />
      <div className="card" style={{ padding: 28, maxWidth: 560 }}>
        <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: 20 }}>
          {[['Full Name', 'full_name', 'text', 'e.g. John Doe'], ['Email Address', 'email', 'email', 'e.g. student@gmail.com'], ['Matric Number', 'matric_number', 'text', 'e.g. CSC/2021/001']].map(([label, key, type, placeholder]) => (
            <div key={key}>
              <label style={{ display: 'block', fontSize: 14, fontWeight: 600, color: 'var(--soft)', marginBottom: 8 }}>{label}</label>
              <input type={type} required className={`input-field${key === 'matric_number' ? ' mono' : ''}`}
                placeholder={placeholder}
                value={form[key as keyof typeof form] as string}
                onChange={e => setForm({ ...form, [key]: e.target.value })} />
            </div>
          ))}

          <div>
            <label style={{ display: 'block', fontSize: 14, fontWeight: 600, color: 'var(--soft)', marginBottom: 10 }}>
              Assign to Course(s)
            </label>
            <div style={{ display: 'flex', gap: 12 }}>
              {courses.map(c => (
                <button type="button" key={c.id} onClick={() => toggleCourse(c.id)}
                  style={{
                    flex: 1, padding: '12px 16px', borderRadius: 10, cursor: 'pointer',
                    fontSize: 15, fontWeight: 600, transition: 'all 0.15s', border: '1.5px solid',
                    backgroundColor: form.course_ids.includes(c.id) ? 'var(--accent)' : 'var(--surface)',
                    borderColor: form.course_ids.includes(c.id) ? 'var(--accent)' : 'var(--border)',
                    color: form.course_ids.includes(c.id) ? '#fff' : 'var(--soft)',
                  }}>
                  {c.course_code}
                  <div style={{ fontSize: 12, fontWeight: 400, opacity: 0.8, marginTop: 2 }}>{c.title}</div>
                </button>
              ))}
            </div>
          </div>

          <button type="submit" className="btn-primary" disabled={loading} style={{ justifyContent: 'center', padding: '13px 24px' }}>
            <UserPlus size={17} /> {loading ? 'Registering...' : 'Register Student'}
          </button>
        </form>
      </div>
    </Layout>
  );
}
