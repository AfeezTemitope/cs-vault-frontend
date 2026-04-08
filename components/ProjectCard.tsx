import Link from 'next/link';
import { FileText, GitBranch, Archive, Calendar, Award } from 'lucide-react';
import { format } from 'date-fns';

const gradeConfig: Record<string, { bg: string; color: string; label: string }> = {
  A: { bg: '#ECFDF5', color: '#16A34A', label: 'A' },
  B: { bg: '#EEF3FD', color: '#2D6BE4', label: 'B' },
  C: { bg: '#FFF7ED', color: '#D97706', label: 'C' },
  D: { bg: '#FFFBEB', color: '#B45309', label: 'D' },
  E: { bg: '#FEF2F2', color: '#DC2626', label: 'E' },
  F: { bg: '#FEF2F2', color: '#991B1B', label: 'F' },
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
  const link = href ?? `/student/projects/${project.id}`;

  return (
    <Link href={link} style={{ textDecoration: 'none', display: 'block' }}>
      <div className="card" style={{ padding: '20px 22px', cursor: 'pointer' }}
        onMouseEnter={e => { (e.currentTarget as HTMLDivElement).style.borderColor = 'var(--accent)'; (e.currentTarget as HTMLDivElement).style.transform = 'translateY(-2px)'; }}
        onMouseLeave={e => { (e.currentTarget as HTMLDivElement).style.borderColor = 'var(--border)'; (e.currentTarget as HTMLDivElement).style.transform = 'translateY(0)'; }}>
        <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: 12, marginBottom: 10 }}>
          <h3 style={{ fontSize: 16, fontWeight: 700, color: 'var(--soft)', lineHeight: 1.4 }}>{project.title}</h3>
          {gc && (
            <div style={{ display: 'flex', alignItems: 'center', gap: 4, padding: '4px 10px', borderRadius: 20, backgroundColor: gc.bg, flexShrink: 0 }}>
              <Award size={12} style={{ color: gc.color }} />
              <span style={{ fontSize: 13, fontWeight: 700, color: gc.color }}>{gc.label}</span>
            </div>
          )}
        </div>
        {project.description && (
          <p style={{ fontSize: 14, color: 'var(--muted)', marginBottom: 14, lineHeight: 1.6, display: '-webkit-box', WebkitLineClamp: 2, WebkitBoxOrient: 'vertical', overflow: 'hidden' }}>
            {project.description}
          </p>
        )}
        <div style={{ display: 'flex', alignItems: 'center', gap: 10, flexWrap: 'wrap' }}>
          {project.courses?.course_code && (
            <span className="badge badge-blue">{project.courses.course_code}</span>
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
          <p className="mono" style={{ fontSize: 12, color: 'var(--muted)', marginTop: 10, paddingTop: 10, borderTop: '1px solid var(--border)' }}>
            {project.users.matric_number} · {project.users.full_name}
          </p>
        )}
      </div>
    </Link>
  );
}
