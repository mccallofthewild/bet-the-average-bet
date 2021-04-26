var BidTwoThirdsTheAverageBid = artifacts.require("BidTwoThirdsTheAverageBid");
const ganache = require('ganache-cli');
const Web3 = require('web3');
let web3 = new Web3(new Web3.providers.HttpProvider("http://127.0.0.1:8545"));

contract ('BidTwoThirdsTheAverageBid', accounts => {

  let ownerAccount;
  let notOwner;
  ownerAccount = accounts[0];
  notOwner = accounts[1];

  let instance;
  let instanceAddress;

  let gameOver;

  it ('#constructor', async () => {
    instance = await BidTwoThirdsTheAverageBid.deployed();
    instanceAddress = await instance.address;
    assert.notStrictEqual(instance, undefined)
  });

  it ('@modifier#onlyOwner via !#setGameDuration', async () => {
    let threw = false;
    try {
      await instance.setGameDuration({
        from: notOwner
      });
    } catch (e) {
      threw = true;
    }
    assert.equal(threw, true)
  });

  it ('#setGameDuration, #getGameDuration', async () => {
    let originalDuration = await instance.getGameDuration.call();
    let proposedDuration = 6; // seconds 
    gameOver = new Promise(resolve => setTimeout(resolve, proposedDuration * 1500));
    await instance.setGameDuration.sendTransaction(
      proposedDuration, 
      { from: ownerAccount }
    );
    let newDuration = await instance.getGameDuration.call();
    assert.notStrictEqual(originalDuration.toNumber(), newDuration.toNumber());
  })

  it ('#setMinBid, #getMinBid', async () => {
    let original = await instance.getMinBid.call();
    let ownerbalance = await web3.eth.getBalance(ownerAccount)
    let notownerbalacne = await web3.eth.getBalance(notOwner)
    await instance.setMinBid(
      original.plus(web3.utils.toWei('0.01', 'ether')).toNumber(),
      { from: ownerAccount }
    );
    let updated = await instance.getMinBid.call();
    assert.notStrictEqual(original, updated);
  })

  it ('@modifier#gameActive via #placeBid', async () => {
    let minBid = await instance.getMinBid.call();
    let threw = false;
    try {
      await instance.placeBid({
        from: notOwner, 
        value: minBid.minus(1).toNumber() 
      });
    } catch (e) {
      threw = e.message.includes('Must start a new game');
    }
    assert.equal(threw, true);
  })

  it ('#startNewGame, #getCurrentGameStartTime', async () => {
    let original = await instance.getCurrentGameStartTime.call();
    await instance.startNewGame.sendTransaction({
      from: notOwner,
    });
    let final = await instance.getCurrentGameStartTime.call();
    assert.equal(
      final.toNumber() > original.toNumber(),
      true
    )
  })
  
  describe ('#placeBid', async () => {

    let minBid;

    it('setup', async () => {
      // instance = await BidTwoThirdsTheAverageBid.deployed();
      // await instance.setGameDuration.sendTransaction(
      //   6,
      //   {
      //     from: ownerAccount,
      //   }
      // );
      // await instance.startNewGame.sendTransaction(
      //   {
      //     from: ownerAccount,
      //   }
      // );
      // await instance.setMinBid.sendTransaction(
      //   web3.utils.toWei('0.2', 'ether'),
      //   {
      //     from: ownerAccount,
      //   }
      // );
      minBid = await instance.getMinBid.call();
    })

    it ('> minBid', async () => {
      let startTime = await instance.getCurrentGameStartTime.call();
      startTime = startTime.toNumber();
      let duration = await instance.getGameDuration.call();
      duration = duration.toNumber();
      let endTime = startTime + duration;
      await instance.placeBid({
        from: notOwner, 
        value: minBid.plus(1000).toNumber() 
      });
    })

    it ('< minBid', async () => {
      let threw = false;
      let amount = minBid.minus(1000).toNumber();
      try {
        await instance.placeBid({
          from: notOwner, 
          value: amount,
        });
      } catch (e) {
        threw = e.message.includes('Must meet minimum bid requirement.');
      }
      assert.equal(threw, true);
    });

  })

  describe('@modifier#gameFinished via #startNewGame', async () => {

    it ('[UNFINISHED GAME]', async () => {
      let threw = false;
      try {
        await instance.startNewGame({
          from: notOwner,
        })
      } catch (e) {
        threw = e.message.includes('Must wait until current game ends to complete this action.');
      }
      assert.equal(threw, true);
    })
  
    it ('[FINISHED GAME]', async () => {
      let threw = false;
      await gameOver;
      try {
        await instance.startNewGame({
          from: notOwner,
        })
      } catch (e) {
        threw = e.message.includes('Must wait until current game ends to complete this action.');
      }
      assert.equal(threw, false);
    })

  })


  describe ('Pausable', async () => {

    let paused = null;
    describe ('(owner)', async () => {

      it('#pause', async () => {
        await instance.pause.sendTransaction({
          from: ownerAccount,
        });
        paused = await instance.paused.call();
        assert.equal(paused, true);
      })

      it ('#unpause', async () => {
        await instance.unpause({
          from: ownerAccount,
        });
        paused = await instance.paused.call();
        assert.equal(paused, false)
      })
      
    })

    describe ('(non-owner)', async () => {

      it('#pause', async () => {
        try {
          await instance.pause.sendTransaction({
            from: notOwner,
          });
        } catch (e) {}
        paused = await instance.paused.call();
        assert.equal(paused, false);
      })

      it ('#unpause', async () => {
        await instance.pause({
          // to test unpause, must correctly pause with owner account.
          from: ownerAccount,
        });
        try {
          await instance.unpause({
            from: notOwner,
          });
        } catch (e) {}
        paused = await instance.paused.call();
        assert.equal(paused, true)
      })

      it('#unpause -- reset with owner', async () => {
        await instance.unpause({
          from: ownerAccount,
        })
      })

    })
    
  })

  // it ('#getGameByStartTime', async () => {
  //   let gameRepresentation = 
  // })

  after (async () => {
    await instance.destroyTheElderWandForItsPowerIsTooGreat({
      from: ownerAccount
    });
  });

});