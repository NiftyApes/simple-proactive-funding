// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./SimpleProactiveFundingDeployment.sol";

contract TestDonate is Test, SimpleProactiveFundingDeployment {
    function setUp() public override {
        super.setUp();
    }

    function test_donate() public {

        vm.startPrank(owner);
        simpleProactiveFunding.setFundingAmount(0xC1200B5147ba1a0348b8462D00d237016945Dfff, 1 ether);
        vm.stopPrank();

        mintOP(buyer1, 100 ether);

        vm.startPrank(buyer1);
        IERC20(0x4200000000000000000000000000000000000042).approve(address(simpleProactiveFunding), 0.5 ether);

        simpleProactiveFunding.donate(0xC1200B5147ba1a0348b8462D00d237016945Dfff, 0.5 ether, ' ', ' ');
        vm.stopPrank();

        assertEq(simpleProactiveFunding.fundingAmountsReceived(0xC1200B5147ba1a0348b8462D00d237016945Dfff), 0.5 ether);

    }

    // function test_setFundingAmount_FAIL_notOwner() public {

    //     vm.prank(buyer1);
        
    //     vm.expectRevert();
    //     simpleProactiveFunding.setFundingAmount(0xC1200B5147ba1a0348b8462D00d237016945Dfff, 1 ether);

    //     vm.stopPrank();

    // }
}
