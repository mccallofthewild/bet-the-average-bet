pragma solidity ^0.4.0;
// USE SECURE MATH (https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/math/Math.sol)
import "./helpers/Mortal.sol";
import "./helpers/CustomMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/lifecycle/Pausable.sol";

/**
 * @title A Game-Theory Inspired Bidding game
 * @dev Bidder who bids closest to average wins the pot. Bids are public.
 */
contract BidTwoThirdsTheAverageBid is Ownable, Mortal, Pausable {
    using SafeMath for uint256;
    using CustomMath for uint256;

    /***************************
     ******** TYPES ************
     ***************************/

    /**
     * @dev represents a game.
     */
    struct Game {
        // start time
        uint256 startTime;
        // end time
        uint256 endTime;
        // minimum bid
        uint256 minBid;
        // sum of all bids sent
        uint256 sumOfBids;
        // total bids sent (for average calculation)
        uint256 bidCount;
        // winner
        address winner;
        // bids as integers of their value
        uint256[] bids;
        // makes players searchable by their bid
        mapping(uint256 => address) playersByBid;
    }

    /***************************
     ******** STATE ************
     ***************************/

    /**
     * @dev stores games by their start time (block timestamp at the game's start).
     */
    mapping(uint256 => Game) private gamesByStartTime;

    // game duration
    uint256 private gameDuration = 1 days;

    // minimum bid
    uint256 private minBid = 0 ether;

    // current game. storing in state avoids additional hash lookups.
    Game private currentGame;

    /***************************
     ******** MODIFIERS ********
     ***************************/

    // ensures the current game is finished before running function
    modifier gameFinished(uint256 gameEndTime) {
        require(
            now > gameEndTime,
            "Must wait until current game ends to complete this action."
        );
        _;
    }

    // ensures current game is active before running function
    modifier gameActive(uint256 gameStartTime, uint256 gameEndTime) {
        require(
            now < gameEndTime && now >= gameStartTime,
            "Game ended. Must start a new game to complete this action."
        );
        _;
    }

    /****************************
     ****** PUBLIC FUNCTIONS ****
     ****************************/

    // #SETTERS

    function setGameDuration(uint256 newDuration) public onlyOwner {
        gameDuration = newDuration;
    }

    function setMinBid(uint256 newMinBid) public onlyOwner {
        minBid = newMinBid;
    }

    // #ACTIONS

    // places bid
    function placeBid()
        public
        payable
        gameActive(currentGame.startTime, currentGame.endTime)
    {
        uint256 value = msg.value;
        require(
            value > currentGame.minBid,
            "Must meet minimum bid requirement."
        );
        require(
            currentGame.playersByBid[value] == address(0),
            "Bids must be unique."
        );
        currentGame.bidCount++;
        currentGame.sumOfBids += value;
        currentGame.bids.push(value);
        currentGame.playersByBid[value] = msg.sender;
    }

    // starts a new game
    function startNewGame() public gameFinished(currentGame.endTime) {
        if (currentGame.startTime > 0) endCurrentGame();
        Game memory game;
        game.minBid = minBid;
        game.startTime = now;
        game.endTime = uint256(now).add(uint256(gameDuration));
        currentGame = game;
    }

    // saves game to storage then deletes
    function endCurrentGame() public gameFinished(currentGame.endTime) {
        gamesByStartTime[currentGame.startTime] = currentGame;
        delete currentGame;
    }

    // verifies winning bid, and sets the winner.
    function determineAndSetGameWinner(uint256 gameStartTime) public {
        Game storage game = gamesByStartTime[gameStartTime];
        uint256 winningBid = determineWinningBid(game.startTime);
        address winner = game.playersByBid[winningBid];
        if (winner == address(0)) winner = owner;
        gamesByStartTime[game.startTime].winner = winner;
    }

    // determines the winning bid.
    function determineWinningBid(uint256 gameStartTime)
        public
        view
        returns (uint256)
    {
        Game storage game = gamesByStartTime[gameStartTime];
        uint256 comparisonNumber =
            calculateTwoThirdsOfAverageBid(game.sumOfBids, game.bidCount);

        // initializing with non-possible values...
        uint256 smallestDifference = game.sumOfBids;
        uint256 bidWithSmallestDifference = game.sumOfBids;

        // ensures that `i` is type cast to the most efficient fitting uint type
        uint256 i = game.bids.length;
        i = 0;

        // saves memory by avoiding repeat variable definitions
        uint256 difference = uint256(game.sumOfBids);
        uint256 bid;

        // for each bid...
        for (i = 0; i < game.bids.length; i++) {
            bid = game.bids[i];

            // absolute value of difference
            difference = uint256(comparisonNumber).difference(uint256(bid));
            bool isClosest = difference < smallestDifference;
            // higher bid takes precedence in case of a tie.
            bool equalDifferenceButHigherBid =
                (difference == smallestDifference) &&
                    (bid > bidWithSmallestDifference);
            if (isClosest || equalDifferenceButHigherBid) {
                difference = smallestDifference;
                bidWithSmallestDifference = bid;
            }
        }
        return bidWithSmallestDifference;
    }

    function calculateTwoThirdsOfAverageBid(uint256 sumOfBids, uint256 bidCount)
        public
        pure
        returns (uint256)
    {
        // safe version of average * 2/3
        return
            uint256(sumOfBids).div(uint256(bidCount)).mul(uint256(2)).div(
                uint256(3)
            );
    }

    // #GETTERS

    // gets a game by its start time
    function getGameByStartTime(uint256 startTime)
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            address,
            uint256[]
        )
    {
        Game storage game = gamesByStartTime[startTime];
        return (
            game.startTime,
            game.endTime,
            game.minBid,
            game.sumOfBids,
            game.bidCount,
            game.winner,
            game.bids
        );
    }

    // gets current game's start time
    function getCurrentGameStartTime() public view returns (uint256) {
        return currentGame.startTime;
    }

    // gets gets game by start time then gets player by bid amount
    function getGamePlayerByBidAmount(uint256 startTime, uint256 bidAmount)
        public
        view
        returns (address)
    {
        return gamesByStartTime[startTime].playersByBid[bidAmount];
    }

    // gets game duration
    function getGameDuration() public view returns (uint256) {
        return gameDuration;
    }

    // gets minimum bid
    function getMinBid() public view returns (uint256) {
        return minBid;
    }

    /*****************************
     ****** PRIVATE FUNCTIONS ****
     *****************************/

    function requireGameFinished(uint256 gameEndTime)
        private
        view
        gameFinished(gameEndTime)
    {}
}
