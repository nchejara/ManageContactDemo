const expect = require("expect");

describe("Simple demo test", function () {

    before(() => {
        console.log("Before All function")
    });
    
    it("1. sum of 2 + 2 should be 4", () => {
        expect(2 + 2).toEqual(4);
    })
    it("2. subtraction of 10 - 5 should be 5", () => {
        expect(10 - 5).toEqual(5);
    });

    after(() => { 
        console.log("After All function");
    });
})