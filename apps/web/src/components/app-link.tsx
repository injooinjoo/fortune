'use client';

import NextLink from 'next/link';
import { usePathname } from 'next/navigation';
import type { AnchorHTMLAttributes } from 'react';

import { requiresNativeNavigation } from '@/lib/href';

type AppLinkProps = Omit<AnchorHTMLAttributes<HTMLAnchorElement>, 'href'> & {
  href: string;
  prefetch?: boolean | null;
};

/**
 * Preserve Next client navigation for ASCII routes, but use a native document
 * navigation whenever Korean route state would be copied into an RSC header.
 */
export function AppLink({ href, prefetch, ...props }: AppLinkProps) {
  const currentPath = usePathname();

  if (requiresNativeNavigation(currentPath, href)) {
    return <a href={href} {...props} />;
  }

  return <NextLink href={href} prefetch={prefetch} {...props} />;
}
