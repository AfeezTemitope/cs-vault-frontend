import { LucideIcon } from 'lucide-react';
export default function StatCard({ label, value, icon: Icon, accent }: {
  label: string; value: string | number; icon: LucideIcon; accent?: boolean;
}) {
  return (
    <div className="rounded-xl p-4 flex items-center gap-4 border"
      style={{ backgroundColor: 'var(--card)', borderColor: accent ? 'rgba(200,241,53,0.3)' : 'var(--border)' }}>
      <div className="w-10 h-10 rounded-lg flex items-center justify-center flex-shrink-0"
        style={{ backgroundColor: accent ? 'rgba(200,241,53,0.1)' : 'var(--border)', color: accent ? 'var(--accent)' : 'var(--muted)' }}>
        <Icon size={18} />
      </div>
      <div>
        <p className="text-2xl font-bold" style={{ color: 'var(--soft)' }}>{value}</p>
        <p className="text-xs" style={{ color: 'var(--muted)' }}>{label}</p>
      </div>
    </div>
  );
}
