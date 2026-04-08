'use client';
import { Sun, Moon } from 'lucide-react';
import { useTheme } from '@/lib/useTheme';

export default function ThemeToggle({ size = 'md' }: { size?: 'sm' | 'md' }) {
  const { theme, toggle, mounted } = useTheme();
  if (!mounted) return <div style={{ width: size === 'sm' ? 32 : 38, height: size === 'sm' ? 32 : 38 }} />;
  return (
    <button onClick={toggle} aria-label="Toggle theme" className="btn-ghost"
      style={{ width: size === 'sm' ? 32 : 38, height: size === 'sm' ? 32 : 38, padding: 0, borderRadius: 10, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
      {theme === 'light' ? <Moon size={size === 'sm' ? 16 : 18} /> : <Sun size={size === 'sm' ? 16 : 18} />}
    </button>
  );
}
