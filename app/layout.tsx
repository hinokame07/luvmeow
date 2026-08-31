import type { Metadata } from 'next';
import { Geist } from 'next/font/google';
import './globals.css';

const geist = Geist({ variable: '--font-geist-sans', subsets: ['latin'] });

export const metadata: Metadata = {
  title: 'luv — designs & carrds',
  description: 'O cantinho criativo da luv: designs, Carrds e identidades feitas com carinho.',
  metadataBase: new URL('https://luv-designs-carrds.hino07.chatgpt.site'),
  openGraph: {
    title: 'luv — designs & carrds',
    description: 'Pretty things live here ♡ Designs, Carrds e identidades feitas com carinho.',
    images: [{ url: '/og.png', width: 1536, height: 804, alt: 'luv — designs & carrds' }],
  },
  twitter: {
    card: 'summary_large_image',
    title: 'luv — designs & carrds',
    description: 'Pretty things live here ♡ Designs, Carrds e identidades feitas com carinho.',
    images: ['/og.png'],
  },
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="pt-BR">
      <body className={geist.variable}>{children}</body>
    </html>
  );
}
