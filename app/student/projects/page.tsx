'use client';
import { useEffect, useState, useRef } from 'react';
import { useRouter } from 'next/navigation';
import { getUser, requireAuth } from '@/lib/auth';
import Layout from '@/components/Layout';
import PageHeader from '@/components/PageHeader';
import ProjectCard from '@/components/ProjectCard';
import EmptyState from '@/components/EmptyState';
import api from '@/lib/api';
import { Search, FolderOpen, ChevronDown, Check } from 'lucide-react';

const SESSIONS = ['2025/2026', '2024/2025', '2023/2024', '2022/2023', '2021/2022'];

function SessionSelect({ value, onChange }: { value: string; onChange: (v: string) => void }) {
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const handler = (e: MouseEvent) => {
      if (ref.current && !ref.current.contains(e.target as Node)) setOpen(false);
    };
    document.addEventListener('mousedown', handler);
    return () => document.removeEventListener('mousedown', handler);
  }, []);

  const options = [{ value: '', label: 'All sessions' }, ...SESSIONS.map(s => ({ value: s, label: s }))];
  const selected = options.find(o => o.value === value);

  return (
    <div ref={ref} style={{ position: 'relative', flexShrink: 0 }}>
      <button type="button" onClick={() => setOpen(!open)} style={{
        display: 'flex', alignItems: 'center', gap: 8, padding: '11px 14px',
        borderRadius: 10, cursor: 'pointer', whiteSpace: 'nowrap',
        border: `1.5px solid ${open ? 'var(--accent)' : 'var(--border)'}`,
        background: 'var(--card)', color: 'var(--soft)',
        fontSize: 14, fontFamily: 'Plus Jakarta Sans, sans-serif', fontWeight: 500,
        boxShadow: open ? '0 0 0 3px var(--accent-glow)' : 'none',
      }}>
        {selected?.label ?? 'All sessions'}
        <ChevronDown size={15} style={{ transform: open ? 'rotate(180deg)' : 'none', transition: 'transform 0.2s', color: 'var(--muted)' }} />
      </button>
      {open && (
        <div style={{
          position: 'absolute', top: 'calc(100% + 6px)', right: 0, zIndex: 200, minWidth: 160,
          background: 'var(--card)', border: '1.5px solid var(--border)',
          borderRadius: 12, boxShadow: 'var(--shadow-md)', overflow: 'hidden',
        }}>
          {options.map(o => (
            <button type="button" key={o.value} onClick={() => { onChange(o.value); setOpen(false); }}
              style={{
                width: '100%', display: 'flex', alignItems: 'center', justifyContent: 'space-between',
                gap: 8, padding: '11px 16px', cursor: 'pointer', border: 'none',
                background: value === o.value ? 'var(--accent-light)' : 'transparent',
                color: value === o.value ? 'var(--accent)' : 'var(--soft)',
                fontSize: 14, fontFamily: 'Plus Jakarta Sans, sans-serif',
                fontWeight: value === o.value ? 600 : 400, textAlign: 'left',
              }}
              onMouseEnter={e => { if (value !== o.value) (e.currentTarget as HTMLButtonElement).style.background = 'var(--surface)'; }}
              onMouseLeave={e => { if (value !== o.value) (e.currentTarget as HTMLButtonElement).style.background = 'transparent'; }}>
              <span>{o.label}</span>
              {value === o.value && <Check size={13} />}
            </button>
          ))}
        </div>
      )}
    </div>
  );
}

export default function BrowseProjects() {
  const router = useRouter();
  const [projects, setProjects] = useState<unknown[]>([]);
  const [search, setSearch] = useState('');
  const [session, setSession] = useState('');
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (!requireAuth(getUser(), router, ['student'])) return;
    load();
  }, [session, router]);

  const load = (q = '') => {
    setLoading(true);
    const endpoint = q ? '/projects/search' : '/projects';
    const params = q ? { q } : (session ? { session } : {});
    api.get(endpoint, { params })
      .then(r => setProjects(r.data))
      .catch(() => {})
      .finally(() => setLoading(false));
  };

  const handleSearch = (e: React.ChangeEvent<HTMLInputElement>) => {
    setSearch(e.target.value);
    if (e.target.value.length > 1) load(e.target.value);
    else if (e.target.value === '') load();
  };

  return (
    <Layout>
      <PageHeader title="Browse Projects" subtitle="Reference past work from your courses" />

      <div style={{ display: 'flex', gap: 12, marginBottom: 24, alignItems: 'center' }}>
        <div style={{ position: 'relative', flex: 1 }}>
          <Search size={16} style={{ position: 'absolute', left: 14, top: '50%', transform: 'translateY(-50%)', color: 'var(--muted)', pointerEvents: 'none' }} />
          <input className="input" style={{ paddingLeft: 44 }}
            placeholder="Search project titles..."
            value={search} onChange={handleSearch} />
        </div>
        <SessionSelect value={session} onChange={v => setSession(v)} />
      </div>

      {loading ? (
        <div style={{ textAlign: 'center', padding: '40px 0', color: 'var(--muted)', fontSize: 14 }}>Searching...</div>
      ) : projects.length === 0 ? (
        <EmptyState icon={FolderOpen} title="No projects found" subtitle="Try a different search or filter" />
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