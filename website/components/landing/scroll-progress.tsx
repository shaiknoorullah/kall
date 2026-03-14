"use client";
import { useEffect, useRef } from "react";
import { gsap, ScrollTrigger } from "@/lib/gsap";

export function ScrollProgress() {
  const barRef = useRef<HTMLDivElement>(null);
  useEffect(() => {
    if (!barRef.current) return;
    gsap.to(barRef.current, {
      scaleX: 1,
      ease: "none",
      scrollTrigger: { trigger: document.body, start: "top top", end: "bottom bottom", scrub: 0.3 },
    });
    return () => { ScrollTrigger.getAll().forEach((t) => t.kill()); };
  }, []);
  return (
    <div className="fixed top-0 left-0 right-0 z-50 h-[2px]">
      <div ref={barRef} className="h-full origin-left bg-gradient-to-r from-[#CBA6F7] via-[#89B4FA] to-[#A6E3A1]" style={{ transform: "scaleX(0)" }} />
    </div>
  );
}
