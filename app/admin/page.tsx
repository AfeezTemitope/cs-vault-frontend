'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { getUser, requireAuth } from '@/lib/auth';
import Layout from '@/components/Layout';
import StatCard from '@/components/StatCard';
import PageHeader from '@/components/PageHeader';
import api from '@/lib/api';
import { Users, GraduationCap, BookOpen, TrendingUp } from 'lucide-react';

export default function AdminDashboard() {
  const router = useRouter();
  const [stats, setStats] = useState({ lecturers: 0, students: 0, courses: 0 });
  const user = getUser();

  useEffect(() => {
    if (!requireAuth(getUser(), router, ['admin'])) return;
    Promise.all([api.get('/admin/lecturers'), api.get('/admin/students'), api.get('/admin/courses')])
      .then(([l, s, c]) => setStats({ lecturers: l.data.length, students: s.data.length, courses: c.data.length }))
      .catch(() => {});
  }, [router]);

  return (
    <Layout>
      <PageHeader title={`Welcome back 👋`} subtitle="Here's what's happening on CS-Vault" />
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: 16, marginBottom: 32 }}>
        <StatCard label="Total Lecturers" value={stats.lecturers} icon={GraduationCap} color="purple" />
        <StatCard label="Total Students" value={stats.students} icon={Users} color="green" />
        <StatCard label="Active Courses" value={stats.courses} icon={BookOpen} color="orange" />
      </div>
      <div className="card" style={{ padding: '24px 28px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 8 }}>
          <TrendingUp size={20} style={{ color: 'var(--accent)' }} />
          <h2 style={{ fontSize: 17, fontWeight: 700, color: 'var(--soft)' }}>Quick Actions</h2>
        </div>
        <p style={{ color: 'var(--muted)', fontSize: 14, marginBottom: 20 }}>Manage your platform from the sidebar</p>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(180px, 1fr))', gap: 12 }}>
          {[
            { label: 'Add Lecturer', href: '/admin/lecturers' },
            { label: 'Create Course', href: '/admin/courses' },
            { label: 'Register Student', href: '/admin/students' },
          ].map(a => (
            <button key={a.href} onClick={() => router.push(a.href)} className="btn-secondary" style={{ justifyContent: 'center', width: '100%' }}>
              {a.label}
            </button>
          ))}
        </div>
      </div>
    </Layout>
  );
}
