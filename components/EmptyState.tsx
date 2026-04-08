import { LucideIcon } from 'lucide-react';
export default function EmptyState({ icon: Icon, title, subtitle }: {
  icon: LucideIcon; title: string; subtitle: string;
}) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '64px 20px', textAlign: 'center' }}>
      <div style={{ width: 64, height: 64, borderRadius: 16, backgroundColor: 'var(--accent-light)', display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 20 }}>
        <Icon size={28} style={{ color: 'var(--accent)' }} />
      </div>
      <h3 style={{ fontSize: 18, fontWeight: 700, color: 'var(--soft)', marginBottom: 8 }}>{title}</h3>
      <p style={{ fontSize: 15, color: 'var(--muted)', maxWidth: 320, lineHeight: 1.6 }}>{subtitle}</p>
    </div>
  );
}
