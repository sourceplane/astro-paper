import { afterEach, describe, expect, it, vi } from "vitest";

// astro.config.ts is evaluated once per build: load it fresh for each case.
async function siteFor(publicSiteUrl: string | undefined): Promise<string | undefined> {
  vi.resetModules();
  if (publicSiteUrl === undefined) delete process.env.PUBLIC_SITE_URL;
  else process.env.PUBLIC_SITE_URL = publicSiteUrl;
  const { default: astroConfig } = await import("../../astro.config");
  return astroConfig.site;
}

const saved = process.env.PUBLIC_SITE_URL;
afterEach(() => {
  if (saved === undefined) delete process.env.PUBLIC_SITE_URL;
  else process.env.PUBLIC_SITE_URL = saved;
});

describe("the build's origin (astro.config.ts)", () => {
  it("is PUBLIC_SITE_URL when a deploy sets it", async () => {
    expect(await siteFor("https://blog-web-stage.example.workers.dev")).toBe(
      "https://blog-web-stage.example.workers.dev"
    );
  });

  it("is the config's own URL for a local build", async () => {
    const { default: userConfig } = await import("../../astro-paper.config");
    expect(await siteFor(undefined)).toBe(userConfig.site.url);
    expect(await siteFor("")).toBe(userConfig.site.url);
  });
});
