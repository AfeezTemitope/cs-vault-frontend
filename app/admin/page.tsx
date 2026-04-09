'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { getUser, requireAuth } from '@/lib/auth';
import Layout from '@/components/Layout';
import StatCard from '@/components/StatCard';
import PageHeader from '@/components/PageHeader';
import api from '@/lib/api';
import { Users, GraduationCap, BookOpen, FolderOpen, CheckCircle, Clock, Download } from 'lucide-react';
import { format } from 'date-fns';

interface Project { id: string; title: string; status?: string; created_at?: string; users?: { full_name: string }; courses?: { course_code: string }; }

export default function AdminDashboard() {
  const router = useRouter();
  const [stats, setStats] = useState({ lecturers: 0, students: 0, courses: 0, total: 0, approved: 0, pending: 0, downloads: 0 });
  const [recent, setRecent] = useState<Project[]>([]);

  useEffect(() => {
    if (!requireAuth(getUser(), router, ['admin'])) return;
    Promise.all([
      api.get('/admin/lecturers'),
      api.get('/admin/students'),
      api.get('/admin/courses'),
      api.get('/lecturer/projects'),
    ]).then(([l, s, c, p]) => {
      const projects: Project[] = p.data;
      setStats({
        lecturers: l.data.length,
        students: s.data.length,
        courses: c.data.length,
        total: projects.length,
        approved: projects.filter((x: Project) => x.status === 'approved').length,
        pending: projects.filter((x: Project) => x.status === 'pending').length,
        downloads: 0,
      });
      setRecent(projects.slice(0, 5));
    }).catch(() => {});
  }, [router]);

  return (
    <Layout>
      <PageHeader title="Dashboard" subtitle="CS-Vault overview" />

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(160px, 1fr))', gap: 14, marginBottom: 28 }}>
        <StatCard label="Lecturers" value={stats.lecturers} icon={GraduationCap} color="purple" />
        <StatCard label="Students" value={stats.students} icon={Users} color="green" />
        <StatCard label="Courses" value={stats.courses} icon={BookOpen} color="orange" />
        <StatCard label="Total Projects" value={stats.total} icon={FolderOpen} color="purple" />
        <StatCard label="Approved" value={stats.approved} icon={CheckCircle} color="green" />
        <StatCard label="Pending" value={stats.pending} icon={Clock} color="orange" />
        <StatCard label="Downloads" value={stats.downloads} icon={Download} color="purple" />
      </div>

      {recent.length > 0 && (
        <div className="card" style={{ padding: '22px 24px' }}>
          <h2 style={{ fontSize: 16, fontWeight: 700, color: 'var(--soft)', marginBottom: 16 }}>Recent Submissions</h2>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
            {recent.map(p => (
              <div key={p.id} style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 12, padding: '10px 0', borderBottom: '1px solid var(--border)' }}>
                <div>
                  <p style={{ fontSize: 14, fontWeight: 600, color: 'var(--soft)' }}>{p.title}</p>
                  <p style={{ fontSize: 12, color: 'var(--muted)', marginTop: 2 }}>{p.users?.full_name} · {p.courses?.course_code}</p>
                </div>
                <div style={{ display: 'flex', alignItems: 'center', gap: 8, flexShrink: 0 }}>
                  <span className={`badge ${p.status === 'approved' ? 'badge-approved' : p.status === 'rejected' ? 'badge-rejected' : 'badge-pending'}`} style={{ textTransform: 'capitalize' }}>
                    {p.status ?? 'pending'}
                  </span>
                  {p.created_at && <span style={{ fontSize: 12, color: 'var(--muted)' }}>{format(new Date(p.created_at), 'dd MMM')}</span>}
                </div>
              </div>
            ))}
          </div>
        </div>
      )}
    </Layout>
  );
}
