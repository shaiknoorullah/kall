"use client";
import { useState } from "react";

export function CopyButton({ text }: { text: string }) {
  const [copied, setCopied] = useState(false);
  const handleCopy = async () => {
    await navigator.clipboard.writeText(text);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };
  return (
    <button onClick={handleCopy} className="group relative flex items-center gap-3 rounded-xl border border-[#313244] bg-[#181825]/80 px-5 py-3.5 font-mono text-sm text-[#CDD6F4] backdrop-blur-sm transition-all duration-300 hover:border-[#CBA6F7]/40 hover:shadow-[0_0_40px_rgba(203,166,247,0.08)]">
      <span className="text-[#585B70]">$</span>
      <span className="text-[#A6E3A1]">{text}</span>
      <span className="ml-2 rounded-md bg-[#313244] px-2.5 py-1 text-xs text-[#CBA6F7] transition-all duration-200 group-hover:bg-[#CBA6F7] group-hover:text-[#1E1E2E]">
        {copied ? "copied!" : "copy"}
      </span>
    </button>
  );
}
