//SPDX-License-Identifier:UNLICENSED
pragma solidity ^0.8.0;

import "./Crowdsale.sol";

/**
 * @title CappedCrowdsale
 * @dev Extension of Crowdsale with a max amount of funds raised
 */
abstract contract CappedCrowdsale is Crowdsale {
    uint256 public cap;

    constructor(uint256 _cap) {
        require(_cap > 0);
        cap = _cap;
    }

    // overriding Crowdsale#hasEnded to add cap logic
    // @return true if crowdsale event has ended
    function hasEnded() public view virtual override returns (bool) {
        bool capReached = weiRaised >= cap;
        return capReached || super.hasEnded();
    }

    // overriding Crowdsale#validPurchase to add extra cap logic
    // @return true if investors can buy at the moment
    function validPurchase() internal view virtual override returns (bool) {
        bool withinCap = (weiRaised + (msg.value)) <= cap;
        return withinCap && super.validPurchase();
    }
}
