## Simple Proactive Funding

Run tests: `forge test --optimize --fork-url https://opt-mainnet.g.alchemy.com/v2/3BnmyMDqbKD1ogt5a2iWGwq2-OiwHr6J`

Deploy: `forge script script/OPSepolia_Deploy_SimpleProactiveFunding.s.sol:DeploySimpleProactiveFundingScript --optimize --rpc-url $OP_SEPOLIA_RPC_URL --private-key $OP_SEPOLIA_PRIVATE_KEY --slow --broadcast --chain-id 11155420 --verify`

verify: `forge verify-contract 0x38F9cd32D41f109ca7bBd07d248c20D22b76b2A5 SimpleProactiveFunding --chain-id 11155420 --watch`
