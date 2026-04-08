'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { getUser, requireAuth } from '@/lib/auth';
import Layout from '@/components/Layout';
import StatCard from '@/components/StatCard';
import PageHeader from '@/components/PageHeader';
import api from '@/lib/api';
import { BookOpen } from 'lucide-react';

interface Course { id: string; title: string; course_code: string; session: string; }

export default function LecturerDashboard() {
  const router = useRouter();
  const [courses, setCourses] = useState<Course[]>([]);
  const user = getUser();

  useEffect(() => {
    if (!requireAuth(getUser(), router, ['lecturer', 'admin'])) return;
    api.get('/lecturer/courses').then(r => setCourses(r.data)).catch(() => {});
  }, [router]);

  return (
    <Layout>
      <PageHeader title={`Hi, ${(user?.name ?? user?.full_name ?? '').split(' ')[0]} 👋`} subtitle="Your teaching overview" />
      <div className="grid grid-cols-2 gap-3 mb-6">
        <StatCard label="My Courses" value={courses.length} icon={BookOpen} color="blue" />
      </div>
      <h2 className="text-xs font-semibold uppercase tracking-widest mb-3" style={{ color: 'var(--muted)' }}>Your Courses</h2>
      <div className="space-y-3">
        {courses.map(c => (
          <button key={c.id} onClick={() => router.push(`/lecturer/courses/${c.id}`)}
            className="w-full rounded-xl p-4 border text-left transition-all group"
            style={{ backgroundColor: 'var(--card)', borderColor: 'var(--border)' }}
            onMouseEnter={e => (e.currentTarget.style.borderColor = 'rgba(200,241,53,0.4)')}
            onMouseLeave={e => (e.currentTarget.style.borderColor = 'var(--border)')}>
            <div className="flex items-center justify-between">
              <p className="font-semibold text-sm" style={{ color: 'var(--soft)' }}>{c.title}</p>
              <span className="mono text-xs px-2 py-0.5 rounded" style={{ color: 'var(--accent)', backgroundColor: 'rgba(200,241,53,0.1)' }}>{c.course_code}</span>
            </div>
            <p className="text-xs mt-1" style={{ color: 'var(--muted)' }}>{c.session}</p>
          </button>
        ))}
      </div>
    </Layout>
  );
}
