//SPDX-License-Identifier:UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";

contract Crowdsale {
    // The token being sold
    ERC20PresetMinterPauser public token;

    // start and end timestamps where investments are allowed (both inclusive)
    uint256 public startTime;
    uint256 public endTime;

    // address where funds are collected
    address payable public wallet;

    // how many token units a buyer gets per wei
    uint256 public rate;

    // amount of raised money in wei
    uint256 public weiRaised;

    /**
     * event for token purchase logging
     * @param purchaser who paid for the tokens
     * @param beneficiary who got the tokens
     * @param value weis paid for purchase
     * @param amount amount of tokens purchased
     */
    event TokenPurchase(
        address indexed purchaser,
        address indexed beneficiary,
        uint256 value,
        uint256 amount
    );

    constructor(
        uint256 _startTime,
        uint256 _endTime,
        uint256 _rate,
        address payable _wallet,
        string memory _name,
        string memory _symbol
    ) {
        require(_startTime >= block.timestamp);
        require(_endTime >= _startTime);
        require(_rate > 0);
        require(_wallet != address(0));

        token = createTokenContract(_name, _symbol);
        startTime = _startTime;
        endTime = _endTime;
        rate = _rate;
        wallet = _wallet;
    }

    // fallback function can be used to buy tokens
    receive() external payable {
        buyTokens(msg.sender);
    }

    // low level token purchase function
    function buyTokens(address beneficiary) public payable virtual {
        require(beneficiary != address(0));
        require(validPurchase());


        uint256 weiAmount = msg.value;
 _preValidatePurchase(beneficiary, weiAmount);
        // calculate token amount to be created
        uint256 tokens = getTokenAmount(weiAmount);

        // update state
        weiRaised = weiRaised + (weiAmount);

        ERC20PresetMinterPauser(address(token)).mint(beneficiary, tokens);
        emit TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

        forwardFunds();
    }

    // @return true if crowdsale event has ended
    function hasEnded() public view virtual returns (bool) {
        return block.timestamp > endTime;
    }

    // creates the token to be sold.
    // override this method to have crowdsale of a specific mintable token.
    function createTokenContract(string memory _name, string memory _symbol)
        internal
        virtual
        returns (ERC20PresetMinterPauser)
    {
        return new ERC20PresetMinterPauser(_name, _symbol);
    }

    // Override this method to have a way to add business logic to your crowdsale when buying
    function getTokenAmount(uint256 weiAmount)
        internal
        view
        virtual
        returns (uint256)
    {
        return weiAmount * (rate);
    }

    // send ether to the fund collection wallet
    // override to create custom fund forwarding mechanisms
    function forwardFunds() internal virtual {
        wallet.transfer(msg.value);
    }

    function isOpen() external view returns (bool) {
        bool withinPeriod = block.timestamp >= startTime &&
            block.timestamp <= endTime;
        return withinPeriod;
    }

    // @return true if the transaction can buy tokens
    function validPurchase() internal view virtual returns (bool) {
   bool withinPeriod = block.timestamp >= startTime &&
            block.timestamp <= endTime;
        bool nonZeroPurchase = msg.value != 0;
        return withinPeriod && nonZeroPurchase;
    }

 function _preValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
    virtual
  {
    require(_beneficiary != address(0));
    require(_weiAmount != 0);
  }
}
