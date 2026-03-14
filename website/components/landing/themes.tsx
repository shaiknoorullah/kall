type Palette = { name: string; colors: string[] };

const palettes: Palette[] = [
  { name: 'Catppuccin Mocha', colors: ['#1E1E2E', '#CBA6F7', '#89B4FA', '#A6E3A1', '#F38BA8', '#F9E2AF', '#CDD6F4'] },
  { name: 'Dracula', colors: ['#282A36', '#BD93F9', '#FF79C6', '#50FA7B', '#FF5555', '#F1FA8C', '#F8F8F2'] },
  { name: 'Nord', colors: ['#2E3440', '#88C0D0', '#81A1C1', '#A3BE8C', '#BF616A', '#EBCB8B', '#ECEFF4'] },
  { name: 'Gruvbox', colors: ['#282828', '#D79921', '#458588', '#98971A', '#CC241D', '#D65D0E', '#EBDBB2'] },
  { name: 'Tokyo Night', colors: ['#1A1B26', '#7AA2F7', '#BB9AF7', '#9ECE6A', '#F7768E', '#E0AF68', '#C0CAF5'] },
  { name: 'Rose Pine', colors: ['#191724', '#C4A7E7', '#EBBCBA', '#31748F', '#EB6F92', '#F6C177', '#E0DEF4'] },
];

export function Themes() {
  return (
    <section className="px-6 py-24">
      <div className="mx-auto max-w-4xl">
        <h2 className="mb-4 text-center text-sm font-semibold uppercase tracking-widest text-[#CBA6F7]">
          6 palettes built in
        </h2>
        <p className="mx-auto mb-6 max-w-lg text-center text-lg text-[#BAC2DE]">
          Pick a palette. Or let your wallpaper decide.
        </p>
        <p className="mx-auto mb-14 max-w-md text-center text-sm text-[#6C7086]">
          Dynamic wallbash theming extracts colors from your wallpaper and
          applies them across every module, every backend, automatically.
        </p>

        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {palettes.map((palette) => (
            <div
              key={palette.name}
              className="rounded-xl border border-[#313244] bg-[#181825]/60 p-5 transition-all hover:border-[#45475A] hover:bg-[#181825]"
            >
              <p className="mb-3 text-sm font-medium text-[#CDD6F4]">{palette.name}</p>
              <div className="flex gap-2">
                {palette.colors.map((color, i) => (
                  <div
                    key={i}
                    className="h-5 w-5 rounded-full border border-white/10"
                    style={{ backgroundColor: color }}
                    title={color}
                  />
                ))}
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
