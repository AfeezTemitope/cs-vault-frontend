'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { getUser, requireAuth } from '@/lib/auth';
import Layout from '@/components/Layout';
import StatCard from '@/components/StatCard';
import PageHeader from '@/components/PageHeader';
import api from '@/lib/api';
import { Users, GraduationCap, BookOpen } from 'lucide-react';

export default function AdminDashboard() {
  const router = useRouter();
  const [stats, setStats] = useState({ lecturers: 0, students: 0, courses: 0 });
  useEffect(() => {
    const user = getUser();
    if (!requireAuth(user, router, ['admin'])) return;
    Promise.all([api.get('/admin/lecturers'), api.get('/admin/students'), api.get('/admin/courses')])
      .then(([l, s, c]) => setStats({ lecturers: l.data.length, students: s.data.length, courses: c.data.length }))
      .catch(() => {});
  }, [router]);
  return (
    <Layout>
      <PageHeader title="Admin Dashboard" subtitle="CS-Vault overview" />
      <div className="grid grid-cols-2 gap-3 md:grid-cols-3 fade-up">
        <StatCard label="Lecturers" value={stats.lecturers} icon={GraduationCap} accent />
        <StatCard label="Students" value={stats.students} icon={Users} />
        <StatCard label="Courses" value={stats.courses} icon={BookOpen} />
      </div>
    </Layout>
  );
}
