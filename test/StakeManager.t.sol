// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "forge-std/Test.sol";
import "../src/StakeManager.sol";
import "../src/TestToken.sol";

contract StakeManagerCobstructorTest is Test {
    StakeManager internal stakeManager;
    TestToken internal maskToken;

    function setUp() public {
        vm.label(address(0x01), "contractCreator");
        vm.label(address(0x02), "caller");
        startHoax(address(0x01));
        uint256 initialSupply = 10_000 * 10 ** 18;
        maskToken = new TestToken(initialSupply, "Mask Token", "MASK");
        stakeManager = new StakeManager(address(maskToken));
        vm.stopPrank();
    }

    function testConstructor() public view {
        address owner = stakeManager.owner();
        address maskTokenAddress = address(stakeManager.maskToken());
        assertTrue(owner == address(0x01));
        assertTrue(maskTokenAddress == address(maskToken));
    }

    function testCreatePool() public {
        startHoax(address(0x01));
        StakeManager.Pool memory pool =
            StakeManager.Pool({ startBlock: 10, endBlock: 20, unlocked: true, stakingEnabled: true });

        vm.expectEmit();
        emit StakeManager.PoolCreated(0);

        stakeManager.createPool(pool);

        (uint256 startBlock, uint256 endBlock, bool unlocked, bool stakingEnabled) = stakeManager.pools(0);

        assertTrue(startBlock == 10);
        assertTrue(endBlock == 20);
        assertTrue(unlocked == true);
        assertTrue(stakingEnabled == true);
    }

    function testRevertNonOwner() public {
        startHoax(address(0x02));
        StakeManager.Pool memory pool =
            StakeManager.Pool({ startBlock: 10, endBlock: 20, unlocked: true, stakingEnabled: true });

        vm.expectRevert("Ownable: caller is not the owner");
        stakeManager.createPool(pool);
    }
}

contract StakeManagerOwnerChangeTest is Test {
    StakeManager internal stakeManager;
    TestToken internal maskToken;
    StakeManager.Pool internal pool;

    function setUp() public {
        vm.label(address(0x01), "contractCreator");
        vm.label(address(0x02), "caller");
        startHoax(address(0x01));
        uint256 initialSupply = 10_000 * 10 ** 18;
        maskToken = new TestToken(initialSupply, "Mask Token", "MASK");
        stakeManager = new StakeManager(address(maskToken));

        pool = StakeManager.Pool({ startBlock: 10, endBlock: 20, unlocked: true, stakingEnabled: true });
        stakeManager.createPool(pool);

        vm.stopPrank();
    }

    function testChangePool() public {
        startHoax(address(0x01));
        StakeManager.Pool memory newPool =
            StakeManager.Pool({ startBlock: 20, endBlock: 30, unlocked: false, stakingEnabled: true });
        stakeManager.updatePool(0, newPool);

        (uint256 startBlock, uint256 endBlock, bool unlocked, bool stakingEnabled) = stakeManager.pools(0);

        assertTrue(startBlock == 20);
        assertTrue(endBlock == 30);
        assertTrue(unlocked == false);
        assertTrue(stakingEnabled == true);
    }

    function testRevertArrayOutOfRange() public {
        startHoax(address(0x01));
        StakeManager.Pool memory newPool =
            StakeManager.Pool({ startBlock: 20, endBlock: 30, unlocked: false, stakingEnabled: true });

        vm.expectRevert();
        stakeManager.updatePool(1, newPool);
    }

    function testRevertStakingNotEnabledPool() public {
        startHoax(address(0x01));

        StakeManager.Pool memory pool2 =
            StakeManager.Pool({ startBlock: 10, endBlock: 20, unlocked: true, stakingEnabled: false });
        stakeManager.createPool(pool2);

        vm.expectRevert("Staking is disabled for this pool");
        stakeManager.updateCurrentPoolId(1);
    }

    function testRevertNoPoolId() public {
        startHoax(address(0x01));
        vm.expectRevert();
        stakeManager.updateCurrentPoolId(2);
    }
}

