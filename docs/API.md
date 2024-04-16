# Stake Mask

## Function Briefing in `StakeManager.sol`

### General Description

The staking pool is divided into multiple pools, and the administrator can add pools and manage the parameters "unlocked" and "stakingEnabled" of the `pool` to manage users' staked assets. Each participating user has a `UserInfo`, which stores the total stakedAmount in the pool and information about the current pool they are in.

### Workflow in stake manager

![Workflow](stake_manager_workflow.png)

1. Users need to call `approve()` in advance to approve of our contract to operating users' token.
2. Users call `depositAndLock(_amount)` to unlock token in current active pool to get point.
3. When this pool unlocked. Owner of the contract will unlock this pool, create a new pool and set the `currentPoolId` to new pool.
4. Users can call `depositAndLock(_amount)` to deposit and lock more token on next pool to participate in the next stage of the event. or call `changePool(_newPoolId)` to relocked token to participate in the next stage of the event. or call `withdraw(_amount)` to withdraw token. If users don't take any action, their assets in the pool won't generate points in the next stage of the event.

### API

### depositAndLock

Users can deposit and lock mask token on StakeManager to get Point.
depositAndLock will change UserInfo.poolId to currentPoolId.

```solidity
function depositAndLock(uint256 _amount) public {}
```

- parameters:
  - `_amount`: Amount of locking Mask tokens
- Requirements:
  - currentPool.stakingEnabled == true
  - enough allowance of mask token
- Events:

  ```solidity
  Staked(address indexed account, uint8 indexed poolId, uint256 stakedAmount);
  ```

### changePool

Users can compound their mask token to new pool.

```solidity
function changePool() public {}
```

- parameters:
  N/A
- Requirements:
  - toPool.stakingEnabled == true
  - fromPool.unlocked == true
- Events:

  ```solidity
  StakeChanged(address indexed account, uint8 indexed fromPoolId, uint8 indexed toPoolId);
  ```

### withdraw

Users can withdraw mask token when pool is unlocked.

```solidity
withdraw(uint256 _amount) public {}
```

- parameters:
  - `_amount`: Amount of withdrawing Mask tokens
- Requirements:
  - pools[userInfos[msg.sender].poolId].unlocked == true
  - userInfos[msg.sender].stakedAmount >= \_amount
- Events:

  ```solidity
  unstaked(address indexed account, uint8 indexed poolId, uint256 unStakedAmount);
  ```

## Function Briefing in `Reward.sol`

### General Description

The backend will calculate the number of points based on contract events on-chain, thereby generating the MerkleTree root for each user's amount of RewardToken. Users can use the MerkleProof to claim their RewardToken rewards.

### Workflow in reward contract

1. Users get the proof data on frontend pages.
2. Users using proof data to call `claim()` to claim reward tokens.

### API

### claim

Users using proof data to call `claim()` to claim reward tokens.

```solidity
function claim(uint8 _poolId, uint256 _amount, bytes32[] calldata _proof) public {}
```

- parameters:
  - `_poolId`: reward pool id
  - `_amount`: Amount of reward tokens (get from frontend page)
  - `_proof`: merkle proof (get from frontend page)
- Requirements:
  - correct \_amount and \_proof using the correct msg.sender.
  - only can claim once for each address on one reward pool.
  - reward pool is unlocked.
- Events:

  ```solidity
  RewardClaimed(uint8 indexed poolId, address indexed account, uint256 amount);
  ```
