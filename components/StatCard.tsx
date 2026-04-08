import { LucideIcon } from 'lucide-react';
export default function StatCard({ label, value, icon: Icon, color = 'blue' }: {
  label: string; value: string | number; icon: LucideIcon; color?: 'blue' | 'green' | 'orange' | 'red';
}) {
  const colors = {
    blue: { bg: 'var(--accent-light)', icon: 'var(--accent)' },
    green: { bg: '#ECFDF5', icon: '#16A34A' },
    orange: { bg: '#FFF7ED', icon: '#D97706' },
    red: { bg: '#FEF2F2', icon: '#DC2626' },
  };
  const c = colors[color];
  return (
    <div className="card" style={{ padding: '20px 24px', display: 'flex', alignItems: 'center', gap: 16 }}>
      <div style={{ width: 48, height: 48, borderRadius: 12, backgroundColor: c.bg, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
        <Icon size={22} style={{ color: c.icon }} />
      </div>
      <div>
        <p style={{ fontSize: 28, fontWeight: 800, color: 'var(--soft)', lineHeight: 1 }}>{value}</p>
        <p style={{ fontSize: 14, color: 'var(--muted)', marginTop: 4, fontWeight: 500 }}>{label}</p>
      </div>
    </div>
  );
}
