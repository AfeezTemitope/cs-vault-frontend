'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { getUser, requireAuth } from '@/lib/auth';
import Layout from '@/components/Layout';
import StatCard from '@/components/StatCard';
import PageHeader from '@/components/PageHeader';
import api from '@/lib/api';
import { BookOpen, ArrowRight } from 'lucide-react';

interface Course { id: string; title: string; course_code: string; session: string; lecturer_id?: string; }

export default function LecturerDashboard() {
  const router = useRouter();
  const [courses, setCourses] = useState<Course[]>([]);
  const [allCourses, setAllCourses] = useState<Course[]>([]);
  const user = getUser();

  useEffect(() => {
    if (!requireAuth(getUser(), router, ['lecturer', 'admin'])) return;
    // Get lecturer's assigned courses
    api.get('/lecturer/courses').then(r => setCourses(r.data)).catch(() => {});
    // Also get all courses for reference
    api.get('/admin/courses').then(r => setAllCourses(r.data)).catch(() => {});
  }, [router]);

  return (
    <Layout>
      <PageHeader
        title={`Hi, ${(user?.name ?? user?.full_name ?? '').split(' ')[0]} 👋`}
        subtitle="Your teaching overview" />

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: 16, marginBottom: 32 }}>
        <StatCard label="Assigned Courses" value={courses.length} icon={BookOpen} color="purple" />
      </div>

      {courses.length === 0 ? (
        <div className="card" style={{ padding: 28, textAlign: 'center' }}>
          <p style={{ color: 'var(--muted)', fontSize: 15, marginBottom: 8 }}>You haven't been assigned to any course yet.</p>
          <p style={{ color: 'var(--muted)', fontSize: 14 }}>Contact the admin to get assigned to CSC 497 or CSC 498.</p>
        </div>
      ) : (
        <div>
          <h2 style={{ fontSize: 14, fontWeight: 700, color: 'var(--muted)', textTransform: 'uppercase', letterSpacing: '0.5px', marginBottom: 14 }}>
            Your Courses
          </h2>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            {courses.map(c => (
              <button key={c.id} onClick={() => router.push(`/lecturer/courses/${c.id}`)}
                className="card" style={{
                  padding: '20px 24px', cursor: 'pointer', textAlign: 'left',
                  display: 'flex', alignItems: 'center', justifyContent: 'space-between',
                  border: '1.5px solid var(--border)', background: 'var(--card)',
                  transition: 'all 0.2s',
                }}
                onMouseEnter={e => { (e.currentTarget as HTMLButtonElement).style.borderColor = 'var(--accent)'; }}
                onMouseLeave={e => { (e.currentTarget as HTMLButtonElement).style.borderColor = 'var(--border)'; }}>
                <div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 4 }}>
                    <span style={{ fontSize: 16, fontWeight: 700, color: 'var(--soft)' }}>{c.title}</span>
                    <span className="badge badge-purple mono">{c.course_code}</span>
                  </div>
                  <span style={{ fontSize: 13, color: 'var(--muted)' }}>{c.session}</span>
                </div>
                <ArrowRight size={18} style={{ color: 'var(--muted)', flexShrink: 0 }} />
              </button>
            ))}
          </div>
        </div>
      )}
    </Layout>
  );
}
