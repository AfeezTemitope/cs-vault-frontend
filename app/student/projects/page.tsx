'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { getUser, requireAuth } from '@/lib/auth';
import Layout from '@/components/Layout';
import PageHeader from '@/components/PageHeader';
import ProjectCard from '@/components/ProjectCard';
import EmptyState from '@/components/EmptyState';
import api from '@/lib/api';
import { Search, FolderOpen } from 'lucide-react';

const SESSIONS = ['2024/2025','2023/2024','2022/2023','2021/2022'];

export default function BrowseProjects() {
  const router = useRouter();
  const [projects, setProjects] = useState<unknown[]>([]);
  const [search, setSearch] = useState('');
  const [session, setSession] = useState('');

  useEffect(() => {
    if (!requireAuth(getUser(), router, ['student'])) return;
    load();
  }, [session, router]);

  const load = (q='') => {
    const endpoint = q ? '/projects/search' : '/projects';
    const params = q ? { q } : (session ? { session } : {});
    api.get(endpoint, { params }).then(r => setProjects(r.data)).catch(()=>{});
  };

  return (
    <Layout>
      <PageHeader title="Browse Projects" subtitle="Reference past work from your courses" />
      <div className="flex gap-2 mb-4">
        <div className="relative flex-1">
          <Search size={15} className="absolute left-4 top-1/2 -translate-y-1/2" style={{ color:'var(--muted)' }} />
          <input className="w-full rounded-xl pl-10 pr-4 py-3 text-sm border focus:outline-none"
            style={{ backgroundColor:'var(--card)', borderColor:'var(--border)', color:'var(--soft)' }}
            placeholder="Search project titles..."
            value={search}
            onChange={e => { setSearch(e.target.value); load(e.target.value); }}
            onFocus={e=>(e.target.style.borderColor='var(--accent)')}
            onBlur={e=>(e.target.style.borderColor='var(--border)')} />
        </div>
        <select className="rounded-xl px-3 py-2 text-sm border focus:outline-none"
          style={{ backgroundColor:'var(--card)', borderColor:'var(--border)', color:'var(--soft)' }}
          value={session} onChange={e => setSession(e.target.value)}>
          <option value="">All sessions</option>
          {SESSIONS.map(s => <option key={s} value={s}>{s}</option>)}
        </select>
      </div>
      {projects.length===0
        ? <EmptyState icon={FolderOpen} title="No projects found" subtitle="Try a different search or filter" />
        : <div className="space-y-3 pb-20">{projects.map((p:unknown) => <ProjectCard key={(p as {id:string}).id} project={p as Parameters<typeof ProjectCard>[0]['project']} />)}</div>
      }
    </Layout>
  );
}
