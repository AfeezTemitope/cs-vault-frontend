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

export default function CourseDetail() {
  const router = useRouter();
  const { courseId } = useParams<{ courseId: string }>();
  const [data, setData] = useState<{ course?: { title: string; course_code: string; session: string }; projects?: unknown[]; students?: { id: string; full_name: string; email: string; matric_number: string }[] } | null>(null);
  const [tab, setTab] = useState<'projects' | 'students'>('projects');

  useEffect(() => {
    if (!requireAuth(getUser(), router, ['lecturer', 'admin'])) return;
    api.get(`/lecturer/courses/${courseId}`).then(r => setData(r.data)).catch(() => {});
  }, [courseId, router]);

  if (!data) return <Layout><p className="text-sm" style={{ color: 'var(--muted)' }}>Loading...</p></Layout>;

  return (
    <Layout>
      <button onClick={() => router.back()} className="text-xs mb-4" style={{ color: 'var(--muted)' }}>← Back</button>
      <PageHeader title={data.course?.title ?? ''} subtitle={`${data.course?.course_code} · ${data.course?.session}`} />
      <div className="flex gap-2 mb-5">
        {(['projects', 'students'] as const).map(t => (
          <button key={t} onClick={() => setTab(t)}
            className="px-4 py-2 rounded-lg text-sm font-medium capitalize transition-all border"
            style={tab === t
              ? { backgroundColor: 'var(--accent)', color: 'var(--ink)', borderColor: 'var(--accent)' }
              : { backgroundColor: 'transparent', color: 'var(--muted)', borderColor: 'var(--border)' }}>
            {t} ({t === 'projects' ? data.projects?.length ?? 0 : data.students?.length ?? 0})
          </button>
        ))}
      </div>
      {tab === 'projects' && (
        !data.projects?.length
          ? <EmptyState icon={FolderOpen} title="No projects yet" subtitle="Students haven't submitted yet" />
          : <div className="space-y-3">{(data.projects as Parameters<typeof ProjectCard>[0]['project'][]).map((p: Parameters<typeof ProjectCard>[0]['project']) => <ProjectCard key={(p as {id:string}).id} project={p} href={`/lecturer/projects/${(p as {id:string}).id}`} />)}</div>
      )}
      {tab === 'students' && (
        !data.students?.length
          ? <EmptyState icon={Users} title="No students enrolled" subtitle="Register students from the sidebar" />
          : <div className="space-y-2">
              {data.students?.map(s => (
                <div key={s.id} className="rounded-xl p-4 border flex items-center justify-between"
                  style={{ backgroundColor: 'var(--card)', borderColor: 'var(--border)' }}>
                  <div>
                    <p className="font-semibold text-sm" style={{ color: 'var(--soft)' }}>{s.full_name}</p>
                    <p className="text-xs" style={{ color: 'var(--muted)' }}>{s.email}</p>
                  </div>
                  <span className="mono text-xs" style={{ color: 'var(--accent)' }}>{s.matric_number}</span>
                </div>
              ))}
            </div>
      )}
    </Layout>
  );
}
