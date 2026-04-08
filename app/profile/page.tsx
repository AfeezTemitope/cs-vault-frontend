'use client';
import { useState, useEffect, Suspense } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import toast from 'react-hot-toast';
import api from '@/lib/api';
import { getUser } from '@/lib/auth';
import Layout from '@/components/Layout';
import PageHeader from '@/components/PageHeader';
import { Lock, AlertTriangle } from 'lucide-react';

function ProfileInner() {
  const router = useRouter();
  const params = useSearchParams();
  const mustChange = params.get('must_change') === 'true';
  const user = getUser();
  const [form, setForm] = useState({ current_password: '', new_password: '', confirm: '' });
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (!user) router.push('/login');
  }, [user, router]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (form.new_password !== form.confirm)
      return toast.error('Passwords do not match');
    if (form.new_password.length < 6)
      return toast.error('Password must be at least 6 characters');
    setLoading(true);
    try {
      await api.put('/auth/change-password', {
        current_password: form.current_password,
        new_password: form.new_password,
      });
      toast.success('Password changed successfully!');
      router.push(`/${user?.role}`);
    } catch (err: unknown) {
      const msg = (err as { response?: { data?: { error?: string } } })?.response?.data?.error;
      toast.error(msg ?? 'Failed to change password');
    } finally { setLoading(false); }
  };

  return (
    <Layout>
      <PageHeader title="Profile" subtitle="Manage your account settings" />

      {/* Must change warning */}
      {mustChange && (
        <div style={{
          display: 'flex', alignItems: 'flex-start', gap: 12,
          padding: '14px 18px', borderRadius: 12, marginBottom: 24,
          background: '#FFFBEB', border: '1.5px solid #FDE68A',
        }}>
          <AlertTriangle size={18} style={{ color: '#D97706', flexShrink: 0, marginTop: 1 }} />
          <p style={{ fontSize: 14, color: '#92400E', fontWeight: 500 }}>
            Please change your auto-generated password before continuing.
          </p>
        </div>
      )}

      {/* Account info */}
      <div className="card" style={{ padding: '22px 24px', marginBottom: 20 }}>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(160px, 1fr))', gap: 20 }}>
          <div>
            <p style={{ fontSize: 12, fontWeight: 600, color: 'var(--muted)', textTransform: 'uppercase', letterSpacing: '0.5px', marginBottom: 6 }}>Name</p>
            <p style={{ fontSize: 16, fontWeight: 700, color: 'var(--soft)' }}>{user?.name ?? user?.full_name}</p>
          </div>
          <div>
            <p style={{ fontSize: 12, fontWeight: 600, color: 'var(--muted)', textTransform: 'uppercase', letterSpacing: '0.5px', marginBottom: 6 }}>Matric Number</p>
            <p className="mono" style={{ fontSize: 15, color: 'var(--soft)' }}>{user?.matric_number}</p>
          </div>
          <div>
            <p style={{ fontSize: 12, fontWeight: 600, color: 'var(--muted)', textTransform: 'uppercase', letterSpacing: '0.5px', marginBottom: 6 }}>Role</p>
            <span className="badge badge-purple" style={{ textTransform: 'uppercase', fontSize: 11 }}>{user?.role}</span>
          </div>
        </div>
      </div>

      {/* Change password */}
      <div className="card" style={{ padding: '24px 24px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 24 }}>
          <div style={{ width: 36, height: 36, borderRadius: 10, background: 'var(--accent-light)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <Lock size={18} style={{ color: 'var(--accent)' }} />
          </div>
          <h2 style={{ fontSize: 17, fontWeight: 700, color: 'var(--soft)' }}>Change Password</h2>
        </div>

        <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: 18 }}>
          <div className="field">
            <label className="label">Current Password</label>
            <input
              type="password"
              className="input"
              placeholder="Enter your current password"
              value={form.current_password}
              onChange={e => setForm({ ...form, current_password: e.target.value })}
              required
            />
          </div>

          <div className="field">
            <label className="label">New Password</label>
            <input
              type="password"
              className="input"
              placeholder="At least 6 characters"
              value={form.new_password}
              onChange={e => setForm({ ...form, new_password: e.target.value })}
              required
            />
          </div>

          <div className="field">
            <label className="label">Confirm New Password</label>
            <input
              type="password"
              className="input"
              placeholder="Repeat your new password"
              value={form.confirm}
              onChange={e => setForm({ ...form, confirm: e.target.value })}
              required
            />
          </div>

          <button type="submit" className="btn btn-primary btn-full" disabled={loading}
            style={{ marginTop: 4, padding: '13px 24px', fontSize: 15 }}>
            {loading ? 'Updating...' : 'Update Password'}
          </button>
        </form>
      </div>
    </Layout>
  );
}

export default function ProfilePage() {
  return (
    <Suspense fallback={<div style={{ minHeight: '100vh', background: 'var(--ink)' }} />}>
      <ProfileInner />
    </Suspense>
  );
}