'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { getUser, requireAuth } from '@/lib/auth';
import Layout from '@/components/Layout';
import PageHeader from '@/components/PageHeader';
import EmptyState from '@/components/EmptyState';
import api from '@/lib/api';
import toast from 'react-hot-toast';
import { GraduationCap, Plus, X, Pencil, Trash2 } from 'lucide-react';
import { format } from 'date-fns';

interface Lecturer { id: string; full_name: string; email: string; matric_number: string; department: string; created_at: string; }
interface Course { id: string; title: string; course_code: string; lecturer_id?: string; }

export default function LecturersPage() {
  const router = useRouter();
  const [lecturers, setLecturers] = useState<Lecturer[]>([]);
  const [courses, setCourses] = useState<Course[]>([]);
  const [showForm, setShowForm] = useState(false);
  const [editId, setEditId] = useState<string | null>(null);
  const [form, setForm] = useState({ full_name: '', email: '', matric_number: '', department: 'Computer Science' });
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (!requireAuth(getUser(), router, ['admin'])) return;
    loadData();
  }, [router]);

  const loadData = async () => {
    const [l, c] = await Promise.all([api.get('/admin/lecturers'), api.get('/admin/courses')]);
    setLecturers(l.data); setCourses(c.data);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault(); setLoading(true);
    try {
      if (editId) {
        await api.put(`/admin/lecturers/${editId}`, { full_name: form.full_name, email: form.email, department: form.department });
        toast.success('Lecturer updated');
      } else {
        await api.post('/admin/lecturers', form);
        toast.success('Lecturer created — credentials sent!');
      }
      setShowForm(false); setEditId(null); setForm({ full_name: '', email: '', matric_number: '', department: 'Computer Science' });
      loadData();
    } catch (err: unknown) {
      toast.error((err as { response?: { data?: { error?: string } } })?.response?.data?.error ?? 'Failed');
    } finally { setLoading(false); }
  };

  const handleDelete = async (id: string, name: string) => {
    if (!confirm(`Remove ${name}? This cannot be undone.`)) return;
    try { await api.delete(`/admin/lecturers/${id}`); toast.success('Lecturer removed'); loadData(); }
    catch { toast.error('Failed to remove'); }
  };

  const startEdit = (l: Lecturer) => {
    setForm({ full_name: l.full_name, email: l.email, matric_number: l.matric_number, department: l.department });
    setEditId(l.id); setShowForm(true);
  };

  const getAssignedCourse = (id: string) => courses.find(c => c.lecturer_id === id);

  return (
    <Layout>
      <PageHeader title="Lecturers" subtitle={`${lecturers.length} registered`}
        action={
          <button className="btn-primary" onClick={() => { setShowForm(!showForm); setEditId(null); setForm({ full_name: '', email: '', matric_number: '', department: 'Computer Science' }); }}>
            <Plus size={16} /> Add Lecturer
          </button>
        } />

      {showForm && (
        <div className="card fade-up" style={{ padding: 24, marginBottom: 24 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 20 }}>
            <h3 style={{ fontSize: 17, fontWeight: 700, color: 'var(--soft)' }}>{editId ? 'Edit Lecturer' : 'New Lecturer'}</h3>
            <button onClick={() => { setShowForm(false); setEditId(null); }} style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--muted)' }}><X size={18} /></button>
          </div>
          <form onSubmit={handleSubmit} style={{ display: 'grid', gap: 16 }}>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16 }}>
              {[['Full Name', 'full_name'], ['Email', 'email']].map(([label, key]) => (
                <div key={key}>
                  <label style={{ display: 'block', fontSize: 14, fontWeight: 600, color: 'var(--soft)', marginBottom: 6 }}>{label}</label>
                  <input className="input-field" required value={form[key as keyof typeof form]}
                    onChange={e => setForm({ ...form, [key]: e.target.value })} />
                </div>
              ))}
            </div>
            {!editId && (
              <div>
                <label style={{ display: 'block', fontSize: 14, fontWeight: 600, color: 'var(--soft)', marginBottom: 6 }}>Staff ID</label>
                <input className="input-field mono" required value={form.matric_number}
                  onChange={e => setForm({ ...form, matric_number: e.target.value })} placeholder="e.g. STAFF001" />
              </div>
            )}
            <button type="submit" className="btn-primary" disabled={loading}>
              {loading ? 'Saving...' : editId ? 'Save Changes' : 'Create & Send Credentials'}
            </button>
          </form>
        </div>
      )}

      {lecturers.length === 0
        ? <EmptyState icon={GraduationCap} title="No lecturers yet" subtitle="Add your first lecturer above" />
        : <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            {lecturers.map(l => {
              const course = getAssignedCourse(l.id);
              return (
                <div key={l.id} className="card" style={{ padding: '18px 22px' }}>
                  <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: 12 }}>
                    <div style={{ flex: 1 }}>
                      <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 4 }}>
                        <p style={{ fontSize: 16, fontWeight: 700, color: 'var(--soft)' }}>{l.full_name}</p>
                        {course && <span className="badge badge-blue">{course.course_code}</span>}
                      </div>
                      <p style={{ fontSize: 14, color: 'var(--muted)' }}>{l.email}</p>
                      <p className="mono" style={{ fontSize: 13, color: 'var(--muted)', marginTop: 4 }}>
                        {l.matric_number} · {l.created_at ? format(new Date(l.created_at), 'dd MMM yyyy') : ''}
                      </p>
                    </div>
                    <div style={{ display: 'flex', gap: 8 }}>
                      <button onClick={() => startEdit(l)} className="btn-secondary" style={{ padding: '8px 12px' }}><Pencil size={15} /></button>
                      <button onClick={() => handleDelete(l.id, l.full_name)} style={{ padding: '8px 12px', borderRadius: 10, border: '1.5px solid #FEE2E2', background: '#FEF2F2', color: '#DC2626', cursor: 'pointer' }}><Trash2 size={15} /></button>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
      }
    </Layout>
  );
}
