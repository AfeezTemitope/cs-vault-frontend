'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { getUser, requireAuth } from '@/lib/auth';
import Layout from '@/components/Layout';
import PageHeader from '@/components/PageHeader';
import EmptyState from '@/components/EmptyState';
import api from '@/lib/api';
import toast from 'react-hot-toast';
import { GraduationCap, Plus, X } from 'lucide-react';
import { format } from 'date-fns';

interface Lecturer { id: string; full_name: string; email: string; matric_number: string; department: string; created_at: string; }

export default function LecturersPage() {
  const router = useRouter();
  const [lecturers, setLecturers] = useState<Lecturer[]>([]);
  const [showForm, setShowForm] = useState(false);
  const [form, setForm] = useState({ full_name: '', email: '', matric_number: '', department: 'Computer Science' });
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (!requireAuth(getUser(), router, ['admin'])) return;
    fetch();
  }, [router]);

  const fetch = () => api.get('/admin/lecturers').then(r => setLecturers(r.data)).catch(() => {});

  const handleCreate = async (e: React.FormEvent) => {
    e.preventDefault(); setLoading(true);
    try {
      await api.post('/admin/lecturers', form);
      toast.success('Lecturer created — credentials sent!');
      setShowForm(false); setForm({ full_name: '', email: '', matric_number: '', department: 'Computer Science' });
      fetch();
    } catch (err: unknown) {
      toast.error((err as { response?: { data?: { error?: string } } })?.response?.data?.error ?? 'Failed');
    } finally { setLoading(false); }
  };

  const inp = "w-full rounded-lg px-4 py-2.5 text-sm focus:outline-none border transition-colors";
  const inpStyle = { backgroundColor: 'var(--surface)', borderColor: 'var(--border)', color: 'var(--soft)' };

  return (
    <Layout>
      <PageHeader title="Lecturers" subtitle={`${lecturers.length} registered`}
        action={
          <button onClick={() => setShowForm(!showForm)}
            className="flex items-center gap-2 px-4 py-2 rounded-lg text-sm font-semibold transition-all"
            style={{ backgroundColor: 'var(--accent)', color: 'var(--ink)' }}>
            <Plus size={15} />Add Lecturer
          </button>
        } />

      {showForm && (
        <div className="rounded-xl p-5 mb-5 border fade-up" style={{ backgroundColor: 'var(--card)', borderColor: 'var(--border)' }}>
          <div className="flex items-center justify-between mb-4">
            <h3 className="font-semibold" style={{ color: 'var(--soft)' }}>New Lecturer</h3>
            <button onClick={() => setShowForm(false)} style={{ color: 'var(--muted)' }}><X size={16} /></button>
          </div>
          <form onSubmit={handleCreate} className="space-y-3">
            {[['Full Name', 'full_name'], ['Email', 'email'], ['Staff ID', 'matric_number']].map(([label, key]) => (
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
              {loading ? 'Creating...' : 'Create & Send Credentials'}
            </button>
          </form>
        </div>
      )}

      {lecturers.length === 0
        ? <EmptyState icon={GraduationCap} title="No lecturers yet" subtitle="Add your first lecturer above" />
        : <div className="space-y-3">
            {lecturers.map((l, i) => (
              <div key={l.id} className={`rounded-xl p-4 border fade-up delay-${Math.min(i+1,4) as 1|2|3|4}`}
                style={{ backgroundColor: 'var(--card)', borderColor: 'var(--border)' }}>
                <div className="flex items-start justify-between">
                  <div>
                    <p className="font-semibold text-sm" style={{ color: 'var(--soft)' }}>{l.full_name}</p>
                    <p className="text-xs mt-0.5" style={{ color: 'var(--muted)' }}>{l.email}</p>
                  </div>
                  <span className="mono text-xs px-2 py-0.5 rounded" style={{ color: 'var(--accent)', backgroundColor: 'rgba(200,241,53,0.1)' }}>{l.matric_number}</span>
                </div>
                <p className="text-xs mt-2" style={{ color: 'var(--muted)' }}>
                  {l.department} · {l.created_at ? format(new Date(l.created_at), 'dd MMM yyyy') : ''}
                </p>
              </div>
            ))}
          </div>
      }
    </Layout>
  );
}
