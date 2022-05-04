pragma solidity ^0.8.4;

import "./Crowdsale.sol";
import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";

/**
 * @title MintedCrowdsale
 * @dev Extension of Crowdsale contract whose tokens are minted in each purchase.
 * Token ownership should be transferred to MintedCrowdsale for minting.
 */
abstract contract MintedCrowdsale is Crowdsale {
    constructor() {}

    /**
     * @dev Overrides delivery by minting tokens upon purchase.
     * @param beneficiary Token purchaser
     * @param tokenAmount Number of tokens to be minted
     */
    // function _deliverTokens(address beneficiary, uint256 tokenAmount)
    //     internal
    //     override
    // {
    //     ERC20PresetMinterPauser(address(token())).mint(
    //         beneficiary,
    //         tokenAmount
    //     );
    // }
}
