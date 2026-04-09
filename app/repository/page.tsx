'use client';
import { useEffect, useState, useRef } from 'react';
import Link from 'next/link';
import ThemeToggle from '@/components/ThemeToggle';
import api from '@/lib/api';
import { Search, Download, Eye, BookOpen, ChevronDown, Check, ArrowLeft, FileText, GitBranch, Archive, Filter } from 'lucide-react';
import { format } from 'date-fns';

interface Project {
  id: string; title: string; session: string; year?: string;
  supervisor?: string; description?: string; pdf_url?: string;
  zip_url?: string; github_link?: string; created_at?: string;
  download_count?: number;
  courses?: { title: string; course_code: string };
  users?: { full_name: string; matric_number: string };
  grades?: { grade: string };
}

function Dropdown({ value, onChange, options, placeholder }: {
  value: string; onChange: (v: string) => void;
  options: { value: string; label: string }[]; placeholder: string;
}) {
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLDivElement>(null);
  const selected = options.find(o => o.value === value);
  useEffect(() => {
    const h = (e: MouseEvent) => { if (ref.current && !ref.current.contains(e.target as Node)) setOpen(false); };
    document.addEventListener('mousedown', h);
    return () => document.removeEventListener('mousedown', h);
  }, []);
  return (
    <div ref={ref} style={{ position: 'relative' }}>
      <button type="button" onClick={() => setOpen(!open)} style={{
        display: 'flex', alignItems: 'center', gap: 8, padding: '10px 14px',
        borderRadius: 10, cursor: 'pointer', whiteSpace: 'nowrap',
        border: `1.5px solid ${open ? 'var(--accent)' : 'var(--border)'}`,
        background: 'var(--card)', color: selected ? 'var(--soft)' : 'var(--muted)',
        fontSize: 14, fontFamily: 'Plus Jakarta Sans, sans-serif', fontWeight: 500,
      }}>
        {selected?.label ?? placeholder}
        <ChevronDown size={14} style={{ transform: open ? 'rotate(180deg)' : 'none', transition: 'transform 0.2s' }} />
      </button>
      {open && (
        <div style={{
          position: 'absolute', top: 'calc(100% + 6px)', left: 0, zIndex: 200, minWidth: 180,
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
              }}>
              <span>{o.label}</span>
              {value === o.value && <Check size={13} />}
            </button>
          ))}
        </div>
      )}
    </div>
  );
}

