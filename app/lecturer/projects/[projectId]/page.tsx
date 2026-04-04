'use client';
import { useEffect, useState } from 'react';
import { useRouter, useParams } from 'next/navigation';
import { getUser, requireAuth } from '@/lib/auth';
import Layout from '@/components/Layout';
import PageHeader from '@/components/PageHeader';
import api from '@/lib/api';
import toast from 'react-hot-toast';
import { FileText, Archive, GitBranch, Send, ExternalLink } from 'lucide-react';
import { format } from 'date-fns';

const GRADES = ['A','B','C','D','E','F'];
const gradeColors: Record<string, React.CSSProperties> = {
  A: { color:'#4ade80', backgroundColor:'rgba(74,222,128,0.1)', borderColor:'rgba(74,222,128,0.3)' },
  B: { color:'var(--accent)', backgroundColor:'rgba(200,241,53,0.1)', borderColor:'rgba(200,241,53,0.3)' },
  C: { color:'#60a5fa', backgroundColor:'rgba(96,165,250,0.1)', borderColor:'rgba(96,165,250,0.3)' },
  D: { color:'#facc15', backgroundColor:'rgba(250,204,21,0.1)', borderColor:'rgba(250,204,21,0.3)' },
  E: { color:'#fb923c', backgroundColor:'rgba(251,146,60,0.1)', borderColor:'rgba(251,146,60,0.3)' },
  F: { color:'#f87171', backgroundColor:'rgba(248,113,113,0.1)', borderColor:'rgba(248,113,113,0.3)' },
};

interface Comment {
  id: string; content: string; created_at: string;
  users?: { full_name: string; role: string };
}

interface Project {
  title: string; description?: string; session: string;
  pdf_url?: string; zip_url?: string; github_link?: string; created_at?: string;
  courses?: { course_code: string };
  users?: { full_name: string; matric_number: string };
  grades?: { grade: string };
  comments?: Comment[];
}

