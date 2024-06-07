// SPDX-License-Identifier: MIT

pragma solidity ^0.8.23;

interface IReward {
    struct RewardPool {
        bool unlocked;
        address rewardToken;
        bytes32 whitelistRoot;
    }

    function rewardPools(uint256 index)
        external
        view
        returns (bool unlocked, address rewardToken, bytes32 whitelistRoot);

    function userRewards(uint8 poolId, address account) external view returns (uint256);

    function claim(uint8 _poolId, uint256 _amount, bytes32[] calldata _proof) external;

    function createRewardPool(IReward.RewardPool calldata _rewardPool) external;

    function updateRewardPool(uint8 _poolId, IReward.RewardPool calldata _pool) external;

    function emergencyWithdraw(address _token, uint256 _amount) external;

    event RewardClaimed(uint8 indexed poolId, address indexed account, uint256 amount);
    event RewardPoolCreated(uint8 indexed poolId, bool unlocked, address rewardToken, bytes32 whitelistRoot);
    event RewardPoolUpdated(uint8 indexed poolId, bool unlocked, address rewardToken, bytes32 whitelistRoot);
}
