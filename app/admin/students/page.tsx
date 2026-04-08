'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { getUser, requireAuth } from '@/lib/auth';
import Layout from '@/components/Layout';
import PageHeader from '@/components/PageHeader';
import EmptyState from '@/components/EmptyState';
import api from '@/lib/api';
import toast from 'react-hot-toast';
import { Users, Plus, X, Trash2, Pencil } from 'lucide-react';
import { format } from 'date-fns';

interface Student { id: string; full_name: string; email: string; matric_number: string; created_at: string; }
interface Course { id: string; title: string; course_code: string; }
interface Enrollment { student_id: string; course_id: string; }

export default function StudentsPage() {
  const router = useRouter();
  const [students, setStudents] = useState<Student[]>([]);
  const [courses, setCourses] = useState<Course[]>([]);
  const [enrollments, setEnrollments] = useState<Enrollment[]>([]);
  const [search, setSearch] = useState('');
  const [showForm, setShowForm] = useState(false);
  const [form, setForm] = useState({ full_name: '', email: '', matric_number: '', course_ids: [] as string[] });
  const [loading, setLoading] = useState(false);
  const [editStudent, setEditStudent] = useState<Student | null>(null);

  useEffect(() => {
    if (!requireAuth(getUser(), router, ['admin'])) return;
    loadData();
  }, [router]);

  const loadData = async () => {
    const [s, c, e] = await Promise.all([
      api.get('/admin/students'),
      api.get('/admin/courses'),
      api.get('/admin/enrollments'),
    ]);
    setStudents(s.data); setCourses(c.data); setEnrollments(e.data);
  };

  const handleRegister = async (e: React.FormEvent) => {
    e.preventDefault(); setLoading(true);
    try {
      if (editStudent) {
        await api.put(`/admin/students/${editStudent.id}`, { full_name: form.full_name, email: form.email });
        if (form.course_ids.length > 0) {
          await api.put(`/admin/students/${editStudent.id}/courses`, { course_ids: form.course_ids });
        }
        toast.success('Student updated');
      } else {
        await api.post('/admin/students/register', form);
        toast.success('Student registered — credentials sent!');
      }
      setShowForm(false); setEditStudent(null);
      setForm({ full_name: '', email: '', matric_number: '', course_ids: [] });
      loadData();
    } catch (err: unknown) {
      toast.error((err as { response?: { data?: { error?: string } } })?.response?.data?.error ?? 'Failed');
    } finally { setLoading(false); }
  };

  const handleDelete = async (id: string, name: string) => {
    if (!confirm(`Remove ${name}?`)) return;
    try { await api.delete(`/admin/students/${id}`); toast.success('Student removed'); loadData(); }
    catch { toast.error('Failed'); }
  };

  const startEdit = (s: Student) => {
    const enrolled = enrollments.filter(e => e.student_id === s.id).map(e => e.course_id);
    setForm({ full_name: s.full_name, email: s.email, matric_number: s.matric_number, course_ids: enrolled });
    setEditStudent(s); setShowForm(true);
  };

  const toggleCourse = (id: string) => {
    setForm(f => ({
      ...f,
      course_ids: f.course_ids.includes(id) ? f.course_ids.filter(c => c !== id) : [...f.course_ids, id]
    }));
  };

  const getStudentCourses = (studentId: string) =>
    enrollments.filter(e => e.student_id === studentId).map(e => courses.find(c => c.id === e.course_id)).filter(Boolean) as Course[];

  const filtered = students.filter(s =>
    s.full_name.toLowerCase().includes(search.toLowerCase()) ||
    s.matric_number.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <Layout>
      <PageHeader title="Students" subtitle={`${students.length} registered`}
        action={
          <button className="btn-primary" onClick={() => { setShowForm(!showForm); setEditStudent(null); setForm({ full_name: '', email: '', matric_number: '', course_ids: [] }); }}>
            <Plus size={16} /> Register Student
          </button>
        } />

      {showForm && (
        <div className="card fade-up" style={{ padding: 24, marginBottom: 24 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 20 }}>
            <h3 style={{ fontSize: 17, fontWeight: 700, color: 'var(--soft)' }}>{editStudent ? 'Edit Student' : 'Register New Student'}</h3>
            <button onClick={() => { setShowForm(false); setEditStudent(null); }} style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--muted)' }}><X size={18} /></button>
          </div>
          <form onSubmit={handleRegister} style={{ display: 'grid', gap: 16 }}>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16 }}>
              {[['Full Name', 'full_name'], ['Email', 'email']].map(([label, key]) => (
                <div key={key}>
                  <label style={{ display: 'block', fontSize: 14, fontWeight: 600, color: 'var(--soft)', marginBottom: 6 }}>{label}</label>
                  <input className="input-field" required value={form[key as keyof typeof form] as string}
                    onChange={e => setForm({ ...form, [key]: e.target.value })} />
                </div>
              ))}
            </div>
            {!editStudent && (
              <div>
                <label style={{ display: 'block', fontSize: 14, fontWeight: 600, color: 'var(--soft)', marginBottom: 6 }}>Matric Number</label>
                <input className="input-field mono" required value={form.matric_number}
                  onChange={e => setForm({ ...form, matric_number: e.target.value })} placeholder="e.g. CSC/2021/001" />
              </div>
            )}
            <div>
              <label style={{ display: 'block', fontSize: 14, fontWeight: 600, color: 'var(--soft)', marginBottom: 10 }}>
                Assign to Course(s) <span style={{ color: 'var(--muted)', fontWeight: 400 }}>(optional)</span>
              </label>
              <div style={{ display: 'flex', gap: 12 }}>
                {courses.map(c => (
                  <button type="button" key={c.id} onClick={() => toggleCourse(c.id)}
                    style={{
                      padding: '10px 20px', borderRadius: 10, cursor: 'pointer', fontSize: 14, fontWeight: 600, transition: 'all 0.15s',
                      border: '1.5px solid', flex: 1, justifyContent: 'center',
                      backgroundColor: form.course_ids.includes(c.id) ? 'var(--accent)' : 'var(--surface)',
                      borderColor: form.course_ids.includes(c.id) ? 'var(--accent)' : 'var(--border)',
                      color: form.course_ids.includes(c.id) ? '#fff' : 'var(--soft)',
                    }}>
                    {c.course_code}
                  </button>
                ))}
              </div>
            </div>
            <button type="submit" className="btn-primary" disabled={loading}>
              {loading ? 'Saving...' : editStudent ? 'Save Changes' : 'Register Student'}
            </button>
          </form>
        </div>
      )}

      <input className="input-field" style={{ marginBottom: 16 }}
        placeholder="Search by name or matric number..."
        value={search} onChange={e => setSearch(e.target.value)} />

      {filtered.length === 0
        ? <EmptyState icon={Users} title="No students found" subtitle="Register students using the button above" />
        : <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
            {filtered.map(s => {
              const studentCourses = getStudentCourses(s.id);
              return (
                <div key={s.id} className="card" style={{ padding: '16px 20px', display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 12 }}>
                  <div style={{ flex: 1 }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 4 }}>
                      <p style={{ fontSize: 15, fontWeight: 700, color: 'var(--soft)' }}>{s.full_name}</p>
                      {studentCourses.map(c => <span key={c.id} className="badge badge-blue">{c.course_code}</span>)}
                    </div>
                    <p style={{ fontSize: 13, color: 'var(--muted)' }}>{s.email}</p>
                    <p className="mono" style={{ fontSize: 12, color: 'var(--muted)', marginTop: 2 }}>
                      {s.matric_number} · {s.created_at ? format(new Date(s.created_at), 'dd MMM yyyy') : ''}
                    </p>
                  </div>
                  <div style={{ display: 'flex', gap: 8 }}>
                    <button onClick={() => startEdit(s)} className="btn-secondary" style={{ padding: '8px 12px' }}><Pencil size={15} /></button>
                    <button onClick={() => handleDelete(s.id, s.full_name)} style={{ padding: '8px 12px', borderRadius: 10, border: '1.5px solid #FEE2E2', background: '#FEF2F2', color: '#DC2626', cursor: 'pointer' }}><Trash2 size={15} /></button>
                  </div>
                </div>
              );
            })}
          </div>
      }
    </Layout>
  );
}
