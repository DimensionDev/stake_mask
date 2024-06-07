# Stake Mask

### Introduction

This project is about staking MASK tokens to earn ecosystem token rewards. It consists of two main contracts:
`StakeManager.sol`, manages the staking of MASK tokens.
`Reward.sol`, distributes ecosystem token rewards.

## Getting Started

### Deployed Contract Address

<!-- begin address -->

| Chain   | StakeManager                  | Reward                         |
| ------- | ----------------------------- | ------------------------------ |
| mainnet | [`0x089f9e40`][stake-mainnet] | [`0xb55f6363`][reward-mainnet] |

[stake-mainnet]: https://etherscan.io/address/0x089f9e409e2ae5837def520ce6bfb2fa03ce5128
[reward-mainnet]: https://etherscan.io/address/0xb55f6363e8033641ada71afadabd667d071bc9b1

<!-- end address -->

### Build / Compile

Build / Compile the contracts:

```sh
$ forge build
```

### Clean

Delete the build artifacts and cache directories:

```sh
$ forge clean
```

### Coverage

Get a test coverage report:

```sh
$ forge coverage
```

### Generate typechain (by hardhat)

Generate typechain (by hardhat):

```sh
$ npx hardhat compile
```

### Deploy

Deploy:

```sh
$ npx hardhat --network <network> deploy <tag>
```

### Format

Format the contracts:

```sh
$ forge fmt
```

### Gas Usage

Get a gas report:

```sh
$ forge test --gas-report
```

### Test

Run the tests:

```sh
$ forge test
```

Run the tests with detailed report:

```sh
$ forge test -vvvv
```

### Verify

Verify contracts:

```sh
$ ETHERSCAN_API_KEY=<etherscan_api_key> forge verify-contract --watch --compiler-version "v0.8.23" \
  [--verifier-url http://localhost:5000] \
  --constructor-args $(cast abi-encode "constructor(string)" "string") \
  <address> Some-contract

```
