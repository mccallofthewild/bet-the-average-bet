pragma solidity ^0.4.0;
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract Mortal is Ownable {
    // This contract inherits the `onlyOwner` modifier from
    // `owned` and applies it to the `close` function, which
    // causes that calls to `close` only have an effect if
    // they are made by the stored owner.
    function destroyTheElderWandForItsPowerIsTooGreat () public onlyOwner {
        selfdestruct(owner);
    }
}