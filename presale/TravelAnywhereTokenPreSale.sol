pragma solidity ^0.4.10;
import "./PreSaleToken.sol";
import "./SafeMath.sol";

contract TravelAnywhereTokenPreSale is PreSaleToken {
    using SafeMath for uint256;

    uint256 public constant decimals = 18;
    
    bool public isEnded = false;
    address public contractOwner;
    address public travelAnywhereEthFund;
    uint256 public presaleStartBlock;
    uint256 public presaleEndBlock;
    uint256 public constant tokenExchangeRate = 620;
    uint256 public constant tokenCap = 62 * (10**6) * 10**decimals;
    
    event CreatePreSale(address indexed _to, uint256 _amount);
    
    function TravelAnywhereTokenPreSale(address _travelAnywhereEthFund, uint256 _presaleStartBlock, uint256 _presaleEndBlock) {
        travelAnywhereEthFund = _travelAnywhereEthFund;
        presaleStartBlock = _presaleStartBlock;
        presaleEndBlock = _presaleEndBlock;
        contractOwner = travelAnywhereEthFund;
        totalSupply = 0;
    }
    
    function () payable public {
        if (isEnded) throw;
        if (block.number < presaleStartBlock) throw;
        if (block.number > presaleEndBlock) throw;
        if (msg.value == 0) throw;
        
        uint256 tokens = msg.value.mul(tokenExchangeRate);
        uint256 checkedSupply = totalSupply.add(tokens);
        
        if (tokenCap < checkedSupply) throw;
        
        totalSupply = checkedSupply;
        balances[msg.sender] += tokens;
        CreatePreSale(msg.sender, tokens);
    }
    
    function endPreSale() public {
        require (msg.sender == contractOwner);
        if (isEnded) throw;
        if (block.number < presaleEndBlock && totalSupply != tokenCap) throw;
        isEnded = true;
        if (!travelAnywhereEthFund.send(this.balance)) throw;
    }
}