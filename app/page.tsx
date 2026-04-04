'use client';
import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { getUser } from '@/lib/auth';

export default function Root() {
  const router = useRouter();
  useEffect(() => {
    const user = getUser();
    if (!user) { router.push('/login'); return; }
    router.push(`/${user.role}`);
  }, [router]);
  return (
    <div className="min-h-screen flex items-center justify-center" style={{ backgroundColor: 'var(--ink)' }}>
      <span className="mono text-sm" style={{ color: 'var(--accent)' }}>cs-vault</span>
    </div>
  );
}
