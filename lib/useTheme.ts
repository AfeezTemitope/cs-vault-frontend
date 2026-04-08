'use client';
import { useEffect, useState } from 'react';

export function useTheme() {
  const [theme, setTheme] = useState<'light' | 'dark'>('light');

  useEffect(() => {
    const saved = localStorage.getItem('cv-theme') as 'light' | 'dark' | null;
    const preferred = saved ?? 'light';
    setTheme(preferred);
    document.documentElement.setAttribute('data-theme', preferred);
  }, []);

  const toggle = () => {
    const next = theme === 'light' ? 'dark' : 'light';
    setTheme(next);
    localStorage.setItem('cv-theme', next);
    document.documentElement.setAttribute('data-theme', next);
  };

  return { theme, toggle };
}
