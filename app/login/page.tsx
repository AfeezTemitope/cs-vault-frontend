'use client';
import { useState, useEffect } from 'react';
import toast from 'react-hot-toast';
import api from '@/lib/api';
import { setAuth } from '@/lib/auth';
import { Eye, EyeOff, Lock, CreditCard, ArrowLeft, ArrowRight } from 'lucide-react';
import ThemeToggle from '@/components/ThemeToggle';
import Link from 'next/link';

type View = 'login' | 'forgot';

export default function LoginPage() {
  const [view, setView] = useState<View>('login');
  const [form, setForm] = useState({ matric_number: '', password: '' });
  const [forgotMatric, setForgotMatric] = useState('');
  const [show, setShow] = useState(false);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    const saved = localStorage.getItem('cv-theme') ?? 'light';
    document.documentElement.setAttribute('data-theme', saved);
  }, []);

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault(); setLoading(true);
    try {
      const { data } = await api.post('/auth/login', form);
      setAuth(data.token, data.user);
      toast.success(`Welcome back, ${data.user.full_name.split(' ')[0]}!`);
      window.location.href = data.user.must_change_password ? '/profile?must_change=true' : `/${data.user.role}`;
    } catch (err: unknown) {
      toast.error((err as { response?: { data?: { error?: string } } })?.response?.data?.error ?? 'Login failed');
      setLoading(false);
    }
  };

  const handleForgot = async (e: React.FormEvent) => {
    e.preventDefault(); setLoading(true);
    try {
      await api.post('/auth/forgot-password', { matric_number: forgotMatric });
      toast.success('New password sent to your registered email!');
      setView('login'); setForgotMatric('');
    } catch (err: unknown) {
      toast.error((err as { response?: { data?: { error?: string } } })?.response?.data?.error ?? 'Something went wrong');
    } finally { setLoading(false); }
  };

  return (
    <div style={{ minHeight: '100vh', backgroundColor: 'var(--ink)', display: 'flex', flexDirection: 'column' }}>
      {/* Top bar */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '16px 24px', borderBottom: '1.5px solid var(--border)', backgroundColor: 'var(--card)' }}>
        <Link href="/" style={{ display: 'flex', alignItems: 'center', gap: 8, textDecoration: 'none' }}>
          <div style={{ width: 32, height: 32, borderRadius: 8, background: 'var(--accent)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <span style={{ color: '#fff', fontWeight: 800, fontSize: 13 }}>CV</span>
          </div>
          <span style={{ fontWeight: 700, fontSize: 16, color: 'var(--soft)' }}>CS-Vault</span>
        </Link>
        <ThemeToggle />
      </div>

      {/* Form area */}
      <div style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', padding: '40px 20px' }}>
        <div style={{ width: '100%', maxWidth: 420 }}>

          {view === 'login' && (
            <div className="fade-up">
              <div style={{ textAlign: 'center', marginBottom: 32 }}>
                <h1 style={{ fontSize: 28, fontWeight: 800, color: 'var(--soft)', letterSpacing: '-0.5px', marginBottom: 8 }}>Welcome back</h1>
                <p style={{ color: 'var(--muted)', fontSize: 15 }}>Sign in to your CS-Vault account</p>
              </div>
              <div className="card" style={{ padding: 28 }}>
                <form onSubmit={handleLogin} style={{ display: 'flex', flexDirection: 'column', gap: 20 }}>
                  <div>
                    <label style={{ display: 'block', fontSize: 14, fontWeight: 600, color: 'var(--soft)', marginBottom: 8 }}>
                      Matric No. | Staff ID
                    </label>
                    <div style={{ position: 'relative' }}>
                      <CreditCard size={16} style={{ position: 'absolute', left: 14, top: '50%', transform: 'translateY(-50%)', color: 'var(--muted)' }} />
                      <input className="input-field mono" style={{ paddingLeft: 42 }}
                        placeholder="e.g. CSC/2021/001 or STAFF001"
                        value={form.matric_number}
                        onChange={e => setForm({ ...form, matric_number: e.target.value })}
                        required />
                    </div>
                  </div>
                  <div>
                    <label style={{ display: 'block', fontSize: 14, fontWeight: 600, color: 'var(--soft)', marginBottom: 8 }}>Password</label>
                    <div style={{ position: 'relative' }}>
                      <Lock size={16} style={{ position: 'absolute', left: 14, top: '50%', transform: 'translateY(-50%)', color: 'var(--muted)' }} />
                      <input className="input-field" type={show ? 'text' : 'password'} style={{ paddingLeft: 42, paddingRight: 42 }}
                        placeholder="Your password"
                        value={form.password}
                        onChange={e => setForm({ ...form, password: e.target.value })}
                        required />
                      <button type="button" onClick={() => setShow(!show)}
                        style={{ position: 'absolute', right: 14, top: '50%', transform: 'translateY(-50%)', background: 'none', border: 'none', cursor: 'pointer', color: 'var(--muted)' }}>
                        {show ? <EyeOff size={16} /> : <Eye size={16} />}
                      </button>
                    </div>
                  </div>
                  <button type="submit" className="btn-primary" disabled={loading} style={{ width: '100%', justifyContent: 'center', padding: '13px 24px', fontSize: 15 }}>
                    {loading ? 'Signing in...' : <><span>Sign in</span><ArrowRight size={16} /></>}
                  </button>
                </form>
                <button onClick={() => setView('forgot')}
                  style={{ width: '100%', textAlign: 'center', marginTop: 16, background: 'none', border: 'none', cursor: 'pointer', color: 'var(--muted)', fontSize: 14, textDecoration: 'underline' }}>
                  Forgot your password?
                </button>
              </div>
            </div>
          )}

          {view === 'forgot' && (
            <div className="fade-up">
              <button onClick={() => setView('login')}
                style={{ display: 'flex', alignItems: 'center', gap: 6, background: 'none', border: 'none', cursor: 'pointer', color: 'var(--muted)', fontSize: 14, marginBottom: 24 }}>
                <ArrowLeft size={15} /> Back to login
              </button>
              <div style={{ textAlign: 'center', marginBottom: 32 }}>
                <h1 style={{ fontSize: 28, fontWeight: 800, color: 'var(--soft)', letterSpacing: '-0.5px', marginBottom: 8 }}>Reset Password</h1>
                <p style={{ color: 'var(--muted)', fontSize: 15 }}>Enter your ID and we'll send a new password to your email</p>
              </div>
              <div className="card" style={{ padding: 28 }}>
                <form onSubmit={handleForgot} style={{ display: 'flex', flexDirection: 'column', gap: 20 }}>
                  <div>
                    <label style={{ display: 'block', fontSize: 14, fontWeight: 600, color: 'var(--soft)', marginBottom: 8 }}>Matric No. | Staff ID</label>
                    <div style={{ position: 'relative' }}>
                      <CreditCard size={16} style={{ position: 'absolute', left: 14, top: '50%', transform: 'translateY(-50%)', color: 'var(--muted)' }} />
                      <input className="input-field mono" style={{ paddingLeft: 42 }}
                        placeholder="e.g. CSC/2021/001 or STAFF001"
                        value={forgotMatric} onChange={e => setForgotMatric(e.target.value)} required />
                    </div>
                  </div>
                  <button type="submit" className="btn-primary" disabled={loading} style={{ width: '100%', justifyContent: 'center', padding: '13px 24px', fontSize: 15 }}>
                    {loading ? 'Sending...' : 'Send New Password'}
                  </button>
                </form>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
