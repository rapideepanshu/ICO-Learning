const BN = require("bn.js");
const { duration, increaseTime } = require("./helpers/increaseTime");

require("chai")
  .use(require("chai-as-promised"))
  .use(require("chai-bn")(BN))
  .should();

const Token = artifacts.require("Token");
const ExampleTokenCrowdsale = artifacts.require("ExampleTokenCrowdsale");
function ether(n) {
  return new web3.utils.BN(web3.utils.toWei(n, "ether"));
}
async function currentTime() {
  const block = await web3.eth.getBlock();
  return block.timestamp;
}
contract("ExampleTokenCrowdsale", function([_, wallet, addr1]) {
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

  beforeEach(async function() {
    name = "ICO Token";
    symbol = "ICT";
    decimals = 18;

    token = await Token.new(name, symbol, decimals);

    rate = new BN(500);
    _wallet = wallet;
    cap = ether("100");
    startTime = (await currentTime()) + duration.weeks(1);
    endTime = startTime + duration.weeks(1);
    console.log(await currentTime());
    crowdsale = await ExampleTokenCrowdsale.new(
      rate,
      _wallet,
      token.address,
      cap,
      startTime,
      endTime
    );

    await token.pause();

    await token.transferOwnership(crowdsale.address);
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
  describe("timed ICO", function() {
    it("is closed", async function() {
      const isClosed = await crowdsale.hasClosed();
      isClosed.should.be.false;
    });
  });
});
