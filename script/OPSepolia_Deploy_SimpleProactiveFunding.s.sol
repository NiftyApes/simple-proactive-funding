pragma solidity ^0.8.20;

import "forge-std/Script.sol";

import "../src/SimpleProactiveFunding.sol";

contract DeploySimpleProactiveFundingScript is Script {
    SimpleProactiveFunding simpleProactiveFunding;

    function run() external {
        vm.startBroadcast();

        simpleProactiveFunding = new SimpleProactiveFunding("GoFundOP", "GFOP", 0x0397B15451aD09c5e7FD851Bcc1315462AC72C2F);

        simpleProactiveFunding.setFundingAmount(0x0397B15451aD09c5e7FD851Bcc1315462AC72C2F, 1 ether);


        vm.stopBroadcast();
    }
}
