const features = [
  { icon: '\u29C9', title: 'Modular', description: 'Install only what you need. Skip the rest.' },
  { icon: '\u21C4', title: 'Any Backend', description: 'Swap rofi for wofi for fzf. Nothing breaks.' },
  { icon: '\u2316', title: 'Cross-Platform', description: 'X11, Wayland, and macOS. One config.' },
  { icon: '\u25D0', title: 'Dynamic Themes', description: 'Colors extracted from your wallpaper. Automatically.' },
  { icon: '\u0023', title: 'Pure Bash', description: 'Zero Python. Zero runtime deps. Just bash.' },
  { icon: '\u002B', title: 'Extensible', description: 'Write a module in 20 lines. Share it with everyone.' },
];

export function Features() {
  return (
    <section className="px-6 py-24">
      <div className="mx-auto max-w-5xl">
        <h2 className="mb-4 text-center text-sm font-semibold uppercase tracking-widest text-[#CBA6F7]">Why kall</h2>
        <p className="mx-auto mb-16 max-w-lg text-center text-lg text-[#BAC2DE]">Everything you cobbled together from 10 repos, but it actually works together.</p>
        <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
          {features.map((feature) => (
            <div key={feature.title} className="group rounded-xl border border-[#313244] bg-[#181825]/60 p-6 transition-all hover:border-[#45475A] hover:bg-[#181825]">
              <div className="mb-4 flex h-10 w-10 items-center justify-center rounded-lg bg-[#313244] text-xl text-[#CBA6F7] transition-colors group-hover:bg-[#CBA6F7]/15">{feature.icon}</div>
              <h3 className="mb-2 text-lg font-semibold text-[#CDD6F4]">{feature.title}</h3>
              <p className="text-sm leading-relaxed text-[#A6ADC8]">{feature.description}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
