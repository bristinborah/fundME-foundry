// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

//Deploy mock when we are on a local anvil chain.
//keep tracks of contract address across different chain.
//Sepolia ETH/USD
//mainnet ETH/USD

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/mockV3Aggregator.sol";

contract HelperConfig is Script{

        NetworkConfig public activeNetworkConfig;

        struct NetworkConfig{
                address priceFeed;
        }

        constructor(){
            if(block.chainid == 11155111 ){
                activeNetworkConfig = getSepoliaETHConfig();
            }else if
            (block.chainid == 1){
                activeNetworkConfig = getMainnetETHConfig();
                }else{
                activeNetworkConfig = getOrCreateAnvilETHConfig();
            }
        }

        function getSepoliaETHConfig() public pure returns(NetworkConfig memory){
            NetworkConfig memory sepoliaConfig = NetworkConfig({
                priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
            });
            return sepoliaConfig;
        }

         function getMainnetETHConfig() public pure returns(NetworkConfig memory){
            NetworkConfig memory mainnetConfig = NetworkConfig({
                priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
            });
            return mainnetConfig;
        }

        function getOrCreateAnvilETHConfig() public returns(NetworkConfig memory){
            // deploy the mocks
            //return the mock address

            if(activeNetworkConfig.priceFeed!= address(0)){
                return activeNetworkConfig;
            }// this basically checks whether there's already a deployed address or not 

            vm.startBroadcast();
            MockV3Aggregator mockpriceFeed = new MockV3Aggregator(8, 2000e8);
            vm.stopBroadcast();

            NetworkConfig memory anvilConfig = NetworkConfig({
                priceFeed: address(mockpriceFeed)
            });
            return anvilConfig;
        }


}

