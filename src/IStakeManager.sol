// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

interface IStakeManager {
    struct Pool {
        uint256 pointAccStartBlock;
        uint256 pointAccEndBlock;
        bool unlocked;
        bool stakingEnabled;
    }

    struct UserInfo {
        uint256 stakedAmount;
        uint8 poolId;
    }

    event Staked(address indexed account, uint8 indexed poolId, uint256 stakedAmount);
    event StakeChanged(address indexed account, uint8 indexed fromPoolId, uint8 indexed toPoolId);
    event Unstaked(address indexed account, uint8 indexed poolId, uint256 unStakedAmount);
    event PoolCreated(
        uint8 indexed poolId, uint256 pointAccStartBlock, uint256 pointAccEndBlock, bool unlocked, bool stakingEnabled
    );
    event PoolUpdated(
        uint8 indexed poolId, uint256 pointAccStartBlock, uint256 pointAccEndBlock, bool unlocked, bool stakingEnabled
    );
    event CurrentPoolIdChanged(uint8 indexed fromPoolId, uint8 indexed toPoolId);

    function depositAndLock(uint256 _amount) external;
    function withdraw(uint256 _amount) external;
    function changePool() external;
    function createPool(Pool calldata _pool) external;
    function updatePool(uint8 _poolId, Pool calldata _pool) external;
    function updateCurrentPoolId(uint8 _poolId) external;
}
