pragma solidity ^0.4.0;

/** 
  * @title A Game-Theory Inspired Game
  * @dev must be refactored towards gains, in order to incentivize playing.
  * A prisoner's dilemma is something you get caught in, not something you 
  * put yourself into for fun.
  *   - Add two to each tradeoff
  * Can't work with current ethereum protocol. too public. 
  * PD requires that there is no communication between the prisoners.
 */ 
contract PrisonersDilemma {

  enum PrisonerAction {
    // betray
    Defect,
    // cooperate
    Cooperate
  }

  struct Game {
    address prisonerA;
    address prisonerB;
    PrisonerAction prisonerAChoice;
    PrisonerAction prisonerBChoice;
    uint prisonerAPayout;
    uint prisonerBPayout;
    uint agreedSum;
  }

  Game currentGame;

  address owner;

  uint ownerPayout;

  uint ownerPayoutBasePercentage = 6;

  constructor () public {
    owner = msg.sender;
  }

  function determineOutcome () public {
    uint agreedSum = currentGame.agreedSum;
    // both incur a 1/3 penalty
    uint dualCooperatePayout = agreedSum * 2/3;
    // one incurs a 3/3 penalty
    uint singleDefectPayout = agreedSum * 2;
    // both incur a 2/3 penalty
    uint dualDefectPayout = agreedSum * 1/3;

    // both cooperate
    if (
      currentGame.prisonerAChoice == PrisonerAction.Cooperate &&
      currentGame.prisonerBChoice == PrisonerAction.Cooperate
    ) {
      currentGame.prisonerAPayout = dualCooperatePayout;
      currentGame.prisonerBPayout = dualCooperatePayout;
    }

    // only prisoner B defects
    if (
      currentGame.prisonerAChoice == PrisonerAction.Cooperate &&
      currentGame.prisonerBChoice == PrisonerAction.Defect
    ) {
      currentGame.prisonerAPayout = 0;
      currentGame.prisonerBPayout = singleDefectPayout;
    }

    // both defect
    if (
      currentGame.prisonerBChoice == PrisonerAction.Defect &&
      currentGame.prisonerAChoice == PrisonerAction.Defect
    ) {
      currentGame.prisonerBPayout = dualDefectPayout;
      currentGame.prisonerAPayout = dualDefectPayout;
    }

    ownerPayout += (currentGame.agreedSum * 2) - (currentGame.prisonerAPayout + currentGame.prisonerBPayout);
  }

}