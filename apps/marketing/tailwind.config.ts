import type { Config } from 'tailwindcss';
import preset from '@saas/config/tailwind';

export default {
  presets: [preset],
  content: [
    './src/**/*.{astro,html,js,jsx,ts,tsx,md,mdx}',
    '../../packages/ui/src/**/*.{ts,tsx}',
  ],
} satisfies Config;
