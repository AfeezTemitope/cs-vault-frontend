export default function PageHeader({ title, subtitle, action }: {
  title: string; subtitle?: string; action?: React.ReactNode;
}) {
  return (
    <div style={{
      display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between',
      marginBottom: 28, gap: 12, flexWrap: 'wrap',
    }}>
      <div style={{ flex: 1, minWidth: 0 }}>
        <h1 style={{ fontSize: 26, fontWeight: 800, color: 'var(--soft)', letterSpacing: '-0.4px', lineHeight: 1.2 }}>{title}</h1>
        {subtitle && <p style={{ fontSize: 15, color: 'var(--muted)', marginTop: 5 }}>{subtitle}</p>}
      </div>
      {action && (
        <div style={{ flexShrink: 0, marginTop: 2 }}>{action}</div>
      )}
    </div>
  );
}
