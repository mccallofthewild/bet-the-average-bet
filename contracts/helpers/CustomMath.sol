pragma solidity ^0.4.0;
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

library CustomMath {
    using SafeMath for uint256;

    function difference (uint256 first, uint256 second) internal pure returns (uint256) {
        if (first == second) return 0;
        if (first > second) return first.sub(second);
        if (first < second) return second.sub(first);
    }
}
