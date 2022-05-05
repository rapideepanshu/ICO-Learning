const BN = require("bn.js");
const { duration } = require("./helpers/increaseTime");
const {
  advanceBlock,
  advanceTimeAndBlock,
  advanceTime,
} = require("./helpers/advanceToBlock");
require("chai")
  .use(require("chai-as-promised"))
  .use(require("chai-bn")(BN))
  .should();

const Token = artifacts.require("Token");
const ExampleTokenCrowdsale = artifacts.require("ExampleTokenCrowdsale");

function ether(n) {
  return new web3.utils.BN(web3.utils.toWei(n, "ether"));
}
const currentTime = async () => {
  const block = await web3.eth.getBlock("latest");
  return block.timestamp;
};

contract("ExampleTokenCrowdsale", function([_, wallet, addr1, addr2, addr3]) {
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
  let goal;
  // before(async function() {
  //   await advanceTimeAndBlock(1);
  //   console.log("current", await currentTime());
  // });

  beforeEach(async function() {
    name = "ICO Token";
    symbol = "ICT";
    decimals = 18;
    rate = new BN(10);
    cap = ether("20");
    _wallet = wallet;
    startTime = (await currentTime()) + duration.weeks(1);
    endTime = startTime + duration.weeks(1);
    afterEndTime = endTime + duration.seconds(1);

    goal = ether("18");

    crowdsale = await ExampleTokenCrowdsale.new(
      startTime,
      endTime,
      rate,
      cap,
      _wallet,
      name,
      symbol,
      goal
    );

    token = await Token.at(await crowdsale.token());
  });

  it("should create crowdsale with correct parameters", async function() {
    crowdsale.should.exist;
    token.should.exist;

    const startTime = await crowdsale.startTime();
    const endTime = await crowdsale.endTime();
    const rate = await crowdsale.rate();
    const walletAddress = await crowdsale.wallet();
    const cap = await crowdsale.cap();

    startTime.should.be.bignumber.equal(startTime);
    endTime.should.be.bignumber.equal(endTime);
    rate.should.be.bignumber.equal(rate);
    walletAddress.should.be.equal(wallet);
    cap.should.be.bignumber.equal(cap);
  });
  it("should not accept payments before start", async function() {
    await crowdsale.send(ether("1")).should.be.rejectedWith("revert");
    await crowdsale
      .buyTokens(addr1, { from: addr1, value: ether("1") })
      .should.be.rejectedWith("revert");
  });

  it("should accept payments during the sale", async function() {
    const investmentAmount = ether("1");
    const expectedTokenAmount = rate.mul(investmentAmount);

    await advanceTimeAndBlock(duration.weeks(1));

    console.log("start", startTime);
    console.log("current", await currentTime());

    console.log("open", await crowdsale.isOpen());

    await crowdsale.buyTokens(addr2, {
      value: investmentAmount,
      from: addr2,
    }).should.be.fulfilled;

    (await token.balanceOf(addr2)).should.be.bignumber.equal(
      expectedTokenAmount
    );
    (await token.totalSupply()).should.be.bignumber.equal(expectedTokenAmount);
  });

  it("should reject payments over cap", async function() {
    await advanceTimeAndBlock(duration.weeks(1));
    await crowdsale.buyTokens(addr2, {
      value: ether("1"),
      from: addr2,
    }).should.be.fulfilled;
    await crowdsale
      .buyTokens(addr2, {
        value: ether("20"),
        from: addr2,
      })
      .should.be.rejectedWith("revert");
  });

  describe("when the goal is reached", function() {
    beforeEach(async function() {
      let walletBalance = await web3.eth.getBalance(wallet);

      await crowdsale.buyTokens(addr1, { value: ether("9"), from: addr1 });
      await crowdsale.buyTokens(addr2, { value: ether("9"), from: addr2 });
    });
    it("handles goal reached", async function() {
      const goalReached = await crowdsale.goalReached();
      goalReached.should.be.true;
    });
  });
});
