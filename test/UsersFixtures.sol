// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "forge-std/Test.sol";

// creates payable addresses
// buyer1, buyer2, seller1, seller2, owner
// and a users array with 10 users
// the balance of each payable address is set to 1000 eth
// and vm.label is used to add clarity to stack traces
contract UsersFixtures is Test {
    bytes32 internal nextUser = keccak256(abi.encodePacked("user address"));

    address payable internal buyer1;
    uint256 internal buyer1_private_key;
    address payable internal buyer2;
    address payable internal seller1;
    uint256 internal seller1_private_key;
    address payable internal seller2;
    address payable internal owner;

    // current total supply of ether
    uint256 internal defaultInitialEthBalance = ~uint128(0);

    function setUp() public virtual {
        buyer1 = payable(0x287841894D6FF7b033C810Dc658F5f295cEb356f);
        buyer1_private_key = 0xe03653b0b5b4758d674f62d5cb4f01fda33b2e6c3d5b7d56942ca34d1564c376;
        vm.deal(buyer1, defaultInitialEthBalance);
        vm.label(buyer1, "buyer1");

        buyer2 = getNextUserAddress();
        vm.deal(buyer2, defaultInitialEthBalance);
        vm.label(buyer2, "buyer2");

        seller1 = payable(0x7DE84B1343651f5Fd09A0C953C20b09D3F4E9872);
        seller1_private_key = 0x8294f76232c16ff75384e1e116f072473efebd6bc3b80f4f1039a8013a9435bc;
        vm.deal(seller1, defaultInitialEthBalance);
        vm.label(seller1, "seller1");

        seller2 = getNextUserAddress();
        vm.deal(seller2, defaultInitialEthBalance);
        vm.label(seller2, "seller2");

        owner = getNextUserAddress();
        vm.deal(owner, defaultInitialEthBalance);
        vm.label(owner, "owner");

    }

    function getNextUserAddress() internal returns (address payable) {
        // bytes32 to address conversion
        // bytes32 (32 bytes) => uint256 (32 bytes) => uint160 (20 bytes) => address (20 bytes)
        // explicit type conversion not allowed from "bytes32" to "uint160"
        // nor from "uint256" to "address"
        address payable user = payable(address(uint160(uint256(nextUser))));
        nextUser = keccak256(abi.encodePacked(nextUser));
        return user;
    }

    function mintWeth(address user, uint256 amount) internal {
        IERC20 wethToken = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
        address wethWhale = 0xF04a5cC80B1E94C69B48f5ee68a08CD2F09A7c3E;
        vm.startPrank(wethWhale);
        wethToken.transfer(user, amount);
        vm.stopPrank();
    }
}
