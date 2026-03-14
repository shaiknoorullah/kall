export function SocialProof() {
  return (
    <section className="px-6 py-20">
      <div className="mx-auto flex max-w-2xl flex-col items-center text-center">
        <h2 className="mb-8 text-sm font-semibold uppercase tracking-widest text-[#CBA6F7]">
          Open source
        </h2>

        {/* GitHub stars badge */}
        <a
          href="https://github.com/shaiknoorullah/kall"
          target="_blank"
          rel="noopener noreferrer"
          className="mb-8 transition-opacity hover:opacity-80"
        >
          {/* eslint-disable-next-line @next/next/no-img-element */}
          <img
            src="https://img.shields.io/github/stars/shaiknoorullah/kall?style=for-the-badge&logo=github&labelColor=181825&color=CBA6F7"
            alt="GitHub stars"
            height="28"
          />
        </a>

        <p className="mb-8 max-w-md text-lg text-[#BAC2DE]">
          Built in the open. Shaped by the people who use it every day.
        </p>

        <a
          href="https://github.com/shaiknoorullah/kall/discussions"
          target="_blank"
          rel="noopener noreferrer"
          className="rounded-lg border border-[#45475A] px-6 py-3 text-sm font-semibold text-[#CDD6F4] transition-all hover:border-[#585B70] hover:bg-[#313244]/50"
        >
          Join the community
        </a>
      </div>
    </section>
  );
}
