import * as React from "react"
import { Slot } from "@radix-ui/react-slot"
import { cva, type VariantProps } from "class-variance-authority"

import { cn } from "@/lib/utils"

const buttonVariants = cva(
  "inline-flex items-center justify-center gap-2 whitespace-nowrap text-sm font-medium transition-all focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:size-4 [&_svg]:shrink-0",
  {
    variants: {
      variant: {
        // Liquid Glass Primary Button
        default: "glass-button-light dark:glass-button-dark text-primary-foreground shadow-sm hover:shadow-lg hover:scale-[1.02] active:scale-[0.98]",
        
        // Glass Secondary Button
        secondary: "glass-card text-secondary-foreground hover:shadow-lg hover:scale-[1.02] active:scale-[0.98]",
        
        // Glass Outline Button
        outline: "border border-input bg-transparent backdrop-blur-sm hover:bg-accent hover:text-accent-foreground hover:shadow-md hover:scale-[1.02] active:scale-[0.98]",
        
        // Glass Ghost Button
        ghost: "bg-transparent backdrop-blur-sm hover:bg-accent hover:text-accent-foreground hover:shadow-sm hover:scale-[1.02] active:scale-[0.98]",
        
        // Glass Destructive Button
        destructive: "bg-destructive/90 text-destructive-foreground backdrop-blur-sm shadow-sm hover:bg-destructive hover:shadow-lg hover:scale-[1.02] active:scale-[0.98]",
        
        // Glass Link Button
        link: "text-primary underline-offset-4 hover:underline hover:scale-[1.02] active:scale-[0.98]",
        
        // Glass Floating Button
        floating: "glass-nav shadow-lg hover:shadow-xl hover:scale-[1.05] active:scale-[0.95] glass-float",
        
        // Glass Shimmer Button
        shimmer: "glass-button-light dark:glass-button-dark text-primary-foreground shadow-sm hover:shadow-lg hover:scale-[1.02] active:scale-[0.98] glass-shimmer",
      },
      size: {
        default: "h-12 px-6 py-3",
        sm: "h-10 px-4 py-2 text-xs",
        lg: "h-14 px-8 py-4 text-base",
        xl: "h-16 px-10 py-5 text-lg",
        icon: "h-12 w-12",
        "icon-sm": "h-10 w-10",
        "icon-lg": "h-14 w-14",
      },
    },
    defaultVariants: {
      variant: "default",
      size: "default",
    },
  }
)

export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  asChild?: boolean
}

const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, asChild = false, ...props }, ref) => {
    const Comp = asChild ? Slot : "button"
    return (
      <Comp
        className={cn(buttonVariants({ variant, size, className }))}
        ref={ref}
        {...props}
      />
    )
  }
)
Button.displayName = "Button"

export { Button, buttonVariants }
