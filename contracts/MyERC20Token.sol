// SPDX-License-Identifier: UNLICENSED
// https://github.com/PacktPublishing/Learn-Ethereum/tree/master/Chapter06/MyERC20Token
pragma solidity >=0.8.9;

import "./ERC20.sol";
import "./Whitelist.sol";
import "./Pausable.sol";

contract MyERC20Token is ERC20, Whitelist, Pausable {
    
    uint8 public constant SUCCESS_CODE = 0;
    string public constant SUCCESS_MESSAGE = "SUCCESS";
    uint8 public constant NON_WHITELIST_CODE = 1;
    string public constant NON_WHITELIST_ERROR = "ILLEGAL_TRANSFER_TO_NON_WHITELISTED_ADDRESS";

    mapping(address => uint256) internal balances;
    mapping(address => mapping(address => uint256)) internal allowed;
    uint internal _totalSupply;
    TokenSummary public tokenSummary;
    struct TokenSummary {
        address initialAccount;
        string name;
        string symbol;
    }

    constructor(string memory _name, string memory _symbol, address initialAccount, uint initialBalance) payable {
        addWhitelist(initialAccount);
        balances[initialAccount] = initialBalance;
        _totalSupply = initialBalance;
        tokenSummary = TokenSummary(initialAccount, _name, _symbol);
    }

    modifier verify (address from, address to, uint256 value) {
        uint8 restrictionCode = validateTransferRestricted(to);
        require(restrictionCode == SUCCESS_CODE, messageHandler(restrictionCode));
        _;
    }

    function validateTransferRestricted (address to) public view returns (uint8 restrictionCode) {
        if (!isWhitelist(to)) {
            restrictionCode = NON_WHITELIST_CODE;
        } else {
            restrictionCode = SUCCESS_CODE;
        }
    }

    function messageHandler (uint8 restrictionCode) public pure returns (string memory message) {
        if (restrictionCode == SUCCESS_CODE) {
            message = SUCCESS_MESSAGE;
        } else if(restrictionCode == NON_WHITELIST_CODE) {
            message = NON_WHITELIST_ERROR;
        }
    }

    function totalSupply() public view returns (uint256) {
       return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
      return balances[account];
    }

    function transfer (address to, uint256 value) public verify(msg.sender, to, value) whenNotPaused  returns (bool success) {
        require(to != address(0) && balances[msg.sender]> value);
        balances[msg.sender] = balances[msg.sender] - value;
        balances[to] = balances[to] + value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
    
    function transferFrom(address from, address spender,uint256 value) public verify(from, spender, value) whenNotPaused returns (bool) {
        require(spender != address(0) && value <= balances[from] && value <= allowed[from][msg.sender]);
        balances[from] = balances[from] - value;
        balances[spender] = balances[spender] + value;
        allowed[from][msg.sender] = allowed[from][msg.sender] - value;
        emit Transfer(from, spender, value);
        return true;
  }
  
  function allowance(address owner,address spender) public view returns (uint256) {
    return allowed[owner][spender];
  }
  
  function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
   }

  function burn(uint256 value) public whenNotPaused onlyAdmin returns (bool success) {
    require(balances[msg.sender] >= value); 
    balances[msg.sender] -= value; 
    _totalSupply -= value;
    emit Burn(msg.sender, value);
    return true;
 }

  function mint(address account, uint256 value) public whenNotPaused onlyAdmin returns (bool) {
    require(account != address(0));
    _totalSupply = _totalSupply += value;
    balances[account] = balances[account] + value;
    emit Transfer(address(0), account, value);
    return true;
  }

    /* Apparently this is no longer needed after 0.4.0 per
    https://ethereum.stackexchange.com/questions/34160/why-do-we-use-revert-in-payable-function

    function () external payable {
       revert();  
    }
    */
}
