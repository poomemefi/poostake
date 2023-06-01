// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

/// Dependencies
import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/PooStaking.sol";
import "../src/PooMeme.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract PooStakingTest is Test {
    PooMeme public pooMeme;
    PooStaking public pooStaking;

    // Staker Address
    address staker = 0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496;
    address staker2 = address(0x7FA9);
    address staker3 = address(0x7FA);

    function setUp() public {
        // Deploy PooMeme Token
        pooMeme = new PooMeme();

        // Unlock token transfer
        pooMeme.unlock();

        // Deploy PooStaking
        pooStaking = new PooStaking(address(pooMeme));
    }

    function test_stake() public {
        // Approve PooStaking to spend POO
        pooMeme.approve(address(pooStaking), 100 * 1 ether);

        // Stake 100 POO
        pooStaking.stake(100 * 1 ether);

        // Check stakedAmount
        assertEq(pooStaking.stakedAmount(staker), 100 * 1 ether);
    }

    function test_withdraw() public {
        // Send POO to Contract
        pooMeme.transfer(address(pooStaking), 10000000 * 1 ether);

        // Approve PooStaking to spend POO
        pooMeme.approve(address(pooStaking), 100 * 1 ether);

        // Stake 100 POO
        pooStaking.stake(100 * 1 ether);

        // Check stakedAmount
        assertEq(pooStaking.stakedAmount(staker), 100 * 1 ether);

        // Withdraw
        // Adjust the block.timestamp to be greater than minimum staking duration
        vm.warp(1680616584 + 90 days + 2 seconds);
        pooStaking.withdraw();
    }

    function test_withdraw_revert_duration() public {
        // Approve PooStaking to spend POO
        pooMeme.approve(address(pooStaking), 100 * 1 ether);

        // Stake 100 POO
        pooStaking.stake(100 * 1 ether);

        // Check stakedAmount
        assertEq(pooStaking.stakedAmount(staker), 100 * 1 ether);

        // Withdraw
        vm.expectRevert("Stake time not completed");
        pooStaking.withdraw();
    }

    function test_withdraw_revert_not_staker() public {
        vm.startPrank(staker2);
        // Withdraw
        vm.expectRevert("User not a Staker");
        pooStaking.withdraw();
    }

    function test_reward() public {
        // Send POO to Contract
        pooMeme.transfer(address(pooStaking), 10000000 * 1 ether);

        // Approve PooStaking to spend POO
        pooMeme.approve(address(pooStaking), 100 * 1 ether);

        // Stake 100 POO
        pooStaking.stake(100 * 1 ether);

        // Check reward
        assertEq(pooStaking.rewards(staker), 1);
    }
}
