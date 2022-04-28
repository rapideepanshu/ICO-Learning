//SPDX-License-Identifier:UNLICENSED
pragma solidity >=0.4.0 <0.8.0;

import "openzeppelin-solidity/contracts/token/ERC20/DetailedERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/MintableToken.sol";
import "openzeppelin-solidity/contracts/token/ERC20/PausableToken.sol";

contract Token is MintableToken, PausableToken, DetailedERC20 {
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) public DetailedERC20(_name, _symbol, _decimals) {}
}
