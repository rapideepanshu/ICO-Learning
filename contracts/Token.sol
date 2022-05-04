//SPDX-License-Identifier:UNLICENSED
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Token is ERC20, Ownable, Pausable {
    constructor(string memory _name, string memory _symbol)
        public
        ERC20(_name, _symbol)
        Ownable()
    {}
}
