function currentTime() {
  return web3.eth.getBlock("latest").timestamp;
}

module.exports = { currentTime };
