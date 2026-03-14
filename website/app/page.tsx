import { Hero } from '@/components/landing/hero';
import { Demo } from '@/components/landing/demo';
import { Features } from '@/components/landing/features';
import { Modules } from '@/components/landing/modules';
import { Themes } from '@/components/landing/themes';
import { SocialProof } from '@/components/landing/social-proof';
import { GettingStarted } from '@/components/landing/getting-started';
import { Footer } from '@/components/landing/footer';

export default function HomePage() {
  return (
    <main className="min-h-screen bg-[#1E1E2E] text-[#CDD6F4]">
      <Hero />
      <Demo />
      <Features />
      <div className="mx-auto max-w-5xl border-t border-[#313244]" />
      <Modules />
      <div className="mx-auto max-w-5xl border-t border-[#313244]" />
      <Themes />
      <SocialProof />
      <div className="mx-auto max-w-5xl border-t border-[#313244]" />
      <GettingStarted />
      <Footer />
    </main>
  );
}
