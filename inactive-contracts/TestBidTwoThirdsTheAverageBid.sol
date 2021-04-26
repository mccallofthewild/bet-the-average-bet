pragma solidity ^0.4.2;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/BidTwoThirdsTheAverageBid.sol";


contract TestBidTwoThirdsTheAverageBid {

  BidTwoThirdsTheAverageBid bidTwoThirds = BidTwoThirdsTheAverageBid(
    DeployedAddresses.BidTwoThirdsTheAverageBid()
  );

  uint initialStartTime;

  function testGetMinBid () public {
    Assert.equal(bidTwoThirds.getMinBid(), 0, "It should construct with minBid 0");
  }

  function testStartNewGame () {
    bidTwoThirds.startNewGame();
    initialStartTime = now;
    Assert.equal(bidTwoThirds.getCurrentGameStartTime(), now, "start time should be now");
  }

  function testSetGameDuration () {
    uint original = bidTwoThirds.getGameDuration();
    bidTwoThirds.setGameDuration(0 seconds);
    Assert.equal(bidTwoThirds.getGameDuration(), 0 seconds, "game duration should've changed");
    Assert.equal(bidTwoThirds.getGameDuration() != original, true, "game duration should've changed");
  }

  function testEndCurrentGame_testGetCurrentGameStartTime () {
    bidTwoThirds.endCurrentGame();
    Assert.equal(bidTwoThirds.getCurrentGameStartTime(), 0, "currentGame should've been deleted");
  }

  function testGetGameByStartTime () {
    (
      uint startTime, 
      uint endTime, 
      uint minBid, 
      uint sumOfBids, 
      uint bidCount, 
      address winner, 
      uint256[] memory bids
    ) = bidTwoThirds.getGameByStartTime(initialStartTime);
    Assert.equal(startTime, initialStartTime, "ended game should've been stored.");
  }



}
