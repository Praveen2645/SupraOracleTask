// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract TokenSwap {
    using SafeMath for uint256;

    address public owner;
    IERC20 public tokenA;
    IERC20 public tokenB;
    uint256 public exchangeRate;

    event Swap(address indexed user, uint256 amountA, uint256 amountB);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    constructor(
        address _tokenA,
        address _tokenB,
        uint256 _exchangeRate
    ) {
        owner = msg.sender;
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
        exchangeRate = _exchangeRate;
    }

    function swapBToA(uint256 amountB) external {
        uint256 amountA = calculateSwapAmountReverse(amountB);
        require(tokenB.balanceOf(msg.sender) >= amountB, "Insufficient balance of Token B");
        require(tokenA.balanceOf(address(this)) >= amountA, "Not enough liquidity");

        tokenB.transferFrom(msg.sender, address(this), amountB);
        tokenA.transfer(msg.sender, amountA);

        emit Swap(msg.sender, amountB, amountA);
    }

    function swapAToB(uint256 amountA) external {
        uint256 amountB = calculateSwapAmount(amountA);
        require(tokenA.balanceOf(msg.sender) >= amountA, "Insufficient balance of Token A");
        require(tokenB.balanceOf(address(this)) >= amountB, "Not enough liquidity");

        tokenA.transferFrom(msg.sender, address(this), amountA);
        tokenB.transfer(msg.sender, amountB);

        emit Swap(msg.sender, amountA, amountB);
    }


    function calculateSwapAmount(uint256 amountA) public view returns (uint256) {
        return amountA.mul(exchangeRate).div(1e18); 
    }

    function calculateSwapAmountReverse(uint256 amountB) public view returns (uint256) {
        return amountB.mul(1e18).div(exchangeRate);
    }

    function updateExchangeRate(uint256 newRate) external onlyOwner {
        exchangeRate = newRate;
    }
}

/*------------------------------------------------------------------------------------------------------------------------------*/

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenA is ERC20 {
    constructor() ERC20("TokenA", "TKA") {
        _mint(msg.sender, 1000000000000000000000000); //mint 10,00000
    }
}

contract TokenB is ERC20 {
    constructor() ERC20("TokenB", "TKB") {
        _mint(msg.sender, 1000000000000000000000000);
    }
}
