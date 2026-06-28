import puppeteer from 'puppeteer';
import { mkdir } from 'node:fs/promises';
import path from 'node:path';

const ROOT = path.resolve(import.meta.dirname, '..');
const WEB_PORT = Number(process.env.WAVE_SCREENSHOT_PORT ?? 8765);
const VIEWPORT = { width: 390, height: 844, deviceScaleFactor: 2 };

const shots = [
  ['home', 'homescreenshot.png'],
  ['dj', 'djscreenshot.png'],
  ['settings', 'settingsscreenshot.png'],
  ['now-playing', 'playingscreenshot.png'],
];

const browser = await puppeteer.launch({
  headless: true,
  args: ['--no-sandbox', '--disable-dev-shm-usage', '--hide-scrollbars'],
});

try {
  const page = await browser.newPage();
  await page.setViewport(VIEWPORT);

  for (const [screen, filename] of shots) {
    const url = `http://127.0.0.1:${WEB_PORT}/?screen=${screen}`;
    console.log(`Capturing ${filename} from ${url}`);
    await page.goto(url, { waitUntil: 'networkidle0', timeout: 60000 });
    await page.waitForSelector('flt-glass-pane', { timeout: 60000 });
    await page.waitForFunction(
      () => {
        const canvas = document.querySelector('canvas');
        return canvas != null && canvas.width > 0;
      },
      { timeout: 60000 },
    );
    await new Promise((resolve) => setTimeout(resolve, 800));
    const out = path.join(ROOT, filename);
    await page.screenshot({ path: out, type: 'png' });
    console.log(`Wrote ${filename}`);
  }
} finally {
  await browser.close();
}
