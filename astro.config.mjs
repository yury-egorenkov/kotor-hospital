import { defineConfig } from 'astro/config';
import tailwind from '@astrojs/tailwind';
import sitemap from '@astrojs/sitemap';

export default defineConfig({
  site: 'https://jzuobkotor.me',
  integrations: [tailwind(), sitemap()],
  i18n: {
    defaultLocale: 'cnr',
    locales: ['cnr', 'en', 'ru', 'uk', 'tr', 'de', 'es', 'fr'],
    routing: {
      prefixDefaultLocale: false,
    },
  },
});
