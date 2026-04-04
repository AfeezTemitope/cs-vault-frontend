'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { getUser, requireAuth } from '@/lib/auth';
import Layout from '@/components/Layout';
import PageHeader from '@/components/PageHeader';
import ProjectCard from '@/components/ProjectCard';
import EmptyState from '@/components/EmptyState';
import api from '@/lib/api';
import { FolderOpen, Search } from 'lucide-react';

export default function LecturerProjects() {
  const router = useRouter();
  const [projects, setProjects] = useState<unknown[]>([]);
  const [search, setSearch] = useState('');

  useEffect(() => {
    if (!requireAuth(getUser(), router, ['lecturer', 'admin'])) return;
    fetchProjects();
  }, [router]);

  const fetchProjects = (q = '') =>
    api.get('/lecturer/projects', { params: q ? { search: q } : {} })
      .then(r => setProjects(r.data)).catch(() => {});

  return (
    <Layout>
      <PageHeader title="All Projects" subtitle="Browse and grade submissions" />
      <div className="relative mb-5">
        <Search size={15} className="absolute left-4 top-1/2 -translate-y-1/2" style={{ color: 'var(--muted)' }} />
        <input className="w-full rounded-xl pl-10 pr-4 py-3 text-sm border focus:outline-none"
          style={{ backgroundColor: 'var(--card)', borderColor: 'var(--border)', color: 'var(--soft)' }}
          placeholder="Search by project title..."
          value={search}
          onChange={e => { setSearch(e.target.value); fetchProjects(e.target.value); }}
          onFocus={e => (e.target.style.borderColor = 'var(--accent)')}
          onBlur={e => (e.target.style.borderColor = 'var(--border)')} />
      </div>
      {projects.length === 0
        ? <EmptyState icon={FolderOpen} title="No projects found" subtitle="Projects appear here once students submit" />
        : <div className="space-y-3">{projects.map((p: unknown) => <ProjectCard key={(p as {id:string}).id} project={p as Parameters<typeof ProjectCard>[0]['project']} href={`/lecturer/projects/${(p as {id:string}).id}`} />)}</div>
      }
    </Layout>
  );
}
