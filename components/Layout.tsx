'use client';
import { useState, useEffect } from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { getUser, logout, User } from '@/lib/auth';
import ThemeToggle from './ThemeToggle';
import {
  LayoutDashboard, BookOpen, Upload, Search,
  Users, GraduationCap, LogOut, Menu, X,
  Settings, FolderOpen, UserPlus
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
    { href: '/lecturer/projects', label: 'Projects', icon: FolderOpen },
    { href: '/lecturer/students/register', label: 'Register Student', icon: UserPlus },
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

  useEffect(() => { setUser(getUser()); setMounted(true); }, []);

  const items = navItems[user?.role ?? ''] ?? [];
  const displayName = user?.name ?? user?.full_name ?? '';

  if (!mounted) return (
    <div className="min-h-screen" style={{ backgroundColor: 'var(--ink)' }}>
      <div style={{ height: 64, backgroundColor: 'var(--card)', borderBottom: '1.5px solid var(--border)' }} />
    </div>
  );

  return (
    <div className="min-h-screen" style={{ backgroundColor: 'var(--ink)' }}>
      {/* Header */}
      <header style={{
        position: 'sticky', top: 0, zIndex: 50,
        backgroundColor: 'var(--card)',
        borderBottom: '1.5px solid var(--border)',
        display: 'flex', alignItems: 'center', justifyContent: 'space-between',
        padding: '0 20px', height: 64,
        boxShadow: 'var(--shadow)',
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
          <button onClick={() => setOpen(!open)} className="md:hidden"
            style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--muted)', padding: 4 }}>
            {open ? <X size={22} /> : <Menu size={22} />}
          </button>
          <Link href={`/${user?.role}`} style={{ display: 'flex', alignItems: 'center', gap: 10, textDecoration: 'none' }}>
            <div style={{
              width: 34, height: 34, borderRadius: 10,
              background: 'var(--accent)', display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>
              <span style={{ color: '#fff', fontWeight: 800, fontSize: 14, fontFamily: 'JetBrains Mono' }}>CV</span>
            </div>
            <span style={{ fontWeight: 800, fontSize: 17, color: 'var(--soft)', letterSpacing: '-0.3px' }}>CS-Vault</span>
          </Link>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
          <span className="hidden sm:block" style={{ fontSize: 14, color: 'var(--muted)', fontWeight: 500 }}>{displayName}</span>
          <span className="badge badge-blue" style={{ fontSize: 11 }}>{user?.role}</span>
          <ThemeToggle />
          <button onClick={logout} style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--muted)', padding: 4 }}>
            <LogOut size={18} />
          </button>
        </div>
      </header>

      <div style={{ display: 'flex' }}>
        {/* Sidebar desktop */}
        <aside className="hidden md:flex" style={{
          flexDirection: 'column', width: 240,
          backgroundColor: 'var(--card)',
          borderRight: '1.5px solid var(--border)',
          padding: '24px 12px',
          position: 'sticky', top: 64,
          height: 'calc(100vh - 64px)',
          gap: 4,
        }}>
          {items.map(({ href, label, icon: Icon }) => {
            const active = pathname === href;
            return (
              <Link key={href} href={href} style={{
                display: 'flex', alignItems: 'center', gap: 12,
                padding: '11px 14px', borderRadius: 10, fontSize: 15,
                fontWeight: active ? 600 : 500, textDecoration: 'none',
                transition: 'all 0.15s ease',
                backgroundColor: active ? 'var(--accent-light)' : 'transparent',
                color: active ? 'var(--accent)' : 'var(--muted)',
                borderLeft: active ? '3px solid var(--accent)' : '3px solid transparent',
              }}>
                <Icon size={18} />
                {label}
              </Link>
            );
          })}
          <div style={{ marginTop: 'auto' }}>
            <Link href="/profile" style={{
              display: 'flex', alignItems: 'center', gap: 12,
              padding: '11px 14px', borderRadius: 10, fontSize: 15,
              fontWeight: pathname === '/profile' ? 600 : 500, textDecoration: 'none',
              backgroundColor: pathname === '/profile' ? 'var(--accent-light)' : 'transparent',
              color: pathname === '/profile' ? 'var(--accent)' : 'var(--muted)',
              borderLeft: pathname === '/profile' ? '3px solid var(--accent)' : '3px solid transparent',
            }}>
              <Settings size={18} />Profile
            </Link>
          </div>
        </aside>

        {/* Mobile drawer */}
        {open && (
          <div style={{ position: 'fixed', inset: 0, zIndex: 40 }} onClick={() => setOpen(false)}>
            <div style={{ position: 'absolute', inset: 0, backgroundColor: 'rgba(0,0,0,0.4)' }} />
            <aside style={{
              position: 'absolute', top: 64, left: 0, bottom: 0, width: 260,
              backgroundColor: 'var(--card)', borderRight: '1.5px solid var(--border)',
              padding: '20px 12px', display: 'flex', flexDirection: 'column', gap: 4,
            }} onClick={e => e.stopPropagation()}>
              {items.map(({ href, label, icon: Icon }) => {
                const active = pathname === href;
                return (
                  <Link key={href} href={href} onClick={() => setOpen(false)} style={{
                    display: 'flex', alignItems: 'center', gap: 12,
                    padding: '13px 14px', borderRadius: 10, fontSize: 15,
                    fontWeight: active ? 600 : 500, textDecoration: 'none',
                    backgroundColor: active ? 'var(--accent-light)' : 'transparent',
                    color: active ? 'var(--accent)' : 'var(--muted)',
                    borderLeft: active ? '3px solid var(--accent)' : '3px solid transparent',
                  }}>
                    <Icon size={18} />{label}
                  </Link>
                );
              })}
              <div style={{ marginTop: 'auto' }}>
                <Link href="/profile" onClick={() => setOpen(false)} style={{
                  display: 'flex', alignItems: 'center', gap: 12,
                  padding: '13px 14px', borderRadius: 10, fontSize: 15,
                  fontWeight: 500, textDecoration: 'none', color: 'var(--muted)',
                }}>
                  <Settings size={18} />Profile
                </Link>
              </div>
            </aside>
          </div>
        )}

        {/* Main content */}
        <main style={{ flex: 1, padding: '32px 24px', maxWidth: 1000, width: '100%', margin: '0 auto', paddingBottom: 100 }}>
          {children}
        </main>
      </div>

      {/* Bottom nav mobile */}
      <nav className="md:hidden" style={{
        position: 'fixed', bottom: 0, left: 0, right: 0, zIndex: 30,
        backgroundColor: 'var(--card)', borderTop: '1.5px solid var(--border)',
        display: 'flex', justifyContent: 'space-around', padding: '8px 0',
        boxShadow: '0 -4px 12px rgba(0,0,0,0.06)',
      }}>
        {items.map(({ href, label, icon: Icon }) => {
          const active = pathname === href;
          return (
            <Link key={href} href={href} style={{
              display: 'flex', flexDirection: 'column', alignItems: 'center',
              gap: 3, padding: '4px 16px', textDecoration: 'none',
              color: active ? 'var(--accent)' : 'var(--muted)',
              fontWeight: active ? 600 : 400,
            }}>
              <Icon size={22} />
              <span style={{ fontSize: 10 }}>{label}</span>
            </Link>
          );
        })}
      </nav>
    </div>
  );
}
