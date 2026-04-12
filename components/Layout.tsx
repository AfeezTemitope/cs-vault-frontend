'use client';
import { useState, useEffect } from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { getUser, logout, User } from '@/lib/auth';
import ThemeToggle from './ThemeToggle';
import {
  LayoutDashboard, BookOpen, Upload, Search,
  Users, GraduationCap, Menu, X,
  Settings, FolderOpen, UserPlus, LogOut, Library
} from 'lucide-react';

const navItems: Record<string, { href: string; label: string; icon: React.ElementType }[]> = {
  admin: [
    { href: '/admin', label: 'Dashboard', icon: LayoutDashboard },
    { href: '/admin/lecturers', label: 'Lecturers', icon: GraduationCap },
    { href: '/admin/courses', label: 'Courses', icon: BookOpen },
    { href: '/admin/students', label: 'Students', icon: Users },
    { href: '/vault', label: 'Repository', icon: Library },
  ],
  lecturer: [
    { href: '/lecturer', label: 'Dashboard', icon: LayoutDashboard },
    { href: '/lecturer/projects', label: 'Projects', icon: FolderOpen },
    { href: '/vault', label: 'Repository', icon: Library },
    { href: '/lecturer/students/register', label: 'Register Student', icon: UserPlus },
  ],
  student: [
    { href: '/student', label: 'Dashboard', icon: LayoutDashboard },
    { href: '/vault', label: 'Repository', icon: Library },
    { href: '/student/upload', label: 'Upload', icon: Upload },
  ],
};

