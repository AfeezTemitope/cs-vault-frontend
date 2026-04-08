'use client';
import { useEffect, useState, useRef } from 'react';
import { useRouter } from 'next/navigation';
import { getUser, requireAuth } from '@/lib/auth';
import Layout from '@/components/Layout';
import PageHeader from '@/components/PageHeader';
import EmptyState from '@/components/EmptyState';
import api from '@/lib/api';
import toast from 'react-hot-toast';
import { BookOpen, Plus, X, Trash2, ChevronDown, Check } from 'lucide-react';

interface Course { id: string; title: string; course_code: string; session: string; lecturer_id?: string; }
interface Lecturer { id: string; full_name: string; }

function CustomSelect({
  value, onChange, options, placeholder
}: {
  value: string;
  onChange: (val: string) => void;
  options: { value: string; label: string }[];
  placeholder: string;
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
      <button type="button" onClick={() => setOpen(!open)}
        style={{
          width: '100%', display: 'flex', alignItems: 'center', justifyContent: 'space-between',
          gap: 8, padding: '10px 14px', borderRadius: 10, cursor: 'pointer',
          border: `1.5px solid ${open ? 'var(--accent)' : 'var(--border)'}`,
          background: 'var(--surface)', color: selected ? 'var(--soft)' : 'var(--muted)',
          fontSize: 14, fontFamily: 'Plus Jakarta Sans, sans-serif', fontWeight: 500,
          boxShadow: open ? '0 0 0 3px var(--accent-glow)' : 'none',
          transition: 'all 0.15s',
        }}>
        <span>{selected ? selected.label : placeholder}</span>
        <ChevronDown size={15} style={{ flexShrink: 0, transform: open ? 'rotate(180deg)' : 'none', transition: 'transform 0.2s', color: 'var(--muted)' }} />
      </button>

      {open && (
        <div style={{
          position: 'absolute', top: 'calc(100% + 6px)', left: 0, right: 0, zIndex: 200,
          background: 'var(--card)', border: '1.5px solid var(--border)',
          borderRadius: 12, boxShadow: 'var(--shadow-md)', overflow: 'hidden',
          maxHeight: 240, overflowY: 'auto',
        }}>
          {options.map(o => (
            <button type="button" key={o.value}
              onClick={() => { onChange(o.value); setOpen(false); }}
              style={{
                width: '100%', display: 'flex', alignItems: 'center', justifyContent: 'space-between',
                gap: 8, padding: '12px 16px', cursor: 'pointer', border: 'none',
                background: value === o.value ? 'var(--accent-light)' : 'transparent',
                color: value === o.value ? 'var(--accent)' : 'var(--soft)',
                fontSize: 14, fontFamily: 'Plus Jakarta Sans, sans-serif', fontWeight: value === o.value ? 600 : 400,
                textAlign: 'left', transition: 'background 0.1s',
              }}
              onMouseEnter={e => { if (value !== o.value) (e.currentTarget as HTMLButtonElement).style.background = 'var(--surface)'; }}
              onMouseLeave={e => { if (value !== o.value) (e.currentTarget as HTMLButtonElement).style.background = 'transparent'; }}>
              <span>{o.label}</span>
              {value === o.value && <Check size={15} style={{ flexShrink: 0 }} />}
            </button>
          ))}
        </div>
      )}
    </div>
  );
}

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
    try {
      await api.post('/admin/courses', form);
      toast.success('Course created');
      setShowForm(false);
      setForm({ title: '', course_code: '', description: '', session: '2024/2025' });
      loadData();
    } catch (err: unknown) {
      toast.error((err as { response?: { data?: { error?: string } } })?.response?.data?.error ?? 'Failed');
    } finally { setLoading(false); }
  };

  const assign = async (course_id: string, lecturer_id: string) => {
    try {
      await api.put('/admin/courses/assign', { course_id, lecturer_id: lecturer_id || null });
      toast.success(lecturer_id ? 'Lecturer assigned!' : 'Lecturer removed');
      loadData();
    } catch { toast.error('Failed to assign'); }
  };

  const handleDelete = async (id: string, title: string) => {
    if (!confirm(`Delete "${title}"? This cannot be undone.`)) return;
    try { await api.delete(`/admin/courses/${id}`); toast.success('Course deleted'); loadData(); }
    catch { toast.error('Failed to delete'); }
  };

  const lecturerOptions = [
    { value: '', label: '— Unassigned —' },
    ...lecturers.map(l => ({ value: l.id, label: l.full_name })),
  ];

  return (
    <Layout>
      <PageHeader title="Courses" subtitle={`${courses.length} active courses`}
        action={
          <button className="btn btn-primary" onClick={() => setShowForm(!showForm)}>
            <Plus size={16} /> Add Course
          </button>
        } />

      {showForm && (
        <div className="card fade-up" style={{ padding: 24, marginBottom: 24 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 20 }}>
            <h3 style={{ fontSize: 17, fontWeight: 700, color: 'var(--soft)' }}>New Course</h3>
            <button onClick={() => setShowForm(false)}
              style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--muted)' }}>
              <X size={20} />
            </button>
          </div>
          <form onSubmit={handleCreate} style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: 16 }}>
            <div className="field">
              <label className="label">Course Title</label>
              <input className="input" required value={form.title}
                onChange={e => setForm({ ...form, title: e.target.value })} />
            </div>
            <div className="field">
              <label className="label">Course Code</label>
              <input className="input mono" required placeholder="e.g. CSC 497" value={form.course_code}
                onChange={e => setForm({ ...form, course_code: e.target.value })} />
            </div>
            <div className="field">
              <label className="label">Session</label>
              <input className="input" required value={form.session}
                onChange={e => setForm({ ...form, session: e.target.value })} />
            </div>
            <div style={{ gridColumn: '1 / -1' }}>
              <button type="submit" className="btn btn-primary" disabled={loading}>
                {loading ? 'Creating...' : 'Create Course'}
              </button>
            </div>
          </form>
        </div>
      )}

      {courses.length === 0
        ? <EmptyState icon={BookOpen} title="No courses yet" subtitle="Add CSC 497 and CSC 498 using the button above" />
        : <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
            {courses.map(c => {
              const assigned = lecturers.find(l => l.id === c.lecturer_id);
              return (
                <div key={c.id} className="card" style={{ padding: '22px 24px' }}>
                  <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: 16, marginBottom: 16 }}>
                    <div>
                      <div style={{ display: 'flex', alignItems: 'center', gap: 10, flexWrap: 'wrap' }}>
                        <h3 style={{ fontSize: 17, fontWeight: 700, color: 'var(--soft)' }}>{c.title}</h3>
                        <span className="badge badge-purple mono">{c.course_code}</span>
                        <span style={{ fontSize: 13, color: 'var(--muted)' }}>{c.session}</span>
                      </div>
                      {assigned && (
                        <p style={{ fontSize: 13, color: 'var(--accent)', marginTop: 6, fontWeight: 600, display: 'flex', alignItems: 'center', gap: 5 }}>
                          <Check size={13} /> {assigned.full_name}
                        </p>
                      )}
                    </div>
                    <button onClick={() => handleDelete(c.id, c.title)} className="btn btn-danger btn-sm">
                      <Trash2 size={15} />
                    </button>
                  </div>

                  <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
                    <label style={{ fontSize: 14, color: 'var(--muted)', fontWeight: 500, whiteSpace: 'nowrap' }}>
                      Assign lecturer:
                    </label>
                    <div style={{ flex: 1, maxWidth: 300 }}>
                      <CustomSelect
                        value={c.lecturer_id ?? ''}
                        onChange={val => assign(c.id, val)}
                        options={lecturerOptions}
                        placeholder="— Unassigned —"
                      />
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