export default function RepositoryPage() {
  const [projects, setProjects] = useState<Project[]>([]);
  const [search, setSearch] = useState('');
  const [filterYear, setFilterYear] = useState('');
  const [filterCourse, setFilterCourse] = useState('');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Fetch approved projects only - public endpoint
    api.get('/projects/public').then(r => setProjects(r.data)).catch(() => {}).finally(() => setLoading(false));
  }, []);

  const years = [...new Set(projects.map(p => p.year ?? new Date(p.created_at ?? '').getFullYear().toString()))].filter(Boolean);
  const courses = [...new Set(projects.map(p => p.courses?.course_code).filter(Boolean))] as string[];

  const filtered = projects.filter(p => {
    const matchSearch = !search || p.title.toLowerCase().includes(search.toLowerCase()) ||
      p.users?.full_name.toLowerCase().includes(search.toLowerCase()) ||
      p.supervisor?.toLowerCase().includes(search.toLowerCase());
    const matchYear = !filterYear || (p.year ?? '') === filterYear;
    const matchCourse = !filterCourse || p.courses?.course_code === filterCourse;
    return matchSearch && matchYear && matchCourse;
  });

  const handleDownload = async (project: Project) => {
    if (project.pdf_url) {
      window.open(project.pdf_url, '_blank');
      await api.post(`/projects/${project.id}/download`).catch(() => {});
    } else {
      toast('No PDF available for this project');
    }
  };

  return (
    <div style={{ minHeight: '100vh', background: 'var(--ink)' }}>
      {/* Nav */}
      <nav style={{
        position: 'sticky', top: 0, zIndex: 100,
        display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        padding: '0 5%', height: 66, background: 'var(--card)', borderBottom: '1.5px solid var(--border)',
        boxShadow: 'var(--shadow-sm)',
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 16 }}>
          <Link href="/" style={{ display: 'flex', alignItems: 'center', gap: 6, textDecoration: 'none', color: 'var(--muted)', fontSize: 14 }}>
            <ArrowLeft size={16} /> Home
          </Link>
          <div style={{ width: 1, height: 20, background: 'var(--border)' }} />
          <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
            <div style={{ width: 32, height: 32, borderRadius: 8, background: 'var(--accent)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <span style={{ color: '#fff', fontWeight: 800, fontSize: 13, fontFamily: 'JetBrains Mono' }}>CV</span>
            </div>
            <span style={{ fontWeight: 800, fontSize: 16, color: 'var(--soft)' }}>Project Repository</span>
          </div>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
          <ThemeToggle />
          <Link href="/login" className="btn btn-primary btn-sm" style={{ textDecoration: 'none', display: 'flex', alignItems: 'center', gap: 6, padding: '8px 16px', fontSize: 14 }}>
            Sign In
          </Link>
        </div>
      </nav>

      {/* Header */}
      <div style={{ padding: '48px 5% 32px', textAlign: 'center', background: 'var(--surface)', borderBottom: '1.5px solid var(--border)' }}>
        <div style={{ display: 'inline-flex', alignItems: 'center', gap: 6, background: 'var(--accent-light)', color: 'var(--accent)', padding: '5px 14px', borderRadius: 99, fontSize: 12, fontWeight: 700, textTransform: 'uppercase', letterSpacing: '0.5px', marginBottom: 16 }}>
          <BookOpen size={12} /> Public Repository
        </div>
        <h1 style={{ fontSize: 'clamp(24px, 4vw, 40px)', fontWeight: 800, color: 'var(--soft)', letterSpacing: '-0.5px', marginBottom: 10 }}>
          CS Project Repository
        </h1>
        <p style={{ fontSize: 16, color: 'var(--muted)', maxWidth: 500, margin: '0 auto' }}>
          Browse all approved Computer Science final year projects. Download, view and learn from past work.
        </p>
        <div style={{ marginTop: 20, display: 'flex', gap: 16, justifyContent: 'center', flexWrap: 'wrap' }}>
          {[
            { label: 'Total Projects', value: projects.length },
            { label: 'CSC 497', value: projects.filter(p => p.courses?.course_code === 'CSC 497').length },
            { label: 'CSC 498', value: projects.filter(p => p.courses?.course_code === 'CSC 498').length },
          ].map(s => (
            <div key={s.label} className="card" style={{ padding: '12px 24px', textAlign: 'center' }}>
              <p style={{ fontSize: 24, fontWeight: 800, color: 'var(--accent)' }}>{s.value}</p>
              <p style={{ fontSize: 13, color: 'var(--muted)' }}>{s.label}</p>
            </div>
          ))}
        </div>
      </div>

      {/* Filters */}
      <div style={{ padding: '24px 5%', borderBottom: '1.5px solid var(--border)', background: 'var(--card)' }}>
        <div style={{ maxWidth: 1100, margin: '0 auto', display: 'flex', gap: 12, flexWrap: 'wrap', alignItems: 'center' }}>
          <div style={{ position: 'relative', flex: 1, minWidth: 200 }}>
            <Search size={16} style={{ position: 'absolute', left: 14, top: '50%', transform: 'translateY(-50%)', color: 'var(--muted)', pointerEvents: 'none' }} />
            <input className="input" style={{ paddingLeft: 44 }}
              placeholder="Search by title, student or supervisor..."
              value={search} onChange={e => setSearch(e.target.value)} />
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
            <Filter size={15} style={{ color: 'var(--muted)' }} />
            <Dropdown value={filterYear} onChange={setFilterYear}
              options={[{ value: '', label: 'All Years' }, ...years.map(y => ({ value: y, label: y }))]}
              placeholder="All Years" />
            <Dropdown value={filterCourse} onChange={setFilterCourse}
              options={[{ value: '', label: 'All Courses' }, ...courses.map(c => ({ value: c, label: c }))]}
              placeholder="All Courses" />
            {(filterYear || filterCourse || search) && (
              <button onClick={() => { setFilterYear(''); setFilterCourse(''); setSearch(''); }}
                style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--accent)', fontSize: 13, fontFamily: 'Plus Jakarta Sans', fontWeight: 600 }}>
                Clear
              </button>
            )}
          </div>
        </div>
      </div>

      {/* Projects grid */}
      <div style={{ padding: '32px 5%', maxWidth: 1100, margin: '0 auto' }}>
        {loading ? (
          <div style={{ textAlign: 'center', padding: '60px 0', color: 'var(--muted)' }}>Loading projects...</div>
        ) : filtered.length === 0 ? (
          <div style={{ textAlign: 'center', padding: '60px 0' }}>
            <div style={{ width: 64, height: 64, borderRadius: 16, background: 'var(--accent-light)', display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '0 auto 16px' }}>
              <BookOpen size={28} style={{ color: 'var(--accent)' }} />
            </div>
            <p style={{ fontSize: 18, fontWeight: 700, color: 'var(--soft)', marginBottom: 8 }}>No projects found</p>
            <p style={{ fontSize: 14, color: 'var(--muted)' }}>Try adjusting your search or filters</p>
          </div>
        ) : (
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(320px, 1fr))', gap: 20 }}>
            {filtered.map(p => (
              <div key={p.id} className="card" style={{ padding: '22px', display: 'flex', flexDirection: 'column', gap: 12 }}>
                <div>
                  <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: 8, marginBottom: 8 }}>
                    <h3 style={{ fontSize: 16, fontWeight: 700, color: 'var(--soft)', lineHeight: 1.4 }}>{p.title}</h3>
                    {p.courses?.course_code && (
                      <span className="badge badge-purple mono" style={{ flexShrink: 0 }}>{p.courses.course_code}</span>
                    )}
                  </div>
                  {p.description && (
                    <p style={{ fontSize: 13, color: 'var(--muted)', lineHeight: 1.6, display: '-webkit-box', WebkitLineClamp: 3, WebkitBoxOrient: 'vertical', overflow: 'hidden' }}>
                      {p.description}
                    </p>
                  )}
                </div>
                <div style={{ display: 'flex', flexDirection: 'column', gap: 6, padding: '12px 0', borderTop: '1px solid var(--border)', borderBottom: '1px solid var(--border)' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                    <span style={{ fontSize: 12, color: 'var(--muted)', fontWeight: 500 }}>Student</span>
                    <span style={{ fontSize: 13, color: 'var(--soft)', fontWeight: 600 }}>{p.users?.full_name}</span>
                  </div>
                  {p.supervisor && (
                    <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                      <span style={{ fontSize: 12, color: 'var(--muted)', fontWeight: 500 }}>Supervisor</span>
                      <span style={{ fontSize: 13, color: 'var(--soft)', fontWeight: 600 }}>{p.supervisor}</span>
                    </div>
                  )}
                  <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                    <span style={{ fontSize: 12, color: 'var(--muted)', fontWeight: 500 }}>Year</span>
                    <span className="mono" style={{ fontSize: 13, color: 'var(--soft)', fontWeight: 600 }}>{p.year ?? new Date(p.created_at ?? '').getFullYear()}</span>
                  </div>
                  {p.download_count !== undefined && (
                    <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                      <span style={{ fontSize: 12, color: 'var(--muted)', fontWeight: 500 }}>Downloads</span>
                      <span className="mono" style={{ fontSize: 13, color: 'var(--accent)', fontWeight: 600 }}>{p.download_count}</span>
                    </div>
                  )}
                </div>
                <div style={{ display: 'flex', gap: 10 }}>
                  {p.pdf_url && (
                    <button onClick={() => handleDownload(p)} className="btn btn-primary btn-sm" style={{ flex: 1, justifyContent: 'center' }}>
                      <Download size={14} /> Download
                    </button>
                  )}
                  <Link href={`/repository/${p.id}`} className="btn btn-secondary btn-sm" style={{ flex: 1, justifyContent: 'center', textDecoration: 'none', display: 'flex', alignItems: 'center', gap: 6 }}>
                    <Eye size={14} /> View
                  </Link>
                  {p.github_link && (
                    <a href={p.github_link} target="_blank" rel="noopener noreferrer" className="btn btn-secondary btn-sm" style={{ padding: '8px 12px' }}>
                      <GitBranch size={14} />
                    </a>
                  )}
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Footer */}
      <footer style={{ borderTop: '1.5px solid var(--border)', padding: '24px 5%', textAlign: 'center', background: 'var(--card)' }}>
        <p style={{ fontSize: 13, color: 'var(--muted)' }}>CS-Vault Project Repository · Computer Science Department · <Link href="/" style={{ color: 'var(--accent)', textDecoration: 'none' }}>Back to Home</Link></p>
      </footer>
    </div>
  );
}
