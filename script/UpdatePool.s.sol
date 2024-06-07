// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import "forge-std/Script.sol";
import "../src/StakeManager.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../src/IStakeManager.sol";

contract UpdatePool is Script {
    IERC20 internal maskToken = IERC20(0x69af81e73A73B40adF4f3d4223Cd9b1ECE623074);
    IStakeManager internal stakeManager = IStakeManager(0x089f9E409e2aE5837dEf520cE6BFB2fa03Ce5128);

    IStakeManager.Pool internal pool;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        pool = IStakeManager.Pool({
            pointAccStartBlock: 19_959_200,
            pointAccEndBlock: 19_960_180,
            unlocked: true,
            stakingEnabled: false
        });
        vm.startBroadcast(deployerPrivateKey);
        stakeManager.updatePool(1, pool);
        vm.stopBroadcast();
    }
}
