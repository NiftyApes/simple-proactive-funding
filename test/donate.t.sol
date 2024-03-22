// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./SimpleProactiveFundingDeployment.sol";

contract TestDonate is Test, SimpleProactiveFundingDeployment {
    function setUp() public override {
        super.setUp();
    }

    function test_donate_simple() public {

        vm.startPrank(owner);
        simpleProactiveFunding.setFundingAmount(0xC1200B5147ba1a0348b8462D00d237016945Dfff, 1 ether);
        vm.stopPrank();

        mintOP(buyer1, 100 ether);

        vm.startPrank(buyer1);
        IERC20(0x4200000000000000000000000000000000000042).approve(address(simpleProactiveFunding), 0.5 ether);

        simpleProactiveFunding.donate(0xC1200B5147ba1a0348b8462D00d237016945Dfff, 0.5 ether, ' ', ' ');
        vm.stopPrank();

        assertEq(simpleProactiveFunding.fundingAmountsReceived(0xC1200B5147ba1a0348b8462D00d237016945Dfff), 0.5 ether);
        // project NFT minted to buyer1
        assertEq(IERC721(address(simpleProactiveFunding)).ownerOf(0), buyer1);
        // early funder NFT minted to buyer1
        assertEq(IERC721(address(simpleProactiveFunding)).ownerOf(1), buyer1);

    }

    function test_donate_overRaise() public {

        vm.startPrank(owner);
        simpleProactiveFunding.setFundingAmount(0xC1200B5147ba1a0348b8462D00d237016945Dfff, 1 ether);
        vm.stopPrank();

        mintOP(buyer1, 100 ether);

        vm.startPrank(buyer1);
        IERC20(0x4200000000000000000000000000000000000042).approve(address(simpleProactiveFunding), 0.5 ether);

        simpleProactiveFunding.donate(0xC1200B5147ba1a0348b8462D00d237016945Dfff, 0.5 ether, ' ', ' ');

        IERC20(0x4200000000000000000000000000000000000042).approve(address(simpleProactiveFunding), 1 ether);


        simpleProactiveFunding.donate(0xC1200B5147ba1a0348b8462D00d237016945Dfff, 1 ether, ' ', ' ');

        vm.stopPrank();

        assertEq(simpleProactiveFunding.fundingAmountsReceived(0xC1200B5147ba1a0348b8462D00d237016945Dfff), 1 ether);

    }

    function test_donate_CANNOT_projectNotWhitelisted() public {

        vm.startPrank(owner);
        simpleProactiveFunding.setFundingAmount(0xC1200B5147ba1a0348b8462D00d237016945Dfff, 1 ether);
        vm.stopPrank();

        mintOP(buyer1, 100 ether);

        vm.startPrank(buyer1);
        IERC20(0x4200000000000000000000000000000000000042).approve(address(simpleProactiveFunding), 0.5 ether);

        vm.expectRevert();
        simpleProactiveFunding.donate(0x4200000000000000000000000000000000000042, 0.5 ether, ' ', ' ');
        vm.stopPrank();

    }

    function test_donate_CANNOT_fundingMet() public {

        vm.startPrank(owner);
        simpleProactiveFunding.setFundingAmount(0xC1200B5147ba1a0348b8462D00d237016945Dfff, 1 ether);
        vm.stopPrank();

        mintOP(buyer1, 100 ether);

        vm.startPrank(buyer1);
        IERC20(0x4200000000000000000000000000000000000042).approve(address(simpleProactiveFunding), 1 ether);

        simpleProactiveFunding.donate(0xC1200B5147ba1a0348b8462D00d237016945Dfff, 1 ether, ' ', ' ');

        assertEq(simpleProactiveFunding.fundingAmountsReceived(0xC1200B5147ba1a0348b8462D00d237016945Dfff), 1 ether);

        IERC20(0x4200000000000000000000000000000000000042).approve(address(simpleProactiveFunding), 1 ether);

        vm.expectRevert();
        simpleProactiveFunding.donate(0xC1200B5147ba1a0348b8462D00d237016945Dfff, 1 ether, ' ', ' ');

        assertEq(simpleProactiveFunding.fundingAmountsReceived(0xC1200B5147ba1a0348b8462D00d237016945Dfff), 1 ether);
        vm.stopPrank();

    }

     function test_donate_CANNOT_fundingAmountZero() public {

        vm.startPrank(owner);
        simpleProactiveFunding.setFundingAmount(0xC1200B5147ba1a0348b8462D00d237016945Dfff, 1 ether);
        vm.stopPrank();

        mintOP(buyer1, 100 ether);

        vm.startPrank(buyer1);
        IERC20(0x4200000000000000000000000000000000000042).approve(address(simpleProactiveFunding), 0.5 ether);

        vm.expectRevert();
        simpleProactiveFunding.donate(0xC1200B5147ba1a0348b8462D00d237016945Dfff, 0 ether, ' ', ' ');
        vm.stopPrank();

    }
}
