pragma solidity ^0.4.18;
interface Token{
        function balanceOf(address _owner) public constant returns (uint256 balance);
        function transfer(address _to, uint256 _value) public returns (bool success);
}

contract Ownable {
    address public owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    function Ownable() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

/**
 *@title SAToken contract,
 *@dev Owner have nothing,only can be transfered by other contract
 * 
 */
 
contract Candy is Ownable {
    using SafeMath for uint256;
    mapping (address => mapping (address => uint256)) public allowed;
    event Transfer(address indexed from, address indexed to, uint256 value);
    Token public tokenAddr;
    function Candy(address _tokenAddr){
        tokenAddr=Token(_tokenAddr);
    }
    function() public payable {
        tokenAddr.transfer (msg.sender,) public  onlyOwner
    }
}
