import type { Metadata } from 'next';
import { Hind, IBM_Plex_Mono } from 'next/font/google';
import './globals.css';

const hind = Hind({ variable: '--font-hind', subsets: ['latin', 'devanagari'], weight: ['300', '400', '500', '600', '700'], display: 'swap' });
const plexMono = IBM_Plex_Mono({ variable: '--font-plex-mono', subsets: ['latin'], weight: ['400', '500', '600'], display: 'swap' });

export const metadata: Metadata = {
  metadataBase: new URL('https://iaic.vicky-rdp.chatgpt.site'),
  title: 'India AI Inference Chip v1.0 | Build sovereign AI in the open',
  description: 'India AI Inference Chip v1.0 is an open-source initiative of RDP for a sovereign AI stack — built in India, built with the world.',
  openGraph: { title: 'India AI Inference Chip v1.0', description: 'India needs its own AI inference chip. Join the open-source initiative.', url: 'https://iaic.vicky-rdp.chatgpt.site', siteName: 'India AI Inference Chip v1.0', images: [{ url: '/og.png', width: 1672, height: 941, alt: 'Concept render of the India AI Inference Chip connected to physical AI devices' }], type: 'website' },
  twitter: { card: 'summary_large_image', title: 'India AI Inference Chip v1.0', description: 'An open-source beginning for a sovereign AI stack.', images: ['/og.png'] },
  icons: { icon: '/favicon.svg' },
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return <html lang="en"><body className={`${hind.variable} ${plexMono.variable}`}>{children}</body></html>;
}
