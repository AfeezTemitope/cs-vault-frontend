import { LucideIcon } from 'lucide-react';
export default function EmptyState({ icon: Icon, title, subtitle }: {
  icon: LucideIcon; title: string; subtitle: string;
}) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '72px 20px', textAlign: 'center' }}>
      <div style={{ width: 72, height: 72, borderRadius: 20, background: 'var(--accent-light)', display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 20 }}>
        <Icon size={32} style={{ color: 'var(--accent)' }} />
      </div>
      <h3 style={{ fontSize: 19, fontWeight: 700, color: 'var(--soft)', marginBottom: 8 }}>{title}</h3>
      <p style={{ fontSize: 15, color: 'var(--muted)', maxWidth: 340, lineHeight: 1.65 }}>{subtitle}</p>
    </div>
  );
}
