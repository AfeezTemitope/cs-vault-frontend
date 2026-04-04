export default function PageHeader({ title, subtitle, action }: {
  title: string; subtitle?: string; action?: React.ReactNode;
}) {
  return (
    <div className="flex items-start justify-between mb-6 gap-4">
      <div>
        <h1 className="text-xl font-bold" style={{ color: 'var(--soft)' }}>{title}</h1>
        {subtitle && <p className="text-sm mt-0.5" style={{ color: 'var(--muted)' }}>{subtitle}</p>}
      </div>
      {action && <div className="flex-shrink-0">{action}</div>}
    </div>
  );
}
