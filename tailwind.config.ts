import type { Config } from "tailwindcss";

export default {
    darkMode: ["class"],
    content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
  	extend: {
  		colors: {
  			background: 'hsl(var(--background))',
  			foreground: 'hsl(var(--foreground))',
  			card: {
  				DEFAULT: 'hsl(var(--card))',
  				foreground: 'hsl(var(--card-foreground))'
  			},
  			popover: {
  				DEFAULT: 'hsl(var(--popover))',
  				foreground: 'hsl(var(--popover-foreground))'
  			},
  			primary: {
  				DEFAULT: 'hsl(var(--primary))',
  				foreground: 'hsl(var(--primary-foreground))'
  			},
  			secondary: {
  				DEFAULT: 'hsl(var(--secondary))',
  				foreground: 'hsl(var(--secondary-foreground))'
  			},
  			muted: {
  				DEFAULT: 'hsl(var(--muted))',
  				foreground: 'hsl(var(--muted-foreground))'
  			},
  			accent: {
  				DEFAULT: 'hsl(var(--accent))',
  				foreground: 'hsl(var(--accent-foreground))'
  			},
  			destructive: {
  				DEFAULT: 'hsl(var(--destructive))',
  				foreground: 'hsl(var(--destructive-foreground))'
  			},
  			border: 'hsl(var(--border))',
  			input: 'hsl(var(--input))',
  			ring: 'hsl(var(--ring))'
  		},
  		borderRadius: {
  			lg: 'var(--radius)',
  			md: 'calc(var(--radius) - 18px)',
  			sm: 'calc(var(--radius) - 24px)',
  			'glass': '42px',
  			'glass-sm': '24px',
  			'glass-lg': '100px'
  		},
  		backdropBlur: {
  			'glass': '45px',
  			'glass-sm': '20px',
  			'glass-lg': '60px'
  		},
  		boxShadow: {
  			'glass': '0px 0px 2px rgba(0, 0, 0, 0.1), 0px 1px 8px rgba(0, 0, 0, 0.1)',
  			'glass-lg': '0px 4px 16px rgba(0, 0, 0, 0.1), inset 0px 1px 0px rgba(255, 255, 255, 0.1)',
  			'glass-xl': '0px 8px 32px rgba(0, 0, 0, 0.1), inset 0px 1px 0px rgba(255, 255, 255, 0.2)',
  			'glass-inset': 'inset 3px 3px 0.5px -3.5px #FFFFFF, inset 2px 2px 0.5px -2px #262626, inset -2px -2px 0.5px -2px #262626, inset 0px 0px 0px 1px #A6A6A6, inset 0px 0px 8px #F2F2F2'
  		},
  		keyframes: {
  			'glass-shimmer': {
  				'0%': { backgroundPosition: '-200% 0' },
  				'100%': { backgroundPosition: '200% 0' }
  			},
  			'glass-float': {
  				'0%, 100%': { transform: 'translateY(0px)' },
  				'50%': { transform: 'translateY(-4px)' }
  			},
  			'glass-pulse': {
  				'0%, 100%': { opacity: '1', transform: 'scale(1)' },
  				'50%': { opacity: '0.8', transform: 'scale(1.02)' }
  			}
  		},
  		animation: {
  			'glass-shimmer': 'glass-shimmer 2s infinite',
  			'glass-float': 'glass-float 3s ease-in-out infinite',
  			'glass-pulse': 'glass-pulse 2s ease-in-out infinite'
  		},
  		fontFamily: {
  			'sf-pro': ['SF Pro Display', 'SF Pro Text', '-apple-system', 'BlinkMacSystemFont', 'sans-serif']
  		},
  		letterSpacing: {
  			'glass': '-0.02em',
  			'glass-sm': '-0.01em'
  		}
  	}
  },
  plugins: [require("tailwindcss-animate")],
} satisfies Config;
