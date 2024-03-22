
pragma solidity ^0.8.20;

import "forge-std/Script.sol";

import "../src/OPToken.sol";

contract DeployOPTokenScript is Script {
    function run() external {
        vm.startBroadcast();

        new OPToken(1000000 ether);

        vm.stopBroadcast();
    }
}
