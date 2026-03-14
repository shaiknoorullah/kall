"use client";
import { useEffect, useRef } from "react";
import { gsap, ScrollTrigger } from "@/lib/gsap";

const problems = [
  { icon: "💀", text: "10 scripts from 10 repos. None themed." },
  { icon: "🔥", text: "Swap rofi for wofi? Everything breaks." },
  { icon: "😤", text: "Wayland? Good luck with xclip." },
  { icon: "🐍", text: "Needs Python 3.11. And pip. And venv." },
];

const solutions = [
  { icon: "📦", text: "26 modules. One config file." },
  { icon: "🔄", text: "Swap backends freely. Nothing breaks." },
  { icon: "🖥️", text: "X11, Wayland, macOS. All of them." },
  { icon: "⚡", text: "Pure bash. yq + jq. That's it." },
];

export function ProblemSolution() {
  const sectionRef = useRef<HTMLElement>(null);

  useEffect(() => {
    if (!sectionRef.current) return;
    const ctx = gsap.context(() => {
      gsap.from(".problem-card", {
        x: -60, opacity: 0, stagger: 0.12, duration: 0.7,
        scrollTrigger: { trigger: sectionRef.current, start: "top 75%" },
      });
      gsap.from(".solution-card", {
        x: 60, opacity: 0, stagger: 0.12, duration: 0.7,
        scrollTrigger: { trigger: sectionRef.current, start: "top 75%" },
      });
    }, sectionRef);
    return () => ctx.revert();
  }, []);

  return (
    <section ref={sectionRef} className="relative px-6 py-32">
      <div className="mx-auto max-w-6xl">
        <div className="mb-16 text-center">
          <h2 className="mb-4 text-4xl font-bold text-[#CDD6F4] md:text-5xl">
            The <span className="line-through text-[#F38BA8]/60">mess</span> you know
          </h2>
          <p className="text-lg text-[#A6ADC8]">vs. the system you deserve</p>
        </div>

        <div className="grid gap-8 md:grid-cols-2">
          {/* Problems */}
          <div className="space-y-4">
            <div className="mb-6 inline-block rounded-full border border-[#F38BA8]/20 bg-[#F38BA8]/5 px-4 py-1.5 text-sm text-[#F38BA8]">before kall</div>
            {problems.map((p, i) => (
              <div key={i} className="problem-card flex items-center gap-4 rounded-xl border border-[#313244]/50 bg-[#181825]/50 p-4 opacity-60">
                <span className="text-2xl">{p.icon}</span>
                <span className="text-[#A6ADC8]">{p.text}</span>
              </div>
            ))}
          </div>

          {/* Solutions */}
          <div className="space-y-4">
            <div className="mb-6 inline-block rounded-full border border-[#A6E3A1]/20 bg-[#A6E3A1]/5 px-4 py-1.5 text-sm text-[#A6E3A1]">with kall</div>
            {solutions.map((s, i) => (
              <div key={i} className="solution-card flex items-center gap-4 rounded-xl border border-[#A6E3A1]/10 bg-[#181825]/80 p-4 transition-all duration-300 hover:border-[#A6E3A1]/30 hover:shadow-[0_0_20px_rgba(166,227,161,0.05)]">
                <span className="text-2xl">{s.icon}</span>
                <span className="text-[#CDD6F4]">{s.text}</span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}
