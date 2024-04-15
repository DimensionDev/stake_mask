// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract Reward is Ownable, ReentrancyGuard {
    struct RewardPool {
        bool unlocked;
        address rewardToken;
        bytes32 whitelistRoot;
    }

    RewardPool[] public rewardPools;

    mapping(uint8 => mapping(address => uint256)) public userRewards;

    event RewardClaimed(uint8 indexed poolId, address indexed account, uint256 amount);

    constructor() Ownable() { }

    function claim(uint8 _poolId, uint256 _amount, bytes32[] calldata _proof) public nonReentrant {
        require(rewardPools[_poolId].unlocked, "Pool is locked");
        require(userRewards[_poolId][msg.sender] == 0, "Already claimed");

        //safe engough for this case
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender, _amount));

        require(MerkleProof.verify(_proof, rewardPools[_poolId].whitelistRoot, leaf), "Invalid proof");

        userRewards[_poolId][msg.sender] = _amount;
        require(IERC20(rewardPools[_poolId].rewardToken).transfer(msg.sender, _amount), "Transfer failed");

        emit RewardClaimed(_poolId, msg.sender, _amount);
    }

    function createRewardPool(RewardPool calldata _rewardPool) public onlyOwner {
        rewardPools.push(_rewardPool);
    }

    function updateRewardPool(uint8 _poolId, RewardPool calldata _pool) public onlyOwner {
        RewardPool storage rewardPool = rewardPools[_poolId];
        rewardPool.unlocked = _pool.unlocked;
        rewardPool.rewardToken = _pool.rewardToken;
        rewardPool.whitelistRoot = _pool.whitelistRoot;
    }

    function emergencyWithdraw(address _token, uint256 _amount) public onlyOwner {
        IERC20(_token).transfer(msg.sender, _amount);
    }
}
