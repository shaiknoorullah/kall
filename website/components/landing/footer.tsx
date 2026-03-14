import Link from "next/link";

export function Footer() {
  return (
    <footer className="border-t border-[#313244]/30 px-6 py-12">
      <div className="mx-auto flex max-w-5xl flex-col items-center justify-between gap-6 sm:flex-row">
        <div className="flex gap-6 text-sm text-[#585B70]">
          <Link href="/docs" className="transition-colors hover:text-[#CDD6F4]">Docs</Link>
          <Link href="https://github.com/shaiknoorullah/kall" target="_blank" className="transition-colors hover:text-[#CDD6F4]">GitHub</Link>
          <Link href="https://github.com/shaiknoorullah/kall/discussions" target="_blank" className="transition-colors hover:text-[#CDD6F4]">Discussions</Link>
          <Link href="https://github.com/shaiknoorullah/kall/blob/main/CONTRIBUTING.md" target="_blank" className="transition-colors hover:text-[#CDD6F4]">Contributing</Link>
        </div>
        <div className="text-xs text-[#45475A]">MIT &middot; Made with obsessive attention to detail</div>
      </div>
    </footer>
  );
}
