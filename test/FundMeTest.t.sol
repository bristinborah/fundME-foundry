// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {

    FundMe fundme;

   address User = makeAddr("Bristin");
   uint256 constant GAS_PRICE = 1;

   function setUp() external {
    //we deployed FundMeTest , FundMeTest deployed FundMe 
       //fundme = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
       DeployFundMe deployFundMe = new DeployFundMe();
         fundme = deployFundMe.run();
         vm.deal(User, 10e18);
   }

    modifier Funded(){
      vm.prank(User);
      fundme.fund{value : 8e18}();
      _;
   }

  function testMinimumDollarIsFive() public {
      console.log("kela");
      assertEq(fundme.MINIMUM_USD(), 5e18);
   }

  

   function testOwnerIsMsgSender() public {
      console.log(msg.sender);
      console.log(fundme.getOwner());
      assertEq(fundme.getOwner(), msg.sender);
   }
  
  function testPriceFeedVersionAccurate() public {
    uint256 version = fundme.getVersion();
    assertEq(version , 4);
  }

  function testFundFailsWithoutEnoughETH() public {
   vm.expectRevert(); // This expects the next line should revert
   fundme.fund(); //sending 0 eth
  }

  function testFundUpdatesFundedDataStructures() public Funded {
   // vm.prank(User);
  //  fundme.fund{value : 7e18}();// calling the fund() with 7 eth
    uint256 amountFunded = fundme.getAddressToAmountFunded(User); //checking the funder amount by passing funder address and storing it
    assertEq(amountFunded , 8e18);//comparing up the funded value with amount funded.
  }

  function testAddsFundersToArrayOfFunders() public Funded{
  // vm.prank(User);
   //fundme.fund{value : 8e18}();
   address funderAddress = fundme.getFunder(0);
   assertEq(funderAddress, User);
  }

  function testOnlyOwnerCanCallWithdraw() public Funded {
      //vm.prank(User);
    // fundme.fund{value: 8e18}();

     vm.expectRevert();
      vm.prank(User);
      fundme.withdraw();

    /*  address owner = fundme.i_owner();
      vm.prank(owner);
      vm.deal(owner, 10e18);
      fundme.withdraw();*/
  }
   function testWithrawASingleFunder() public Funded{
      //arrange 
      uint256 startingOwnerBalance = fundme.getOwner().balance;
      
      uint256 startingFundMeBalance = address(fundme).balance;

      //act 
      uint256 gasStart = gasleft();
      vm.txGasPrice(GAS_PRICE);
      vm.prank(fundme.getOwner());
      fundme.withdraw();

      uint256 gasEnd = gasleft();
      uint256 gasUsed = (gasStart- gasEnd) * tx.gasprice;
      console.log(gasUsed);

      //assert
      uint256 endingOwnerBalance = fundme.getOwner().balance;
      uint256 endingFundMeBalance = address(fundme).balance;
      assertEq(startingOwnerBalance+startingFundMeBalance, endingOwnerBalance );
      assertEq(endingFundMeBalance,0);
   }

   function testWithdrawFromMultipleFunders() public {
      
      uint160 numberOfFunders = 10;
      uint160 startingFunderIndex = 1;

      for(uint160 i = startingFunderIndex; i<=numberOfFunders; i++){
         hoax(address(i), 10e18);
         fundme.fund{value : 8e18}();
      }

      uint256 startingOwnerBalance = fundme.getOwner().balance;
      uint256 startingFundMeBalance = address(fundme).balance;

      vm.startPrank(fundme.getOwner());
      fundme.withdraw();
      vm.stopPrank();

      assertEq(address(fundme).balance , 0);
      assertEq(startingFundMeBalance + startingOwnerBalance , fundme.getOwner().balance);
   }

      function testWithdrawFromMultipleFunderCheaper() public {
      
      uint160 numberOfFunders = 10;
      uint160 startingFunderIndex = 1;

      for(uint160 i = startingFunderIndex; i<=numberOfFunders; i++){
         hoax(address(i), 10e18);
         fundme.fund{value : 8e18}();
      }

      uint256 startingOwnerBalance = fundme.getOwner().balance;
      uint256 startingFundMeBalance = address(fundme).balance;

      vm.startPrank(fundme.getOwner());
      fundme.cheaperWithdrawal();
      vm.stopPrank();

      assertEq(address(fundme).balance , 0);
      assertEq(startingFundMeBalance + startingOwnerBalance , fundme.getOwner().balance);
   }

} 