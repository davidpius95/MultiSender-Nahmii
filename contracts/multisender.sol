
pragma solidity ^0.8.0;

//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MultiSender {
    
    address public owner;
    address public pendingOwner;
    uint256 public arrayLimit = 500;
    uint256 public discountStep = 0.00005 ether;
    uint256 public fee = 0.06 ether;
    
    mapping(address => uint256) public txCount;
    mapping  (address => uint) public balance;
    
    event Multisended(uint256 total, address tokenAddress);
    event ClaimedTokens(address token, address owner, uint256 balance);

    modifier onlyOwner() {
        require(msg.sender == owner, "not the owner");
        _;
    }
    modifier hasFee() {
        require(msg.value >= fee - discountRate(msg.sender),"must pay fee");
        balance[msg.sender]=msg.value;
        _;
    }

    constructor public  (address _owner, address _pendingOwner) public {
        owner = _owner;
        pendingOwner = _pendingOwner;
    }
    
    

    // the discount rate to charge for a customer address 
    function discountRate(address _customer) public view returns(uint256) {
        uint256 count = txCount[_customer];
        return count * discountStep;
    }
    // To view the current fee charge by the smart contract to an address 
    function currentFee(address _customer) public view returns(uint256) {
        return fee - discountRate(_customer);
    }
    // change the owner of the smart contract 
    function claimOwner(address _newPendingOwner) public {
        require(msg.sender == pendingOwner);
        owner = pendingOwner;
        pendingOwner = _newPendingOwner;
    }
    // change the Limit of how many address the multisender can send token 
    function changeTreshold(uint _newLimit) public onlyOwner {
        arrayLimit = _newLimit;
    }
    // change the fee which the contract will charge a user 
    function changeFee(uint256 _newFee) public onlyOwner {
        fee = _newFee;
    }
    // change the discount owner wish to give to a user 
    function changeDiscountStep(uint256 _newStep) public onlyOwner {
        discountStep = _newStep;
    } 
    // check balance of an address in the contract 
    function balanceOf(address account) public view returns(uint){
        return balance[account];
    }
    // MultiSend ERC20 
    function multisendToken(address token, address[] calldata _contributors, uint256[] calldata _balances) public hasFee payable {
        uint256 total = 0;
        require(_contributors.length <= arrayLimit, "IT ablove the Limit");
        IERC20 erc20token = IERC20(token);

        require(erc20token.allowance(msg.sender, address(this)) > 0,"must allow address(this) to spend");
        for (uint8 i =0; i < _contributors.length; i++) {
            erc20token.transferFrom(msg.sender, _contributors[i], _balances[i]);
            total += _balances[i];
        }
        txCount[msg.sender]++;
      emit  Multisended(total, token);
      
    }
    // multisend ETH 
    function multisendEther(address[] calldata  _contributors, uint256[] calldata _balances) public hasFee payable {
        // this function is always free, however if there is anything left over, I will keep it.
        uint256 total = 0;
        require(_contributors.length <= arrayLimit,"IT ablove the Limit");
       
        for ( uint8 i = 0; i < _contributors.length; i++) {
          payable(  _contributors[i]).transfer(_balances[i]);
            total += _balances[i];
        }
        txCount[msg.sender]++;
       emit Multisended(total, address(0));
    }
    // claim the token which is still remaining in the smart contract to the owner of the contract
    function claimTokens(address _token) public onlyOwner {
        if (_token == address(0)) {
          payable( owner).transfer(address(this).balance);
            return;
        }
        IERC20 erc20token = IERC20(_token);
        uint256 balance_ = erc20token.balanceOf(address(this));
        erc20token.transfer(owner, balance_);
     emit ClaimedTokens(_token, owner, balance_);
    }
    
    
    receive() external payable {}

    
   // withdraw all the fee in the contract to the owner of the contract  
  function withdraw(address account) public payable onlyOwner {
    (bool succes, ) = payable(account).call{value: address(this).balance}("");
    require(succes,"withdraw was not succesfull");
  }
    
    
    
    
    
    
}