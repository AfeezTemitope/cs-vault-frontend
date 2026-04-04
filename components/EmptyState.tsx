import { LucideIcon } from 'lucide-react';
export default function EmptyState({ icon: Icon, title, subtitle }: {
  icon: LucideIcon; title: string; subtitle: string;
}) {
  return (
    <div className="flex flex-col items-center justify-center py-16 text-center">
      <div className="w-14 h-14 rounded-full flex items-center justify-center mb-4"
        style={{ backgroundColor: 'var(--border)' }}>
        <Icon size={24} style={{ color: 'var(--muted)' }} />
      </div>
      <h3 className="font-semibold mb-1" style={{ color: 'var(--soft)' }}>{title}</h3>
      <p className="text-sm max-w-xs" style={{ color: 'var(--muted)' }}>{subtitle}</p>
    </div>
  );
}
