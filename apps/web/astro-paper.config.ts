import { defineAstroPaperConfig } from "./src/types/config";
import { SITE_NAME } from "./src/site";

export default defineAstroPaperConfig({
  site: {
    // The origin a local build links to. A deploy builds for its own
    // environment's origin instead: astro.config.ts takes PUBLIC_SITE_URL
    // over this, and the rest of the site reads Astro's resolved `site`.
    url: "https://astro-paper.example.com/",
    title: SITE_NAME,
    description: "A minimal, responsive and SEO-friendly Astro blog theme.",
    author: "Sat Naing",
    profile: "https://satna.ing",
    ogImage: "default-og.jpg",
    lang: "en",
    timezone: "Asia/Bangkok",
    dir: "ltr",
  },
  posts: {
    perPage: 4,
    perIndex: 4,
    scheduledPostMargin: 15 * 60 * 1000,
  },
  features: {
    lightAndDarkMode: true,
    dynamicOgImage: true,
    showArchives: true,
    showBackButton: true,
    editPost: {
      enabled: true,
      url: "https://github.com/sourceplane/astro-paper/edit/main/apps/web/",
    },
    search: "pagefind",
  },
  socials: [
    { name: "github",   url: "https://github.com/sourceplane/astro-paper" },
    { name: "x",        url: "https://x.com/username" },
    { name: "linkedin", url: "https://www.linkedin.com/in/username/" },
    { name: "mail",     url: "mailto:yourmail@gmail.com" },
  ],
  shareLinks: [
    { name: "whatsapp", url: "https://wa.me/?text=" },
    { name: "facebook", url: "https://www.facebook.com/sharer.php?u=" },
    { name: "x",        url: "https://x.com/intent/post?url=" },
    { name: "telegram", url: "https://t.me/share/url?url=" },
    { name: "pinterest", url: "https://pinterest.com/pin/create/button/?url=" },
    { name: "mail",     url: "mailto:?subject=See%20this%20post&body=" },
  ],
});