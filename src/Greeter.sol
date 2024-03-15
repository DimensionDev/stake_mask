//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;


contract Greeter {
    address public deployer;
    string private greeting;

    constructor(string memory _greeting) {
        greeting = _greeting;
        deployer = msg.sender;
    }

    modifier onlyDeployer() {
        require(msg.sender == deployer, "Not Deployer");
        _;
    }

    function setGreeting(string memory _greeting) public onlyDeployer {
        greeting = _greeting;
    }

    function greet() public view returns (string memory) {
        return greeting;
    }
}
