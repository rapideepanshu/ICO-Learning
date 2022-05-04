//SPDX-License-Identifier:UNLICENSED
pragma solidity ^0.8.4;

import "./Crowdsale.sol";
import "./CappedCrowdsale.sol";
import "./MintedCrowdsale.sol";

import "./TimedCrowdsale.sol";

// import "openzeppelin-solidity/contracts/crowdsale/distribution/RefundableCrowdsale.sol";

contract ExampleTokenCrowdsale is Crowdsale, CappedCrowdsale, TimedCrowdsale {
    uint256 public investorMinCap = 20000000000000000000;
    uint256 public investorHardCap = 50000000000000000000;

    mapping(address => uint256) public contributions;

    constructor(
        uint256 _rate,
        address payable _wallet,
        ERC20 _token,
        uint256 _cap,
        uint256 _openingTime,
        uint256 _closingTime
    )
        public
        Crowdsale(_rate, _wallet, _token)
        CappedCrowdsale(_cap)
        TimedCrowdsale(_openingTime, _closingTime)
    {}

    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount)
        internal
        override(Crowdsale, CappedCrowdsale, TimedCrowdsale)
    {
        super._preValidatePurchase(_beneficiary, _weiAmount);
        uint256 _existingContribution = contributions[_beneficiary];
        uint256 _newContribution = _existingContribution + (_weiAmount);
        require(
            _newContribution >= investorMinCap &&
                _newContribution <= investorHardCap
        );
        contributions[_beneficiary] = _newContribution;
    }
}
