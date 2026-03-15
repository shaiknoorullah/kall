"use client";

const palettes = [
  { name: "Catppuccin Mocha", colors: ["#1E1E2E", "#CDD6F4", "#CBA6F7", "#89B4FA", "#A6E3A1"] },
  { name: "Dracula", colors: ["#282A36", "#F8F8F2", "#BD93F9", "#FF79C6", "#50FA7B"] },
  { name: "Nord", colors: ["#2E3440", "#ECEFF4", "#88C0D0", "#81A1C1", "#BF616A"] },
  { name: "Gruvbox", colors: ["#282828", "#EBDBB2", "#D79921", "#458588", "#CC241D"] },
  { name: "Tokyo Night", colors: ["#1A1B26", "#C0CAF5", "#7AA2F7", "#BB9AF7", "#F7768E"] },
  { name: "Rose Pine", colors: ["#191724", "#E0DEF4", "#C4A7E7", "#EBBCBA", "#EB6F92"] },
];

export function Themes() {
  return (
    <section className="relative px-6 py-24 md:py-32">
      <div className="mx-auto max-w-5xl">
        <div className="mb-12 text-center">
          <h2 className="mb-4 text-3xl font-bold text-[#CDD6F4] md:text-5xl">Six palettes. <span className="text-[#F9E2AF]">Or your wallpaper.</span></h2>
          <p className="text-lg text-[#A6ADC8]">Static palettes ship out of the box. Enable wallbash and your wallpaper becomes your theme.</p>
        </div>
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {palettes.map((p) => (
            <div key={p.name} className="group rounded-xl border border-[#313244]/40 bg-[#181825]/40 p-4 transition-all duration-300 hover:border-[#585B70] hover:bg-[#181825]/80">
              <div className="mb-3 flex gap-2">
                {p.colors.map((c, j) => (
                  <div key={j} className="h-8 w-8 rounded-lg transition-transform duration-300 group-hover:scale-110" style={{ backgroundColor: c }} />
                ))}
              </div>
              <div className="text-sm font-medium text-[#CDD6F4]">{p.name}</div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
