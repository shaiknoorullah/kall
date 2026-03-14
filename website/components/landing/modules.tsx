type Module = {
  name: string;
  description: string;
};

type Category = {
  label: string;
  color: string;
  modules: Module[];
};

const categories: Category[] = [
  {
    label: 'System',
    color: '#F38BA8',
    modules: [
      { name: 'power', description: 'Shutdown, reboot, lock, suspend' },
      { name: 'bluetooth', description: 'Scan, pair, connect devices' },
      { name: 'network', description: 'Wi-Fi and connection manager' },
      { name: 'audio', description: 'Sink and source switcher' },
      { name: 'brightness', description: 'Display brightness control' },
      { name: 'wallpaper', description: 'Browse and apply wallpapers' },
    ],
  },
  {
    label: 'Productivity',
    color: '#A6E3A1',
    modules: [
      { name: 'clipboard', description: 'History, search, pin items' },
      { name: 'emoji', description: 'Search and paste emoji' },
      { name: 'screenshot', description: 'Region, window, fullscreen' },
      { name: 'screenrecord', description: 'Record screen regions' },
      { name: 'calculator', description: 'Quick math from the launcher' },
    ],
  },
  {
    label: 'Developer',
    color: '#89B4FA',
    modules: [
      { name: 'tmux', description: 'Session picker and creator' },
      { name: 'ssh', description: 'Connect to saved hosts' },
      { name: 'docker', description: 'Manage containers and images' },
      { name: 'git', description: 'Quick repo actions' },
    ],
  },
  {
    label: 'Browser',
    color: '#FAB387',
    modules: [
      { name: 'websearch', description: 'Search from your launcher' },
      { name: 'bookmarks', description: 'Browser bookmarks lookup' },
      { name: 'tabs', description: 'Switch or close browser tabs' },
    ],
  },
  {
    label: 'Notes',
    color: '#F5C2E7',
    modules: [
      { name: 'obsidian', description: 'Open vaults, search notes' },
      { name: 'quicknote', description: 'Capture a thought instantly' },
    ],
  },
];

export function Modules() {
  return (
    <section className="px-6 py-24">
      <div className="mx-auto max-w-5xl">
        <h2 className="mb-4 text-center text-sm font-semibold uppercase tracking-widest text-[#CBA6F7]">
          26 modules and counting
        </h2>
        <p className="mx-auto mb-16 max-w-lg text-center text-lg text-[#BAC2DE]">
          Every action you reach for, already wired up.
        </p>

        <div className="space-y-10">
          {categories.map((category) => (
            <div key={category.label}>
              <h3 className="mb-4 flex items-center gap-2 text-sm font-semibold uppercase tracking-wider">
                <span
                  className="inline-block h-2 w-2 rounded-full"
                  style={{ backgroundColor: category.color }}
                />
                <span style={{ color: category.color }}>{category.label}</span>
              </h3>
              <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
                {category.modules.map((mod) => (
                  <div
                    key={mod.name}
                    className="flex items-baseline gap-3 rounded-lg border border-[#313244]/60 bg-[#181825]/40 px-4 py-3 transition-colors hover:border-[#45475A] hover:bg-[#181825]/80"
                  >
                    <code className="shrink-0 text-sm font-semibold text-[#CDD6F4]">
                      {mod.name}
                    </code>
                    <span className="text-sm text-[#6C7086]">
                      {mod.description}
                    </span>
                  </div>
                ))}
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
