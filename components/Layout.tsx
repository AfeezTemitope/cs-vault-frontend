'use client';
import { useState, useEffect } from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { getUser, logout, User } from '@/lib/auth';
import {
  LayoutDashboard, BookOpen, Upload, Search,
  Users, GraduationCap, LogOut, Menu, X, Settings, FolderOpen
} from 'lucide-react';

const navItems: Record<string, { href: string; label: string; icon: React.ElementType }[]> = {
  admin: [
    { href: '/admin', label: 'Dashboard', icon: LayoutDashboard },
    { href: '/admin/lecturers', label: 'Lecturers', icon: GraduationCap },
    { href: '/admin/courses', label: 'Courses', icon: BookOpen },
    { href: '/admin/students', label: 'Students', icon: Users },
  ],
  lecturer: [
    { href: '/lecturer', label: 'Dashboard', icon: LayoutDashboard },
    // { href: '/lecturer/courses', label: 'My Courses', icon: BookOpen },
    { href: '/lecturer/projects', label: 'All Projects', icon: FolderOpen },
    { href: '/lecturer/students/register', label: 'Register', icon: Users },
  ],
  student: [
    { href: '/student', label: 'Dashboard', icon: LayoutDashboard },
    { href: '/student/projects', label: 'Browse', icon: Search },
    { href: '/student/upload', label: 'Upload', icon: Upload },
  ],
};

export default function Layout({ children }: { children: React.ReactNode }) {
  const [open, setOpen] = useState(false);
  const [user, setUser] = useState<User | null>(null);
  const [mounted, setMounted] = useState(false);
  const pathname = usePathname();

  // Only read cookies on the client — fixes hydration mismatch
  useEffect(() => {
    setUser(getUser());
    setMounted(true);
  }, []);

  const items = navItems[user?.role ?? ''] ?? [];
  const displayName = user?.name ?? user?.full_name ?? '';

  // Render a minimal shell on server to avoid mismatch
  if (!mounted) {
    return (
      <div className="min-h-screen flex flex-col" style={{ backgroundColor: 'var(--ink)' }}>
        <header className="sticky top-0 z-50 flex items-center px-4 h-14 border-b"
          style={{ backgroundColor: 'var(--surface)', borderColor: 'var(--border)' }}>
          <span className="mono font-medium tracking-tight text-sm" style={{ color: 'var(--accent)' }}>CS-VAULT</span>
        </header>
        <main className="flex-1 p-4 md:p-8 max-w-4xl w-full mx-auto">{children}</main>
      </div>
    );
  }

  return (
    <div className="min-h-screen flex flex-col" style={{ backgroundColor: 'var(--ink)' }}>
      {/* Header */}
      <header className="sticky top-0 z-50 flex items-center justify-between px-4 h-14 border-b"
        style={{ backgroundColor: 'var(--surface)', borderColor: 'var(--border)' }}>
        <div className="flex items-center gap-3">
          <button onClick={() => setOpen(!open)} className="md:hidden" style={{ color: 'var(--muted)' }}>
            {open ? <X size={20} /> : <Menu size={20} />}
          </button>
          <span className="mono font-medium tracking-tight text-sm" style={{ color: 'var(--accent)' }}>CS-VAULT</span>
        </div>
        <div className="flex items-center gap-3">
          <span className="text-xs hidden sm:block" style={{ color: 'var(--muted)' }}>{displayName}</span>
          <span className="mono text-xs px-2 py-0.5 rounded uppercase"
            style={{ backgroundColor: 'var(--border)', color: 'var(--accent)' }}>{user?.role}</span>
          <button onClick={logout} style={{ color: 'var(--muted)' }}><LogOut size={16} /></button>
        </div>
      </header>

      <div className="flex flex-1">
        {/* Sidebar desktop */}
        <aside className="hidden md:flex flex-col w-56 py-6 px-3 gap-1 sticky top-14 h-[calc(100vh-3.5rem)] border-r"
          style={{ backgroundColor: 'var(--surface)', borderColor: 'var(--border)' }}>
          {items.map(({ href, label, icon: Icon }) => {
            const active = pathname === href;
            return (
              <Link key={href} href={href}
                className="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm transition-all"
                style={active
                  ? { backgroundColor: 'var(--accent)', color: 'var(--ink)', fontWeight: 600 }
                  : { color: 'var(--muted)' }}>
                <Icon size={16} />{label}
              </Link>
            );
          })}
          <div className="mt-auto">
            <Link href="/profile"
              className="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm transition-all"
              style={pathname === '/profile'
                ? { backgroundColor: 'var(--accent)', color: 'var(--ink)', fontWeight: 600 }
                : { color: 'var(--muted)' }}>
              <Settings size={16} />Profile
            </Link>
          </div>
        </aside>

        {/* Mobile drawer */}
        {open && (
          <div className="fixed inset-0 z-40 md:hidden" onClick={() => setOpen(false)}>
            <div className="absolute inset-0" style={{ backgroundColor: 'rgba(0,0,0,0.6)' }} />
            <aside className="absolute top-14 left-0 bottom-0 w-64 flex flex-col py-6 px-3 gap-1 border-r"
              style={{ backgroundColor: 'var(--surface)', borderColor: 'var(--border)' }}
              onClick={e => e.stopPropagation()}>
              {items.map(({ href, label, icon: Icon }) => {
                const active = pathname === href;
                return (
                  <Link key={href} href={href} onClick={() => setOpen(false)}
                    className="flex items-center gap-3 px-3 py-3 rounded-lg text-sm transition-all"
                    style={active
                      ? { backgroundColor: 'var(--accent)', color: 'var(--ink)', fontWeight: 600 }
                      : { color: 'var(--muted)' }}>
                    <Icon size={16} />{label}
                  </Link>
                );
              })}
              <div className="mt-auto">
                <Link href="/profile" onClick={() => setOpen(false)}
                  className="flex items-center gap-3 px-3 py-3 rounded-lg text-sm"
                  style={{ color: 'var(--muted)' }}>
                  <Settings size={16} />Profile
                </Link>
              </div>
            </aside>
          </div>
        )}

        {/* Main */}
        <main className="flex-1 p-4 md:p-8 max-w-4xl w-full mx-auto pb-24 md:pb-8">
          {children}
        </main>
      </div>

      {/* Bottom nav mobile */}
      <nav className="md:hidden fixed bottom-0 left-0 right-0 flex justify-around py-2 z-30 border-t"
        style={{ backgroundColor: 'var(--surface)', borderColor: 'var(--border)' }}>
        {items.map(({ href, label, icon: Icon }) => (
          <Link key={href} href={href}
            className="flex flex-col items-center gap-0.5 px-3 py-1"
            style={{ color: pathname === href ? 'var(--accent)' : 'var(--muted)' }}>
            <Icon size={20} />
            <span style={{ fontSize: 10 }}>{label}</span>
          </Link>
        ))}
      </nav>
    </div>
  );
}