contract StakeManagerUsageTest is Test {
    StakeManager internal stakeManager;
    TestToken internal maskToken;
    StakeManager.Pool internal pool0;
    StakeManager.Pool internal pool1;
    StakeManager.Pool internal pool2;

    function setUp() public {
        vm.label(address(0x01), "contractCreator");
        vm.label(address(0x02), "caller");
        startHoax(address(0x01));
        uint256 initialSupply = 10_000 * 10 ** 18;
        maskToken = new TestToken(initialSupply, "Mask Token", "MASK");
        stakeManager = new StakeManager(address(maskToken));

        pool0 = StakeManager.Pool({ startBlock: 10, endBlock: 20, unlocked: true, stakingEnabled: true });
        stakeManager.createPool(pool0);

        pool1 = StakeManager.Pool({ startBlock: 10, endBlock: 20, unlocked: false, stakingEnabled: true });
        stakeManager.createPool(pool1);

        pool2 = StakeManager.Pool({ startBlock: 10, endBlock: 20, unlocked: true, stakingEnabled: false });
        stakeManager.createPool(pool2);

        stakeManager.updateCurrentPoolId(0);

        maskToken.transfer(address(0x02), 10_000 * 10 ** 18);
        vm.stopPrank();
    }

    function _deposit() internal {
        startHoax(address(0x02));
        maskToken.approve(address(stakeManager), 100 * 10 ** 18);

        vm.expectEmit();
        emit StakeManager.Staked(address(0x02), stakeManager.currentPoolId(), 100 * 10 ** 18);

        stakeManager.deposit(100 * 10 ** 18);
        vm.stopPrank();
    }

    function testDeposit() public {
        startHoax(address(0x02));
        maskToken.approve(address(stakeManager), 100 * 10 ** 18);

        vm.expectEmit();
        emit StakeManager.Staked(address(0x02), stakeManager.currentPoolId(), 100 * 10 ** 18);

        stakeManager.deposit(100 * 10 ** 18);

        (uint256 stakedAmount, uint8 poolId) = stakeManager.userInfos(address(0x02));

        assertTrue(stakedAmount == 100 * 10 ** 18);
        assertTrue(poolId == 0);
        assertTrue(maskToken.balanceOf(address(stakeManager)) == 100 * 10 ** 18);
        vm.stopPrank();
    }

    function testWithdraw() public {
        _deposit();
        startHoax(address(0x02));

        vm.expectEmit();
        emit StakeManager.unstaked(address(0x02), stakeManager.currentPoolId(), 99 * 10 ** 18);

        stakeManager.withdraw(99 * 10 ** 18);

        (uint256 stakedAmount, uint8 poolId) = stakeManager.userInfos(address(0x02));

        assertTrue(stakedAmount == 1 * 10 ** 18);
        assertTrue(poolId == 0);
        assertTrue(maskToken.balanceOf(address(stakeManager)) == 1 * 10 ** 18);
        vm.stopPrank();
    }

    function testChangePool() public {
        _deposit();
        startHoax(address(0x02));

        vm.expectEmit();
        emit StakeManager.StakeChanged(address(0x02), 0, 1);

        stakeManager.changePool(1);

        (uint256 stakedAmount, uint8 poolId) = stakeManager.userInfos(address(0x02));

        assertTrue(stakedAmount == 100 * 10 ** 18);
        assertTrue(poolId == 1);
        assertTrue(maskToken.balanceOf(address(stakeManager)) == 100 * 10 ** 18);
        vm.stopPrank();
    }

    function testRevertStakingDisabled() public {
        _deposit();
        startHoax(address(0x02));

        vm.expectRevert("Staking is disabled for this pool");
        stakeManager.changePool(2);
    }

    function testRevertUnlocked() public {
        _deposit();
        startHoax(address(0x02));

        stakeManager.changePool(1);

        vm.expectRevert("Pool is locked");
        stakeManager.withdraw(100 * 10 ** 18);
    }
}
