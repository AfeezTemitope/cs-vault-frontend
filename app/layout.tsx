import type { Metadata } from 'next';
import { Toaster } from 'react-hot-toast';
import './globals.css';

export const metadata: Metadata = {
  title: 'CS-Vault | School Project Repository',
  description: 'Computer Science project repository',
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        {children}
        <Toaster position="top-center" toastOptions={{
          style: { background: '#17171F', color: '#E8E8F0', border: '1px solid #252530', fontFamily: 'Syne, sans-serif', fontSize: '14px' },
          success: { iconTheme: { primary: '#C8F135', secondary: '#0A0A0F' } },
        }} />
      </body>
    </html>
  );
}
