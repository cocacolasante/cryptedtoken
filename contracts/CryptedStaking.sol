// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;



import CryptedToken from "./CryptedToken.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

error Staking__NeedsMoreThanZero();

contract CryptedTokenStaking {

    IERC20 public immutable s_stakingToken;
    IERC20 public immutable s_rewardToken;

    uint256 public s_totalSupply;
    uint256 public s_rewardPerTokenStaked;
    uint256 public s_lastUpdateTime;
    uint256 public constant rewardRate = 100;

    address public owner;


    // address mapped to amount staked
    mapping(address => uint256) public s_balances;

    // address to what theyve been paid
    mapping(address => uint256) public s_userRewardPerTokenPaid;

    // mapping of how much rewards each address has to claim
    mapping(address => uint256) public s_rewards;
    
    constructor(address stakingToken, address rewardToken) {
        owner = msg.sender
        s_stakingToken =IERC20(stakingToken);
        s_rewardToken = IERC20(rewardToken);
    }

    function earned(address account) public view returns(uin256){
        uint256 currentBalance = s_balances[account];
        uint256 amountPaid = s_userRewardPerTokenPaid[account];
        uint256 currentRewardPerToken = rewardPerToken();
        uint256 pastRewards = s_rewards[account];

        uint256 _earned = ((currentBalance * (currentRewardPerToken - amountPaid)) / 1e18) + pastRewards;
        return _earned;
    }

        // update reward
    modifier updateReward(address account){
        // reward per token
        // last timestamp
        s_rewardPerTokenStaked = rewardPerToken();
        s_lastUpdateTime = block.timestamp;
        s_rewards[account] = earned(account);
        s_userRewardPerTokenPaid[account] = s_rewardPerTokenStaked;
        _;
        
    }

    modifier moreThanZero(uint256 amount){
        if(amount == 0){
            revert Staking__NeedsMoreThanZero();
        }
        _;
    }

    function rewardPerToken() public view returns(uint256){
        if(s_totalSupply == 0){
            return s_rewardPerTokenStaked;
        }
        return s_rewardPerTokenStaked + (((block.timestamp - s_lastUpdateTime ) * rewardRate * 1e18)/ s_totalSupply);
    }


    // staking function for only one token crypted token to earn governance token
    function stake(uint256 amount) external updateReward(msg.sender) moreThanZero(amount) {

        s_balances[msg.sender] = s_balances[msg.sender] + amount;
        s_totalSupply = s_totalSupply + amount;
        // emit event

        // transfer token to the contract
        bool success = s_stakingToken.transferFrom(msg.sender, address(this), amount);
        require(success);
        
    }

    // withdraw
    function withdraw(uint256 amount) external updateReward(msg.sender) moreThanZero(amount) {
        s_balances[msg.sender] = s_balances[msg.sender] - amount;
        s_totalSupply = s_totalSupply - amount;

        bool success = s_stakingToken.transfer(msg.sender, amount);

    }

    // claim reward
    function claimReward() external updateReward(msg.sender) {
        uint256 reward = s_rewards[msg.sender];
        bool success = s_rewardToken.transfer(msg.sender, reward);
        require(success);

    }
    
}
