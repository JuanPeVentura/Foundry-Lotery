// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;


import {Test, console} from "forge-std/Test.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

import {CreateSubscription, FundSubscription, AddConsumer} from "script/Interactions.s.sol";
import {DeployRaffle} from "script/DeployRaffle.s.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {Raffle} from "src/Raffle.sol";

contract InteractionsTest is Test {
    CreateSubscription createSubscription;
    FundSubscription fundSubscription;
    AddConsumer addConsumer;
    HelperConfig helperConfig;
    Raffle raffle;

    address vrfCoordinator;
    uint256 subscriptionId;
    address link;
    address account;


    function setUp() public {
        createSubscription = new CreateSubscription();
        fundSubscription = new FundSubscription();
        addConsumer = new AddConsumer();

        DeployRaffle deployer = new DeployRaffle();
        (raffle,helperConfig) = deployer.deployContract();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

        vrfCoordinator = config.vrfCoordinator;
        subscriptionId = config.subscriptionId;
        link = config.link;
        account = config.account;

    }

    function testCreateSubscriptionUsingConfigCreatesTheSubscription() public {
        (uint256 subId,) = createSubscription.createSubscription(vrfCoordinator, account);
        console.log("The subId generated is: ", subId);
        console.log("The config subId is: ", subscriptionId);

        assert(subId != 0);
    }


    function testFundSubscriptionFundsSubscritpion() public {
        
        (uint256 subId, ) = createSubscription.createSubscription(vrfCoordinator, account);
        (uint256 balanceBeforeFund, , , , ) = VRFCoordinatorV2_5Mock(vrfCoordinator).getSubscription(subId);
        fundSubscription.fundSubscription(vrfCoordinator, subId, link, account);
        (uint256 balanceAfterFund, , , , ) = VRFCoordinatorV2_5Mock(vrfCoordinator).getSubscription(subId);
        console.log("Subscription balance before fund is: ", balanceBeforeFund);
        console.log("Subscription balance after fund is: ", balanceAfterFund);

        assert(balanceAfterFund > balanceBeforeFund);
    }

    function testAddConsumerAddsAConsumer() public {
        (uint256 subId, ) = createSubscription.createSubscription(vrfCoordinator, account);
        addConsumer.addConsumer(address(raffle), vrfCoordinator, subId, account);
        (, , , ,address[] memory consumers ) = VRFCoordinatorV2_5Mock(vrfCoordinator).getSubscription(subId);
        console.log("Consumer is: ", consumers[0]);
        assert(consumers[0] == address(raffle));
    }
}