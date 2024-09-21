-include .env

.PHONY: all test clean deploy fund help install snapshot format anvil 

DEFAULT_ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

help:
	@echo "Usage:"
	@echo "  make deploy [ARGS=...]\n    example: make deploy ARGS=\"--network sepolia\""
	@echo ""
	@echo "  make fund [ARGS=...]\n    example: make deploy ARGS=\"--network sepolia\""

all: clean remove install update build

# Clean the repo
clean  :; forge clean

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

install :; forge install cyfrin/foundry-devops@0.2.2 --no-commit && forge install smartcontractkit/chainlink-brownie-contracts@1.1.1 --no-commit && forge install foundry-rs/forge-std@v1.8.2 --no-commit && forge install transmissions11/solmate@v6 --no-commit

# Update Dependencies
update:; forge update

build:; forge build

test :; forge test 

snapshot :; forge snapshot

format :; forge fmt

anvil :; anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1

NETWORK_ARGS := --rpc-url http://localhost:8545 --private-key  --broadcast

ifeq ($(findstring --network sepolia,$(ARGS)),--network sepolia)
	NETWORK_ARGS := -rpc-url https://eth-sepolia.g.alchemy.com/v2/n_07YnqPCJNvRc7N5FWXRrBprJT4EJ-r --private-key  fee929d9036d579f5f3f394ab509aa58085fcd81f0232fd457b2d1fdf644284b --broadcast --verify --etherscan-api-key TRD6MK7AKS41ZTYTRFZR44C6R3C9XYXJ6A -vvvv
endif

deploy:
	@forge script script/DeployRaffle.s.sol:DeployRaffle $(NETWORK_ARGS)

createSubscription:
	@forge script script/Interactions.s.sol:CreateSubscription $(NETWORK_ARGS)

addConsumer:
	@forge script script/Interactions.s.sol:AddConsumer $(NETWORK_ARGS)

fundSubscription:
	@forge script script/Interactions.s.sol:FundSubscription $(NETWORK_ARGS)

deploy-sepolia: 
	@forge script script/DeployRaffle.s.sol:DeployRaffle --rpc-url https://eth-sepolia.g.alchemy.com/v2/n_07YnqPCJNvRc7N5FWXRrBprJT4EJ-r --private-key  fee929d9036d579f5f3f394ab509aa58085fcd81f0232fd457b2d1fdf644284b --broadcast --verify --etherscan-api-key TRD6MK7AKS41ZTYTRFZR44C6R3C9XYXJ6A -vvvv