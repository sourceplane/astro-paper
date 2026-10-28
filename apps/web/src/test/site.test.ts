import { experimental_AstroContainer as AstroContainer } from "astro/container";
import { describe, expect, it } from "vitest";
import config from "@/config";
import userConfig from "@/astro-paper.config";
import Header from "../components/Header.astro";
import { SITE_NAME } from "../site";

// Astro escapes text it renders; a site name may carry `&` or `'`.
const escaped = (s: string) =>
  s
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;");

describe("site identity (src/site.ts)", () => {
  it("names the site", () => {
    expect(SITE_NAME.trim()).not.toBe("");
  });

  it("is the title the theme's config carries — not a second copy of the name", () => {
    expect(userConfig.site.title).toBe(SITE_NAME);
    expect(config.site.title).toBe(SITE_NAME);
  });

  it("is what the header says", async () => {
    const container = await AstroContainer.create();
    const html = await container.renderToString(Header);
    expect(html).toContain(escaped(SITE_NAME));
  });
});

describe("the site's origin", () => {
  it("is the origin Astro built for (astro.config.ts's site), which the feed and the OG image use", () => {
    expect(config.site.url).toBe(import.meta.env.SITE);
  });
});
