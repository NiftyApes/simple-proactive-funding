pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract OPToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("OP", "OP") {
        _mint(msg.sender, initialSupply);
    }
}