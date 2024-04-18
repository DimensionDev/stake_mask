// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract StakeManager is Ownable, ReentrancyGuard {
    IERC20 public maskToken;

    struct Pool {
        // pointAccStartBlock and pointAccEndBlock are set for external reading and
        // do not participate in business logic on contract.
        uint256 pointAccStartBlock;
        uint256 pointAccEndBlock;
        bool unlocked;
        bool stakingEnabled;
    }

    struct UserInfo {
        uint256 stakedAmount;
        // uint8 is enought for 256 pools
        uint8 poolId;
    }

    Pool[] public pools;
    mapping(address => UserInfo) public userInfos;

    uint8 public currentPoolId = 0;

    event Staked(address indexed account, uint8 indexed poolId, uint256 stakedAmount);
    event StakeChanged(address indexed account, uint8 indexed fromPoolId, uint8 indexed toPoolId);
    event unstaked(address indexed account, uint8 indexed poolId, uint256 unStakedAmount);
    event PoolCreated(
        uint8 indexed poolId, uint256 pointAccStartBlock, uint256 pointAccEndBlock, bool unlocked, bool stakingEnabled
    );
    event PoolUpdated(
        uint8 indexed poolId, uint256 pointAccStartBlock, uint256 pointAccEndBlock, bool unlocked, bool stakingEnabled
    );
    event CurrentPoolIdChanged(uint8 indexed fromPoolId, uint8 indexed toPoolId);

    constructor(address _maskToken) Ownable() {
        maskToken = IERC20(_maskToken);
    }

    function depositAndLock(uint256 _amount) public nonReentrant {
        Pool storage pool = pools[currentPoolId];

        require(pool.stakingEnabled, "Staking is disabled for this pool");

        require(maskToken.transferFrom(msg.sender, address(this), _amount), "Transfer failed");
        userInfos[msg.sender].stakedAmount += _amount;
        // depositAndLock will always stake to currentPoolId
        // it will init userInfos[msg.sender].poolId for the first time
        // it will change userInfos[msg.sender].poolId to currntPoolId(which means new pool) when
        //   user deposit after prev pool unlocked
        userInfos[msg.sender].poolId = currentPoolId;

        emit Staked(msg.sender, currentPoolId, _amount);
    }

    function withdraw(uint256 _amount) public nonReentrant {
        Pool storage pool = pools[userInfos[msg.sender].poolId];

        require(pool.unlocked, "Pool is locked");
        require(userInfos[msg.sender].stakedAmount >= _amount, "Insufficient balance");

        userInfos[msg.sender].stakedAmount -= _amount;
        require(maskToken.transfer(msg.sender, _amount), "Transfer failed");

        emit unstaked(msg.sender, userInfos[msg.sender].poolId, _amount);
    }

    function changePool() public nonReentrant {
        uint8 fromPoolId = userInfos[msg.sender].poolId;
        Pool storage fromPool = pools[userInfos[msg.sender].poolId];
        Pool storage toPool = pools[currentPoolId];

        require(toPool.stakingEnabled, "Staking is disabled for this pool");
        require(fromPool.unlocked, "From pool is locked");
        require(userInfos[msg.sender].stakedAmount > 0, "No staked amount");

        userInfos[msg.sender].poolId = currentPoolId;

        emit StakeChanged(msg.sender, fromPoolId, currentPoolId);
    }

    function createPool(Pool calldata _pool) public onlyOwner {
        pools.push(_pool);
        emit PoolCreated(
            uint8(pools.length - 1),
            _pool.pointAccStartBlock,
            _pool.pointAccEndBlock,
            _pool.unlocked,
            _pool.stakingEnabled
        );
    }

    function updatePool(uint8 _poolId, Pool calldata _pool) public onlyOwner {
        Pool storage pool = pools[_poolId];
        pool.pointAccStartBlock = _pool.pointAccStartBlock;
        pool.pointAccEndBlock = _pool.pointAccEndBlock;
        pool.unlocked = _pool.unlocked;
        pool.stakingEnabled = _pool.stakingEnabled;

        emit PoolUpdated(
            _poolId, _pool.pointAccStartBlock, _pool.pointAccEndBlock, _pool.unlocked, _pool.stakingEnabled
        );
    }

    function updateCurrentPoolId(uint8 _poolId) public onlyOwner {
        uint8 fromPoolId = currentPoolId;
        Pool storage pool = pools[_poolId];
        require(pool.stakingEnabled, "Staking is disabled for this pool");

        currentPoolId = _poolId;

        emit CurrentPoolIdChanged(fromPoolId, _poolId);
    }
}
