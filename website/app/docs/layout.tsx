import { DocsLayout } from 'fumadocs-ui/layouts/docs';
import type { ReactNode } from 'react';
import { source } from '@/lib/source';

export default function Layout({ children }: { children: ReactNode }) {
  return (
    <DocsLayout
      tree={source.pageTree}
      nav={{
        title: 'kall docs',
        url: '/',
      }}
      links={[
        { text: 'Home', url: '/' },
        { text: 'Docs', url: '/docs' },
        { text: 'Showcase', url: '/showcase' },
      ]}
      githubUrl="https://github.com/kall-org/kall"
    >
      {children}
    </DocsLayout>
  );
}
