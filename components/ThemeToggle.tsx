'use client';
import { Sun, Moon } from 'lucide-react';
import { useTheme } from '@/lib/useTheme';

export default function ThemeToggle() {
  const { theme, toggle } = useTheme();
  return (
    <button onClick={toggle} aria-label="Toggle theme"
      style={{
        width: 38, height: 38, borderRadius: 10,
        border: '1.5px solid var(--border)',
        background: 'var(--surface)',
        color: 'var(--muted)',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        cursor: 'pointer', transition: 'all 0.2s ease',
      }}
      onMouseEnter={e => {
        (e.currentTarget as HTMLButtonElement).style.borderColor = 'var(--accent)';
        (e.currentTarget as HTMLButtonElement).style.color = 'var(--accent)';
      }}
      onMouseLeave={e => {
        (e.currentTarget as HTMLButtonElement).style.borderColor = 'var(--border)';
        (e.currentTarget as HTMLButtonElement).style.color = 'var(--muted)';
      }}>
      {theme === 'light' ? <Moon size={17} /> : <Sun size={17} />}
    </button>
  );
}
