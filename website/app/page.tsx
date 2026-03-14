import { ScrollProgress } from "@/components/landing/scroll-progress";
import { Hero } from "@/components/landing/hero";
import { ProblemSolution } from "@/components/landing/problem-solution";
import { Features } from "@/components/landing/features";
import { ModuleCatalog } from "@/components/landing/module-catalog";
import { Backends } from "@/components/landing/backends";
import { Themes } from "@/components/landing/themes";
import { InstallCTA } from "@/components/landing/install-cta";
import { Footer } from "@/components/landing/footer";

export default function LandingPage() {
  return (
    <div className="min-h-screen bg-[#1E1E2E] text-[#CDD6F4]">
      <ScrollProgress />
      <Hero />
      <ProblemSolution />
      <Features />
      <ModuleCatalog />
      <Backends />
      <Themes />
      <InstallCTA />
      <Footer />
    </div>
  );
}
