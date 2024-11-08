-include .env

build:; forge build

deploy-seploia: forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broardcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv