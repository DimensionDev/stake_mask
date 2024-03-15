// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Greeter.sol";

contract GreeterTest is Test {
    Greeter internal greeter;
    string internal deployedGreetMsg = "Hello, World!";
    string internal newGreetMsg = "Hello, Solidity!";

    function setUp() public {
        vm.label(address(0x01), "contractCreator");
        vm.label(address(0x02), "caller");
        startHoax(address(0x01));
        greeter = new Greeter(deployedGreetMsg);
        vm.stopPrank();
    }

    function testDeployer() public {
        address deployer = greeter.deployer();
        assertTrue(deployer == address(0x01));
    }

    function testGreetMsg() public {
        string memory greetMsg = greeter.greet();
        assertEq(greetMsg, deployedGreetMsg);
    }

    function testSetGreeter() public {
        startHoax(address(0x01));
        greeter.setGreeting(newGreetMsg);
        string memory greetMsg = greeter.greet();
        assertEq(greetMsg, newGreetMsg);
    }

    function testCannotSetGreeter() public {
        vm.expectRevert(getErrorMsg("Not Deployer"));
        greeter.setGreeting(newGreetMsg);
    }

    function getErrorMsg(string memory errorMsg) internal pure returns(bytes memory){
        return bytes(errorMsg);
    }

}
