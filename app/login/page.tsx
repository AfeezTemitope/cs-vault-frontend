'use client';
import { useState } from 'react';
import { useRouter } from 'next/navigation';
import toast from 'react-hot-toast';
import api from '@/lib/api';
import { setAuth } from '@/lib/auth';
import { Eye, EyeOff, Lock, User } from 'lucide-react';

export default function LoginPage() {
  const router = useRouter();
  const [form, setForm] = useState({ matric_number: '', password: '' });
  const [show, setShow] = useState(false);
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      const { data } = await api.post('/auth/login', form);
      setAuth(data.token, data.user);
      toast.success(`Welcome, ${data.user.full_name.split(' ')[0]}!`);
      router.push(data.user.must_change_password ? '/profile?must_change=true' : `/${data.user.role}`);
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : 'Login failed';
      const axiosMsg = (err as { response?: { data?: { error?: string } } })?.response?.data?.error;
      toast.error(axiosMsg ?? msg);
    } finally { setLoading(false); }
  };

  return (
    <div className="min-h-screen flex flex-col items-center justify-center px-4 relative overflow-hidden"
      style={{ backgroundColor: 'var(--ink)' }}>
      {/* Grid bg */}
      <div className="absolute inset-0 opacity-[0.025]"
        style={{ backgroundImage: 'linear-gradient(#C8F135 1px,transparent 1px),linear-gradient(90deg,#C8F135 1px,transparent 1px)', backgroundSize: '40px 40px' }} />

      <div className="w-full max-w-sm relative z-10">
        <div className="text-center mb-10 fade-up">
          <div className="inline-flex items-center justify-center w-12 h-12 rounded-xl mb-4"
            style={{ backgroundColor: 'var(--accent)' }}>
            <span className="mono font-bold text-lg" style={{ color: 'var(--ink)' }}>CV</span>
          </div>
          <h1 className="text-2xl font-bold" style={{ color: 'var(--soft)' }}>CS-Vault</h1>
          <p className="text-sm mt-1" style={{ color: 'var(--muted)' }}>School Project Repository</p>
        </div>

        <div className="rounded-2xl p-6 border fade-up delay-2"
          style={{ backgroundColor: 'var(--card)', borderColor: 'var(--border)' }}>
          <h2 className="text-lg font-semibold mb-1" style={{ color: 'var(--soft)' }}>Sign in</h2>
          <p className="text-xs mb-6" style={{ color: 'var(--muted)' }}>Use your matric number and password</p>

          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="text-xs block mb-1.5" style={{ color: 'var(--muted)' }}>Matric Number</label>
              <div className="relative">
                <User size={15} className="absolute left-3 top-1/2 -translate-y-1/2" style={{ color: 'var(--muted)' }} />
                <input
                  className="w-full rounded-lg pl-9 pr-4 py-3 text-sm mono focus:outline-none transition-colors border"
                  style={{ backgroundColor: 'var(--surface)', borderColor: 'var(--border)', color: 'var(--soft)' }}
                  placeholder="e.g. CSC/2021/001"
                  value={form.matric_number}
                  onChange={e => setForm({ ...form, matric_number: e.target.value })}
                  onFocus={e => (e.target.style.borderColor = 'var(--accent)')}
                  onBlur={e => (e.target.style.borderColor = 'var(--border)')}
                  required />
              </div>
            </div>

            <div>
              <label className="text-xs block mb-1.5" style={{ color: 'var(--muted)' }}>Password</label>
              <div className="relative">
                <Lock size={15} className="absolute left-3 top-1/2 -translate-y-1/2" style={{ color: 'var(--muted)' }} />
                <input
                  type={show ? 'text' : 'password'}
                  className="w-full rounded-lg pl-9 pr-10 py-3 text-sm focus:outline-none transition-colors border"
                  style={{ backgroundColor: 'var(--surface)', borderColor: 'var(--border)', color: 'var(--soft)' }}
                  placeholder="Your password"
                  value={form.password}
                  onChange={e => setForm({ ...form, password: e.target.value })}
                  onFocus={e => (e.target.style.borderColor = 'var(--accent)')}
                  onBlur={e => (e.target.style.borderColor = 'var(--border)')}
                  required />
                <button type="button" onClick={() => setShow(!show)}
                  className="absolute right-3 top-1/2 -translate-y-1/2 transition-colors"
                  style={{ color: 'var(--muted)' }}>
                  {show ? <EyeOff size={15} /> : <Eye size={15} />}
                </button>
              </div>
            </div>

            <button type="submit" disabled={loading}
              className="w-full font-semibold py-3 rounded-lg text-sm transition-all mt-2 disabled:opacity-50"
              style={{ backgroundColor: 'var(--accent)', color: 'var(--ink)' }}>
              {loading ? 'Signing in...' : 'Sign in'}
            </button>
          </form>
        </div>
        <p className="text-center text-xs mt-6" style={{ color: 'var(--muted)' }}>
          Forgot your password? Contact your lecturer.
        </p>
      </div>
    </div>
  );
}
