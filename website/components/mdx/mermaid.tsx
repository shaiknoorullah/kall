'use client';

import { useEffect, useId, useState } from 'react';

export function Mermaid({ chart }: { chart: string }) {
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  if (!mounted) return null;
  return <MermaidContent chart={chart} />;
}

function MermaidContent({ chart }: { chart: string }) {
  const id = useId();
  const [svg, setSvg] = useState<string>('');

  useEffect(() => {
    let cancelled = false;
    import('mermaid').then(({ default: mermaid }) => {
      mermaid.initialize({
        startOnLoad: false,
        securityLevel: 'strict',
        fontFamily: 'inherit',
        theme: 'dark',
        themeVariables: {
          primaryColor: '#CBA6F7',
          primaryTextColor: '#CDD6F4',
          primaryBorderColor: '#585B70',
          lineColor: '#A6ADC8',
          secondaryColor: '#313244',
          tertiaryColor: '#181825',
        },
      });
      const safeId = id.replace(/:/g, '-').replace(/^-/, 'm');
      mermaid.render(safeId, chart).then(({ svg: rendered }) => {
        if (!cancelled) setSvg(rendered);
      });
    });
    return () => { cancelled = true; };
  }, [chart, id]);

  if (!svg) {
    return (
      <div className="my-4 text-center text-sm text-[#585B70]">
        Loading diagram...
      </div>
    );
  }

  return (
    <div className="my-4 flex justify-center overflow-x-auto">
      <img
        src={`data:image/svg+xml;base64,${typeof btoa !== 'undefined' ? btoa(unescape(encodeURIComponent(svg))) : Buffer.from(svg).toString('base64')}`}
        alt="Architecture diagram"
        className="max-w-full"
      />
    </div>
  );
}
