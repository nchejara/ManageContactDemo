const expect = require("expect");
const webdriver = require('selenium-webdriver');
const chrome = require('selenium-webdriver/chrome');
const chromedriver = require('chromedriver');

var driver = null;
const host = process.env.HOST || "localhost"
const port = process.env.PORT || "3000"
const hostname = "http://" + host + ":" + port;
function sleep(millis) {
    return new Promise(resolve => setTimeout(resolve, millis));
}
async function SlowType(element, text, delay=1000) {
    await sleep(delay);
    for(const c in text) {
        await element.sendKeys(text[c])
    }
    
}
describe("Home Page Test Suite", function(){
    
    this.timeout(1000 * 60 * 60); 
    before(async () => {
        driver = await new webdriver.Builder()
            .forBrowser('chrome')
            .setChromeOptions(new chrome.Options().headless()) // Running test in headless browser
            .build();

        await driver.get(hostname);
        var title = await driver.getTitle();
        console.log(title);
    });
 
    after(async () => {
        if(driver != null)
            await driver.quit();
    });
    
    it("Add Contacts", async () => {
        await SlowType(await driver.findElement(webdriver.By.id("name")), "Naren Chejara");
        await SlowType(await driver.findElement(webdriver.By.id("mobile_number")), "124578963245");
        await SlowType(await driver.findElement(webdriver.By.id("email")), "naren@123.com");
        await driver.findElement(webdriver.By.id("submit")).click();

        await SlowType(await driver.findElement(webdriver.By.id("name")), "Daksh Chejara");
        await SlowType(await driver.findElement(webdriver.By.id("mobile_number")), "85467891245");
        await SlowType(await driver.findElement(webdriver.By.id("email")), "daksh@123.com");
        await driver.findElement(webdriver.By.id("submit")).click();
    });
 
    it("Delete Contacts", async () => {
        var elements = await driver.findElements(webdriver.By.linkText("Delete"));
        console.log("Found '" + elements.length + "' Links tag ");
        for(var i=0; i < elements.length; i++) {
            await driver.findElement(webdriver.By.linkText("Delete")).click();
            await driver.get(hostname);
            await sleep(5000);
        }
    });
  
});