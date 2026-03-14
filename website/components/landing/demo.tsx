export function Demo() {
  return (
    <section className="px-6 py-20">
      <div className="mx-auto max-w-4xl">
        <h2 className="mb-4 text-center text-sm font-semibold uppercase tracking-widest text-[#CBA6F7]">See it in action</h2>
        <div className="overflow-hidden rounded-xl border border-[#45475A] bg-[#181825] shadow-2xl shadow-black/30">
          <div className="flex items-center gap-2 border-b border-[#313244] px-4 py-3">
            <div className="h-3 w-3 rounded-full bg-[#F38BA8]" />
            <div className="h-3 w-3 rounded-full bg-[#F9E2AF]" />
            <div className="h-3 w-3 rounded-full bg-[#A6E3A1]" />
            <span className="ml-3 text-xs text-[#6C7086]">kall — bash</span>
          </div>
          <div className="flex min-h-[350px] flex-col items-center justify-center p-8 sm:min-h-[420px]">
            <div className="mb-6 text-5xl opacity-30"><span className="font-mono text-[#CBA6F7]">&gt;_</span></div>
            <p className="mb-2 text-lg font-medium text-[#BAC2DE]">Demo coming soon</p>
            <p className="max-w-sm text-center text-sm text-[#6C7086]">A full walkthrough of kall in action — switching backends, launching modules, and wallbash theming on the fly.</p>
          </div>
        </div>
      </div>
    </section>
  );
}
