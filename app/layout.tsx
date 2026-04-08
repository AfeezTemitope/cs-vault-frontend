import type { Metadata, Viewport } from 'next';
import { Toaster } from 'react-hot-toast';
import './globals.css';

export const metadata: Metadata = {
  metadataBase: new URL('https://csvault.xyz'),
  title: { default: 'CS-Vault | School Project Repository', template: '%s | CS-Vault' },
  description: 'CS-Vault is a school project repository platform for Computer Science students and lecturers.',
  manifest: '/manifest.json',
  appleWebApp: { capable: true, statusBarStyle: 'default', title: 'CS-Vault' },
  icons: {
    icon: [{ url: '/favicon-16x16.png', sizes: '16x16' }, { url: '/favicon-32x32.png', sizes: '32x32' }, { url: '/favicon.ico' }],
    apple: [{ url: '/apple-touch-icon.png', sizes: '180x180' }],
  },
};

export const viewport: Viewport = {
  themeColor: [{ media: '(prefers-color-scheme: light)', color: '#7C3AED' }, { media: '(prefers-color-scheme: dark)', color: '#A78BFA' }],
  width: 'device-width', initialScale: 1, maximumScale: 1,
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <head>
        <script dangerouslySetInnerHTML={{
          __html: `(function(){var t=localStorage.getItem('cv-theme')||'light';document.documentElement.setAttribute('data-theme',t);})();`
        }} />
      </head>
      <body>
        {children}
        <Toaster position="top-center" toastOptions={{
          style: { background: 'var(--card)', color: 'var(--soft)', border: '1.5px solid var(--border)', fontFamily: "'Plus Jakarta Sans', sans-serif", fontSize: '14px', borderRadius: '12px', boxShadow: 'var(--shadow-md)' },
          success: { iconTheme: { primary: '#7C3AED', secondary: '#fff' } },
        }} />
      </body>
    </html>
  );
}
