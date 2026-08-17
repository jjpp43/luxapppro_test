import { Sidebar } from "./Sidebar";
import { TopBar } from "./TopBar";

export function AppShell({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex h-dvh max-h-dvh overflow-hidden bg-[var(--canvas)] text-[var(--ink)]">
      <Sidebar />
      <div className="flex min-h-0 min-w-0 flex-1 flex-col overflow-hidden">
        <TopBar />
        <main className="min-h-0 flex-1 overflow-y-auto overscroll-contain px-5 py-6 md:px-8">
          {children}
        </main>
      </div>
    </div>
  );
}
