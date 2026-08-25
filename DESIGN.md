# Design System — India AI Inference Chip v1.0

This is the implementation source of truth for the IAIC website and future product interfaces. The companion brand guide lives in [`docs/brand-identity.md`](docs/brand-identity.md).

## Product Context

- **What this is:** An open-source project building efficient AI inference silicon and the surrounding software stack from India.
- **Who it is for:** Hardware and verification engineers, RISC-V and compiler developers, AI researchers, students, startups, universities, and global contributors.
- **Space/industry:** Semiconductors, AI infrastructure, open hardware, RISC-V, and physical AI.
- **Project type:** Technical marketing site and open-source project documentation.

## Aesthetic Direction

- **Direction:** Circuit & Chakra — industrial editorial with a disciplined tricolour signal.
- **Decoration level:** Intentional. Use a visible grid, hairline rules, chip geometry, and small chakra/circuit motifs. Avoid ornamental nationalism.
- **Mood:** Capable, open, grounded, and forward-looking. It should feel like serious engineering that welcomes people in.
- **Memorable thing:** India-originated inference silicon, built in public with the world.

## Typography

- **Display and body:** Hind, a screen-optimised Indian typeface with Latin and Devanagari support. Use weight and size to create hierarchy rather than switching to a generic tech font.
- **Technical/data:** IBM Plex Mono with tabular numerals for RTL, benchmark, and interface details.
- **Devanagari accent:** Use Hind Devanagari for short phrases such as `भारत से · दुनिया के लिए` (from India, for the world). Devanagari is an accent and invitation, never a language gate.
- **Loading:** Prefer `next/font/google` or a self-hosted WOFF2 copy. Never fall back to system-ui as the primary identity font.
- **Scale:** Display 96/0.94, H1 72/0.96, H2 56/0.98, H3 20/1.15, body 16/1.55, small 12/1.4, mono 11/1.4.

## Color

- **Approach:** Balanced. Flag colours carry meaning; Indian material colours provide warmth and range; navy and ivory keep the system legible.
- **Ashoka Navy:** `#000080` — heritage signal, links, focus rings, and high-confidence technical emphasis.
- **Chip Ink:** `#071A2B` — primary text, dark surfaces, and primary actions.
- **Bharat Saffron:** `#FF9933` — action, energy, live status, and highlighted words.
- **Bharat Green:** `#138808` — progress, verification, shipped work, and positive status.
- **Chakra White:** `#FFFFFF` — the flag reference and high-contrast text on dark surfaces.
- **Ivory:** `#FBF8F1` — primary light canvas; warmer and more human than pure white.
- **Sand:** `#F1EBDD` — secondary surface and quiet section contrast.
- **Terracotta:** `#B85C38` — Indian earth accent for editorial callouts; use sparingly.
- **Turmeric:** `#E0A52B` — caution, annotation, and secondary highlight.
- **Neem:** `#526A4A` — muted ecological/edge-compute accent.
- **Dark mode:** Use Chip Ink as the base, reduce saffron/green saturation by 10–15% on large surfaces, and preserve Ivory for readable text. Never place saffron or green body text on Ivory below accessible contrast.

## Spacing

- **Base unit:** 4px.
- **Density:** Comfortable for documentation; compact for telemetry and tables.
- **Scale:** 2xs(2), xs(4), sm(8), md(16), lg(24), xl(32), 2xl(48), 3xl(64), 4xl(96), 5xl(144).

## Layout

- **Approach:** Hybrid. Use a disciplined grid for technical content and a slightly editorial asymmetry for mission/brand pages.
- **Grid:** 4 columns mobile, 8 columns tablet, 12 columns desktop.
- **Max content width:** 1240px.
- **Gutters:** 18px mobile, 32px desktop.
- **Rules:** 1px lines in `rgba(7,26,43,.16)` on light surfaces and `rgba(255,255,255,.16)` on dark surfaces.
- **Border radius:** sm(3px), md(6px), lg(10px), pill(9999px). Use small radii for hardware credibility; reserve pills for tags/status only.

## Graphic System

- **Primary mark:** Signal Chakra, a compact chip frame containing a reduced Ashoka Chakra and three horizontal signal rails in saffron, white, and green.
- **Motif:** 12 or 16 radial spokes intersecting a square chip grid. Use as a faint background watermark, not a decorative sticker.
- **Tricolour rule:** When the flag palette appears as a stripe, order it saffron → white → green. Keep the white band visible on light backgrounds with a fine rule.
- **Image treatment:** Prefer real boards, RTL diagrams, waveforms, labs, hands, and Indian built environments. Use high-contrast crops, technical labels, and restrained overlays.

## Motion

- **Approach:** Intentional but restrained.
- **Easing:** enter(ease-out), exit(ease-in), move(ease-in-out).
- **Duration:** micro(80ms), short(180ms), medium(320ms), long(520ms).
- **Rule:** Motion should communicate signal, progress, or connection. Avoid perpetual spinning chakra animations and decorative parallax.

## Decisions Log

| Date | Decision | Rationale |
|------|----------|-----------|
| 2026-08-26 | Circuit & Chakra direction | Gives an India-specific identity to serious semiconductor work without turning the interface into a flag motif. |
| 2026-08-26 | Hind + IBM Plex Mono | Hind supplies an Indian Latin/Devanagari voice; Plex Mono supports technical evidence and telemetry. |
| 2026-08-26 | Flag tones plus Indian material accents | Saffron, white, green, and navy are recognisable; terracotta, turmeric, and neem add range for real communication needs. |
