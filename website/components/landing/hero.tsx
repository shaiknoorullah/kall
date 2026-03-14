'use client';

import { useState } from 'react';
import Link from 'next/link';

export function Hero() {
  const [copied, setCopied] = useState(false);
  const installCmd = 'curl -fsSL kall.sh/install | bash';

  const handleCopy = async () => {
    try {
      await navigator.clipboard.writeText(installCmd);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    } catch {
      const textarea = document.createElement('textarea');
      textarea.value = installCmd;
      document.body.appendChild(textarea);
      textarea.select();
      document.execCommand('copy');
      document.body.removeChild(textarea);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    }
  };

  return (
    <section className="relative flex min-h-[90vh] flex-col items-center justify-center overflow-hidden px-6 py-24">
      <div className="pointer-events-none absolute inset-0">
        <div className="absolute left-1/2 top-1/4 h-[500px] w-[500px] -translate-x-1/2 -translate-y-1/2 rounded-full bg-[#CBA6F7]/8 blur-[120px]" />
        <div className="absolute right-1/4 top-1/2 h-[300px] w-[300px] rounded-full bg-[#89B4FA]/6 blur-[100px]" />
        <div className="absolute bottom-1/4 left-1/3 h-[250px] w-[250px] rounded-full bg-[#F5C2E7]/5 blur-[90px]" />
      </div>
      <div className="relative z-10 flex max-w-3xl flex-col items-center text-center">
        <h1 className="mb-6 text-8xl font-black tracking-tighter sm:text-9xl">
          <span className="hero-glow bg-gradient-to-r from-[#CBA6F7] via-[#89B4FA] to-[#F5C2E7] bg-clip-text text-transparent">
            kall
          </span>
        </h1>
        <p className="mb-10 max-w-xl text-xl leading-relaxed text-[#BAC2DE] sm:text-2xl">
          Stop duct-taping scripts together.
          <br />
          <span className="text-[#CDD6F4]">One command center. Every desktop action. Pure bash.</span>
        </p>
        <div className="mb-10 w-full max-w-lg">
          <div className="group relative flex items-center rounded-lg border border-[#45475A] bg-[#181825] font-mono text-sm transition-colors hover:border-[#585B70]">
            <span className="select-none px-4 text-[#6C7086]">$</span>
            <code className="flex-1 py-3.5 pr-2 text-[#A6E3A1]">{installCmd}</code>
            <button
              onClick={handleCopy}
              className="mr-2 rounded-md px-3 py-1.5 text-xs text-[#6C7086] transition-all hover:bg-[#313244] hover:text-[#CDD6F4]"
              aria-label="Copy install command"
            >
              {copied ? (
                <span className="text-[#A6E3A1]">copied!</span>
              ) : (
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <rect x="9" y="9" width="13" height="13" rx="2" ry="2" />
                  <path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1" />
                </svg>
              )}
            </button>
          </div>
        </div>
        <div className="flex flex-col gap-4 sm:flex-row">
          <Link href="/docs/user/getting-started" className="rounded-lg bg-[#CBA6F7] px-8 py-3.5 text-sm font-semibold text-[#1E1E2E] transition-all hover:bg-[#CBA6F7]/85 hover:shadow-lg hover:shadow-[#CBA6F7]/20">
            Get Started
          </Link>
          <a href="https://github.com/shaiknoorullah/kall" target="_blank" rel="noopener noreferrer" className="flex items-center justify-center gap-2 rounded-lg border border-[#45475A] px-8 py-3.5 text-sm font-semibold text-[#CDD6F4] transition-all hover:border-[#585B70] hover:bg-[#313244]/50">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z" /></svg>
            GitHub
          </a>
        </div>
      </div>
      <div className="absolute bottom-8 left-1/2 -translate-x-1/2 animate-bounce text-[#6C7086]">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polyline points="6 9 12 15 18 9" /></svg>
      </div>
    </section>
  );
}
