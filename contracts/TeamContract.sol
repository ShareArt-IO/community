pragma solidity ^0.4.18;

/**
 *@dev this contract will lock supply until six month 
 *fund/team/advisor will be controled by this contract
 */
 
contract Token {
    function transfer(address _to, uint256 _value) public returns (bool);
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

contract Lockable{
    uint256  public releaseTime =0;
    function Lockable() public {
        releaseTime = now + 180 * 1 days;
    }

    modifier canTransfer(){
        require(releaseTime < now );
        _;
    }
}

contract TeamContract is Ownable, Lockable {
    Token public tokenReward;
    
    event CrowdStatus(bool);
    event Transfer(bool, uint256);

    function TeamContract() public {
    }

    function connectTokenAddress(address _tokenAddr) public onlyOwner {
        tokenReward = Token(_tokenAddr);
    }
    
    function transfer(address _to, uint256 _value) public canTransfer onlyOwner {
        require(_value > 0 && _to!= address(0) && _to !=msg.sender);
        tokenReward.transfer( _to, _value);
        emit Transfer(true, _value);
    }
}
