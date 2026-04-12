'use client';
import { useEffect, useState, useRef } from 'react';
import { useRouter } from 'next/navigation';
import { getUser, requireAuth } from '@/lib/auth';
import Layout from '@/components/Layout';
import PageHeader from '@/components/PageHeader';
import api from '@/lib/api';
import toast from 'react-hot-toast';
import {
  Search, Download, Eye, BookOpen, ChevronDown,
  Check, Filter, FileText, GitBranch, Archive, Clock, CheckCircle, XCircle
} from 'lucide-react';
import { format } from 'date-fns';

interface Project {
  id: string; title: string; session: string; year?: string; supervisor?: string;
  description?: string; pdf_url?: string; zip_url?: string; github_link?: string;
  created_at?: string; download_count?: number; status?: string;
  courses?: { title: string; course_code: string };
  users?: { full_name: string; matric_number: string };
  grades?: { grade: string }[];
}

function Dropdown({ value, onChange, options, placeholder }: {
  value: string; onChange: (v: string) => void;
  options: { value: string; label: string }[]; placeholder: string;
}) {
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLDivElement>(null);
  const selected = options.find(o => o.value === value);
  useEffect(() => {
    const h = (e: MouseEvent) => {
      if (ref.current && !ref.current.contains(e.target as Node)) setOpen(false);
    };
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
          position: 'absolute', top: 'calc(100% + 6px)', left: 0, zIndex: 200, minWidth: 160,
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

const STATUS_CONFIG: Record<string, { label: string; icon: React.ElementType; class: string }> = {
  pending:  { label: 'Pending',  icon: Clock,         class: 'badge badge-pending' },
  approved: { label: 'Approved', icon: CheckCircle,   class: 'badge badge-approved' },
  rejected: { label: 'Rejected', icon: XCircle,       class: 'badge badge-rejected' },
};

export default function VaultPage() {
  const router = useRouter();
  const user = getUser();
  const [projects, setProjects] = useState<Project[]>([]);
  const [search, setSearch] = useState('');
  const [filterYear, setFilterYear] = useState('');
  const [filterCourse, setFilterCourse] = useState('');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!requireAuth(getUser(), router)) return;
    // Admins and lecturers see all projects, students see approved only
    const endpoint = user?.role === 'student' ? '/projects/approved' : '/lecturer/projects';
    api.get(endpoint)
      .then(r => setProjects(r.data))
      .catch(() => {})
      .finally(() => setLoading(false));
  }, [router, user?.role]);

  const years = [...new Set(projects.map(p => p.year).filter(Boolean))] as string[];
  const courses = [...new Set(projects.map(p => p.courses?.course_code).filter(Boolean))] as string[];

  const filtered = projects.filter(p => {
    const matchSearch = !search ||
      p.title.toLowerCase().includes(search.toLowerCase()) ||
      p.users?.full_name.toLowerCase().includes(search.toLowerCase()) ||
      p.supervisor?.toLowerCase().includes(search.toLowerCase());
    const matchYear = !filterYear || p.year === filterYear;
    const matchCourse = !filterCourse || p.courses?.course_code === filterCourse;
    return matchSearch && matchYear && matchCourse;
  });

  const handleDownload = async (project: Project) => {
    if (project.pdf_url) {
      window.open(project.pdf_url, '_blank');
      await api.post(`/projects/${project.id}/download`).catch(() => {});
    } else {
      toast.error('No PDF available for this project');
    }
  };

  const gradeColors: Record<string, string> = {
    A: '#059669', B: '#7C3AED', C: '#D97706', D: '#B45309', E: '#DC2626', F: '#991B1B'
  };

  return (
    <Layout>
      <PageHeader
        title="Project Repository"
        subtitle={`${filtered.length} ${user?.role === 'student' ? 'approved' : ''} projects`}
      />

      {/* Stats row */}
      <div style={{ display: 'flex', gap: 12, marginBottom: 24, flexWrap: 'wrap' }}>
        {[
          { label: 'Total', value: projects.length, color: 'var(--accent)' },
          { label: 'Approved', value: projects.filter(p => p.status === 'approved').length, color: '#059669' },
          { label: 'Pending', value: projects.filter(p => p.status === 'pending').length, color: '#D97706' },
        ].map(s => (
          <div key={s.label} className="card" style={{ padding: '12px 20px', display: 'flex', alignItems: 'center', gap: 10 }}>
            <span style={{ fontSize: 22, fontWeight: 800, color: s.color }}>{s.value}</span>
            <span style={{ fontSize: 13, color: 'var(--muted)', fontWeight: 500 }}>{s.label}</span>
          </div>
        ))}
      </div>

      {/* Search & filters */}
      <div style={{ display: 'flex', gap: 10, marginBottom: 24, flexWrap: 'wrap', alignItems: 'center' }}>
        <div style={{ position: 'relative', flex: 1, minWidth: 200 }}>
          <Search size={16} style={{ position: 'absolute', left: 14, top: '50%', transform: 'translateY(-50%)', color: 'var(--muted)', pointerEvents: 'none' }} />
          <input className="input" style={{ paddingLeft: 44 }}
            placeholder="Search by title, student or supervisor..."
            value={search} onChange={e => setSearch(e.target.value)} />
        </div>
        <div style={{ display: 'flex', gap: 8, alignItems: 'center', flexWrap: 'wrap' }}>
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

      {/* Projects */}
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
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))', gap: 16 }}>
          {filtered.map(p => {
            const status = p.status ?? 'pending';
            const sc = STATUS_CONFIG[status] ?? STATUS_CONFIG.pending;
            const grade = Array.isArray(p.grades) ? p.grades[0]?.grade : undefined;
            return (
              <div key={p.id} className="card" style={{ padding: '20px', display: 'flex', flexDirection: 'column', gap: 12 }}>
                {/* Header */}
                <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: 8 }}>
                  <h3 style={{ fontSize: 15, fontWeight: 700, color: 'var(--soft)', lineHeight: 1.4, flex: 1 }}>{p.title}</h3>
                  <div style={{ display: 'flex', flexDirection: 'column', gap: 4, alignItems: 'flex-end', flexShrink: 0 }}>
                    <span className={sc.class} style={{ display: 'flex', alignItems: 'center', gap: 4, fontSize: 11 }}>
                      <sc.icon size={10} /> {sc.label}
                    </span>
                    {grade && (
                      <span style={{ fontSize: 12, fontWeight: 700, color: gradeColors[grade] ?? 'var(--muted)', background: `${gradeColors[grade] ?? '#888'}18`, padding: '2px 8px', borderRadius: 99 }}>
                        {grade}
                      </span>
                    )}
                  </div>
                </div>

                {/* Abstract */}
                {p.description && (
                  <p style={{ fontSize: 13, color: 'var(--muted)', lineHeight: 1.6, display: '-webkit-box', WebkitLineClamp: 3, WebkitBoxOrient: 'vertical', overflow: 'hidden' }}>
                    {p.description}
                  </p>
                )}

                {/* Meta */}
                <div style={{ display: 'flex', flexDirection: 'column', gap: 5, padding: '10px 0', borderTop: '1px solid var(--border)', borderBottom: '1px solid var(--border)', fontSize: 13 }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                    <span style={{ color: 'var(--muted)', fontWeight: 500 }}>Student</span>
                    <span style={{ color: 'var(--soft)', fontWeight: 600 }}>{p.users?.full_name}</span>
                  </div>
                  {p.supervisor && (
                    <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                      <span style={{ color: 'var(--muted)', fontWeight: 500 }}>Supervisor</span>
                      <span style={{ color: 'var(--soft)', fontWeight: 600 }}>{p.supervisor}</span>
                    </div>
                  )}
                  <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                    <span style={{ color: 'var(--muted)', fontWeight: 500 }}>Course</span>
                    <span className="badge badge-purple mono" style={{ fontSize: 11 }}>{p.courses?.course_code}</span>
                  </div>
                  <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                    <span style={{ color: 'var(--muted)', fontWeight: 500 }}>Year</span>
                    <span className="mono" style={{ color: 'var(--soft)', fontWeight: 600 }}>{p.year ?? new Date(p.created_at ?? '').getFullYear()}</span>
                  </div>
                  {p.download_count !== undefined && p.download_count > 0 && (
                    <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                      <span style={{ color: 'var(--muted)', fontWeight: 500 }}>Downloads</span>
                      <span className="mono" style={{ color: 'var(--accent)', fontWeight: 600 }}>{p.download_count}</span>
                    </div>
                  )}
                </div>

                {/* Actions */}
                <div style={{ display: 'flex', gap: 8 }}>
                  {p.pdf_url && (
                    <button onClick={() => handleDownload(p)} className="btn btn-primary btn-sm" style={{ flex: 1, justifyContent: 'center' }}>
                      <Download size={14} /> Download
                    </button>
                  )}
                  <button onClick={() => router.push(user?.role === 'lecturer' || user?.role === 'admin' ? `/lecturer/projects/${p.id}` : `/student/projects/${p.id}`)}
                    className="btn btn-secondary btn-sm" style={{ flex: 1, justifyContent: 'center' }}>
                    <Eye size={14} /> View
                  </button>
                  {p.github_link && (
                    <a href={p.github_link} target="_blank" rel="noopener noreferrer"
                      className="btn btn-secondary btn-sm" style={{ padding: '8px 12px', textDecoration: 'none' }}>
                      <GitBranch size={14} />
                    </a>
                  )}
                </div>
              </div>
            );
          })}
        </div>
      )}
    </Layout>
  );
}
