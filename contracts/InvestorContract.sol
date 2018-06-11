pragma solidity ^0.4.18;

contract Token {
    function transfer(address _to, uint256 _value) public returns (bool);
    function releaseLimit(address _to) public;
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

contract InvestorContract is Ownable {
    using SafeMath for uint256;
    Token public tokenReward;
    address public receiptAddress;
    uint256 public price;
    bool  public isCrowding=false;
    mapping(address => uint256) public balances;
    event Transfer(bool, uint256);
    
    function InvestorContract(address _addr,uint256 _price) public {
        receiptAddress = _addr;
        price = _price;
    }
    
    function connectTokenAddress(address _tokenAddr) public onlyOwner {
        tokenReward = Token(_tokenAddr);
    }
    
    function startInvest(bool _isStart) public onlyOwner {
        isCrowding=_isStart;
    }
    
    function () public payable {
        require(isCrowding == true);
        require(msg.value > 0 && price > 0);
        uint256 value=price.mul(msg.value);
        receiptAddress.transfer(msg.value);
        tokenReward.transfer(msg.sender, value); 
        tokenReward.releaseLimit(msg.sender);
        balances[msg.sender] = balances[msg.sender].add(msg.value); 
        emit Transfer(true, value);
    }
}
