// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "forge-std/Test.sol";
import "../src/Reward.sol";
import "../src/TestToken.sol";

contract RewardConstructorTest is Test {
    Reward internal reward;
    TestToken internal rewardToken1;

    function setUp() public {
        vm.label(address(0x01), "contractCreator");
        vm.label(address(0x02), "caller");
        startHoax(address(0x01));
        uint256 initialSupply = 10_000 * 10 ** 18;
        rewardToken1 = new TestToken(initialSupply, "Reward Token1", "Reward1");
        reward = new Reward();

        rewardToken1.transfer(address(reward), initialSupply);
        vm.stopPrank();
    }

    function testConstructor() public {
        address owner = reward.owner();
        assertTrue(owner == address(0x01));
    }

    function testCreateRewardPool() public {
        startHoax(address(0x01));
        Reward.RewardPool memory pool =
            Reward.RewardPool({ unlocked: true, rewardToken: address(rewardToken1), whitelistRoot: bytes32(0x0) });

        reward.createRewardPool(pool);

        (bool unlocked, address rewardToken, bytes32 whitelistRoot) = reward.rewardPools(0);

        assertTrue(unlocked == true);
        assertTrue(rewardToken == address(rewardToken));
        assertTrue(whitelistRoot == bytes32(0x0));
    }

    function testUpdateRewardPool() public {
        startHoax(address(0x01));
        Reward.RewardPool memory pool =
            Reward.RewardPool({ unlocked: true, rewardToken: address(rewardToken1), whitelistRoot: bytes32(0x0) });

        reward.createRewardPool(pool);

        Reward.RewardPool memory updatedPool =
            Reward.RewardPool({ unlocked: false, rewardToken: address(0x2), whitelistRoot: bytes32(0x0) });

        reward.updateRewardPool(0, updatedPool);

        (bool unlocked, address rewardToken, bytes32 whitelistRoot) = reward.rewardPools(0);

        assertTrue(unlocked == false);
        assertTrue(rewardToken == address(0x2));
        assertTrue(whitelistRoot == bytes32(0x0));
    }

    function testEmergencyWithdraw() public {
        startHoax(address(0x01));

        reward.emergencyWithdraw(address(rewardToken1), 100 * 10 ** 18);

        uint256 balance = rewardToken1.balanceOf(address(0x01));

        assertTrue(balance == 100 * 10 ** 18);
    }
}

contract RewardUserageTest is Test {
    Reward internal reward;
    TestToken internal rewardToken1;
    TestToken internal rewardToken2;

    function setUp() public {
        vm.label(address(0x01), "contractCreator");
        vm.label(address(0x02), "caller");
        startHoax(address(0x01));
        uint256 initialSupply = 10_000 * 10 ** 18;
        rewardToken1 = new TestToken(initialSupply, "Reward Token1", "Reward1");
        rewardToken2 = new TestToken(initialSupply, "Reward Token2", "Reward2");
        reward = new Reward();

        rewardToken1.transfer(address(reward), initialSupply);
        rewardToken2.transfer(address(reward), initialSupply);

        reward.createRewardPool(
            Reward.RewardPool({ unlocked: true, rewardToken: address(rewardToken1), whitelistRoot: bytes32(0x0) })
        );

        reward.createRewardPool(
            Reward.RewardPool({ unlocked: true, rewardToken: address(rewardToken2), whitelistRoot: bytes32(0x0) })
        );

        vm.stopPrank();
    }

    function testClaim() public { }
}
