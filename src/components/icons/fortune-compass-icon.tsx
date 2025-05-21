
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
      {/* Outer circle - thicker and more prominent */}
      <circle cx="12" cy="12" r="10" strokeWidth="2" opacity="0.4" />
      
      {/* Inner decorative elements - more abstract and mystical */}
      <path d="M12 6V2" /> {/* Top line */}
      <path d="M12 22V18" /> {/* Bottom line */}
      <path d="M18 12H22" /> {/* Right line */}
      <path d="M2 12H6" /> {/* Left line */}

      {/* Diagonal lines for a compass feel, but slightly offset for a mystical look */}
      <path d="M15.536 8.464L18.364 5.636" /> {/* NE */}
      <path d="M8.464 15.536L5.636 18.364" /> {/* SW */}
      <path d="M8.464 8.464L5.636 5.636" /> {/* NW */}
      <path d="M15.536 15.536L18.364 18.364" /> {/* SE */}

      {/* Central element - could be a star, a stylized eye, or a simple dot */}
      {/* Option 1: Simple dot */}
      {/* <circle cx="12" cy="12" r="1.5" fill="currentColor" /> */}

      {/* Option 2: Stylized star/sparkle */}
      <path d="M12 9.5L12.7 11.3L14.5 12L12.7 12.7L12 14.5L11.3 12.7L9.5 12L11.3 11.3L12 9.5Z" fill="currentColor" opacity="0.8"/>
      
      {/* Optional: very faint background patterns or runes if the style allows */}
      {/* <path d="M9 10 A3 3 0 0 1 15 10" opacity="0.2" />
      <path d="M9 14 A3 3 0 0 0 15 14" opacity="0.2" /> */}
    </svg>
  );
}

