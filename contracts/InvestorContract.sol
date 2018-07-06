pragma solidity ^0.4.18;

contract Token {
    function transfer(address _to, uint256 _value) public returns (bool);
    function lockTransfer(address _to,uint256 _percent,uint8 _limitRound) public ;
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
    uint256 public total=0;
    uint8 public step = 1;
    bool  public isCrowding=false;
    mapping(address => uint256) public balances;
    event Transfer(bool, uint256);
    
    function InvestorContract(address _addr) public {
        require(_addr != address(0) );
        receiptAddress = _addr;
    }
    
    function connectTokenAddress(address _tokenAddr) public onlyOwner {
        tokenReward = Token(_tokenAddr);
    }
    
    function startInvest(bool _isStart) public onlyOwner {
        isCrowding=_isStart;
    }
    
    function endBase() public onlyOwner {
        step=2;
    }
function test() public payable {
        require(isCrowding == true);
        uint256 price=0;
        uint8 percent=10;
        uint8 limitRound=3;
        
        if(total <2500*10**18 && step==1 ){
            price=14*10000;
            percent=10;
            limitRound=6;
        }  else if( step == 2  && total < 10000*10**18) {
            limitRound=3;
            percent=10;
            price=10*10000;
        }
        else{
            limitRound=4;
            percent=10;
            price=20*10000;
        }
        emit Transfer(true,price);
    }
    
    function () public payable {
        require(msg.value > 0 );
        require(isCrowding == true);
        uint256 price=0;
        uint8 percent=10;
        uint8 limitRound=3;
        
        if(total <2500*10**18 && step==1 ){
            price=14*10000;
            percent=10;
            limitRound=6;
        }  else {
            step=2;
            limitRound=3;
            percent=10;
            price=10*10000;
        }

        uint256 value=price.mul(msg.value);
        receiptAddress.transfer(msg.value);
        tokenReward.transfer(msg.sender, value); 
        if(percent > 0) {
            tokenReward.lockTransfer(msg.sender,percent,limitRound);
        }
        balances[msg.sender] = balances[msg.sender].add(msg.value); 
        total = total.add(msg.value);
        emit Transfer(true, value);
    }
}
