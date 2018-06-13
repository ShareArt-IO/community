pragma solidity ^0.4.18;

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

//ERC-20 
contract Token {
    function balanceOf(address _owner) public constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
    function approve(address _spender, uint256 _value) public returns (bool);
    function allowance(address _owner, address _spender) public constant returns (uint256);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

/**
 *@title LockableTokenImpl
 *@dev this contract will control the intvestor only
 */
contract LockableTokenImpl {
    using SafeMath for uint256;
    struct LockInfo{
        uint256 balance;
        uint256 allowance;
        uint256 releaseAmountPerMonth;
        uint8   isOwner;
        uint8   round;
    }

    uint8 public round;
    mapping(address => LockInfo) public lockBalances;

    function LockableTokenImpl() public {
        round=1;
    }

    modifier canTransfer(address _from, uint256 _value) {
        if ( lockBalances[_from].releaseAmountPerMonth == 0) {
            _;
            return;
        } else {
            require(round >= lockBalances[_from].round);
            uint256 needAddAllowance = lockBalances[_from].releaseAmountPerMonth.mul(round - lockBalances[_from].round);
            lockBalances[_from].round = round;
            lockBalances[_from].allowance=lockBalances[_from].allowance.add(needAddAllowance);
            require( lockBalances[_from].allowance >= _value );
            _;
        }
    }

    function lock(address _addr,uint256 _percent,address _whereLock) internal {
		require(lockBalances[_whereLock].isOwner == 1);
        if (lockBalances[_addr].balance > 0) {
            if(_percent > 100){
                _percent = 100;
            }
            if (lockBalances[_addr].releaseAmountPerMonth == 0) {
                lockBalances[_addr].round=round;
            } 
            lockBalances[_addr].releaseAmountPerMonth = lockBalances[_addr].balance.mul(_percent).div(100);
        }
    }
    
    function addSupply(address _addr,uint256 _amount) internal {
        lockBalances[_addr] = LockInfo(_amount, 0, 0, 1, 0);
    }
    
    function getBalance(address _owner) internal view returns(uint256) {
        return lockBalances[_owner].balance;
    }

    function transferDo(address _from, address _to, uint256 _value) internal canTransfer(_from, _value) {
        require(_from != _to && _to!= address(0) );
        require(lockBalances[_from].balance >= _value);
        lockBalances[_from].balance = lockBalances[_from].balance.sub(_value);
        lockBalances[_to].balance = lockBalances[_to].balance.add(_value);
    }

    function changeBalanceDo(address _from,address _to) internal returns(bool) {
        require(lockBalances[_from].balance > 0);
        require(lockBalances[_from].isOwner == 1);
        require(lockBalances[_to].balance == 0);
        lockBalances[_to] = lockBalances[_from];
        lockBalances[_from] = LockInfo(0, 0, 0, 0, 0);
    }
}

/**
 *@title SAToken contract,
 *@dev Owner have nothing,only can be transfered by other contract
 */
contract SAToken is Ownable, Token , LockableTokenImpl {
    using SafeMath for uint256;
    mapping (address => mapping (address => uint256)) public allowed;
    uint256 public totalSupply=100*10**26;
    uint256 public lastRoundTime=0;
    string public constant name = "ShareArt Token";
    string public constant symbol = "SAT";
    uint8 public constant decimals = 18;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function SAToken(
        address _team,
        address _fund,
        address _advisor,
        address _community,
         address _investor
        ) public {
        addSupply(_team, totalSupply.mul(14).div(100));
        addSupply(_fund, totalSupply.mul(30).div(100));
        addSupply(_advisor, totalSupply.mul(30).div(100));
        addSupply(_community, totalSupply.mul(15).div(100));
        addSupply(_investor, totalSupply.mul(11).div(100));
        round = 1;
    }
        
    function unlockThisRound() public onlyOwner returns(bool) {
		if(now - lastRoundTime > 20 * 1 days){
			round = round + 1;
			lastRoundTime = now;
			return true;
		}
		return false;
    }
    
    function lockTransfer(address _to,uint256 _percent) public {
        lock(_to,_percent,msg.sender);
    }
    
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != msg.sender);
        transferDo(msg.sender,_to, _value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != msg.sender );
        require(_value <= allowed[_from][msg.sender]);

        transferDo(_from, _to ,_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        
        emit Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return getBalance(_owner);
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    function changeAllowance(address _from,address _to) public onlyOwner returns(bool) {
        return changeBalanceDo(_from,_to);	    	
    }
}
