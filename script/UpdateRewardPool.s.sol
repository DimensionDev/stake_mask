// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import "forge-std/Script.sol";
import "../src/StakeManager.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../src/IReward.sol";

contract UpdateRewardPool is Script {
    IERC20 internal maskToken = IERC20(0x69af81e73A73B40adF4f3d4223Cd9b1ECE623074);
    IReward internal reward = IReward(0xB55F6363E8033641Ada71AFADaBd667d071bC9b1);

    IReward.RewardPool internal rewardPool;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        rewardPool = IReward.RewardPool({
            unlocked: true,
            rewardToken: 0x582d872A1B094FC48F5DE31D3B73F2D9bE47def1,
            whitelistRoot: 0x00
        });
        vm.startBroadcast(deployerPrivateKey);
        reward.updateRewardPool(1, rewardPool);
        vm.stopBroadcast();
    }
}
