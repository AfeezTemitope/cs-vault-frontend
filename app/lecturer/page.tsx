'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { getUser, requireAuth } from '@/lib/auth';
import Layout from '@/components/Layout';
import StatCard from '@/components/StatCard';
import PageHeader from '@/components/PageHeader';
import api from '@/lib/api';
import { BookOpen, FolderOpen, CheckCircle, Clock, ArrowRight } from 'lucide-react';

interface Course { id: string; title: string; course_code: string; session: string; }
interface Project { id: string; status?: string; }

export default function LecturerDashboard() {
  const router = useRouter();
  const [courses, setCourses] = useState<Course[]>([]);
  const [projects, setProjects] = useState<Project[]>([]);
  const user = getUser();

  useEffect(() => {
    if (!requireAuth(getUser(), router, ['lecturer', 'admin'])) return;
    Promise.all([api.get('/lecturer/courses'), api.get('/lecturer/projects')])
      .then(([c, p]) => { setCourses(c.data); setProjects(p.data); }).catch(() => {});
  }, [router]);

  const pending = projects.filter(p => p.status === 'pending').length;
  const approved = projects.filter(p => p.status === 'approved').length;

  return (
    <Layout>
      <PageHeader title={`Hi, ${(user?.name ?? user?.full_name ?? '').split(' ')[0]} 👋`} subtitle="Your teaching overview" />

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(160px, 1fr))', gap: 14, marginBottom: 28 }}>
        <StatCard label="My Courses" value={courses.length} icon={BookOpen} color="purple" />
        <StatCard label="Total Projects" value={projects.length} icon={FolderOpen} color="purple" />
        <StatCard label="Pending Review" value={pending} icon={Clock} color="orange" />
        <StatCard label="Approved" value={approved} icon={CheckCircle} color="green" />
      </div>

      {pending > 0 && (
        <div style={{ padding: '14px 18px', borderRadius: 12, marginBottom: 24, background: '#FFF7ED', border: '1.5px solid #FDE68A', display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 12 }}>
          <p style={{ fontSize: 14, color: '#92400E', fontWeight: 600 }}>
            ⏳ {pending} project{pending > 1 ? 's' : ''} waiting for your review
          </p>
          <button onClick={() => router.push('/lecturer/projects')}
            style={{ background: '#D97706', color: '#fff', border: 'none', borderRadius: 8, padding: '8px 14px', fontSize: 13, fontWeight: 600, cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 6, fontFamily: 'Plus Jakarta Sans' }}>
            Review Now <ArrowRight size={13} />
          </button>
        </div>
      )}

      {courses.length === 0 ? (
        <div className="card" style={{ padding: 28, textAlign: 'center' }}>
          <p style={{ color: 'var(--muted)', fontSize: 15, marginBottom: 6 }}>You haven't been assigned to any course yet.</p>
          <p style={{ color: 'var(--muted)', fontSize: 14 }}>Contact admin to get assigned to CSC 497 or CSC 498.</p>
        </div>
      ) : (
        <div>
          <h2 style={{ fontSize: 13, fontWeight: 700, color: 'var(--muted)', textTransform: 'uppercase', letterSpacing: '0.5px', marginBottom: 14 }}>Your Courses</h2>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            {courses.map(c => (
              <button key={c.id} onClick={() => router.push(`/lecturer/courses/${c.id}`)}
                className="card" style={{ padding: '20px 24px', cursor: 'pointer', textAlign: 'left', display: 'flex', alignItems: 'center', justifyContent: 'space-between', background: 'var(--card)', border: '1.5px solid var(--border)', transition: 'all 0.2s' }}
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
