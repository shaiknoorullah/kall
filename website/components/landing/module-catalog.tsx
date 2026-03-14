"use client";
import { useState, useEffect, useRef } from "react";
import { gsap } from "@/lib/gsap";

const categories = {
  System: [
    { name: "power", desc: "Shutdown, reboot, lock, suspend, logout" },
    { name: "screenshot", desc: "Full, area, window — clipboard + notification" },
    { name: "clipboard", desc: "History, favorites, image preview, OCR" },
    { name: "display", desc: "Multi-monitor layout manager" },
    { name: "wallpaper", desc: "Category browser + setter + theme trigger" },
    { name: "bluetooth", desc: "Scan, pair, connect, trust devices" },
    { name: "systemd", desc: "Start, stop, enable, disable services" },
  ],
  Productivity: [
    { name: "websearch", desc: "Autocomplete + bang syntax (!g, !yt, !w)" },
    { name: "calculator", desc: "Quick math without leaving your flow" },
    { name: "emoji", desc: "Picker with recents and categories" },
    { name: "glyph", desc: "Every Nerd Font icon at your fingertips" },
    { name: "media", desc: "Play, pause, next, prev — any player" },
  ],
  Developer: [
    { name: "git-profiles", desc: "Switch git user.name/email per project" },
    { name: "tmux", desc: "Session manager — create, attach, kill" },
    { name: "projects", desc: "Jump to any project in your editor" },
  ],
  Browser: [
    { name: "bookmarks", desc: "Firefox, Chrome, Zen — all browsers, one menu" },
    { name: "zen-tabs", desc: "Fuzzy tab search with favicon preview" },
    { name: "zen-workspaces", desc: "Domain-based tab grouping + dedup" },
  ],
  Notes: [
    { name: "obsidian", desc: "Quick note, daily note, open vault" },
    { name: "obsidian-search", desc: "Full-text search across all notes" },
  ],
};

const catKeys = Object.keys(categories) as (keyof typeof categories)[];

export function ModuleCatalog() {
  const [active, setActive] = useState<keyof typeof categories>("System");
  const listRef = useRef<HTMLDivElement>(null);
  const sectionRef = useRef<HTMLElement>(null);

  useEffect(() => {
    if (!sectionRef.current) return;
    const ctx = gsap.context(() => {
      gsap.from(sectionRef.current!, {
        y: 60, opacity: 0, duration: 0.8,
        scrollTrigger: { trigger: sectionRef.current, start: "top 80%" },
      });
    }, sectionRef);
    return () => ctx.revert();
  }, []);

  useEffect(() => {
    if (!listRef.current) return;
    const items = listRef.current.querySelectorAll(".module-item");
    gsap.fromTo(items, { x: 20, opacity: 0 }, { x: 0, opacity: 1, stagger: 0.05, duration: 0.3, ease: "power2.out" });
  }, [active]);

  return (
    <section ref={sectionRef} className="relative px-6 py-32">
      <div className="mx-auto max-w-5xl">
        <div className="mb-12 text-center">
          <h2 className="mb-4 text-4xl font-bold text-[#CDD6F4] md:text-5xl">
            26 modules. <span className="text-[#89B4FA]">Zero bloat.</span>
          </h2>
          <p className="text-lg text-[#A6ADC8]">Pick what you need. Ignore the rest. Each one tested on X11, Wayland, and macOS.</p>
        </div>

        {/* Tabs */}
        <div className="mb-8 flex flex-wrap justify-center gap-2">
          {catKeys.map((cat) => (
            <button key={cat} onClick={() => setActive(cat)} className={`rounded-full px-4 py-2 text-sm font-medium transition-all duration-300 ${active === cat ? "bg-[#CBA6F7] text-[#1E1E2E]" : "border border-[#313244] text-[#A6ADC8] hover:border-[#585B70] hover:text-[#CDD6F4]"}`}>
              {cat} <span className="ml-1 text-xs opacity-70">({categories[cat].length})</span>
            </button>
          ))}
        </div>

        {/* Module list */}
        <div ref={listRef} className="grid gap-3 sm:grid-cols-2">
          {categories[active].map((m, i) => (
            <div key={m.name} className="module-item flex items-center gap-3 rounded-xl border border-[#313244]/40 bg-[#181825]/40 px-4 py-3 transition-all duration-300 hover:border-[#CBA6F7]/20 hover:bg-[#181825]/80">
              <code className="rounded bg-[#313244] px-2 py-0.5 text-xs text-[#CBA6F7]">{m.name}</code>
              <span className="text-sm text-[#A6ADC8]">{m.desc}</span>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
