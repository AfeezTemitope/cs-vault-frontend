import { LucideIcon } from 'lucide-react';
export default function StatCard({ label, value, icon: Icon, color = 'purple' }: {
  label: string; value: string | number; icon: LucideIcon; color?: 'purple' | 'green' | 'orange' | 'red';
}) {
  const colors = {
    purple: { bg: 'var(--accent-light)', icon: 'var(--accent)' },
    green:  { bg: '#ECFDF5', icon: '#059669' },
    orange: { bg: '#FFF7ED', icon: '#D97706' },
    red:    { bg: '#FEF2F2', icon: '#DC2626' },
  };
  const c = colors[color];
  return (
    <div className="card" style={{ padding: '22px 24px', display: 'flex', alignItems: 'center', gap: 18 }}>
      <div style={{ width: 52, height: 52, borderRadius: 14, background: c.bg, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
        <Icon size={24} style={{ color: c.icon }} />
      </div>
      <div>
        <p style={{ fontSize: 30, fontWeight: 800, color: 'var(--soft)', lineHeight: 1 }}>{value}</p>
        <p style={{ fontSize: 14, color: 'var(--muted)', marginTop: 5, fontWeight: 500 }}>{label}</p>
      </div>
    </div>
  );
}
