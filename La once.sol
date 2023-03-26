 // SPDX-License-Identifier: MIT
 // Compiler version
 pragma solidity>=0.4.4<0.8.10;
 pragma experimental ABIEncoderV2;
 // import library safemath
 import "./ERC20.sol";
 
 //Lottery contract
 contract La_Once{
     // ----------------------------Opening Statements-----------------------------

     //Instance Token Contract
     ERC20RER private token;
     
     //address
     address public owner;
     address public Contract;
     // Events of purchased Tokens
     event BuyingTokens(uint,address);

     // number of tokens to create
     uint public tokens_created =10000;
     constructor()public{
         token = new ERC20RER(tokens_created);
         owner= payable (msg.sender);
         Contract = address(this);
     }

     // --------------------------------Token-------------------------------------------
     // Establish the value of the Tokens in ethers
     function PriceTokens (uint _numTokens)internal pure returns(uint){
         return _numTokens*(1 ether);
     }
     //Create more La Once Tokens
      function GenerateTokens (uint _numTokens)public onlyByLaOnce(msg.sender){
          token.increaseTotalSupply(_numTokens);
      }
      //modifier
      modifier onlyByLaOnce (address _address){
          require(_address==owner,"No permission");
          _;
      }
      // Buy La Once Tokens
      function BuyLaOnceTokens (uint _numTokens)public payable{
          //calculate the cost of the Tokens
          uint cost = PriceTokens(_numTokens);
          //Is require the Ethers value is the same of the cost
          require(msg.value>=cost,"buy less Tokens or purchase more Ethers");
          //Difference to pay
          uint returnValue =msg.value-cost;
          //Transfer the difference
          msg.sender.transfer(returnValue);
          //Obtain the balance the contract tokens
          uint Balance = AvalaibleTokens ();
          //Filter to evaluate the tokens to buy with the available tokens
          require(_numTokens<= Balance, "Buy more Tokens");
          //Transfer to buyer
          token.transfer(msg.sender,_numTokens);
          emit BuyingTokens(_numTokens,msg.sender);
           }
       // Balance of tokens in the contract
      function AvalaibleTokens() public view returns (uint){
          return token.balanceOf(Contract);
      }    
      // obtain the balance of Tokens accumulated by the jackpot
      function jackpot() public view returns(uint){
          return token.balanceOf(owner);
      }
      // Visualize the quantity of tokens owns the customer
      function MyTokens () public view returns (uint){
          return token.balanceOf(msg.sender);
      }
      // --------------------------------La Once Lottery-------------------------------------------
    
    // price Lottery Ticket in Tokens
    uint public PriceTicket = 5;
    // mapping relating customer who buys the ticket with the number of tickets
    mapping(address=>uint [])idCustomer_ticket;
    // Mapping to identify the winner 
    mapping (uint=> address) WinTicket;
    // Random numbers
    uint randNonce = 0;
    // Generated tickets
    uint []PurchasedTickets;
    // Events
    event PurchasedTicket(uint,address);
    event WinnerTicket(uint);
    event ReturnedTicket(uint,address);

    //Buy lottery tickets
    function BuyYourTicket (uint _tickets)public {
        //total price of the tickets
        uint Total_price= _tickets*PriceTicket;
        //filtering of tokens to pay
        require(Total_price<=MyTokens(),"you need more Tokens");
        //transfer tokens to owner -> jackpot/prize

      /*  The client pays the attraction in tokens:
      - it has been necessary to create a function in ERC20.sol with the name: "transferLottery 
        because in case of using the Transfer or Transferfrom  
      the addresses that were chosen to carry out 
       the transaction were wrong. Since the msg.sender that
        received the Transfer Transferfrom method was the address of the contract and 
        it must be the address of the physical person    */
      
        token.transferLottery(msg.sender,owner,Total_price);

        /*what this would do is take the timestamp block.timestamp, 
        the msg.sender and nonce (a number that only uses once, 
        so we execute the same hash function twice with the same parameters)
         in increments. We then use keccak256 to convert these inputs into a 
         random hash. convert that hash to uint and then use %1000 to grab 
         the last 4 digits. Giving i a random value between 0-9999 */
        
        for (uint i=0;i< _tickets;i++){
            uint random = uint(keccak256(abi.encodePacked(block.timestamp,msg.sender,randNonce)))%10000;
            randNonce++;
            //Store the tickets data
            idCustomer_ticket[msg.sender].push(random);
            //Number of buyed tickets
            PurchasedTickets.push(random);
            //Award of winning ticket
            WinTicket[random]= msg.sender;
            //emit of the event
            emit PurchasedTicket (random, msg.sender);
        }
    }
    // function who permit visuliaze the number of tickets of the customer
   function YourTickets() public view returns (uint []memory){
      return idCustomer_ticket[msg.sender];
  }
    //Generate ticket winner and give the prize
    function GenerateWinner() public onlyByLaOnce(msg.sender){
        //The winning tickets should be buyed to generate a winner
        require(PurchasedTickets.length>0,"No Tickets ");
        //Rtatement array length 
        uint length = PurchasedTickets.length;
        //Randomly choose a number between 0 -length
        //1- Choose random array position 
         uint arrayPosition = uint(uint (keccak256(abi.encodePacked(block.timestamp)))%length);
         //2- Select the random number through the random array position
         uint choice = PurchasedTickets[arrayPosition];
         //Emit of the event
         emit WinnerTicket (choice);
         //Recover the winner address
         address winner_Address = WinTicket[choice];
         //Send Tokens to the winner
         token.transferLottery(msg.sender,winner_Address,jackpot());
    }
      //Convert Tokens in Ethers
      function returnTokens (uint _numTokens) public payable{
          // the number of tokens should be more than 0
          require(_numTokens>0,"need to return a positive number of tokens");
          //the user/customer should have tokens
          require(_numTokens<= MyTokens(),"you don´t have enough tokens");
          //RETURN:
          //1.The customer return tokens
          //2.The lottery pays the tokens  returned in ethers
          token.transferLottery(msg.sender,address(this),_numTokens);
          msg.sender.transfer(PriceTokens(_numTokens));
          //Event return tokens
          emit ReturnedTicket(_numTokens,msg.sender);

      }


  

 }