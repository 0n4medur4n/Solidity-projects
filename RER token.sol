 // SPDX-License-Identifier: MIT
 // Compiler version
 pragma solidity>=0.4.4<0.8.10;
 pragma experimental ABIEncoderV2;
 // import library safemath
 import "./SafeMath.sol";
 
  //ERC-20 interface
//ex: address 
// Orlando 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
// Nana 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
// Papa 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db


  interface IERC20{
    //returns the amount of token in existence
    function totalsupply() external view returns(uint256);

    //returns the amount of token for an address indicated by parameter
    function balanceOf(address account)external view returns(uint256);

    // returns the nº tokens that the spender can spend on behalf of the owner
    function allowance(address owner,address spender)external view returns(uint256);

    // returns a boolean value or result of the indicated operatio
    function transfer(address recipient, uint256 amount) external returns(bool);

    // returns a boolean value with the result of the expense operation
    function approve(address spender, uint256 amount) external returns(bool);

    //returns a boolean value with the result of the operation of the operation of passing an amount of tokens using the allowance method()
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);



    //event to be emitted when a number of tokens passes from a source to a destination
    event tr4nsfer(address indexed from, address indexed to,uint256 value);

    //event to be emitted when an allocation is established with the allowance method
    event approval(address indexed owner,address indexed spender,uint256 value);
    
    }
 
 //implementation of the functions of the erc20 token
     contract ERC20RER is IERC20 {
     string public constant name ="ERC20RER";
     string public constant symbol = "RER";
     uint8 public constant decimals =2;


     event Transfer(address indexed from, address indexed to,uint256 tokens);
     event Approval(address indexed owner,address indexed spender,uint256 tokens);

     using SafeMath for uint256;
     mapping(address=> uint) balance;
     mapping(address=> mapping(address=>uint))allowed;
     uint256 totalsupply_;

     constructor (uint256 initialsupply) public{
        totalsupply_ = initialsupply;
        balance[msg.sender] = totalsupply_;
      }
     function totalsupply() public override view returns(uint256){
     return totalsupply_;
       }
     
     function increaseTotalSupply(uint newTokensAmount)public{
         totalsupply_ += newTokensAmount;
         balance[msg.sender]+= newTokensAmount;
     }

     function balanceOf(address tokenOwner)public override view returns(uint256){
     return balance[tokenOwner];
     }

     function allowance(address owner,address spender)public override view returns(uint256){
     return allowed[owner][spender];    
     }
     function transfer(address recipient, uint256 numTokens) public override returns(bool){
     require(numTokens<= balance[msg.sender]);
     balance[msg.sender]= balance[msg.sender].sub(numTokens);
     balance[recipient]= balance[msg.sender].add(numTokens);
     emit Transfer(msg.sender,recipient,numTokens);
     return true;
     }
     
     function approve(address spender, uint256 numTokens)public override returns(bool){
     allowed[msg.sender][spender]= numTokens;
     emit Approval (msg.sender,spender,numTokens);
     return true;
     }

     function transferFrom(address owner, address buyer, uint256 numTokens) public override returns(bool){
       require(numTokens<=balance[owner]);
       require(numTokens<=allowed[owner][msg.sender]);

       balance[owner]=balance[owner].sub(numTokens);
       allowed[owner][msg.sender]= allowed[owner][msg.sender].sub(numTokens);
       balance[buyer]= balance[buyer].add(numTokens);
       emit Transfer(owner,buyer,numTokens);
       return true;
     }




}

 