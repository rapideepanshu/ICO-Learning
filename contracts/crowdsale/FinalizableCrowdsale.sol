//SPDX-License-Identifier:UNLICENSED
pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./Crowdsale.sol";

/**
 * @title FinalizableCrowdsale
 * @dev Extension of Crowdsale where an owner can do extra work
 * after finishing.
 */
abstract contract FinalizableCrowdsale is Crowdsale, Ownable {
    bool public isFinalized = false;

    event Finalized();

    /**
     * @dev Must be called after crowdsale ends, to do some extra finalization
     * work. Calls the contract's finalization function.
     */
    function finalize() public onlyOwner {
        require(!isFinalized);
        require(hasEnded());

        finalization();
        emit Finalized();


        isFinalized=true;
    }

    /**
     * @dev Can be overridden to add finalization logic. The overriding function
     * should call super.finalization() to ensure the chain of finalization is
     * executed entirely.
     */
    function finalization() internal virtual {}
}
