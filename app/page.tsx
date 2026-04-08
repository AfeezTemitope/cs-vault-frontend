'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { getUser } from '@/lib/auth';
import LandingPage from '@/components/LandingPage';

export default function Root() {
  const router = useRouter();
  const [show, setShow] = useState(false);

  useEffect(() => {
    const user = getUser();
    if (user) { router.push(`/${user.role}`); return; }
    setShow(true);
  }, [router]);

  if (!show) return (
    <div style={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', background: 'var(--ink)' }}>
      <div style={{ width: 44, height: 44, borderRadius: 12, background: 'var(--accent)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <span style={{ color: '#fff', fontWeight: 800, fontSize: 16, fontFamily: 'JetBrains Mono' }}>CV</span>
      </div>
    </div>
  );

  return <LandingPage />;
}
