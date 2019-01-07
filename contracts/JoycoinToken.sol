pragma solidity ^0.4.24;

import 'openzeppelin-solidity/contracts/token/ERC20/ERC20.sol';
import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';

interface IJoycoinSale  {
    function getEndDate() external view returns (uint256);
}

contract JoycoinToken is ERC20, Ownable {
   
    string public symbol;
    string public  name;
    uint256 public decimals;

    uint256 private _cap;

    address public saleAddress;
    IJoycoinSale public sale;

    bool public unlocked = false;

    bool public sendedToSale;
    bool public sendedToTeam;
    bool public sendedToTeamLock;
    bool public sendedToAdvisors;
    bool public sendedToAdvisorsLock;
    bool public sendedToService;

    uint256 public salePart;
    uint256 public teamPart;
    uint256 public teamPartLock;
    uint256 public advisorsPart;
    uint256 public advisorsPartLock;
    uint256 public servicePart;

    uint256 constant LOCK_TIME = 365 days;
    

    modifier whenUnlocked()  {
        if (msg.sender != saleAddress) {
            require(unlocked);
        }
        _;
    }

    modifier onlySale() {
	    require(msg.sender == saleAddress);
	    _;
	}


    function cap() public view returns(uint256) {
        return _cap;
    }

    function _mint(address account, uint256 value) internal {
        require(totalSupply().add(value) <= _cap);
        super._mint(account, value);
    }


	function transfer(address _to, uint256 _value) public whenUnlocked() returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public whenUnlocked() returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) public whenUnlocked() returns (bool) {
        return super.approve(_spender, _value);
	}


    constructor() public {
        symbol = "JOY";
        name = "Joycoin";
        decimals = 8;

        _cap             =  2400000000 * 10 ** decimals; 

        salePart         =  1625400000 * 10 ** decimals; // 67,725%
                      
        advisorsPart     =    42000000 * 10 ** decimals; // 25% from 7%
        advisorsPartLock =   126000000 * 10 ** decimals; // 75% from 7%

        teamPart         =    31650000 * 10 ** decimals;  // 25% from 5,275%
        teamPartLock     =    94950000 * 10 ** decimals; // 75% from 5,275%

        servicePart      =   480000000 * 10 ** decimals; // 20%

        require (_cap == salePart + advisorsPart + advisorsPartLock + teamPart + teamPartLock + servicePart);
    }


    function setSaleAddress(address _address) public onlyOwner returns (bool) {
        require(saleAddress == address(0));
        require (!sendedToSale);
        saleAddress = _address;
        sale = IJoycoinSale(saleAddress);
        return true;
	}

	function unlockTokens() public onlyOwner returns (bool)	{
		unlocked = true;
		return true;
	}

	function burnUnsold() public onlySale returns (bool) {
    	_burn(saleAddress, balanceOf(saleAddress));
        return true;
  	}

    function sendTokensToSale() public onlyOwner returns (bool) {
        require (saleAddress != address(0x0));
        require (!sendedToSale);
        sendedToSale = true;
        _mint(saleAddress, salePart);
        return true;
    }

    function sendTokensToTeamLock(address _teamAddress) public onlyOwner returns (bool) {
        require (_teamAddress != address(0x0));
        require (!sendedToTeamLock);
        require (sale.getEndDate() > 0 && now > (sale.getEndDate() + LOCK_TIME) );
        sendedToTeamLock = true;
        _mint(_teamAddress, teamPartLock);
        return true;
    }

    function sendTokensToTeam(address _teamAddress) public onlyOwner returns (bool) {
        require (_teamAddress != address(0x0));
        require (!sendedToTeam);
        require ( sale.getEndDate() > 0 && now > sale.getEndDate() );
        sendedToTeam = true;
        _mint(_teamAddress, teamPart);
        return true;
    }

    function sendTokensToAdvisors(address _advisorsAddress) public onlyOwner returns (bool) {
        require (_advisorsAddress != address(0x0));
        require (!sendedToAdvisors);
        require (sale.getEndDate() > 0 && now > sale.getEndDate());
        sendedToAdvisors = true;
        _mint(_advisorsAddress, advisorsPart);
        return true;
    }

    function sendTokensToAdvisorsLock(address _advisorsAddress) public onlyOwner returns (bool) {
        require (_advisorsAddress != address(0x0));
        require (!sendedToAdvisorsLock);
        require (sale.getEndDate() > 0 && now > (sale.getEndDate() + LOCK_TIME) );
        sendedToAdvisorsLock = true;
        _mint(_advisorsAddress, advisorsPartLock);
        return true;
    }

    function sendTokensToService(address _serviceAddress) public onlyOwner returns (bool) {
        require (_serviceAddress != address(0x0));
        require (!sendedToService);
        sendedToService = true;
        _mint(_serviceAddress, servicePart);
        return true;
    }

}
