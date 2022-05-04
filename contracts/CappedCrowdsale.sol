pragma solidity ^0.8.0;

import "./Crowdsale.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/**
 * @title CappedCrowdsale
 * @dev Crowdsale with a limit for total contributions.
 */
abstract contract CappedCrowdsale is Crowdsale {
    using SafeMath for uint256;

    uint256 public cap;

    /**
     * @dev Constructor, takes maximum amount of wei accepted in the crowdsale.
     * @param _cap Max amount of wei to be contributed
     */
    constructor(uint256 _cap) {
        require(_cap > 0);
        cap = _cap;
    }

    /**
     * @dev Checks whether the cap has been reached.
     * @return Whether the cap was reached
     */
    function capReached() public returns (bool) {
        if (weiRaised() >= cap) return true;
        else return false;
    }

    /**
     * @dev Extend parent behavior requiring purchase to respect the funding cap.
     * @param _beneficiary Token purchaser
     * @param _weiAmount Amount of wei contributed
     */
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount)
        internal
        virtual
        override
    {
        super._preValidatePurchase(_beneficiary, _weiAmount);
        require((weiRaised() + _weiAmount) <= cap);
    }
}
