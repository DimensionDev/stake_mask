// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import "forge-std/Script.sol";
import "../src/StakeManager.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../src/IStakeManager.sol";

contract UpdatePool is Script {
    IERC20 internal maskToken = IERC20(0x34CBae8f53Af6D7B50656137e773A29754F01F13);
    IStakeManager internal stakeManager = IStakeManager(0xEcE3EF2bf6F6FA7F13BeAb519c60a72e92bbD47C);

    IStakeManager.Pool internal pool;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        pool = IStakeManager.Pool({
            pointAccStartBlock: 5_766_024,
            pointAccEndBlock: 5_966_024,
            unlocked: true,
            stakingEnabled: true
        });
        vm.startBroadcast(deployerPrivateKey);
        stakeManager.updatePool(0, pool);
        vm.stopBroadcast();
    }
}
