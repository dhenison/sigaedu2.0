---
name: SIGAEDU Core
colors:
  surface: '#fdf8f8'
  surface-dim: '#ddd9d8'
  surface-bright: '#fdf8f8'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f7f3f2'
  surface-container: '#f1edec'
  surface-container-high: '#ebe7e6'
  surface-container-highest: '#e5e2e1'
  on-surface: '#1c1b1b'
  on-surface-variant: '#444748'
  inverse-surface: '#313030'
  inverse-on-surface: '#f4f0ef'
  outline: '#747878'
  outline-variant: '#c4c7c7'
  surface-tint: '#5f5e5e'
  primary: '#000000'
  on-primary: '#ffffff'
  primary-container: '#1c1b1b'
  on-primary-container: '#858383'
  inverse-primary: '#c8c6c5'
  secondary: '#705d00'
  on-secondary: '#ffffff'
  secondary-container: '#fcd400'
  on-secondary-container: '#6e5c00'
  tertiary: '#000000'
  on-tertiary: '#ffffff'
  tertiary-container: '#191c1e'
  on-tertiary-container: '#818487'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e5e2e1'
  primary-fixed-dim: '#c8c6c5'
  on-primary-fixed: '#1c1b1b'
  on-primary-fixed-variant: '#474746'
  secondary-fixed: '#ffe16d'
  secondary-fixed-dim: '#e9c400'
  on-secondary-fixed: '#221b00'
  on-secondary-fixed-variant: '#544600'
  tertiary-fixed: '#e0e3e6'
  tertiary-fixed-dim: '#c4c7ca'
  on-tertiary-fixed: '#191c1e'
  on-tertiary-fixed-variant: '#44474a'
  background: '#fdf8f8'
  on-background: '#1c1b1b'
  surface-variant: '#e5e2e1'
typography:
  headline-xl:
    fontFamily: Inter
    fontSize: 40px
    fontWeight: '700'
    lineHeight: 48px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 14px
    letterSpacing: 0.04em
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  base: 8px
  xs: 4px
  sm: 12px
  md: 24px
  lg: 48px
  xl: 80px
  container-max: 1440px
  gutter: 24px
---

## Brand & Style
The design system for SIGAEDU is built on the pillars of **academic authority, modern accessibility, and structural clarity**. It targets educational institutions requiring a high-fidelity interface that balances professional rigor with a vibrant, motivating energy.

The aesthetic follows a **High-Fidelity Corporate** direction, blending the stability of a neutral layout with "Cristálico" (crystalline) accents. This style uses controlled glassmorphism to signify modern density without sacrificing the legibility expected of a SaaS platform. The emotional response is one of reliability and focus, punctuated by high-contrast yellow accents that drive action and celebrate achievement.

## Colors
The palette is architectural, using depth and contrast to organize information.

- **Primary (Deep Black):** Used for structural elements, headers, and primary text to establish authority.
- **Secondary (Vibrant Yellow):** Reserved for high-priority calls to action, progress indicators, and "success" highlights. 
- **Neutral (Ice/Gelo):** Used for secondary backgrounds and structural borders to soften the interface.
- **Background:** A specialized off-white (#F8F9FA) reduces eye strain during long administrative or study sessions.

**Color-Coding Strategy:**
- Use Yellow for "Active/In Progress" or "Primary Action."
- Use Deep Black for "Stable/Completed" or "Navigation."
- Use Ice for "Static/Supportive" information.

## Typography
Inter is utilized for its exceptional legibility in data-heavy SaaS environments. The type scale is generous to ensure accessibility across diverse age groups in education.

**Information Differentiation:**
Bold weights (600-700) are used strictly for navigation and categorical headers. Semantic color-coding should be applied to labels: black for titles, dark grey for body text, and the secondary yellow for interactive links or status highlights.

## Layout & Spacing
The design system employs a **Fixed Grid** philosophy for desktop to maintain the "Classic High-Fidelity" feel, centered within a 1440px max-width container.

- **Desktop (12 Columns):** 24px gutters, 80px side margins.
- **Tablet (8 Columns):** 16px gutters, 40px side margins.
- **Mobile (4 Columns):** 16px gutters, 16px side margins.

A strict 8px spacing rhythm ensures vertical consistency. Large cards should be separated by `lg` (48px) spacing to prevent visual clutter in administrative dashboards.

## Elevation & Depth
Elevation is achieved through the **"Cristálico"** effect and subtle tonal layering:

1.  **Level 0 (Background):** #F8F9FA.
2.  **Level 1 (Cards/Base):** Solid #FFFFFF with a 1px border of #F0F2F5. No shadow, or a very faint 4px blur, 2% opacity black shadow.
3.  **Level 2 (Navigation/Crystalline):** Backdrop filter: `blur(12px)` with a 70% white tint. This is used for top navigation bars and floating side menus to create the "Cristálico" feel.
4.  **Level 3 (Modals):** Solid #FFFFFF with a defined ambient shadow (16px blur, 10% opacity).

## Shapes
To maintain a professional and sturdy appearance, this design system uses **Soft (0.25rem)** roundedness. This provides a clean, modern edge without appearing too "playful" or consumer-grade.

- **Standard Elements (Buttons, Inputs):** 4px (`rounded`).
- **Large Elements (Cards, Tables):** 8px (`rounded-lg`).
- **Containers (Modals):** 12px (`rounded-xl`).

## Components
Consistent styling across the SAAS platform is governed by these rules:

- **Large Cards:** White backgrounds, 8px radius, and generous 32px internal padding. Headers within cards should have a subtle bottom border in #F0F2F5.
- **Crystalline Menus:** Sidebars and headers use the 70% translucent white with a 1px inner stroke for a "glass" edge.
- **Buttons:** 
    - *Primary:* Vibrant Yellow (#FFD700) with Black text for maximum visibility.
    - *Secondary:* Deep Black (#1A1A1A) with White text for structural actions.
    - *Ghost:* No fill, Deep Black outline for tertiary actions.
- **Tables:** High-fidelity execution with #F8F9FA header rows, 16px cell padding, and thin #F0F2F5 horizontal dividers. No vertical dividers.
- **Input Fields:** 1px border (#F0F2F5) that transitions to Deep Black on focus. Labels always sit above the field in `label-md` style.
- **Chips/Status:** Use the Ice/Gelo (#F0F2F5) background with `label-sm` text for neutral states, and Yellow for active status alerts.