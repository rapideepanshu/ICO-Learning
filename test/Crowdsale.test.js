const BN = require("bn.js");
const { duration, increaseTimeTo } = require("./helpers/increaseTime");

require("chai")
  .use(require("chai-as-promised"))
  .use(require("chai-bn")(BN))
  .should();

const Token = artifacts.require("Token");
const ExampleTokenCrowdsale = artifacts.require("ExampleTokenCrowdsale");
// const RefundVault = artifacts.require("RefundVault");
function ether(n) {
  return new web3.utils.BN(web3.utils.toWei(n, "ether"));
}
async function currentTime() {
  const block = await web3.eth.getBlock();
  return block.timestamp;
}
contract("ExampleTokenCrowdsale", function([_, wallet, addr1, addr2]) {
  let name;
  let symbol;
  let decimals;
  let token;
  let rate;
  let _wallet;
  let cap;
  let crowdsale;
  let startTime;
  let endTime;
  let minimumcap;
  let maximumcap;
  let vaultAddress;
  let vault;
  let goal;

  before(async function() {
    // Transfer extra ether to investor1's account for testing
    await web3.eth.sendTransaction({ from: _, to: addr1, value: ether("25") });
  });

  beforeEach(async function() {
    name = "ICO Token";
    symbol = "ICT";
    decimals = 18;

    token = await Token.new(name, symbol);

    rate = new BN(500);
    _wallet = wallet;
    cap = ether("19");
    goal = ether("15");
    startTime = (await currentTime()) + duration.weeks(1);
    endTime = startTime + duration.weeks(1);
    minimumcap = ether("0.002");
    maximumcap = ether("20");

    crowdsale = await ExampleTokenCrowdsale.new(
      rate,
      _wallet,
      token.address,
      cap
    );

    await token.paused();

    await token.transferOwnership(crowdsale.address);
    // vaultAddress = await crowdsale.vault();
    // vault = RefundVault.at(vaultAddress);
    // await increaseTimeTo(openingTime + 1);
  });

  describe("crowdsale", function() {
    it("rate should be equal", async function() {
      const _rate = await crowdsale.rate();
      console.log(_rate);
      _rate.should.be.bignumber.equal(rate);
    });
    it("wallet address sould be equal", async function() {
      const wallet = await crowdsale.wallet();
      wallet.should.equal(_wallet);
    });

    it("token should be equal", async function() {
      const _token = await crowdsale.token();
      _token.should.equal(token.address);
    });
  });

  describe("capped crowdsale", async function() {
    it("it has the correct hard cap", async function() {
      const _cap = await crowdsale.cap();
      _cap.should.be.bignumber.equal(cap);
    });
  });

  describe("buyTokens", function() {
    describe("when the contribution is less than the minimum cap", function() {
      it("rejects the transaction", async function() {
        const value = minimumcap - 1;
        await crowdsale
          .buyTokens(addr2, { value: value, from: addr2 })
          .should.be.rejectedWith("revert");
      });
    });
  });

  describe("when max cap reached", function() {
    it("rejects the transaction", async function() {
      const value1 = ether("2");
      await crowdsale.buyTokens(addr1, { value: value1, from: addr1 });

      //   const value2 = ether("20");
      //   await crowdsale
      //     .buyTokens(addr2, { value: value2, from: addr2 })
      //     .should.be.rejectedWith("revert");
    });
  });

  // describe("timed ICO", function() {
  //   it("is closed", async function() {
  //     const isClosed = await crowdsale.hasClosed();
  //     isClosed.should.be.false;
  //   });
  // });

  // describe("when the total contributions exceed the investor hard cap", function() {
  //   it("rejects the transaction", async function() {
  //     await crowdsale.buyTokens(addr1, { value: ether("2"), from: addr1 });

  //     await crowdsale
  //       .buyTokens(addr1, { value: ether("19"), from: addr1 })
  //       .should.be.rejectedWith("revert");
  //   });
  // });

  // describe("during crowdsale", function() {
  //   it("prevents the investor from claiming refund", async function() {
  //     await this.vault
  //       .refund(investor1, { from: investor1 })
  //       .should.be.rejectedWith("revert");
  //   });
  // });
});
