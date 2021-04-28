<p align="center">
<img width="300" src="https://raw.githubusercontent.com/mccallofthewild/bet-the-average-bet/master/public/3-Logo.svg"/>
</p>

 <h1 align="center">Bet The Average Bet </h1>

<p align="center">
 An Experiment in Smart Contract Security and Gamification
</p>

<p align="center">
 <b>Solidity Implementation:</b>
 <a href="https://github.com/mccallofthewild/bet-the-average-bet/blob/master/contracts/BidTwoThirdsTheAverageBid.sol">
  contracts/BidTwoThirdsTheAverageBid.sol
 </a>
</p>

The goal of this project is to implement Game Theory's classic <a href="https://en.wikipedia.org/wiki/Guess_2/3_of_the_average">"Guess 2/3 of the Average"</a> on Ethereum as a smart contract. I wrote this code in October 2018, inspired by <a href="https://fomo3d.hostedwiki.co/pages/Fomo3D%20Explained">FOMO3D</a> and the Yale University Game Theory course in which I was first introduced to the game.

In short, it is a Solidity Smart Contract which takes bids and, every X minutes, sends the entire pot to the person who bid the closest to the 2/3 average bid.

# Attack Vectors

## Flash Loans 
After initially allowing their targets to place bets, attackers could:
* Send a high volume of high-quantity bets via a flash loan, immediately ending any game capped by pot size or bet count
* Utilize all unique bids remaining for [unique-bid](https://en.wikipedia.org/wiki/Unique_bid_auction) auction variant

## Spam betting 
Attackers can send a high volume of low bids and deviate the average to zero, thus disincentivizing higher bids. 
Possible Solutions: 
* Make the minimum bid amount a certain % of the pot.
* Unique bids at a certain precision 
  * Possible attack vector = If bid amount is capped in order to prevent [attritional warfare](https://en.wikipedia.org/wiki/War_of_attrition_(game)), someone could bid the mean of the factorial of the max bid, then bid most of the bids below that.

## Transaction Racing
Attackers could watch for new transactions being signed on the network, update their bets, and beat them to the punch by attaching a higher gas fee to their transactions. Similar to a strategy used by arbitrage traders on Ethereum DEX's.

# 🤔 Protocol Design Options
## Payment/Bidding Process:
- [x] Bid _is_ payment: bids are public anyway. why not.
- [ ] Staking: use in-contract proof of stake to validate participants, then use . 
## Tie Handling:
- [x] Higher bid wins.
## Game Duration:
- [x] By time
- [ ] 2 hours from the last bid: Could trigger a war of attrition
- [ ] By bid count: individuals could rig the game by taking up majority of bets (if unique bids)
- [ ] By pot size: game ends once pot reaches certain size. (See Flash Loan vulnerability above)
- [ ] Dynamic: game ends once pot reaches 100x the average.
- [ ] Dynamic: Has worked well with FOMO3D
## Target Bid:
- [x] 2/3 the average? - deviates to zero - sticks to original
- [ ] Double the average? - deviates to ethereum total supply || bid cap
## Bid attributes:
- [x] Unique? - discourages spamming
- [ ] Capped range? e.g. 0<=>100 - if unique and capped, the game is halted after 100 bids
- [ ] Dynamic capped range? e.g. 0<==>Average Bid - interesting, but possibly too complex
- [+] Uncapped? e.g. 0< - possibly gives upper hand to rich people
- [ ] Updateable? - decreases the effectiveness of bid-spamming
##  Fees?:
- [x] percentage of pot
##  Winner Calculation:
- [ ] remove lowest & highest bids?
## Marketing 
- If it's too complex, no one will play it.
  - which is a better game - chess or flappy bird? (A crude crude comparison, but a serious epistemological consideration)
- Stick with the original classic game as closely as possible
