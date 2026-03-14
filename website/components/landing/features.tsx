"use client";
import { useEffect, useRef } from "react";
import { gsap } from "@/lib/gsap";

const features = [
  { icon: "🧩", title: "Modular", desc: "Install only what you need. Skip the rest. 26 modules, pick 5 or all 26.", accent: "#CBA6F7" },
  { icon: "🔄", title: "Any Backend", desc: "Rofi today, fzf tomorrow, wofi next week. Your config doesn't care.", accent: "#89B4FA" },
  { icon: "🌍", title: "Cross-Platform", desc: "X11, Wayland, and macOS. One config. Zero \"works on my machine.\"", accent: "#A6E3A1" },
  { icon: "🎨", title: "Dynamic Themes", desc: "Colors extracted from your wallpaper. Automatically. Or pick from 6 curated palettes.", accent: "#F9E2AF" },
  { icon: "⚡", title: "Pure Bash", desc: "No Python. No Node. No Ruby. No runtime deps. Bash and chill.", accent: "#FAB387" },
  { icon: "🔌", title: "Extensible", desc: "Write a module in 20 lines. Share it. Anyone can contribute.", accent: "#F5C2E7" },
];

export function Features() {
  const gridRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!gridRef.current) return;
    const ctx = gsap.context(() => {
      gsap.from(".feature-card", {
        y: 60, opacity: 0, stagger: 0.1, duration: 0.7, ease: "power2.out",
        scrollTrigger: { trigger: gridRef.current, start: "top 80%" },
      });
    }, gridRef);
    return () => ctx.revert();
  }, []);

  return (
    <section className="relative px-6 py-32">
      <div className="mx-auto max-w-6xl">
        <div className="mb-16 text-center">
          <h2 className="mb-4 text-4xl font-bold text-[#CDD6F4] md:text-5xl">
            Built different. <span className="text-[#CBA6F7]">On purpose.</span>
          </h2>
          <p className="text-lg text-[#A6ADC8]">Every decision was &quot;how do we not end up like the other 47 rofi script repos&quot;</p>
        </div>

        <div ref={gridRef} className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
          {features.map((f, i) => (
            <div key={i} className="feature-card group relative overflow-hidden rounded-2xl border border-[#313244]/50 bg-[#181825]/60 p-6 transition-all duration-500 hover:border-[color:var(--accent)]/30 hover:shadow-[0_0_40px_rgba(203,166,247,0.06)]" style={{"--accent": f.accent} as React.CSSProperties}>
              <div className="pointer-events-none absolute -right-8 -top-8 h-32 w-32 rounded-full opacity-0 blur-[60px] transition-opacity duration-500 group-hover:opacity-100" style={{backgroundColor: f.accent + "15"}} />
              <span className="mb-4 block text-3xl">{f.icon}</span>
              <h3 className="mb-2 text-lg font-semibold text-[#CDD6F4]">{f.title}</h3>
              <p className="text-sm leading-relaxed text-[#A6ADC8]">{f.desc}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
