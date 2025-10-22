import { chromium } from 'playwright';
import fs from 'fs';
import path from 'path';

const BASE_URL = 'http://localhost:4000';
const LOGIN_EMAIL = 'demo@ad.nexus';
const LOGIN_PASSWORD = 'adnexus';

// Define viewport sizes
const viewports = [
  { name: 'MOBILE', width: 375, height: 667, label: 'iPhone SE' },
  { name: 'TABLET', width: 768, height: 1024, label: 'iPad' },
  { name: 'DESKTOP', width: 1920, height: 1080, label: 'Desktop' }
];

const screenshotDir = '/Users/z/work/adnexus/dsp/responsive-screenshots';

async function ensureDir(dir) {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
}

async function loginUser(page) {
  console.log('🔐 Logging in...');
  
  await page.goto(`${BASE_URL}/login`, { waitUntil: 'networkidle' });
  await page.waitForSelector('input[name="email"]', { timeout: 10000 });
  
  // Fill login form
  await page.fill('input[name="email"]', LOGIN_EMAIL);
  await page.fill('input[name="password"]', LOGIN_PASSWORD);
  
  // Click sign in button
  await page.click('button[type="submit"]');
  
  // Wait for any navigation to complete
  await page.waitForLoadState('networkidle');
  await page.waitForTimeout(2000);
  
  const currentUrl = page.url();
  console.log(`✓ Successfully logged in - Redirected to: ${currentUrl}`);
}

async function testPage(page, url, viewportConfig, pageLabel) {
  try {
    console.log(`\n=== Testing ${pageLabel} at ${viewportConfig.name} (${viewportConfig.width}x${viewportConfig.height}) ===`);
    
    await page.goto(url, { waitUntil: 'networkidle' });
    await page.waitForLoadState('networkidle');
    
    // Wait for main content to load
    await page.waitForSelector('body', { timeout: 5000 });
    await page.waitForTimeout(1500);
    
    // Take screenshot
    const filename = `${pageLabel}-${viewportConfig.name.toLowerCase()}.png`;
    const filepath = path.join(screenshotDir, filename);
    
    await page.screenshot({ path: filepath, fullPage: true });
    console.log(`✓ Screenshot saved: ${filename}`);
    
    // Check page title
    const pageTitle = await page.title();
    console.log(`✓ Page title: ${pageTitle}`);
    
    // Check for breadcrumbs
    try {
      const breadcrumbElement = page.locator('[class*="breadcrumb"]').first();
      const isVisible = await breadcrumbElement.isVisible().catch(() => false);
      if (isVisible) {
        const breadcrumbText = await breadcrumbElement.textContent();
        console.log(`✓ Breadcrumbs: "${breadcrumbText?.trim()}"`);
      } else {
        console.log(`⚠ Breadcrumbs: Not visible`);
      }
    } catch (e) {
      console.log(`⚠ Breadcrumbs: Check failed`);
    }
    
    // Check for stat cards (look for common patterns)
    try {
      const statCards = page.locator('[class*="stat-card"], [class*="stat_card"]');
      const statCount = await statCards.count();
      if (statCount > 0) {
        console.log(`✓ Stat cards found: ${statCount}`);
        
        // Check the grid layout
        const parent = await statCards.first().locator('..').getAttribute('class');
        console.log(`  Grid parent classes: ${parent}`);
      } else {
        console.log(`⚠ Stat cards: Not found (may use different classes)`);
      }
    } catch (e) {
      console.log(`⚠ Stat cards: Unable to check`);
    }
    
    // Look for cards more broadly
    try {
      const allCards = page.locator('[class*="card"]');
      const cardCount = await allCards.count();
      if (cardCount > 0) {
        console.log(`✓ Card elements found: ${cardCount}`);
      }
    } catch (e) {
      console.log(`⚠ Card search failed`);
    }
    
    // Check for profile information
    try {
      const profileText = await page.locator('body').textContent();
      if (profileText?.includes('Demo User') || profileText?.includes('Profile')) {
        console.log(`✓ Profile content visible`);
      }
    } catch (e) {
      // Ignore
    }
    
    // Check grid layout
    try {
      const gridElement = page.locator('[class*="grid"]').first();
      const isGridVisible = await gridElement.isVisible().catch(() => false);
      if (isGridVisible) {
        const gridClasses = await gridElement.getAttribute('class');
        console.log(`✓ Grid layout: ${gridClasses}`);
      }
    } catch (e) {
      console.log(`⚠ Grid layout: Not detected`);
    }
    
    return filepath;
    
  } catch (error) {
    console.error(`✗ Error testing ${viewportConfig.name}: ${error.message}`);
    throw error;
  }
}

async function runTests() {
  console.log('🚀 Starting Responsive Design Tests');
  console.log(`Base URL: ${BASE_URL}`);
  console.log(`\nViewport configurations:`);
  viewports.forEach(v => console.log(`  • ${v.name}: ${v.width}x${v.height} (${v.label})`));
  
  await ensureDir(screenshotDir);
  
  const browser = await chromium.launch({ headless: true });
  
  try {
    // Create a single context and page for all tests to maintain session
    console.log('\n🌐 Initializing browser context with DESKTOP viewport...');
    const context = await browser.newContext({
      viewport: { width: 1920, height: 1080 }
    });
    
    const page = await context.newPage();
    
    // Login once
    await loginUser(page);
    
    // Test /myaccount page at different sizes
    console.log('\n\n📱 Testing /myaccount Page');
    console.log('='.repeat(60));
    
    for (const viewport of viewports) {
      // Set viewport size
      await page.setViewportSize({ width: viewport.width, height: viewport.height });
      await page.waitForTimeout(500);
      
      await testPage(page, `${BASE_URL}/myaccount`, viewport, 'myaccount');
    }
    
    // Test dashboard page
    console.log('\n\n🎯 Testing Dashboard Page');
    console.log('='.repeat(60));
    
    for (const viewport of viewports) {
      // Set viewport size
      await page.setViewportSize({ width: viewport.width, height: viewport.height });
      await page.waitForTimeout(500);
      
      await testPage(page, `${BASE_URL}/dashboards`, viewport, 'dashboards');
    }
    
    // Also test home page
    console.log('\n\n🏠 Testing Home Page (/)');
    console.log('='.repeat(60));
    
    for (const viewport of viewports) {
      // Set viewport size
      await page.setViewportSize({ width: viewport.width, height: viewport.height });
      await page.waitForTimeout(500);
      
      await testPage(page, `${BASE_URL}/`, viewport, 'home');
    }
    
    await context.close();
    
    console.log('\n\n✅ All tests completed!');
    console.log(`Screenshots saved to: ${screenshotDir}`);
    console.log('\nScreenshot files:');
    const files = fs.readdirSync(screenshotDir).sort();
    files.forEach(f => console.log(`  • ${f}`));
    
  } catch (error) {
    console.error('❌ Test suite failed:', error.message);
    console.error(error);
    process.exit(1);
  } finally {
    await browser.close();
  }
}

runTests();
