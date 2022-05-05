//SPDX-License-Identifier:UNLICENSED
pragma solidity ^0.8.4;

import "./crowdsale/CappedCrowdsale.sol";
import "./crowdsale/FinalizableCrowdsale.sol";
import "./crowdsale/RefundableCrowdsale.sol";
import "./Token.sol";

contract ExampleTokenCrowdsale is CappedCrowdsale, FinalizableCrowdsale ,RefundableCrowdsale{
    constructor(
        uint256 _startTime,
        uint256 _endTime,
        uint256 _rate,
        uint256 _cap,
        address payable _wallet,
        string memory _name,
        string memory _symbol,
        uint256 _goal
    )
        CappedCrowdsale(_cap)
        RefundableCrowdsale(_goal)
        Crowdsale(_startTime, _endTime, _rate, _wallet, _name, _symbol)
    {
        require(_goal<=_cap);
    }

    // Create a custom token to mint instead of the default MintableToken
    function createTokenContract(string memory _name, string memory _symbol)
        internal
        override
        returns (ERC20PresetMinterPauser)
    {
        return new Token(_name, _symbol);
    }

    // Override to indicate when the crowdsale ends and does not accept any more contributions
    // Checks endTime by default, plus cap from CappedCrowdsale
    function hasEnded()
        public
        view
        override(Crowdsale, CappedCrowdsale)
        returns (bool)
    {
        return super.hasEnded();
    }

    // Override this method to have a way to add business logic to your crowdsale when buying
    // Returns weiAmount times rate by default
    function getTokenAmount(uint256 weiAmount)
        internal
        view
        override
        returns (uint256)
    {
        return super.getTokenAmount(weiAmount);
    }

    // Override to create custom fund forwarding mechanisms
    // Forwards funds to the specified wallet by default
    function forwardFunds() internal override(Crowdsale,RefundableCrowdsale) {
        return super.forwardFunds();
    }

    // Criteria for accepting a purchase
    // Make sure to call super.validPurchase(), or all the criteria from parents will be overwritten.
    function validPurchase()
        internal
        view
        override(Crowdsale, CappedCrowdsale)
        returns (bool)
    {
        return super.validPurchase();
    }

    // Override to execute any logic once the crowdsale finalizes
    // Requires a call to the public finalize method, only after the sale hasEnded
    // Remember that super.finalization() calls the token finishMinting(),
    // so no new tokens can be minted after that
    function finalization() internal override(FinalizableCrowdsale,RefundableCrowdsale) {
        super.finalization();
    }
}
