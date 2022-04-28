const Token = artifacts.require("./Token.sol");
const ExampleTokenCrowdsale = artifacts.require("./ExampleTokenCrowdsale.sol");

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

  await deployer.deploy(Token, _name, _symbol, _decimals);
  const deployedToken = await Token.deployed();

  const _rate = 500;
  const _wallet = accounts[0];
  const _token = deployedToken.address;
  const _cap = 100;
  const _startTime = currentTime;
  const _endTime = _startTime + duration.weeks(1);

  await deployer.deploy(
    ExampleTokenCrowdsale,
    _rate,
    _wallet,
    _token,
    _cap,
    _startTime,
    _endTime
  );

  return true;
};
