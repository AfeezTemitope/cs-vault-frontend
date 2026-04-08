export default function PageHeader({ title, subtitle, action }: {
  title: string; subtitle?: string; action?: React.ReactNode;
}) {
  return (
    <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', marginBottom: 28, gap: 16 }}>
      <div>
        <h1 style={{ fontSize: 26, fontWeight: 800, color: 'var(--soft)', letterSpacing: '-0.4px' }}>{title}</h1>
        {subtitle && <p style={{ fontSize: 15, color: 'var(--muted)', marginTop: 4 }}>{subtitle}</p>}
      </div>
      {action && <div style={{ flexShrink: 0 }}>{action}</div>}
    </div>
  );
}
