#!/usr/bin/env node

const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

const SCREENSHOT_DIR = '/tmp/billing-test-screenshots';

// Create screenshot directory
if (!fs.existsSync(SCREENSHOT_DIR)) {
  fs.mkdirSync(SCREENSHOT_DIR, { recursive: true });
}

async function testBillingPages() {
  const browser = await chromium.launch({ headless: false });
  const context = await browser.newContext();
  const page = await context.newPage();

  try {
    console.log('='.repeat(60));
    console.log('BILLING PAGES TEST SUITE');
    console.log('='.repeat(60));

    // Login first
    console.log('\n[1] Logging in...');
    await page.goto('http://localhost:4000/login', { waitUntil: 'networkidle' });
    await page.fill('input[name="email"]', 'demo@ad.nexus');
    await page.fill('input[name="password"]', 'adnexus');
    await page.click('button:has-text("Sign In")');
    await page.waitForNavigation({ waitUntil: 'networkidle' });
    console.log('✓ Successfully logged in');

    // TEST 1: Manage Payment Methods
    console.log('\n' + '='.repeat(60));
    console.log('TEST 1: MANAGE PAYMENT METHODS on /subscriptions');
    console.log('='.repeat(60));

    console.log('\n[1.1] Navigating to /subscriptions...');
    await page.goto('http://localhost:4000/subscriptions', { waitUntil: 'networkidle' });
    console.log(`✓ Navigated to subscriptions`);
    console.log(`Current URL: ${page.url()}`);

    console.log('\n[1.2] Taking screenshot before clicking...');
    await page.screenshot({ path: `${SCREENSHOT_DIR}/01-subscriptions-before.png`, fullPage: true });
    console.log(`✓ Screenshot saved: 01-subscriptions-before.png`);

    console.log('\n[1.3] Looking for "Manage Payment Methods" button...');
    const managePaymentButton = await page.$('a:has-text("Manage Payment Methods"), button:has-text("Manage Payment Methods")');
    
    if (!managePaymentButton) {
      console.log('⚠ "Manage Payment Methods" button not found');
      console.log('Available buttons on page:');
      const buttons = await page.$$eval('a, button', els => 
        els.map(el => ({
          text: el.textContent?.trim().substring(0, 50),
          tag: el.tagName,
          href: el.href || 'N/A',
          onclick: el.getAttribute('onclick') || 'N/A'
        }))
      );
      console.log(JSON.stringify(buttons, null, 2));
    } else {
      console.log('✓ Found "Manage Payment Methods" button');

      // Get button details
      const buttonHref = await managePaymentButton.evaluate(el => el.href || el.getAttribute('href'));
      console.log(`Button href: ${buttonHref}`);

      console.log('\n[1.4] Clicking "Manage Payment Methods"...');
      const urlBefore = page.url();
      
      // Listen for popup or navigation
      let redirectUrl = null;
      const navigationPromise = page.waitForNavigation({ waitUntil: 'networkidle', timeout: 10000 }).catch(() => null);
      
      await managePaymentButton.click();
      
      // Wait for any navigation
      const navResult = await navigationPromise;
      redirectUrl = page.url();
      
      console.log(`URL before: ${urlBefore}`);
      console.log(`URL after: ${redirectUrl}`);
      console.log(`Navigated: ${urlBefore !== redirectUrl}`);

      console.log('\n[1.5] Waiting 5 seconds...');
      await page.waitForTimeout(5000);

      console.log('\n[1.6] Taking screenshot after clicking...');
      await page.screenshot({ path: `${SCREENSHOT_DIR}/02-subscriptions-after.png`, fullPage: true });
      console.log(`✓ Screenshot saved: 02-subscriptions-after.png`);

      console.log('\n[1.7] Checking console for errors...');
      const consoleErrors = [];
      page.on('console', msg => {
        if (msg.type() === 'error') {
          consoleErrors.push(msg.text());
          console.log(`✗ Console Error: ${msg.text()}`);
        }
      });

      page.on('pageerror', error => {
        console.log(`✗ Page Error: ${error.message}`);
        consoleErrors.push(error.message);
      });

      await page.waitForTimeout(2000);

      if (consoleErrors.length === 0) {
        console.log('✓ No console errors detected');
      }
    }

    // TEST 2: Purchase Credits
    console.log('\n' + '='.repeat(60));
    console.log('TEST 2: PURCHASE CREDITS on /credits');
    console.log('='.repeat(60));

    console.log('\n[2.1] Navigating to /credits...');
    await page.goto('http://localhost:4000/credits', { waitUntil: 'networkidle' });
    console.log(`✓ Navigated to credits`);
    console.log(`Current URL: ${page.url()}`);

    console.log('\n[2.2] Taking screenshot before filling form...');
    await page.screenshot({ path: `${SCREENSHOT_DIR}/03-credits-before.png`, fullPage: true });
    console.log(`✓ Screenshot saved: 03-credits-before.png`);

    console.log('\n[2.3] Looking for amount input field...');
    const amountInput = await page.$('input[name*="amount"], input[type="number"]');
    
    if (!amountInput) {
      console.log('⚠ Amount input field not found');
      console.log('Available inputs on page:');
      const inputs = await page.$$eval('input, button, a', els => 
        els.map(el => ({
          text: el.textContent?.trim().substring(0, 40),
          tag: el.tagName,
          name: el.name || 'N/A',
          type: el.type || el.getAttribute('type') || 'N/A',
          class: el.className?.substring(0, 50) || 'N/A'
        }))
      );
      console.log(JSON.stringify(inputs, null, 2));
    } else {
      console.log('✓ Found amount input field');

      console.log('\n[2.4] Entering "25" in amount field...');
      await amountInput.fill('25');
      console.log('✓ Entered "25"');

      console.log('\n[2.5] Looking for "Add Credits" or "Purchase" button...');
      const purchaseButton = await page.$(
        'button:has-text("Add Credits"), button:has-text("Purchase"), button:has-text("Buy"), a:has-text("Add Credits")'
      );

      if (!purchaseButton) {
        console.log('⚠ Purchase button not found');
        console.log('Available buttons on page:');
        const buttons = await page.$$eval('button, a', els => 
          els.map(el => ({
            text: el.textContent?.trim().substring(0, 40),
            tag: el.tagName,
            onclick: el.getAttribute('onclick') || 'N/A'
          }))
        );
        console.log(JSON.stringify(buttons, null, 2));
      } else {
        console.log('✓ Found purchase button');

        console.log('\n[2.6] Clicking purchase button...');
        const urlBefore = page.url();
        
        // Listen for navigation
        const navigationPromise = page.waitForNavigation({ waitUntil: 'networkidle', timeout: 10000 }).catch(() => null);
        
        await purchaseButton.click();
        
        // Wait for any navigation
        const navResult = await navigationPromise;
        const redirectUrl = page.url();
        
        console.log(`URL before: ${urlBefore}`);
        console.log(`URL after: ${redirectUrl}`);
        console.log(`Redirected to Stripe: ${redirectUrl.includes('stripe') || redirectUrl.includes('checkout')}`);

        console.log('\n[2.7] Waiting 5 seconds...');
        await page.waitForTimeout(5000);

        console.log('\n[2.8] Taking screenshot after clicking...');
        await page.screenshot({ path: `${SCREENSHOT_DIR}/04-credits-after.png`, fullPage: true });
        console.log(`✓ Screenshot saved: 04-credits-after.png`);

        console.log('\n[2.9] Checking page content...');
        const pageTitle = await page.title();
        const pageUrl = page.url();
        console.log(`Page title: ${pageTitle}`);
        console.log(`Current URL: ${pageUrl}`);
      }
    }

    console.log('\n' + '='.repeat(60));
    console.log('TEST SUITE COMPLETED');
    console.log('='.repeat(60));
    console.log(`\nScreenshots saved to: ${SCREENSHOT_DIR}`);
    console.log('Files:');
    console.log('  - 01-subscriptions-before.png');
    console.log('  - 02-subscriptions-after.png');
    console.log('  - 03-credits-before.png');
    console.log('  - 04-credits-after.png');

  } catch (error) {
    console.error('✗ Test failed:', error.message);
    await page.screenshot({ path: `${SCREENSHOT_DIR}/error-screenshot.png`, fullPage: true });
  } finally {
    await browser.close();
  }
}

testBillingPages();
