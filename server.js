const puppeteer = require('puppeteer');

(async () => {
		  const browser = await puppeteer.launch({args: ['--no-sandbox', '--disable-setuid-sandbox', '--enable-logging', '--v=1']});
		  const page = await browser.newPage();
		  await page.goto('https://www.google.com.ar');
		  await page.screenshot({path: 'example.png'});

		  await browser.close();
})();
