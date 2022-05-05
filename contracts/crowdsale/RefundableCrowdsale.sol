pragma solidity ^0.8.0;

import "./FinalizableCrowdsale.sol";
import "./RefundVault.sol";

/**
 * @title RefundableCrowdsale
 * @dev Extension of Crowdsale contract that adds a funding goal, and
 * the possibility of users getting a refund if goal is not met.
 * Uses a RefundVault as the crowdsale's vault.
 */
abstract contract RefundableCrowdsale is FinalizableCrowdsale {
    // minimum amount of funds to be raised in weis
    uint256 public goal;

    // refund vault used to hold funds while crowdsale is running
    RefundVault public vault;

    constructor(uint256 _goal) {
        require(_goal > 0);
        vault = new RefundVault(wallet);
        goal = _goal;
    }

    // if crowdsale is unsuccessful, investors can claim refunds here
    function claimRefund() public {
        require(isFinalized);
        require(!goalReached());

        vault.refund(payable(msg.sender));
    }

    function goalReached() public view returns (bool) {
        return weiRaised >= goal;
    }

    // vault finalization task, called when owner calls finalize()
    function finalization() internal override virtual {
        if (goalReached()) {
            vault.close();
        } else {
            vault.enableRefunds();
        }

        super.finalization();
    }

    // We're overriding the fund forwarding from Crowdsale.
    // In addition to sending the funds, we want to call
    // the RefundVault deposit function
    function forwardFunds() internal virtual  override {
        vault.deposit{value: (msg.value)}(msg.sender);
    }
}
