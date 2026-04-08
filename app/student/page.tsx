'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { getUser, requireAuth } from '@/lib/auth';
import Layout from '@/components/Layout';
import PageHeader from '@/components/PageHeader';
import ProjectCard from '@/components/ProjectCard';
import api from '@/lib/api';
import { Upload, FolderOpen } from 'lucide-react';

export default function StudentDashboard() {
  const router = useRouter();
  const [projects, setProjects] = useState<unknown[]>([]);
  const user = getUser();

  useEffect(() => {
    if (!requireAuth(getUser(), router, ['student'])) return;
    api.get('/projects').then(r => setProjects(r.data.slice(0, 5))).catch(() => {});
  }, [router]);

  return (
    <Layout>
      <PageHeader
        title={`Hi, ${(user?.name ?? user?.full_name ?? '').split(' ')[0]} 👋`}
        subtitle="Your project hub"
      />

      {/* Submit CTA */}
      <div className="card" style={{
        padding: '20px 24px', marginBottom: 28,
        display: 'flex', alignItems: 'center', gap: 16,
        border: '1.5px solid var(--accent)',
        background: 'var(--accent-light)',
        flexWrap: 'wrap',
      }}>
        <div style={{
          width: 44, height: 44, borderRadius: 12,
          background: 'var(--accent)', display: 'flex',
          alignItems: 'center', justifyContent: 'center', flexShrink: 0,
        }}>
          <Upload size={20} style={{ color: '#fff' }} />
        </div>
        <div style={{ flex: 1, minWidth: 160 }}>
          <p style={{ fontSize: 16, fontWeight: 700, color: 'var(--soft)', marginBottom: 2 }}>Submit your project</p>
          <p style={{ fontSize: 13, color: 'var(--muted)' }}>Help others by sharing your work</p>
        </div>
        <button
          onClick={() => router.push('/student/upload')}
          className="btn btn-primary"
          style={{ flexShrink: 0, whiteSpace: 'nowrap' }}>
          Upload Project
        </button>
      </div>

      {/* Recent projects */}
      <h2 style={{ fontSize: 13, fontWeight: 700, color: 'var(--muted)', textTransform: 'uppercase', letterSpacing: '0.5px', marginBottom: 16 }}>
        Recent Projects
      </h2>

      {projects.length === 0 ? (
        <div style={{ textAlign: 'center', padding: '48px 20px' }}>
          <div style={{ width: 60, height: 60, borderRadius: 16, background: 'var(--accent-light)', display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '0 auto 16px' }}>
            <FolderOpen size={28} style={{ color: 'var(--accent)' }} />
          </div>
          <p style={{ fontSize: 16, fontWeight: 600, color: 'var(--soft)', marginBottom: 6 }}>No projects yet</p>
          <p style={{ fontSize: 14, color: 'var(--muted)' }}>Projects from your courses will appear here</p>
        </div>
      ) : (
        <div style={{ display: 'flex', flexDirection: 'column', gap: 12, paddingBottom: 80 }}>
          {projects.map((p: unknown) => (
            <ProjectCard
              key={(p as { id: string }).id}
              project={p as Parameters<typeof ProjectCard>[0]['project']}
            />
          ))}
        </div>
      )}
    </Layout>
  );
}