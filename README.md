# Bet The Average Bet 
The goal of this project is to implement Game Theory's classic ["Guess 2/3 of the Average"](https://en.wikipedia.org/wiki/Guess_2/3_of_the_average) on Ethereum as a smart contract. I wrote this code in October 2018, inspired in part by [FOMO3D](https://fomo3d.hostedwiki.co/pages/Fomo3D%20Explained) and in part by the Yale University Game Theory course 

In short, it is a Solidity Smart Contract which takes bids and, every X minutes, sends the entire pot to the person who bid the closest to the 2/3 average bid.

## Vulnerabilities
### Spam betting 
Attackers can send a high volume of low bids and deviate the average to zero, thus disincentivizing higher bids. 
Possible Solutions: 
* Make the minimum bid amount a certain % of the pot.
* Unique bids at a certain precision 
  * Possible attack vector = If bid amount is capped in order to prevent [attritional warfare](https://en.wikipedia.org/wiki/War_of_attrition_(game)), someone could bid the mean of the factorial of the max bid, then bid most of the bids below that.

## Considerations
- If it's too complex, no one will play it.
  - which is a better game - chess or flappy bird? (A crude crude comparison, but a serious epistemological consideration)
- Stick with the original classic game as closely as possible
### Payment process:
- [x] Bid _is_ payment: - bids are public anyway. why not.
- [ ] Staking -  use in-contract proof of stake to validate participants, with separate methods for staking 
### Tie handling:
- [x] Higher bid wins.
### Game duration:
- [x] By time? - presumes that the game will be popular - needs to be popular in order to work. - simplest. - Extension?:
- [ ] 2 hours from the last bid  
- would probably just cause an infinite war of attrition
- [ ] By bid count? - individuals could rig the game by taking up majority of bets (if unique bids)
- [ ] By pot size - game ends once pot reaches certain size
- [ ] Dynamic - game ends once pot reaches 100x the average - too complex
- [ ] Dynamic - Has worked well with FOMO3D
### Target bid:
- [x] 2/3 the average? - deviates to zero - sticks to original
- [ ] Double the average? - deviates to ethereum total supply || bid cap
### Bid attributes:
- [x] Unique? - discourages spamming
- [ ] Capped range? e.g. 0<=>100 - if unique and capped, the game is halted after 100 bids
- [ ] Dynamic capped range? e.g. 0<==>Average Bid - interesting, but possibly too complex
- [+] Uncapped? e.g. 0< - possibly gives upper hand to rich people
- [ ] Updateable? - decreases the effectiveness of bid-spamming
###  Fees?:
- [x] percentage of pot
###  Winner Calculation:
- [ ] remove lowest & highest bids?
