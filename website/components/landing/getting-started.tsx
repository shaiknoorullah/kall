'use client';

import { useState } from 'react';
import Link from 'next/link';

const steps = [
  { number: '1', title: 'Install', description: 'One command. No package managers, no make, no sudo.' },
  { number: '2', title: 'Pick modules', description: 'Enable only the modules you actually use.' },
  { number: '3', title: 'Add keybindings', description: 'Bind kall to Super+Space and forget about it.' },
];

export function GettingStarted() {
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
    <section className="px-6 py-24">
      <div className="mx-auto max-w-3xl">
        <h2 className="mb-4 text-center text-sm font-semibold uppercase tracking-widest text-[#CBA6F7]">
          Get started in 30 seconds
        </h2>
        <p className="mx-auto mb-14 max-w-md text-center text-lg text-[#BAC2DE]">
          Three steps. No gotchas.
        </p>

        {/* Steps */}
        <div className="mb-14 grid gap-6 sm:grid-cols-3">
          {steps.map((step) => (
            <div key={step.number} className="text-center">
              <div className="mx-auto mb-4 flex h-10 w-10 items-center justify-center rounded-full border border-[#CBA6F7]/30 bg-[#CBA6F7]/10 text-sm font-bold text-[#CBA6F7]">
                {step.number}
              </div>
              <h3 className="mb-2 text-lg font-semibold text-[#CDD6F4]">{step.title}</h3>
              <p className="text-sm text-[#A6ADC8]">{step.description}</p>
            </div>
          ))}
        </div>

        {/* Install command */}
        <div className="mx-auto mb-10 max-w-lg">
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

        {/* CTA */}
        <div className="text-center">
          <Link
            href="/docs/user/getting-started"
            className="inline-block rounded-lg bg-[#CBA6F7] px-8 py-3.5 text-sm font-semibold text-[#1E1E2E] transition-all hover:bg-[#CBA6F7]/85 hover:shadow-lg hover:shadow-[#CBA6F7]/20"
          >
            Read the full guide
          </Link>
        </div>
      </div>
    </section>
  );
}
