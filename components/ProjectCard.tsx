import Link from 'next/link';
import { FileText, GitBranch, Archive, Calendar, Award } from 'lucide-react';
import { format } from 'date-fns';

const gradeConfig: Record<string, { bg: string; color: string }> = {
  A: { bg: '#ECFDF5', color: '#059669' },
  B: { bg: 'var(--accent-light)', color: 'var(--accent)' },
  C: { bg: '#FFF7ED', color: '#D97706' },
  D: { bg: '#FFFBEB', color: '#B45309' },
  E: { bg: '#FEF2F2', color: '#DC2626' },
  F: { bg: '#FEF2F2', color: '#991B1B' },
};

interface Project {
  id: string; title: string; description?: string; session?: string;
  pdf_url?: string; zip_url?: string; github_link?: string; created_at?: string;
  grades?: { grade: string } | { grade: string }[];
  courses?: { title: string; course_code: string };
  users?: { full_name: string; matric_number: string };
}

export default function ProjectCard({ project, href }: { project: Project; href?: string }) {
  const grade = Array.isArray(project.grades) ? project.grades[0]?.grade : project.grades?.grade;
  const gc = grade ? gradeConfig[grade] : null;

  return (
    <Link href={href ?? `/student/projects/${project.id}`} style={{ textDecoration: 'none', display: 'block' }}>
      <div className="card card-hover" style={{ padding: '20px 22px', cursor: 'pointer' }}>
        <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: 12, marginBottom: 10 }}>
          <h3 style={{ fontSize: 16, fontWeight: 700, color: 'var(--soft)', lineHeight: 1.4 }}>{project.title}</h3>
          {gc && (
            <div style={{ display: 'flex', alignItems: 'center', gap: 4, padding: '4px 10px', borderRadius: 99, background: gc.bg, flexShrink: 0 }}>
              <Award size={12} style={{ color: gc.color }} />
              <span style={{ fontSize: 13, fontWeight: 700, color: gc.color }}>{grade}</span>
            </div>
          )}
        </div>
        {project.description && (
          <p style={{ fontSize: 14, color: 'var(--muted)', marginBottom: 14, lineHeight: 1.65, display: '-webkit-box', WebkitLineClamp: 2, WebkitBoxOrient: 'vertical', overflow: 'hidden' }}>
            {project.description}
          </p>
        )}
        <div style={{ display: 'flex', alignItems: 'center', gap: 10, flexWrap: 'wrap' }}>
          {project.courses?.course_code && (
            <span className="badge badge-purple">{project.courses.course_code}</span>
          )}
          {project.pdf_url && <FileText size={14} style={{ color: 'var(--muted)' }} />}
          {project.zip_url && <Archive size={14} style={{ color: 'var(--muted)' }} />}
          {project.github_link && <GitBranch size={14} style={{ color: 'var(--muted)' }} />}
          {project.created_at && (
            <span style={{ marginLeft: 'auto', display: 'flex', alignItems: 'center', gap: 5, fontSize: 13, color: 'var(--muted)' }}>
              <Calendar size={13} />{format(new Date(project.created_at), 'dd MMM yyyy')}
            </span>
          )}
        </div>
        {project.users && (
          <p className="mono" style={{ fontSize: 12, color: 'var(--muted)', marginTop: 12, paddingTop: 12, borderTop: '1px solid var(--border)' }}>
            {project.users.matric_number} · {project.users.full_name}
          </p>
        )}
      </div>
    </Link>
  );
}
