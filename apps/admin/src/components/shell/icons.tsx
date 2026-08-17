import type { NavIcon } from "./nav";

const stroke = {
  fill: "none",
  stroke: "currentColor",
  strokeWidth: 1.75,
  strokeLinecap: "round" as const,
  strokeLinejoin: "round" as const,
};

export function NavIconGlyph({
  name,
  className,
}: {
  name: NavIcon;
  className?: string;
}) {
  const props = { className, viewBox: "0 0 24 24", "aria-hidden": true };

  switch (name) {
    case "home":
      return (
        <svg {...props}>
          <path {...stroke} d="M4 10.5 12 4l8 6.5V20a1 1 0 0 1-1 1h-5v-6H10v6H5a1 1 0 0 1-1-1v-9.5Z" />
        </svg>
      );
    case "campaigns":
      return (
        <svg {...props}>
          <path {...stroke} d="M4 10v4h2l5 3V7L6 10H4Z" />
          <path {...stroke} d="M14 9.5a3.5 3.5 0 0 1 0 5" />
          <path {...stroke} d="M16.5 7.5a6.5 6.5 0 0 1 0 9" />
        </svg>
      );
    case "audience":
      return (
        <svg {...props}>
          <circle {...stroke} cx="12" cy="12" r="8" />
          <circle {...stroke} cx="12" cy="12" r="3" />
          <path {...stroke} d="M12 4v2M12 18v2M4 12h2M18 12h2" />
        </svg>
      );
    case "loyalty":
      return (
        <svg {...props}>
          <path
            {...stroke}
            d="m12 3.5 2.2 4.5 5 .7-3.6 3.5.9 5-4.5-2.4L7.5 17.2l.9-5L4.8 8.7l5-.7L12 3.5Z"
          />
        </svg>
      );
    case "memberships":
      return (
        <svg {...props}>
          <path {...stroke} d="M12 3 20 8.5v7L12 21 4 15.5v-7L12 3Z" />
          <path {...stroke} d="M12 8.5v7M8.5 10.5 12 12.5l3.5-2" />
        </svg>
      );
    case "customize":
      return (
        <svg {...props}>
          <circle {...stroke} cx="12" cy="12" r="3" />
          <path
            {...stroke}
            d="M12 3.5v2.2M12 18.3v2.2M4.9 6.5l1.6 1.6M17.5 15.9l1.6 1.6M3.5 12h2.2M18.3 12h2.2M4.9 17.5l1.6-1.6M17.5 8.1l1.6-1.6"
          />
        </svg>
      );
    case "reports":
      return (
        <svg {...props}>
          <path {...stroke} d="M5 19V9M10 19V5M15 19v-7M20 19V8" />
        </svg>
      );
    case "account":
      return (
        <svg {...props}>
          <circle {...stroke} cx="12" cy="8" r="3.5" />
          <path {...stroke} d="M5 19.5c1.6-3.2 4-4.8 7-4.8s5.4 1.6 7 4.8" />
        </svg>
      );
    case "resources":
      return (
        <svg {...props}>
          <path {...stroke} d="M5 5.5h6a2 2 0 0 1 2 2V20l-3-1.5L7 20V7.5a2 2 0 0 0-2-2Z" />
          <path {...stroke} d="M13 7.5a2 2 0 0 1 2-2h4V20l-3-1.5L13 20V7.5Z" />
        </svg>
      );
    case "help":
      return (
        <svg {...props}>
          <circle {...stroke} cx="12" cy="12" r="8.5" />
          <path {...stroke} d="M9.5 9.5a2.5 2.5 0 1 1 3.8 2.1c-.8.5-1.3 1-1.3 2" />
          <path {...stroke} d="M12 16.5h.01" />
        </svg>
      );
    case "contact":
      return (
        <svg {...props}>
          <path
            {...stroke}
            d="M7 4.5h3l1.2 3-1.8 1.2a10 10 0 0 0 4.9 4.9L15.5 12l3 1.2v3A1.8 1.8 0 0 1 16.7 18 13.5 13.5 0 0 1 6 7.3 1.8 1.8 0 0 1 7 4.5Z"
          />
        </svg>
      );
  }
}
