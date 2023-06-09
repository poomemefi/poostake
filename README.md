# $POO Stake Smart Contract

This repository contains the code for an Ethereum-based staking smart contract for the POO Token.

## Key Features
- Deployed and controlled by master address that deploys the contract
- Staking reserve pool that accepts token deposits from any address
- Master address can withdraw any tokens deposited into the reserve at any time
- Users accrue rewards on a daily basis, displayed on the DApp
- Contract can be updated by the master address, including updating reward variables
- Minimum staking amount: 100 $POO tokens
- Maximum staking amount: N/A
- Locked staking duration to receive rewards: 3 months
- Stakes are locked for the duration of the stake (minimum of 3 months) and only end when the user unstakes their tokens. Users can only unlock staking requests and withdraw rewards after this period.
- Stakers accrue rewards based on the equation: Individual staking power / Total staking power ie. 100 / 5000 = .02 rewards rate
- Individual staking power = Duration of stake * Amount of $POO staked ie. 100 = 1 day * 100 $POO
- Total Staking Power = Sum of all individual staking power ie. 5000 = 50 Stakers that all have 100 ISP 

## Staking Process
1. To stake $POO tokens, users must first approve the staking contract to spend their tokens.
2. Once the tokens have been approved, users can stake their tokens by calling the stake() function. The stake() function returns a unique identifier representing the user's stake.
3. Users can track their rewards by calling the rewards() function. The rewards() function returns the total amount of rewards earned by the user.
4. Users can withdraw their rewards by calling the withdraw() function. The withdraw() function returns the total amount of rewards earned by the user. 

## Getting Started
To get started with this project, follow these steps:

1. Clone the repository
```bash
git clone https://github.com/poomemefi/poostake.git


2. Install dependencies
npm install


3. Compile the smart contract
npx hardhat compile


4. Deploy the smart contract
npx hardhat run scripts/deploy.js --network <network>


Testing
To run the test suite, execute the following command:

npx hardhat test
