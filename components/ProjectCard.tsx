import Link from 'next/link';
import { FileText, GitBranch, Archive, Calendar } from 'lucide-react';
import { format } from 'date-fns';

const gradeColors: Record<string, string> = {
  A: '#4ade80', B: '#C8F135', C: '#60a5fa', D: '#facc15', E: '#fb923c', F: '#f87171',
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
  const link = href ?? `/student/projects/${project.id}`;
  return (
    <Link href={link} className="block rounded-xl p-4 border transition-all group"
      style={{ backgroundColor: 'var(--card)', borderColor: 'var(--border)' }}
      onMouseEnter={e => (e.currentTarget.style.borderColor = 'rgba(200,241,53,0.4)')}
      onMouseLeave={e => (e.currentTarget.style.borderColor = 'var(--border)')}>
      <div className="flex items-start justify-between gap-2 mb-2">
        <h3 className="font-semibold text-sm leading-snug line-clamp-2 transition-colors"
          style={{ color: 'var(--soft)' }}>{project.title}</h3>
        {grade && (
          <span className="mono text-xs font-bold px-2 py-0.5 rounded flex-shrink-0"
            style={{ color: gradeColors[grade] ?? 'var(--muted)', backgroundColor: `${gradeColors[grade] ?? '#888'}18` }}>
            {grade}
          </span>
        )}
      </div>
      {project.description && (
        <p className="text-xs line-clamp-2 mb-3" style={{ color: 'var(--muted)' }}>{project.description}</p>
      )}
      <div className="flex items-center gap-3 flex-wrap">
        {project.courses?.course_code && (
          <span className="mono text-xs px-2 py-0.5 rounded" style={{ backgroundColor: 'var(--border)', color: 'var(--muted)' }}>
            {project.courses.course_code}
          </span>
        )}
        {project.pdf_url && <FileText size={13} style={{ color: 'var(--muted)' }} />}
        {project.zip_url && <Archive size={13} style={{ color: 'var(--muted)' }} />}
        {project.github_link && <GitBranch size={13} style={{ color: 'var(--muted)' }} />}
        {project.created_at && (
          <span className="text-xs ml-auto flex items-center gap-1" style={{ color: 'var(--muted)' }}>
            <Calendar size={11} />{format(new Date(project.created_at), 'dd MMM yyyy')}
          </span>
        )}
      </div>
      {project.users && (
        <p className="mono text-xs mt-2" style={{ color: 'var(--muted)' }}>
          {project.users.matric_number} · {project.users.full_name}
        </p>
      )}
    </Link>
  );
}