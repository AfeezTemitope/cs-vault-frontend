'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { getUser, requireAuth } from '@/lib/auth';
import Layout from '@/components/Layout';
import PageHeader from '@/components/PageHeader';
import ProjectCard from '@/components/ProjectCard';
import api from '@/lib/api';
import { Upload } from 'lucide-react';

export default function StudentDashboard() {
  const router = useRouter();
  const [projects, setProjects] = useState<unknown[]>([]);
  const user = getUser();

  useEffect(() => {
    if (!requireAuth(getUser(), router, ['student'])) return;
    api.get('/projects').then(r => setProjects(r.data.slice(0,5))).catch(()=>{});
  }, [router]);

  return (
    <Layout>
      <PageHeader title={`Hi, ${(user?.name??user?.full_name??'').split(' ')[0]} 👋`} subtitle="Your project hub" />
      <div className="rounded-xl p-4 border mb-6 flex items-center gap-4"
        style={{ backgroundColor:'var(--card)', borderColor:'rgba(200,241,53,0.2)' }}>
        <div className="w-10 h-10 rounded-lg flex items-center justify-center flex-shrink-0"
          style={{ backgroundColor:'rgba(200,241,53,0.1)' }}>
          <Upload size={18} style={{ color:'var(--accent)' }} />
        </div>
        <div className="flex-1">
          <p className="font-semibold text-sm" style={{ color:'var(--soft)' }}>Submit your project</p>
          <p className="text-xs" style={{ color:'var(--muted)' }}>Help others by sharing your work</p>
        </div>
        <button onClick={() => router.push('/student/upload')}
          className="flex-shrink-0 px-4 py-2 rounded-lg text-sm font-semibold"
          style={{ backgroundColor:'var(--accent)', color:'var(--ink)' }}>Upload</button>
      </div>
      <h2 className="text-xs font-semibold uppercase tracking-widest mb-3" style={{ color:'var(--muted)' }}>Recent Projects</h2>
      <div className="space-y-3 pb-20">
        {projects.map((p:unknown) => <ProjectCard key={(p as {id:string}).id} project={p as Parameters<typeof ProjectCard>[0]['project']} />)}
      </div>
    </Layout>
  );
}
