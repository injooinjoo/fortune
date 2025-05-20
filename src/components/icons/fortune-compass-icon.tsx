import type { SVGProps } from 'react';

export function FortuneCompassIcon(props: SVGProps<SVGSVGElement>) {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="1.5"
      strokeLinecap="round"
      strokeLinejoin="round"
      {...props}
    >
      <circle cx="12" cy="12" r="10" opacity="0.3" />
      <path d="M12 2L12 6" /> {/* N */}
      <path d="M12 18L12 22" /> {/* S */}
      <path d="M2 12L6 12" /> {/* W */}
      <path d="M18 12L22 12" /> {/* E */}
      <path d="M4.93 4.93L7.76 7.76" /> {/* NW */}
      <path d="M16.24 16.24L19.07 19.07" /> {/* SE */}
      <path d="M4.93 19.07L7.76 16.24" /> {/* SW */}
      <path d="M16.24 7.76L19.07 4.93" /> {/* NE */}
      <circle cx="12" cy="12" r="3" strokeWidth="2" />
      <path d="M12 12L15.5 10.5" /> {/* Pointer */}
      {/* Mystical elements: e.g., subtle star or moon shapes if desired */}
      <path d="M10.5 7.5 L12 4.5 L13.5 7.5 Z" fill="currentColor" opacity="0.7" /> {/* Small triangle/star shape */}
    </svg>
  );
}
