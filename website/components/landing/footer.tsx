import Link from 'next/link';

const links = [
  { label: 'Docs', href: '/docs' },
  { label: 'GitHub', href: 'https://github.com/shaiknoorullah/kall', external: true },
  { label: 'Showcase', href: '/showcase' },
  { label: 'Contributing', href: 'https://github.com/shaiknoorullah/kall/blob/main/CONTRIBUTING.md', external: true },
];

export function Footer() {
  return (
    <footer className="border-t border-[#313244] px-6 py-12">
      <div className="mx-auto flex max-w-4xl flex-col items-center gap-6">
        {/* Links */}
        <nav className="flex flex-wrap justify-center gap-6">
          {links.map((link) =>
            link.external ? (
              <a key={link.label} href={link.href} target="_blank" rel="noopener noreferrer" className="text-sm text-[#6C7086] transition-colors hover:text-[#CDD6F4]">
                {link.label}
              </a>
            ) : (
              <Link key={link.label} href={link.href} className="text-sm text-[#6C7086] transition-colors hover:text-[#CDD6F4]">
                {link.label}
              </Link>
            )
          )}
        </nav>

        {/* License and author */}
        <div className="flex flex-col items-center gap-1 text-xs text-[#6C7086]">
          <span>MIT License</span>
          <span>
            Built by{' '}
            <a href="https://github.com/shaiknoorullah" target="_blank" rel="noopener noreferrer" className="text-[#BAC2DE] transition-colors hover:text-[#CDD6F4]">
              @shaiknoorullah
            </a>
          </span>
        </div>
      </div>
    </footer>
  );
}
