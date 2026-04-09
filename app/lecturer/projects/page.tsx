'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { getUser, requireAuth } from '@/lib/auth';
import Layout from '@/components/Layout';
import PageHeader from '@/components/PageHeader';
import EmptyState from '@/components/EmptyState';
import api from '@/lib/api';
import toast from 'react-hot-toast';
import { FolderOpen, Search, CheckCircle, XCircle, Clock, FileText, GitBranch, Archive, Download } from 'lucide-react';
import { format } from 'date-fns';

interface Project {
  id: string; title: string; session: string; year?: string; supervisor?: string;
  description?: string; pdf_url?: string; zip_url?: string; github_link?: string;
  created_at?: string; status?: string; download_count?: number;
  courses?: { title: string; course_code: string };
  users?: { full_name: string; matric_number: string };
  grades?: { grade: string }[];
}

const STATUS_CONFIG: Record<string, { label: string; badgeClass: string; icon: React.ElementType }> = {
  pending:  { label: 'Pending',  badgeClass: 'badge badge-pending',  icon: Clock },
  approved: { label: 'Approved', badgeClass: 'badge badge-approved', icon: CheckCircle },
  rejected: { label: 'Rejected', badgeClass: 'badge badge-rejected', icon: XCircle },
};

export default function LecturerProjects() {
  const router = useRouter();
  const [projects, setProjects] = useState<Project[]>([]);
  const [search, setSearch] = useState('');
  const [filter, setFilter] = useState('all');
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (!requireAuth(getUser(), router, ['lecturer', 'admin'])) return;
    fetchProjects();
  }, [router]);

  const fetchProjects = (q = '') => {
    setLoading(true);
    api.get('/lecturer/projects', { params: q ? { search: q } : {} })
      .then(r => setProjects(r.data)).catch(() => {}).finally(() => setLoading(false));
  };

  const handleApprove = async (id: string) => {
    try {
      await api.put(`/lecturer/projects/${id}/approve`);
      toast.success('Project approved — now visible in public repository');
      fetchProjects();
    } catch { toast.error('Failed to approve'); }
  };

  const handleReject = async (id: string) => {
    try {
      await api.put(`/lecturer/projects/${id}/reject`);
      toast.success('Project rejected');
      fetchProjects();
    } catch { toast.error('Failed to reject'); }
  };

  const handleGrade = async (id: string, grade: string) => {
    try {
      await api.put(`/lecturer/projects/${id}/grade`, { grade });
      toast.success('Grade saved');
      fetchProjects();
    } catch { toast.error('Failed to grade'); }
  };

  const GRADES = ['A', 'B', 'C', 'D', 'E', 'F'];
  const filtered = projects.filter(p => {
    const matchSearch = !search || p.title.toLowerCase().includes(search.toLowerCase());
    const matchFilter = filter === 'all' || p.status === filter;
    return matchSearch && matchFilter;
  });

  const counts = {
    all: projects.length,
    pending: projects.filter(p => p.status === 'pending').length,
    approved: projects.filter(p => p.status === 'approved').length,
    rejected: projects.filter(p => p.status === 'rejected').length,
  };

  return (
    <Layout>
      <PageHeader title="Projects" subtitle="Review and approve student submissions" />

      {/* Filter tabs */}
      <div style={{ display: 'flex', gap: 8, marginBottom: 20, flexWrap: 'wrap' }}>
        {(['all', 'pending', 'approved', 'rejected'] as const).map(f => (
          <button key={f} onClick={() => setFilter(f)}
            style={{
              padding: '8px 16px', borderRadius: 10, cursor: 'pointer', fontSize: 14,
              fontWeight: filter === f ? 700 : 500, border: '1.5px solid',
              fontFamily: 'Plus Jakarta Sans, sans-serif', textTransform: 'capitalize',
              transition: 'all 0.15s',
              background: filter === f ? 'var(--accent)' : 'var(--card)',
              borderColor: filter === f ? 'var(--accent)' : 'var(--border)',
              color: filter === f ? '#fff' : 'var(--muted)',
            }}>
            {f === 'all' ? 'All' : f.charAt(0).toUpperCase() + f.slice(1)} ({counts[f]})
          </button>
        ))}
      </div>

      {/* Search */}
      <div style={{ position: 'relative', marginBottom: 20 }}>
        <Search size={16} style={{ position: 'absolute', left: 14, top: '50%', transform: 'translateY(-50%)', color: 'var(--muted)', pointerEvents: 'none' }} />
        <input className="input" style={{ paddingLeft: 44 }}
          placeholder="Search by project title..."
          value={search} onChange={e => { setSearch(e.target.value); fetchProjects(e.target.value); }} />
      </div>

      {loading ? (
        <div style={{ textAlign: 'center', padding: '40px', color: 'var(--muted)' }}>Loading...</div>
      ) : filtered.length === 0 ? (
        <EmptyState icon={FolderOpen} title="No projects found" subtitle="Projects appear here once students submit" />
      ) : (
        <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
          {filtered.map(p => {
            const status = p.status ?? 'pending';
            const sc = STATUS_CONFIG[status] ?? STATUS_CONFIG.pending;
            const currentGrade = Array.isArray(p.grades) ? p.grades[0]?.grade : undefined;
            return (
              <div key={p.id} className="card" style={{ padding: '22px 24px' }}>
                <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: 12, marginBottom: 14 }}>
                  <div style={{ flex: 1 }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: 10, flexWrap: 'wrap', marginBottom: 6 }}>
                      <h3 style={{ fontSize: 17, fontWeight: 700, color: 'var(--soft)' }}>{p.title}</h3>
                      <span className={sc.badgeClass} style={{ display: 'flex', alignItems: 'center', gap: 4 }}>
                        <sc.icon size={11} /> {sc.label}
                      </span>
                      {p.courses?.course_code && <span className="badge badge-purple mono">{p.courses.course_code}</span>}
                    </div>
                    <div style={{ display: 'flex', gap: 16, flexWrap: 'wrap' }}>
                      <span style={{ fontSize: 13, color: 'var(--muted)' }}>
                        <strong style={{ color: 'var(--soft)' }}>{p.users?.full_name}</strong> · {p.users?.matric_number}
                      </span>
                      {p.supervisor && <span style={{ fontSize: 13, color: 'var(--muted)' }}>Supervisor: <strong style={{ color: 'var(--soft)' }}>{p.supervisor}</strong></span>}
                      {p.year && <span style={{ fontSize: 13, color: 'var(--muted)' }}>Year: <strong style={{ color: 'var(--soft)' }}>{p.year}</strong></span>}
                      {p.created_at && <span style={{ fontSize: 13, color: 'var(--muted)' }}>{format(new Date(p.created_at), 'dd MMM yyyy')}</span>}
                    </div>
                  </div>
                </div>

                {p.description && (
                  <p style={{ fontSize: 14, color: 'var(--muted)', lineHeight: 1.6, marginBottom: 14, padding: '12px 14px', background: 'var(--surface)', borderRadius: 8 }}>
                    {p.description}
                  </p>
                )}

                {/* Files */}
                <div style={{ display: 'flex', gap: 8, marginBottom: 14, flexWrap: 'wrap' }}>
                  {p.pdf_url && <a href={p.pdf_url} target="_blank" rel="noopener noreferrer" className="btn btn-secondary btn-sm" style={{ textDecoration: 'none' }}><FileText size={14} /> View PDF</a>}
                  {p.zip_url && <a href={p.zip_url} target="_blank" rel="noopener noreferrer" className="btn btn-secondary btn-sm" style={{ textDecoration: 'none' }}><Archive size={14} /> Source Code</a>}
                  {p.github_link && <a href={p.github_link} target="_blank" rel="noopener noreferrer" className="btn btn-secondary btn-sm" style={{ textDecoration: 'none' }}><GitBranch size={14} /> GitHub</a>}
                  {p.download_count !== undefined && (
                    <span style={{ display: 'flex', alignItems: 'center', gap: 5, fontSize: 13, color: 'var(--muted)', padding: '8px 12px' }}>
                      <Download size={13} /> {p.download_count} downloads
                    </span>
                  )}
                </div>

                {/* Actions */}
                <div style={{ display: 'flex', gap: 10, flexWrap: 'wrap', alignItems: 'center', paddingTop: 14, borderTop: '1px solid var(--border)' }}>
                  {status === 'pending' && (
                    <>
                      <button onClick={() => handleApprove(p.id)} className="btn btn-primary btn-sm">
                        <CheckCircle size={15} /> Approve
                      </button>
                      <button onClick={() => handleReject(p.id)} className="btn btn-danger btn-sm">
                        <XCircle size={15} /> Reject
                      </button>
                    </>
                  )}
                  {status === 'approved' && (
                    <button onClick={() => handleReject(p.id)} className="btn btn-secondary btn-sm">
                      <XCircle size={15} /> Revoke Approval
                    </button>
                  )}
                  {status === 'rejected' && (
                    <button onClick={() => handleApprove(p.id)} className="btn btn-secondary btn-sm">
                      <CheckCircle size={15} /> Re-approve
                    </button>
                  )}

                  {/* Grade */}
                  <div style={{ marginLeft: 'auto', display: 'flex', alignItems: 'center', gap: 8 }}>
                    <span style={{ fontSize: 13, color: 'var(--muted)', fontWeight: 500 }}>Grade:</span>
                    <div style={{ display: 'flex', gap: 4 }}>
                      {GRADES.map(g => (
                        <button key={g} onClick={() => handleGrade(p.id, g)}
                          style={{
                            width: 32, height: 32, borderRadius: 8, cursor: 'pointer',
                            border: `1.5px solid ${currentGrade === g ? 'var(--accent)' : 'var(--border)'}`,
                            background: currentGrade === g ? 'var(--accent)' : 'var(--surface)',
                            color: currentGrade === g ? '#fff' : 'var(--muted)',
                            fontSize: 13, fontWeight: 700, fontFamily: 'JetBrains Mono',
                            transition: 'all 0.15s',
                          }}>
                          {g}
                        </button>
                      ))}
                    </div>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      )}
    </Layout>
  );
}
