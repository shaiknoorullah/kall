"use client";
import { useEffect, useRef } from "react";
import { gsap } from "@/lib/gsap";
import { CopyButton } from "./copy-button";
import Link from "next/link";

export function InstallCTA() {
  const sectionRef = useRef<HTMLElement>(null);
  useEffect(() => {
    if (!sectionRef.current) return;
    const ctx = gsap.context(() => {
      gsap.from(sectionRef.current!, {
        y: 40, opacity: 0, duration: 0.8,
        scrollTrigger: { trigger: sectionRef.current, start: "top 85%" },
      });
    }, sectionRef);
    return () => ctx.revert();
  }, []);

  return (
    <section ref={sectionRef} className="relative px-6 py-32">
      <div className="mx-auto max-w-3xl text-center">
        <h2 className="mb-4 text-4xl font-bold text-[#CDD6F4] md:text-5xl">Ready to stop duct-taping?</h2>
        <p className="mb-8 text-lg text-[#A6ADC8]">One command. Pick your modules. Add keybindings. Done.</p>
        <div className="mb-8 flex justify-center">
          <CopyButton text="curl -fsSL kall.sh/install | bash" />
        </div>
        <div className="flex justify-center gap-8 text-sm text-[#585B70]">
          <div className="flex items-center gap-2"><span className="text-[#A6E3A1]">1.</span> Install</div>
          <div className="flex items-center gap-2"><span className="text-[#89B4FA]">2.</span> Pick modules</div>
          <div className="flex items-center gap-2"><span className="text-[#CBA6F7]">3.</span> Ship it</div>
        </div>
        <div className="mt-8">
          <Link href="/docs/user/getting-started" className="text-sm text-[#CBA6F7] underline underline-offset-4 transition-colors hover:text-[#B4BEFE]">Read the docs &rarr;</Link>
        </div>
      </div>
    </section>
  );
}
