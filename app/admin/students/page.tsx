'use client';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { getUser, requireAuth } from '@/lib/auth';
import Layout from '@/components/Layout';
import PageHeader from '@/components/PageHeader';
import EmptyState from '@/components/EmptyState';
import api from '@/lib/api';
import { Users } from 'lucide-react';
import { format } from 'date-fns';

interface Student { id: string; full_name: string; email: string; matric_number: string; created_at: string; }

export default function StudentsPage() {
  const router = useRouter();
  const [students, setStudents] = useState<Student[]>([]);
  const [search, setSearch] = useState('');

  useEffect(() => {
    if (!requireAuth(getUser(), router, ['admin'])) return;
    api.get('/admin/students').then(r => setStudents(r.data)).catch(() => {});
  }, [router]);

  const filtered = students.filter(s =>
    s.full_name.toLowerCase().includes(search.toLowerCase()) ||
    s.matric_number.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <Layout>
      <PageHeader title="Students" subtitle={`${students.length} registered`} />
      <input className="w-full rounded-xl px-4 py-3 text-sm mb-4 border focus:outline-none"
        style={{ backgroundColor: 'var(--card)', borderColor: 'var(--border)', color: 'var(--soft)' }}
        placeholder="Search by name or matric number..."
        value={search} onChange={e => setSearch(e.target.value)}
        onFocus={e => (e.target.style.borderColor = 'var(--accent)')}
        onBlur={e => (e.target.style.borderColor = 'var(--border)')} />
      {filtered.length === 0
        ? <EmptyState icon={Users} title="No students found" subtitle="Students appear once registered by a lecturer" />
        : <div className="space-y-2">
            {filtered.map((s, i) => (
              <div key={s.id} className={`rounded-xl p-4 border flex items-center justify-between fade-up delay-${Math.min(i+1,4) as 1|2|3|4}`}
                style={{ backgroundColor: 'var(--card)', borderColor: 'var(--border)' }}>
                <div>
                  <p className="font-semibold text-sm" style={{ color: 'var(--soft)' }}>{s.full_name}</p>
                  <p className="text-xs mt-0.5" style={{ color: 'var(--muted)' }}>{s.email}</p>
                </div>
                <div className="text-right">
                  <p className="mono text-xs" style={{ color: 'var(--accent)' }}>{s.matric_number}</p>
                  <p className="text-xs mt-0.5" style={{ color: 'var(--muted)' }}>{s.created_at ? format(new Date(s.created_at), 'dd MMM yy') : ''}</p>
                </div>
              </div>
            ))}
          </div>
      }
    </Layout>
  );
}
