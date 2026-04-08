'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { getUser, requireAuth } from '@/lib/auth';
import Layout from '@/components/Layout';
import PageHeader from '@/components/PageHeader';
import EmptyState from '@/components/EmptyState';
import api from '@/lib/api';
import toast from 'react-hot-toast';
import { Users, Plus, X, Trash2, Pencil, CheckCircle, Search } from 'lucide-react';
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
    try {
      const [s, c] = await Promise.all([
        api.get('/admin/students'),
        api.get('/admin/courses'),
      ]);
      setStudents(s.data);
      setCourses(c.data);
  
      // Enrollments — fetch separately, don't fail if empty
      try {
        const e = await api.get('/admin/enrollments');
        setEnrollments(e.data);
      } catch {
        setEnrollments([]);
      }
    } catch {}
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault(); setLoading(true);
    try {
      if (editStudent) {
        await api.put(`/admin/students/${editStudent.id}`, { full_name: form.full_name, email: form.email });
        await api.put(`/admin/students/${editStudent.id}/courses`, { course_ids: form.course_ids });
        toast.success('Student updated successfully');
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
    if (!confirm(`Remove ${name}? This cannot be undone.`)) return;
    try { await api.delete(`/admin/students/${id}`); toast.success('Student removed'); loadData(); }
    catch { toast.error('Failed to remove'); }
  };

  const startEdit = (s: Student) => {
    const enrolled = enrollments.filter(e => e.student_id === s.id).map(e => e.course_id);
    setForm({ full_name: s.full_name, email: s.email, matric_number: s.matric_number, course_ids: enrolled });
    setEditStudent(s); setShowForm(true);
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  const toggleCourse = (id: string) =>
    setForm(f => ({
      ...f,
      course_ids: f.course_ids.includes(id) ? f.course_ids.filter(c => c !== id) : [...f.course_ids, id]
    }));

  const getStudentCourses = (sid: string) =>
    enrollments.filter(e => e.student_id === sid).map(e => courses.find(c => c.id === e.course_id)).filter(Boolean) as Course[];

  const filtered = students.filter(s =>
    s.full_name.toLowerCase().includes(search.toLowerCase()) ||
    s.matric_number.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <Layout>
      <PageHeader title="Students" subtitle={`${students.length} registered`}
        action={
          <button className="btn btn-primary" onClick={() => {
            setShowForm(!showForm); setEditStudent(null);
            setForm({ full_name: '', email: '', matric_number: '', course_ids: [] });
          }}>
            <Plus size={16} /> Register Student
          </button>
        } />

      {showForm && (
        <div className="card fade-up" style={{ padding: 24, marginBottom: 24 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 20 }}>
            <h3 style={{ fontSize: 17, fontWeight: 700, color: 'var(--soft)' }}>
              {editStudent ? 'Edit Student' : 'Register New Student'}
            </h3>
            <button onClick={() => { setShowForm(false); setEditStudent(null); }}
              style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--muted)' }}>
              <X size={20} />
            </button>
          </div>
          <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: 20 }}>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: 16 }}>
              <div className="field">
                <label className="label">Full Name</label>
                <input className="input" required value={form.full_name}
                  onChange={e => setForm({ ...form, full_name: e.target.value })} />
              </div>
              <div className="field">
                <label className="label">Email</label>
                <input className="input" type="email" required value={form.email}
                  onChange={e => setForm({ ...form, email: e.target.value })} />
              </div>
            </div>
            {!editStudent && (
              <div className="field">
                <label className="label">Matric Number</label>
                <input className="input mono" required placeholder="e.g. CSC/2021/001"
                  value={form.matric_number} onChange={e => setForm({ ...form, matric_number: e.target.value })} />
              </div>
            )}

            {/* Course assignment */}
            <div className="field">
              <label className="label">
                Assign to Course(s)
                <span style={{ fontWeight: 400, color: 'var(--muted)', fontSize: 13, marginLeft: 6 }}>Optional</span>
              </label>
              {courses.length === 0 ? (
                <p style={{ color: 'var(--muted)', fontSize: 14, padding: '12px 0' }}>No courses yet — create courses first</p>
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
                          transition: 'all 0.15s', textAlign: 'left',
                        }}>
                        <div style={{
                          width: 22, height: 22, borderRadius: 6, flexShrink: 0,
                          border: `2px solid ${selected ? 'var(--accent)' : 'var(--border)'}`,
                          background: selected ? 'var(--accent)' : 'transparent',
                          display: 'flex', alignItems: 'center', justifyContent: 'center',
                        }}>
                          {selected && <CheckCircle size={13} style={{ color: '#fff' }} />}
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

            <button type="submit" className="btn btn-primary" disabled={loading}>
              {loading ? 'Saving...' : editStudent ? 'Save Changes' : 'Register Student'}
            </button>
          </form>
        </div>
      )}

      {/* Search */}
      <div style={{ position: 'relative', marginBottom: 20 }}>
        <Search size={16} style={{ position: 'absolute', left: 14, top: '50%', transform: 'translateY(-50%)', color: 'var(--muted)', pointerEvents: 'none' }} />
        <input className="input" style={{ paddingLeft: 44 }}
          placeholder="Search by name or matric number..."
          value={search} onChange={e => setSearch(e.target.value)} />
      </div>

      {filtered.length === 0
        ? <EmptyState icon={Users} title="No students yet" subtitle="Register your first student using the button above" />
        : <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
            {filtered.map(s => {
              const sc = getStudentCourses(s.id);
              return (
                <div key={s.id} className="card" style={{ padding: '16px 20px', display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 12 }}>
                  <div style={{ flex: 1, minWidth: 0 }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: 8, flexWrap: 'wrap', marginBottom: 4 }}>
                      <p style={{ fontSize: 15, fontWeight: 700, color: 'var(--soft)' }}>{s.full_name}</p>
                      {sc.map(c => <span key={c.id} className="badge badge-purple">{c.course_code}</span>)}
                    </div>
                    <p style={{ fontSize: 13, color: 'var(--muted)' }}>{s.email}</p>
                    <p className="mono" style={{ fontSize: 12, color: 'var(--muted)', marginTop: 2 }}>
                      {s.matric_number} · {s.created_at ? format(new Date(s.created_at), 'dd MMM yyyy') : ''}
                    </p>
                  </div>
                  <div style={{ display: 'flex', gap: 8, flexShrink: 0 }}>
                    <button onClick={() => startEdit(s)} className="btn btn-secondary btn-sm"><Pencil size={15} /></button>
                    <button onClick={() => handleDelete(s.id, s.full_name)} className="btn btn-danger btn-sm"><Trash2 size={15} /></button>
                  </div>
                </div>
              );
            })}
          </div>
      }
    </Layout>
  );
}
