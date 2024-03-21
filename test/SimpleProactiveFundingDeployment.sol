// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;



import "../src/SimpleProactiveFunding.sol";
import "./UsersFixtures.sol";

import "forge-std/Test.sol";

// deploy & initializes Simple Proactive Funding contracts
contract SimpleProactiveFundingDeployment is Test, UsersFixtures {
    SimpleProactiveFunding simpleProactiveFunding;

    function setUp() public virtual override {
        super.setUp();

        vm.startPrank(owner);

        simpleProactiveFunding = new SimpleProactiveFunding("GoFundOP", "GFOP", owner);

        vm.stopPrank();
    }
}
