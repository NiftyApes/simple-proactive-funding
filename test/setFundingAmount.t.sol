// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";

import "./SimpleProactiveFundingDeployment.sol";

contract TestSetFundingAmount is Test, SimpleProactiveFundingDeployment {
    function setUp() public override {
        super.setUp();
    }

    function test_setFundingAmount() public {

        vm.prank(owner);
        
        simpleProactiveFunding.setFundingAmount(0xC1200B5147ba1a0348b8462D00d237016945Dfff, 1 ether);

        assertEq(simpleProactiveFunding.fundingAmounts(0xC1200B5147ba1a0348b8462D00d237016945Dfff), 1 ether);
        assertEq(simpleProactiveFunding.fundingAmounts(0x0397B15451aD09c5e7FD851Bcc1315462AC72C2F), 0);

        vm.stopPrank();

    }

    function test_setFundingAmount_FAIL_notOwner() public {

        vm.prank(buyer1);
        
        vm.expectRevert();
        simpleProactiveFunding.setFundingAmount(0xC1200B5147ba1a0348b8462D00d237016945Dfff, 1 ether);

        vm.stopPrank();

    }
}
