"use client";
import { useState } from "react";

const backends = [
  { name: "rofi", desc: "Full-featured. Icons, markup, calculator, app launcher.", color: "#CBA6F7" },
  { name: "fzf", desc: "Terminal-native. Preview pipelines. Most portable.", color: "#A6E3A1" },
  { name: "wofi", desc: "Wayland-native. Clean and fast.", color: "#89B4FA" },
  { name: "tofi", desc: "Ultra-minimal. When less is more.", color: "#F9E2AF" },
  { name: "fuzzel", desc: "Wayland-native with icon support.", color: "#FAB387" },
  { name: "dmenu", desc: "The OG. Keyboard-driven purity.", color: "#F5C2E7" },
];

export function Backends() {
  const [active, setActive] = useState(0);

  return (
    <section className="relative px-6 py-24 md:py-32">
      <div className="mx-auto max-w-4xl text-center">
        <h2 className="mb-4 text-3xl font-bold text-[#CDD6F4] md:text-5xl">
          Locked to rofi? <span className="text-[#F38BA8]">Not anymore.</span>
        </h2>
        <p className="mb-12 text-lg text-[#A6ADC8]">Swap your launcher like you swap your wallpaper. Your modules don&apos;t care which one you pick.</p>

        <div className="mb-8 flex flex-wrap justify-center gap-3">
          {backends.map((b, i) => (
            <button key={b.name} onClick={() => setActive(i)} className={`rounded-lg px-4 py-2 font-mono text-sm transition-all duration-200 ${active === i ? "text-[#1E1E2E] font-semibold" : "border border-[#313244] text-[#A6ADC8] hover:border-[#585B70]"}`} style={active === i ? { backgroundColor: b.color, borderColor: b.color } : {}}>
              {b.name}
            </button>
          ))}
        </div>

        <div className="rounded-2xl border border-[#313244]/50 bg-[#181825]/60 p-8 transition-all duration-200">
          <div className="text-3xl font-bold" style={{ color: backends[active].color }}>{backends[active].name}</div>
          <p className="mt-2 text-[#A6ADC8]">{backends[active].desc}</p>
          <p className="mt-4 font-mono text-xs text-[#585B70]">menu_backend: {backends[active].name}</p>
        </div>
      </div>
    </section>
  );
}
