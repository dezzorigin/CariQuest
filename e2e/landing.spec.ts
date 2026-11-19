import { test, expect } from "@playwright/test";

test.describe("landing CariQuest", () => {
  test("judul + hero + fakta data demo tampil", async ({ page }) => {
    await page.goto("/");
    await expect(page).toHaveTitle(/CariQuest/);
    await expect(
      page.getByRole("heading", { name: /Tugas kampusmu/ }),
    ).toBeVisible();
    // Fakta data demo asli repo (bukan angka karangan).
    await expect(page.getByText("Rp30.000–Rp300.000")).toBeVisible();
    await expect(page.getByText("4.8").first()).toBeVisible();
    await expect(
      page.getByRole("link", { name: "Lihat Papan Quest" }),
    ).toBeVisible();
  });

  test("tag OG/Twitter lengkap di head", async ({ page }) => {
    await page.goto("/");
    const ogTitle = await page
      .locator('meta[property="og:title"]')
      .getAttribute("content");
    expect(ogTitle).toContain("CariQuest");
    const ogImage = await page
      .locator('meta[property="og:image"]')
      .getAttribute("content");
    expect(ogImage).toBe("https://cariquest.pages.dev/og-image.png");
    const card = await page
      .locator('meta[name="twitter:card"]')
      .getAttribute("content");
    expect(card).toBe("summary_large_image");
  });

  test("papan quest: 5 kartu demo + saring Selesai = 1", async ({ page }) => {
    await page.goto("/");
    const board = page.locator("#quest-list");
    const cards = board.locator(".ticket");
    await expect(cards).toHaveCount(5);
    await expect(
      board.getByRole("heading", { name: "Buat Desain UI Mobile App" }),
    ).toBeVisible();
    await expect(
      board.getByRole("heading", { name: "Translasi Jurnal Bahasa Inggris" }),
    ).toBeVisible();

    await page.getByRole("button", { name: "Selesai", exact: true }).click();
    await expect(cards.filter({ visible: true })).toHaveCount(1);
    await expect(
      board.getByRole("heading", { name: "Coding Tugas OOP Java" }),
    ).toBeVisible();

    await page.getByRole("button", { name: "Semua", exact: true }).click();
    await expect(cards.filter({ visible: true })).toHaveCount(5);
  });

  test("tabel akun demo: 3 akun + kata sandi demo123", async ({ page }) => {
    await page.goto("/");
    const table = page.locator(".demo-table");
    await expect(table.getByText("expert@demo.com")).toBeVisible();
    await expect(table.getByText("seeker@demo.com")).toBeVisible();
    await expect(table.getByText("admin@demo.com")).toBeVisible();
    await expect(table.getByText("Aldi Firmansyah")).toBeVisible();
    await expect(table.getByText("Bunga Pratiwi")).toBeVisible();
    await expect(page.locator(".copy-pass")).toHaveText("demo123");
  });

  test("alur 4 langkah + peran tampil", async ({ page }) => {
    await page.goto("/");
    await expect(
      page.getByRole("heading", { name: "Seeker memasang quest" }),
    ).toBeVisible();
    await expect(
      page.getByRole("heading", { name: "Review, rating, dana cair" }),
    ).toBeVisible();
    await expect(
      page.getByRole("heading", { name: /Pasang quest, terima hasil/ }),
    ).toBeVisible();
    await expect(
      page.getByRole("heading", { name: /Portofolio, bid, dompet/ }),
    ).toBeVisible();
  });

  test("og-image.png bisa diunduh sebagai gambar", async ({ page }) => {
    const res = await page.request.get("/og-image.png");
    expect(res.status()).toBe(200);
    expect(res.headers()["content-type"]).toContain("image/png");
    expect((await res.body()).length).toBeGreaterThanOrEqual(10240);
  });

  test("tanpa scroll horizontal", async ({ page }) => {
    await page.goto("/");
    const overflow = await page.evaluate(
      () => document.documentElement.scrollWidth - window.innerWidth,
    );
    expect(overflow).toBeLessThanOrEqual(1);
  });
});