export default function Layout({ children }: { children: React.ReactNode }) {
  const [open, setOpen] = useState(false);
  const [user, setUser] = useState<User | null>(null);
  const [mounted, setMounted] = useState(false);
  const pathname = usePathname();

  useEffect(() => { setUser(getUser()); setMounted(true); }, []);

  const items = navItems[user?.role ?? ''] ?? [];
  const name = user?.name ?? user?.full_name ?? '';

  if (!mounted) return (
    <div style={{ minHeight: '100vh', background: 'var(--ink)' }}>
      <div style={{ height: 66, background: 'var(--card)', borderBottom: '1.5px solid var(--border)' }} />
    </div>
  );

  const SideLink = ({ href, label, Icon, onClick }: {
    href: string; label: string; Icon: React.ElementType; onClick?: () => void;
  }) => {
    const active = pathname === href;
    return (
      <Link href={href} onClick={onClick} style={{
        display: 'flex', alignItems: 'center', gap: 12,
        padding: '11px 14px', borderRadius: 10, fontSize: 15,
        fontWeight: active ? 700 : 500, textDecoration: 'none',
        transition: 'all 0.15s ease',
        background: active ? 'var(--accent-light)' : 'transparent',
        color: active ? 'var(--accent)' : 'var(--muted)',
        borderLeft: `3px solid ${active ? 'var(--accent)' : 'transparent'}`,
      }}>
        <Icon size={18} />{label}
      </Link>
    );
  };

  const LogoutBtn = ({ onClick }: { onClick?: () => void }) => (
    <button onClick={() => { onClick?.(); logout(); }}
      style={{
        display: 'flex', alignItems: 'center', gap: 12,
        padding: '11px 14px', borderRadius: 10, fontSize: 15,
        fontWeight: 500, cursor: 'pointer', width: '100%',
        background: 'none', border: 'none', color: 'var(--muted)',
        borderLeft: '3px solid transparent', transition: 'all 0.15s',
        fontFamily: 'Plus Jakarta Sans, sans-serif',
      }}
      onMouseEnter={e => {
        (e.currentTarget as HTMLButtonElement).style.color = '#DC2626';
        (e.currentTarget as HTMLButtonElement).style.background = '#FEF2F2';
      }}
      onMouseLeave={e => {
        (e.currentTarget as HTMLButtonElement).style.color = 'var(--muted)';
        (e.currentTarget as HTMLButtonElement).style.background = 'none';
      }}>
      <LogOut size={18} /> Logout
    </button>
  );

  return (
    <div style={{ minHeight: '100vh', background: 'var(--ink)' }}>
      {/* Header */}
      <header style={{
        position: 'sticky', top: 0, zIndex: 50,
        background: 'var(--card)', borderBottom: '1.5px solid var(--border)',
        display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        padding: '0 20px', height: 66, boxShadow: 'var(--shadow-sm)',
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
          <button onClick={() => setOpen(!open)} className="mobile-only"
            style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--muted)', display: 'flex', padding: 6 }}>
            {open ? <X size={22} /> : <Menu size={22} />}
          </button>
          <Link href={`/${user?.role}`} style={{ display: 'flex', alignItems: 'center', gap: 10, textDecoration: 'none' }}>
            <div style={{ width: 34, height: 34, borderRadius: 10, background: 'var(--accent)', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
              <span style={{ color: '#fff', fontWeight: 800, fontSize: 14, fontFamily: 'JetBrains Mono' }}>CV</span>
            </div>
            <span style={{ fontWeight: 800, fontSize: 17, color: 'var(--soft)', letterSpacing: '-0.3px' }}>CS-Vault</span>
          </Link>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
          <span className="desktop-only" style={{ fontSize: 14, color: 'var(--muted)', fontWeight: 500 }}>{name}</span>
          <span className="badge badge-purple" style={{ fontSize: 11 }}>{user?.role}</span>
          <ThemeToggle size="sm" />
        </div>
      </header>

      <div style={{ display: 'flex' }}>
        {/* Desktop sidebar */}
        <aside className="sidebar-desktop" style={{
          flexDirection: 'column', width: 240,
          background: 'var(--card)', borderRight: '1.5px solid var(--border)',
          padding: '20px 12px', position: 'sticky', top: 66,
          height: 'calc(100vh - 66px)', gap: 3, overflowY: 'auto',
        }}>
          {items.map(({ href, label, icon: Icon }) => (
            <SideLink key={href} href={href} label={label} Icon={Icon} />
          ))}
          <div style={{ marginTop: 'auto', paddingTop: 12, borderTop: '1.5px solid var(--border)', display: 'flex', flexDirection: 'column', gap: 3 }}>
            <SideLink href="/profile" label="Profile" Icon={Settings} />
            <LogoutBtn />
          </div>
        </aside>

        {/* Mobile drawer */}
        {open && (
          <div style={{ position: 'fixed', inset: 0, zIndex: 40 }} onClick={() => setOpen(false)}>
            <div style={{ position: 'absolute', inset: 0, background: 'rgba(0,0,0,0.5)', backdropFilter: 'blur(2px)' }} />
            <aside style={{
              position: 'absolute', top: 66, left: 0, bottom: 0, width: 268,
              background: 'var(--card)', borderRight: '1.5px solid var(--border)',
              padding: '16px 12px', display: 'flex', flexDirection: 'column', gap: 3, overflowY: 'auto',
            }} onClick={e => e.stopPropagation()}>
              <div style={{ padding: '0 14px 16px', borderBottom: '1.5px solid var(--border)', marginBottom: 8 }}>
                <p style={{ fontSize: 16, fontWeight: 700, color: 'var(--soft)' }}>{name}</p>
                <p style={{ fontSize: 13, color: 'var(--muted)', marginTop: 2, textTransform: 'capitalize' }}>{user?.role}</p>
              </div>
              {items.map(({ href, label, icon: Icon }) => (
                <SideLink key={href} href={href} label={label} Icon={Icon} onClick={() => setOpen(false)} />
              ))}
              <div style={{ marginTop: 'auto', paddingTop: 12, borderTop: '1.5px solid var(--border)', display: 'flex', flexDirection: 'column', gap: 3 }}>
                <SideLink href="/profile" label="Profile" Icon={Settings} onClick={() => setOpen(false)} />
                <LogoutBtn onClick={() => setOpen(false)} />
              </div>
            </aside>
          </div>
        )}

        <main style={{ flex: 1, padding: '28px 20px', maxWidth: 1040, width: '100%', margin: '0 auto', paddingBottom: 60 }}>
          {children}
        </main>
      </div>
    </div>
  );
}