export default function LecturerProjectDetail() {
  const router = useRouter();
  const { projectId } = useParams<{ projectId: string }>();
  const [project, setProject] = useState<Project | null>(null);
  const [comment, setComment] = useState('');
  const [grade, setGrade] = useState('');

  useEffect(() => {
    if (!requireAuth(getUser(), router, ['lecturer', 'admin'])) return;
    load();
  }, [projectId, router]);

  const load = () => api.get(`/projects/${projectId}`)
    .then(r => { setProject(r.data); setGrade(r.data.grades?.grade ?? ''); })
    .catch(() => { toast.error('Not found'); router.back(); });

  const saveGrade = () => api.put(`/lecturer/projects/${projectId}/grade`, { grade })
    .then(() => { toast.success('Grade saved'); load(); })
    .catch(() => toast.error('Failed'));

  const postComment = async () => {
    if (!comment.trim()) return;
    try {
      await api.post(`/projects/${projectId}/comments`, { content: comment });
      setComment(''); load();
    } catch { toast.error('Failed'); }
  };

  if (!project) return <Layout><p className="text-sm" style={{ color: 'var(--muted)' }}>Loading...</p></Layout>;

  const card = 'rounded-xl p-4 border';
  const cardStyle = { backgroundColor: 'var(--card)', borderColor: 'var(--border)' };
  const linkStyle = { backgroundColor: 'var(--surface)', borderColor: 'var(--border)', color: 'var(--soft)' };

  return (
    <Layout>
      <button onClick={() => router.back()} className="text-xs mb-4 flex items-center gap-1" style={{ color: 'var(--muted)' }}>← Back</button>
      <PageHeader title={project.title} subtitle={`${project.courses?.course_code} · ${project.session}`} />

      <div className="space-y-4">
        {/* Student info */}
        <div className={card} style={cardStyle}>
          <p className="text-xs mb-1" style={{ color: 'var(--muted)' }}>Submitted by</p>
          <p className="font-semibold" style={{ color: 'var(--soft)' }}>{project.users?.full_name}</p>
          <p className="mono text-xs" style={{ color: 'var(--accent)' }}>{project.users?.matric_number}</p>
          {project.created_at && (
            <p className="text-xs mt-1" style={{ color: 'var(--muted)' }}>
              {format(new Date(project.created_at), 'dd MMM yyyy · HH:mm')}
            </p>
          )}
        </div>

        {/* Description */}
        {project.description && (
          <div className={card} style={cardStyle}>
            <p className="text-xs mb-2" style={{ color: 'var(--muted)' }}>Description</p>
            <p className="text-sm leading-relaxed" style={{ color: 'var(--soft)' }}>{project.description}</p>
          </div>
        )}

        {/* Files */}
        <div className={card} style={cardStyle}>
          <p className="text-xs mb-3" style={{ color: 'var(--muted)' }}>Files & Links</p>
          <div className="flex flex-wrap gap-2">
            {project.pdf_url && (
              <a href={project.pdf_url} target="_blank" rel="noopener noreferrer"
                className="flex items-center gap-2 px-3 py-2 rounded-lg text-sm border transition-all" style={linkStyle}>
                <FileText size={14} style={{ color: 'var(--accent)' }} /> PDF <ExternalLink size={12} style={{ color: 'var(--muted)' }} />
              </a>
            )}
            {project.zip_url && (
              <a href={project.zip_url} target="_blank" rel="noopener noreferrer"
                className="flex items-center gap-2 px-3 py-2 rounded-lg text-sm border transition-all" style={linkStyle}>
                <Archive size={14} style={{ color: 'var(--accent)' }} /> ZIP <ExternalLink size={12} style={{ color: 'var(--muted)' }} />
              </a>
            )}
            {project.github_link && (
              <a href={project.github_link} target="_blank" rel="noopener noreferrer"
                className="flex items-center gap-2 px-3 py-2 rounded-lg text-sm border transition-all" style={linkStyle}>
                <GitBranch size={14} style={{ color: 'var(--accent)' }} /> GitHub <ExternalLink size={12} style={{ color: 'var(--muted)' }} />
              </a>
            )}
          </div>
        </div>

        {/* Grade */}
        <div className={card} style={cardStyle}>
          <p className="text-xs mb-3" style={{ color: 'var(--muted)' }}>Grade</p>
          <div className="flex gap-2 flex-wrap mb-3">
            {GRADES.map(g => (
              <button key={g} onClick={() => setGrade(g)}
                className="w-10 h-10 rounded-lg border mono font-bold text-sm transition-all"
                style={grade === g ? gradeColors[g] : { backgroundColor: 'var(--surface)', borderColor: 'var(--border)', color: 'var(--muted)' }}>
                {g}
              </button>
            ))}
          </div>
          <button onClick={saveGrade} disabled={!grade}
            className="px-4 py-2 rounded-lg text-sm font-semibold disabled:opacity-40"
            style={{ backgroundColor: 'var(--accent)', color: 'var(--ink)' }}>
            Save Grade
          </button>
        </div>

        {/* Comments */}
        <div className={card} style={cardStyle}>
          <p className="text-xs mb-3" style={{ color: 'var(--muted)' }}>Comments ({project.comments?.length ?? 0})</p>
          <div className="space-y-3 mb-4 max-h-64 overflow-y-auto">
            {project.comments?.map(c => (
              <div key={c.id} className="rounded-lg p-3 border" style={{ backgroundColor: 'var(--surface)', borderColor: 'var(--border)' }}>
                <div className="flex items-center gap-2 mb-1">
                  <span className="text-xs font-semibold" style={{ color: 'var(--soft)' }}>{c.users?.full_name}</span>
                  <span className="mono text-xs px-1.5 py-0.5 rounded"
                    style={c.users?.role === 'lecturer'
                      ? { backgroundColor: 'rgba(200,241,53,0.1)', color: 'var(--accent)' }
                      : { backgroundColor: 'var(--border)', color: 'var(--muted)' }}>
                    {c.users?.role}
                  </span>
                </div>
                <p className="text-sm" style={{ color: 'var(--soft)' }}>{c.content}</p>
                {c.created_at && (
                  <p className="text-xs mt-1" style={{ color: 'var(--muted)' }}>
                    {format(new Date(c.created_at), 'dd MMM · HH:mm')}
                  </p>
                )}
              </div>
            ))}
          </div>
          <div className="flex gap-2">
            <input
              className="flex-1 rounded-lg px-4 py-2.5 text-sm border focus:outline-none"
              style={{ backgroundColor: 'var(--surface)', borderColor: 'var(--border)', color: 'var(--soft)' }}
              placeholder="Leave a comment..." value={comment}
              onChange={e => setComment(e.target.value)}
              onKeyDown={e => e.key === 'Enter' && postComment()}
              onFocus={e => (e.target.style.borderColor = 'var(--accent)')}
              onBlur={e => (e.target.style.borderColor = 'var(--border)')} />
            <button onClick={postComment} disabled={!comment.trim()}
              className="p-2.5 rounded-lg disabled:opacity-40"
              style={{ backgroundColor: 'var(--accent)', color: 'var(--ink)' }}>
              <Send size={16} />
            </button>
          </div>
        </div>
      </div>
    </Layout>
  );
}