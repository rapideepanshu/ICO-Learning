const Token = artifacts.require("./Token.sol");
const ExampleTokenCrowdsale = artifacts.require("./ExampleTokenCrowdsale.sol");

function ether(n) {
  return new web3.utils.BN(web3.utils.toWei(n, "ether"));
}
const duration = {
  seconds: function(val) {
    return val;
  },
  minutes: function(val) {
    return val * this.seconds(60);
  },
  hours: function(val) {
    return val * this.minutes(60);
  },
  days: function(val) {
    return val * this.hours(24);
  },
  weeks: function(val) {
    return val * this.days(7);
  },
  years: function(val) {
    return val * this.days(365);
  },
};

module.exports = async function(deployer, network, accounts) {
  const _name = "ICO Token";
  const _symbol = "ICT";
  const _decimals = 18;

  const date = new Date();
  const currentTime = date.getTime();

  const _rate = 500;
  const _wallet = accounts[0];

  const _cap = ether("100");
  const _goal = ether("80");
  const _startTime = currentTime + duration.weeks(1);
  const _endTime = _startTime + duration.weeks(1);

  const crowdsale = await deployer.deploy(
    ExampleTokenCrowdsale,
    _startTime,
    _endTime,
    _rate,
    _cap,
    _wallet,
    _name,
    _symbol,
    _goal
  );
  // console.log(crowdsale);

  // const open = await crowdsale.cap();
  // console.log(open);

  return true;
};
