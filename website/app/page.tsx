import Link from 'next/link';

export default function HomePage() {
  return (
    <main className="flex flex-1 flex-col items-center justify-center text-center">
      <h1 className="mb-4 text-4xl font-bold">kall</h1>
      <p className="mb-8 text-fd-muted-foreground">
        Documentation site coming soon.
      </p>
      <div className="flex gap-4">
        <Link
          href="/docs"
          className="rounded-lg bg-fd-primary px-6 py-3 text-sm font-medium text-fd-primary-foreground transition-colors hover:bg-fd-primary/90"
        >
          Read the Docs
        </Link>
        <Link
          href="/showcase"
          className="rounded-lg border border-fd-border px-6 py-3 text-sm font-medium transition-colors hover:bg-fd-accent"
        >
          Showcase
        </Link>
      </div>
    </main>
  );
}
