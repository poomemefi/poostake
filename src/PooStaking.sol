// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

/// Dependencies
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract PooStaking is Ownable {
    /// Variables
    uint256 public MIN_STAKE = 100 * 1 ether;
    uint256 public MAX_STAKE;
    uint256 public MIN_STAKE_DURATION = 90 days; // 3 months, 90 days
    IERC20 public POO_TOKEN;

    /// Storage
    address[] public stakers;
    mapping(address => uint256) public stakedAmount;
    mapping(address => uint256) public stakedTime;

    /// Events
    event Staked(address indexed user, uint256 amount, uint256 timestamp);
    // event Unstaked(address indexed user, uint256 amount, uint256 timestamp);
    // event RewardClaimed(address indexed user, uint256 amount, uint256 timestamp);
    event Withdraw(address indexed user, uint256 amount, uint256 timestamp);

    /// Modifiers

    /// Constructor
    constructor(address _pooToken) {
        require(_pooToken != address(0), "Cannot set zero address");
        POO_TOKEN = IERC20(_pooToken);
    }

    /// Functions

    function stake(uint256 amount) external {
        require(stakedAmount[msg.sender] == 0, "Already staked");
        require(
            POO_TOKEN.balanceOf(msg.sender) >= amount,
            "Insufficient token amount"
        );
        require(
            POO_TOKEN.transferFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );

        stakers.push(msg.sender);
        stakedAmount[msg.sender] = amount;
        stakedTime[msg.sender] = block.timestamp;
        emit Staked(msg.sender, amount, block.timestamp);
    }

    function withdraw() external {
        require(stakedAmount[msg.sender] >= MIN_STAKE, "User not a Staker");
        require(
            block.timestamp - stakedTime[msg.sender] >= MIN_STAKE_DURATION,
            "Stake time not completed"
        );

        uint256 _rewards = _calculateReward(msg.sender);
        uint256 _stakedAmount = stakedAmount[msg.sender];
        uint256 _total = _rewards + _stakedAmount;

        stakedAmount[msg.sender] = 0;
        stakedTime[msg.sender] = 0;

        require(_rewards > 0, "No rewards to claim");
        require(
            POO_TOKEN.balanceOf(address(this)) >= _total,
            "Insufficient Contract token balance"
        );
        require(POO_TOKEN.transfer(msg.sender, _total), "Transfer failed");

        emit Withdraw(msg.sender, _total, block.timestamp);
    }

    function rewards(address _user) external view returns (uint256 _rewards) {
        require(stakedAmount[_user] >= MIN_STAKE, "User not a Staker");
        require(_calculateReward(_user) > 0, "No rewards to claim");
        _rewards = _calculateReward(_user);
        return _rewards;
    }

    function stakeDuration(
        address _user
    ) external view returns (uint256 duration) {
        require(stakedAmount[_user] >= MIN_STAKE, "User not a Staker");
        duration = block.timestamp - stakedTime[_user];
        return duration;
    }

    /// Internal functions

    function _calculateReward(
        address _user
    ) internal view returns (uint256 reward) {
        uint256 stakingPower = _individualStakePower(_user);
        uint256 totalStakingPower = _calculateTotalStakingPower();
        reward = stakingPower / totalStakingPower;
        return reward;
    }

    function _individualStakePower(
        address _user
    ) internal view returns (uint256 stakingPower) {
        uint256 timeDiff = block.timestamp - stakedTime[_user];
        stakingPower = stakedAmount[_user] * timeDiff;
        return stakingPower;
    }

    function _calculateTotalStakingPower()
        internal
        view
        returns (uint256 totalStakingPower)
    {
        for (uint256 i = 0; i < stakers.length; i++) {
            totalStakingPower += _individualStakePower(stakers[i]);
        }
        return totalStakingPower;
    }
}
