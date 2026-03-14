"use client";
import { useEffect, useRef } from "react";
import { gsap } from "@/lib/gsap";
import { CopyButton } from "./copy-button";
import Link from "next/link";

export function Hero() {
  const sectionRef = useRef<HTMLElement>(null);
  const titleRef = useRef<HTMLHeadingElement>(null);
  const storyRef = useRef<HTMLParagraphElement>(null);
  const solutionRef = useRef<HTMLParagraphElement>(null);
  const actionsRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!sectionRef.current) return;
    const ctx = gsap.context(() => {
      const tl = gsap.timeline({ defaults: { ease: "power3.out" } });
      if (titleRef.current) {
        const chars = titleRef.current.querySelectorAll(".char");
        tl.from(chars, { y: 120, opacity: 0, rotateX: -90, stagger: 0.08, duration: 1 });
      }
      if (storyRef.current) tl.from(storyRef.current, { y: 40, opacity: 0, duration: 0.8 }, "-=0.3");
      if (solutionRef.current) tl.from(solutionRef.current, { y: 30, opacity: 0, duration: 0.6 }, "-=0.2");
      if (actionsRef.current) tl.from(actionsRef.current, { y: 20, opacity: 0, duration: 0.6 }, "-=0.1");
    }, sectionRef);
    return () => ctx.revert();
  }, []);

  return (
    <section ref={sectionRef} className="relative flex min-h-screen flex-col items-center justify-center overflow-hidden px-6 pt-24 pb-16">
      {/* Atmospheric bg */}
      <div className="pointer-events-none absolute inset-0">
        <div className="absolute top-1/4 left-1/2 -translate-x-1/2 h-[600px] w-[800px] rounded-full bg-[#CBA6F7]/[0.04] blur-[120px]" />
        <div className="absolute bottom-1/4 right-1/4 h-[400px] w-[400px] rounded-full bg-[#89B4FA]/[0.03] blur-[100px]" />
        <div className="absolute inset-0 opacity-[0.015]" style={{backgroundImage: "url(\"data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)' opacity='1'/%3E%3C/svg%3E\")"}} />
      </div>

      <div className="relative z-10 mx-auto max-w-4xl text-center">
        <h1 ref={titleRef} className="mb-8 text-[clamp(5rem,15vw,12rem)] font-bold leading-[0.85] tracking-tighter" style={{perspective: "1000px"}}>
          {"kall".split("").map((char, i) => (
            <span key={i} className="char inline-block bg-gradient-to-b from-[#CDD6F4] via-[#CDD6F4] to-[#585B70] bg-clip-text text-transparent" style={{transformOrigin: "center bottom"}}>{char}</span>
          ))}
        </h1>

        <p ref={storyRef} className="mx-auto mb-6 max-w-2xl text-lg leading-relaxed text-[#A6ADC8] md:text-xl">
          You&apos;ve been here before. New wallpaper, broken clipboard script.
          Three hours later you&apos;re debugging someone else&apos;s rofi
          spaghetti at 2am. Half your scripts die on Wayland. The other half
          never worked on your laptop.
        </p>

        <p ref={solutionRef} className="mx-auto mb-12 max-w-xl text-xl font-medium text-[#CDD6F4] md:text-2xl">
          One command center. <span className="text-[#CBA6F7]">Any launcher.</span>{" "}
          Every platform. <span className="text-[#A6E3A1]">Pure bash.</span>
        </p>

        <div ref={actionsRef} className="flex flex-col items-center gap-6">
          <CopyButton text="curl -fsSL kall.sh/install | bash" />
          <div className="flex gap-4">
            <Link href="/docs/user/getting-started" className="rounded-lg bg-[#CBA6F7] px-6 py-2.5 text-sm font-semibold text-[#1E1E2E] transition-all duration-300 hover:bg-[#B4BEFE] hover:shadow-[0_0_30px_rgba(203,166,247,0.3)]">Get Started</Link>
            <Link href="https://github.com/shaiknoorullah/kall" target="_blank" className="rounded-lg border border-[#313244] px-6 py-2.5 text-sm font-semibold text-[#CDD6F4] transition-all duration-300 hover:border-[#585B70] hover:bg-[#181825]">GitHub</Link>
          </div>
        </div>
      </div>

      <div className="absolute bottom-8 left-1/2 -translate-x-1/2 animate-bounce text-[#585B70]">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><polyline points="6 9 12 15 18 9"/></svg>
      </div>
    </section>
  );
}
