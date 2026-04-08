'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { getUser } from '@/lib/auth';
import LandingPage from './landing/LandingPage';

export default function Root() {
  const router = useRouter();
  const [ready, setReady] = useState(false);

  useEffect(() => {
    // Init theme
    const saved = localStorage.getItem('cv-theme') ?? 'light';
    document.documentElement.setAttribute('data-theme', saved);
    const user = getUser();
    if (user) { router.push(`/${user.role}`); return; }
    setReady(true);
  }, [router]);

  if (!ready) return (
    <div style={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', backgroundColor: 'var(--ink)' }}>
      <div style={{ width: 40, height: 40, borderRadius: 10, background: 'var(--accent)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <span style={{ color: '#fff', fontWeight: 800, fontSize: 16 }}>CV</span>
      </div>
    </div>
  );

  return <LandingPage />;
}
