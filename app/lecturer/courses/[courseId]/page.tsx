'use client';
import { useEffect, useState } from 'react';
import { useRouter, useParams } from 'next/navigation';
import { getUser, requireAuth } from '@/lib/auth';
import Layout from '@/components/Layout';
import PageHeader from '@/components/PageHeader';
import ProjectCard from '@/components/ProjectCard';
import EmptyState from '@/components/EmptyState';
import api from '@/lib/api';
import { FolderOpen, Users } from 'lucide-react';

interface Student { id: string; full_name: string; email: string; matric_number: string; }
interface CourseData {
  course?: { title: string; course_code: string; session: string };
  projects?: unknown[];
  students?: Student[];
}

export default function CourseDetail() {
  const router = useRouter();
  const { courseId } = useParams<{ courseId: string }>();
  const [data, setData] = useState<CourseData | null>(null);
  const [tab, setTab] = useState<'projects' | 'students'>('projects');

  useEffect(() => {
    if (!requireAuth(getUser(), router, ['lecturer', 'admin'])) return;
    api.get(`/lecturer/courses/${courseId}`).then(r => setData(r.data)).catch(() => {});
  }, [courseId, router]);

  if (!data) return <Layout><p style={{ color: 'var(--muted)', fontSize: 15 }}>Loading...</p></Layout>;

  return (
    <Layout>
      <button onClick={() => router.back()}
        style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--muted)', fontSize: 14, marginBottom: 16, display: 'flex', alignItems: 'center', gap: 4, fontFamily: 'Plus Jakarta Sans', padding: 0 }}>
        ← Back
      </button>
      <PageHeader title={data.course?.title ?? ''} subtitle={`${data.course?.course_code} · ${data.course?.session}`} />

      {/* Tab buttons */}
      <div style={{ display: 'flex', gap: 8, marginBottom: 24 }}>
        {(['projects', 'students'] as const).map(t => (
          <button key={t} onClick={() => setTab(t)}
            style={{
              padding: '9px 20px', borderRadius: 10, cursor: 'pointer', fontSize: 14,
              fontWeight: tab === t ? 700 : 500, border: '1.5px solid',
              fontFamily: 'Plus Jakarta Sans, sans-serif', textTransform: 'capitalize',
              transition: 'all 0.15s',
              background: tab === t ? 'var(--accent)' : 'var(--card)',
              borderColor: tab === t ? 'var(--accent)' : 'var(--border)',
              color: tab === t ? '#fff' : 'var(--muted)',
            }}>
            {t.charAt(0).toUpperCase() + t.slice(1)} ({t === 'projects' ? data.projects?.length ?? 0 : data.students?.length ?? 0})
          </button>
        ))}
      </div>

      {tab === 'projects' && (
        !data.projects?.length
          ? <EmptyState icon={FolderOpen} title="No projects yet" subtitle="Students haven't submitted yet" />
          : <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
              {(data.projects as Parameters<typeof ProjectCard>[0]['project'][]).map(p => (
                <ProjectCard key={(p as {id:string}).id} project={p} href={`/lecturer/projects/${(p as {id:string}).id}`} />
              ))}
            </div>
      )}

      {tab === 'students' && (
        !data.students?.length
          ? <EmptyState icon={Users} title="No students enrolled" subtitle="Register students from the sidebar" />
          : <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
              {data.students?.map(s => (
                <div key={s.id} className="card" style={{ padding: '16px 20px', display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 12 }}>
                  <div>
                    <p style={{ fontSize: 15, fontWeight: 700, color: 'var(--soft)', marginBottom: 3 }}>{s.full_name}</p>
                    <p style={{ fontSize: 13, color: 'var(--muted)' }}>{s.email}</p>
                  </div>
                  <span className="mono badge badge-purple">{s.matric_number}</span>
                </div>
              ))}
            </div>
      )}
    </Layout>
  );
}
