'use client';
import { useState, useEffect, Suspense } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import toast from 'react-hot-toast';
import api from '@/lib/api';
import { getUser } from '@/lib/auth';
import Layout from '@/components/Layout';
import PageHeader from '@/components/PageHeader';
import { Lock } from 'lucide-react';

function ProfileInner() {
  const router = useRouter();
  const params = useSearchParams();
  const mustChange = params.get('must_change') === 'true';
  const user = getUser();
  const [form, setForm] = useState({ current_password: '', new_password: '', confirm: '' });
  const [loading, setLoading] = useState(false);

  useEffect(() => { if (!user) router.push('/login'); }, [user, router]);

  const inputStyle = {
    width: '100%', backgroundColor: 'var(--surface)', borderColor: 'var(--border)',
    color: 'var(--soft)', border: '1px solid var(--border)', borderRadius: 8,
    padding: '10px 16px', fontSize: 14, outline: 'none',
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (form.new_password !== form.confirm) return toast.error('Passwords do not match');
    if (form.new_password.length < 6) return toast.error('Min 6 characters');
    setLoading(true);
    try {
      await api.put('/auth/change-password', { current_password: form.current_password, new_password: form.new_password });
      toast.success('Password changed!');
      router.push(`/${user?.role}`);
    } catch (err: unknown) {
      const axiosMsg = (err as { response?: { data?: { error?: string } } })?.response?.data?.error;
      toast.error(axiosMsg ?? 'Failed');
    } finally { setLoading(false); }
  };

  return (
    <Layout>
      <PageHeader title="Profile" subtitle="Manage your account" />
      {mustChange && (
        <div className="rounded-xl p-4 mb-5 text-sm border" style={{ backgroundColor: 'rgba(200,241,53,0.08)', borderColor: 'rgba(200,241,53,0.3)', color: 'var(--accent)' }}>
          ⚠️ Please change your auto-generated password before continuing.
        </div>
      )}
      <div className="rounded-xl p-5 mb-5 border" style={{ backgroundColor: 'var(--card)', borderColor: 'var(--border)' }}>
        <p className="text-xs mb-1" style={{ color: 'var(--muted)' }}>Name</p>
        <p className="font-semibold" style={{ color: 'var(--soft)' }}>{user?.name ?? user?.full_name}</p>
        <p className="text-xs mt-3 mb-1" style={{ color: 'var(--muted)' }}>Matric Number</p>
        <p className="mono text-sm" style={{ color: 'var(--soft)' }}>{user?.matric_number}</p>
        <p className="text-xs mt-3 mb-1" style={{ color: 'var(--muted)' }}>Role</p>
        <span className="mono text-xs px-2 py-0.5 rounded uppercase" style={{ backgroundColor: 'var(--border)', color: 'var(--accent)' }}>{user?.role}</span>
      </div>
      <div className="rounded-xl p-5 border" style={{ backgroundColor: 'var(--card)', borderColor: 'var(--border)' }}>
        <div className="flex items-center gap-2 mb-4">
          <Lock size={16} style={{ color: 'var(--accent)' }} />
          <h2 className="font-semibold" style={{ color: 'var(--soft)' }}>Change Password</h2>
        </div>
        <form onSubmit={handleSubmit} className="space-y-4">
          {(['current_password', 'new_password', 'confirm'] as const).map(f => (
            <div key={f}>
              <label className="text-xs block mb-1.5 capitalize" style={{ color: 'var(--muted)' }}>{f.replace(/_/g, ' ')}</label>
              <input type="password" required style={inputStyle}
                value={form[f]} onChange={e => setForm({ ...form, [f]: e.target.value })}
                onFocus={e => (e.target.style.borderColor = 'var(--accent)')}
                onBlur={e => (e.target.style.borderColor = 'var(--border)')} />
            </div>
          ))}
          <button type="submit" disabled={loading}
            className="w-full font-semibold py-3 rounded-lg text-sm transition-all disabled:opacity-50"
            style={{ backgroundColor: 'var(--accent)', color: 'var(--ink)' }}>
            {loading ? 'Saving...' : 'Update Password'}
          </button>
        </form>
      </div>
    </Layout>
  );
}

export default function ProfilePage() {
  return <Suspense><ProfileInner /></Suspense>;
}
