import Cookies from 'js-cookie';
import { AppRouterInstance } from 'next/dist/shared/lib/app-router-context.shared-runtime';

export interface User {
  id: string;
  name?: string;
  full_name?: string;
  email: string;
  role: 'admin' | 'lecturer' | 'student';
  matric_number: string;
  must_change_password?: boolean;
}

export const getUser = (): User | null => {
  try {
    const u = Cookies.get('user');
    return u ? JSON.parse(u) : null;
  } catch { return null; }
};

export const setAuth = (token: string, user: User) => {
  Cookies.set('token', token, { expires: 7 });
  Cookies.set('user', JSON.stringify(user), { expires: 7 });
};

export const logout = () => {
  Cookies.remove('token');
  Cookies.remove('user');
  window.location.href = '/login';
};

export const requireAuth = (
  user: User | null,
  router: AppRouterInstance,
  roles: string[] = []
): boolean => {
  if (!user) { router.push('/login'); return false; }
  if (roles.length && !roles.includes(user.role)) {
    router.push(`/${user.role}`);
    return false;
  }
  return true;
};
