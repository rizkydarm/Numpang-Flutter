---
name: Amber Map System
colors:
  surface: '#121414'
  surface-dim: '#121414'
  surface-bright: '#38393a'
  surface-container-lowest: '#0c0f0f'
  surface-container-low: '#1a1c1c'
  surface-container: '#1e2020'
  surface-container-high: '#282a2b'
  surface-container-highest: '#333535'
  on-surface: '#e2e2e2'
  on-surface-variant: '#d2c5ac'
  inverse-surface: '#e2e2e2'
  inverse-on-surface: '#2f3131'
  outline: '#9b9079'
  outline-variant: '#4e4633'
  surface-tint: '#f3c01a'
  primary: '#ffebc2'
  on-primary: '#3e2e00'
  primary-container: '#ffca28'
  on-primary-container: '#705600'
  inverse-primary: '#765b00'
  secondary: '#9ecaff'
  on-secondary: '#003258'
  secondary-container: '#1e95f2'
  on-secondary-container: '#002b4d'
  tertiary: '#daf0fd'
  on-tertiary: '#1e333c'
  tertiary-container: '#bed4e0'
  on-tertiary-container: '#475c66'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#ffdf93'
  primary-fixed-dim: '#f3c01a'
  on-primary-fixed: '#241a00'
  on-primary-fixed-variant: '#594400'
  secondary-fixed: '#d1e4ff'
  secondary-fixed-dim: '#9ecaff'
  on-secondary-fixed: '#001d36'
  on-secondary-fixed-variant: '#00497d'
  tertiary-fixed: '#cfe6f2'
  tertiary-fixed-dim: '#b4cad6'
  on-tertiary-fixed: '#071e27'
  on-tertiary-fixed-variant: '#354a53'
  background: '#121414'
  on-background: '#e2e2e2'
  surface-variant: '#333535'
typography:
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  title-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.5px
  label-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  edge_margin: 16px
  gutter: 12px
  stack_sm: 8px
  stack_md: 16px
  stack_lg: 24px
---

## Brand & Style

This design system is a utility-first framework designed for high-frequency navigation and local discovery. The brand personality is dependable, energetic, and highly legible, prioritizing rapid information retrieval over decorative elements. It utilizes a **Corporate / Modern** style heavily influenced by Material Design 3 principles, focusing on tonal relationships and functional elevation.

The primary objective is to provide a "heads-up" interface that remains usable in various lighting conditions, specifically optimized for low-light and night-time use via a native dark-first approach. The aesthetic is characterized by deep canvas depth, a warm primary accent that signals action and expertise, and a structured hierarchy that handles complex data layers without visual clutter.

## Colors

The color palette centers on an authoritative Amber primary (#FFCA28) used for critical actions and state indicators. A vibrant "User Blue" (#2196F3) is reserved exclusively for the user’s location dot and active route polyline to ensure it is the most prominent element on the map canvas.

**Surface Strategy:**
- **Dark Mode (Default):** Employs a "Muted High-Contrast" approach. Surfaces use deep grays and blacks (#1A1C1C) to reduce glare and eye strain. Labels and active routes utilize high-luminance tints and the Amber primary to maintain strict legibility.
- **Light Mode:** Uses high-reflectance whites and cool grays to keep the map readable under direct sunlight.
- **Status Colors:** Standardized semantic colors (Success Green, Error Red) apply for traffic conditions and ETA updates.

## Typography

The design system utilizes **Plus Jakarta Sans** for its exceptional legibility at small sizes and its friendly, modern geometric curves. This choice maintains a clean, functional look while feeling more contemporary than traditional neo-grotesques.

Typography is used to define spatial hierarchy. Headlines are tight and bold for place names, while labels utilize increased letter-spacing for metadata (distance, time, price). On the map itself, labels should use a subtle text halo (black in dark mode, white in light mode) to ensure contrast against varying terrain colors.

## Layout & Spacing

This design system uses a **Fluid Layout** with a strict 4px baseline grid. Content should typically adhere to a 16px safe area from the screen edges to ensure floating elements do not feel cramped.

Floating elements (Search Bar, FABs) are positioned contextually over the map. The vertical stack follows a "Bottom-Heavy" priority: the Bottom Sheet and Bottom Navigation Bar take precedence for thumb-reachability, while the Floating Search Bar remains at the top to keep the center of the map clear for visual navigation.

## Elevation & Depth

Visual hierarchy is managed through **Tonal Layers** and **Ambient Shadows**. This design system avoids harsh borders, instead using depth to separate the map interface from the functional UI controls.

- **Level 0 (Map):** The base canvas.
- **Level 1 (Bottom Sheet):** In dark mode, this surface is slightly lightened from the background color to indicate elevation.
- **Level 2 (Search Bar & Chips):** Uses a medium surface tint to signal persistence and interactivity.
- **Level 3 (Floating Action Buttons):** Highest tonal contrast to signal primary interaction and "pressability."

In Dark Mode, elevation is communicated by lightening the surface color of the containers (Surface Tint) rather than relying solely on shadow opacity.

## Shapes

The design system uses a **Rounded** (8px base) shape language to balance professional structure with modern softness.

- **Standard Containers:** Cards, Bottom Sheets, and Search Bars use a 0.5rem (8px) radius as the default.
- **Large Elements:** Larger modals or expanded background containers use a 1rem (16px) radius.
- **Interactive Elements:** Selection chips and FABs utilize standardized rounded corners to distinguish them as tactile, interactable objects while maintaining a structured grid.
- **Drag Handle:** A 4px thick, 32px wide rounded bar centered at the top of the Bottom Sheet.

## Components

**Floating Search Bar**
A persistent top-mounted bar with an 8px corner radius. It includes the `microphone` icon for voice search on the right and a leading "Search here" placeholder.

**Horizontal Scrollable Chips**
Rounded buttons (8px radius) located immediately below the search bar. Use `primary_color` for the active state and a dark neutral surface for inactive states. Each chip should feature a Material Symbol (e.g., Restaurants, Gas, Groceries).

**Bottom Navigation Bar**
A fixed 5-tab bar (Explore, Go, Saved, Contribute, Updates). Icons use the "Rounded" Material Symbols set. The active tab is indicated by an Amber rounded background or a bold Amber icon tint.

**Bottom Sheet**
Features a persistent drag handle. The sheet transitions from a "Collapsed" state (showing name and rating) to a "Half" state (showing primary actions) and "Full" state (showing reviews and details). It uses a 16px radius on the top corners when fully expanded.

**Floating Action Buttons (FAB)**
Rounded buttons (8px radius) positioned 16px above the Bottom Navigation or Bottom Sheet.
- **Primary FAB:** The `navigation` icon in a high-contrast Amber container.
- **Utility FABs:** The `crosshair` (center-to-my-location) and `plus` (report/add) icons in smaller, secondary-styled rounded containers.

**User Location Dot**
A 12px vibrant blue circle (#2196F3) with a white 2px border and a large, low-opacity blue pulse animation to indicate GPS accuracy.