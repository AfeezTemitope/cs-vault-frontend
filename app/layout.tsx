import type { Metadata, Viewport } from 'next';
import { Toaster } from 'react-hot-toast';
import './globals.css';

const BASE_URL = 'https://csvault.xyz';

export const metadata: Metadata = {
  metadataBase: new URL(BASE_URL),
  title: {
    default: 'CS-Vault | School Project Repository',
    template: '%s | CS-Vault',
  },
  description: 'CS-Vault is a school project repository platform for Computer Science students and lecturers. Upload, browse and reference past projects.',
  keywords: [
    'computer science projects',
    'school project repository',
    'student projects',
    'CS projects',
    'university projects',
    'project repository',
    'academic projects',
  ],
  authors: [{ name: 'CS-Vault' }],
  creator: 'CS-Vault',
  publisher: 'CS-Vault',
  applicationName: 'CS-Vault',
  manifest: '/manifest.json',
  appleWebApp: {
    capable: true,
    statusBarStyle: 'black-translucent',
    title: 'CS-Vault',
  },
  openGraph: {
    type: 'website',
    locale: 'en_US',
    url: BASE_URL,
    siteName: 'CS-Vault',
    title: 'CS-Vault | School Project Repository',
    description: 'Upload, browse and reference Computer Science projects. Built for students and lecturers.',
    images: [
      {
        url: '/android-chrome-512x512.png',
        width: 512,
        height: 512,
        alt: 'CS-Vault Logo',
      },
    ],
  },
  twitter: {
    card: 'summary',
    title: 'CS-Vault | School Project Repository',
    description: 'Upload, browse and reference Computer Science projects.',
    images: ['/android-chrome-512x512.png'],
  },
  robots: {
    index: false, // private academic platform — keep off Google
    follow: false,
  },
  icons: {
    icon: [
      { url: '/favicon-16x16.png', sizes: '16x16', type: 'image/png' },
      { url: '/favicon-32x32.png', sizes: '32x32', type: 'image/png' },
      { url: '/favicon.ico' },
    ],
    apple: [
      { url: '/apple-touch-icon.png', sizes: '180x180', type: 'image/png' },
    ],
    other: [
      { rel: 'mask-icon', url: '/android-chrome-192x192.png' },
    ],
  },
};

export const viewport: Viewport = {
  themeColor: '#C8F135',
  width: 'device-width',
  initialScale: 1,
  maximumScale: 1,
  userScalable: false,
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <head>
        <link rel="manifest" href="/manifest.json" />
        <meta name="mobile-web-app-capable" content="yes" />
        <meta name="apple-mobile-web-app-capable" content="yes" />
        <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent" />
        <meta name="apple-mobile-web-app-title" content="CS-Vault" />
        <meta name="application-name" content="CS-Vault" />
        <meta name="msapplication-TileColor" content="#C8F135" />
        <meta name="msapplication-TileImage" content="/android-chrome-192x192.png" />
      </head>
      <body>
        {children}
        <Toaster
          position="top-center"
          toastOptions={{
            style: {
              background: '#17171F',
              color: '#E8E8F0',
              border: '1px solid #252530',
              fontFamily: 'Syne, sans-serif',
              fontSize: '14px',
            },
            success: { iconTheme: { primary: '#C8F135', secondary: '#0A0A0F' } },
          }}
        />
      </body>
    </html>
  );
}