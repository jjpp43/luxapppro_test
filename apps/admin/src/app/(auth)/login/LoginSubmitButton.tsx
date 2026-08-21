"use client";

import { useFormStatus } from "react-dom";

export function LoginSubmitButton() {
  const { pending } = useFormStatus();

  return (
    <button
      type="submit"
      disabled={pending}
      aria-disabled={pending}
      className="inline-flex w-full items-center justify-center gap-2 rounded-lg bg-[var(--accent)] px-4 py-2.5 text-sm font-semibold text-white transition-[transform,background-color,opacity] hover:bg-[var(--accent-hover)] active:scale-[0.99] disabled:cursor-wait disabled:opacity-80 disabled:active:scale-100"
    >
      {pending ? (
        <span className="inline-flex items-center gap-2" aria-live="polite">
          <svg
            aria-hidden="true"
            viewBox="0 0 24 24"
            className="size-4 animate-spin motion-reduce:animate-none"
          >
            <circle
              cx="12"
              cy="12"
              r="9"
              fill="none"
              stroke="currentColor"
              strokeWidth="3"
              className="opacity-30"
            />
            <path
              d="M21 12a9 9 0 0 0-9-9"
              fill="none"
              stroke="currentColor"
              strokeLinecap="round"
              strokeWidth="3"
            />
          </svg>
          Signing in…
        </span>
      ) : (
        "Sign in"
      )}
    </button>
  );
}
