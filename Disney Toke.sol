 // SPDX-License-Identifier: MIT
 // Compiler version
 pragma solidity>=0.4.4<0.8.10;
 pragma experimental ABIEncoderV2;
 // import library safemath
 import "./ERC20.sol";

 // contract Disney

 contract DisneyToken{

     // ----------------------------Opening Statements-----------------------------

     //Instance Disney Token
     ERC20RER  private token;
      
     // Disney address (owner)
     address payable public owner;

     //Constructor
     constructor()public{
         token = new ERC20RER(1000000);
         owner = payable (msg.sender);
     }
     // Data structure to store new disney customers
     struct signup_customer{
          string customer_name;
            string customer_id; 

     }
     // Data structure to store disney customers
     struct customer{
            uint buyed_tokens;
            string []attractions_enjoyed;
     }
     // Customer signup mapping
     mapping (address =>signup_customer) public Addcustomer;
     //Customer register mapping
     mapping(address => customer) public customersExperience;
     // ----------------------------Signup Management-------------------------------

      function NewDisneyCustomer(string memory customer_name,string memory customer_id) public{
        Addcustomer[msg.sender] = signup_customer(customer_name,customer_id);
     }

     // ----------------------------Token Management-------------------------------

     //Function to set the price of a token
     function TokenPrice(uint _numTokens)internal pure returns(uint){

         //Convert tokens to ethers : 1 Token-> 1 ether
         return _numTokens*(1 ether);
     }

     //Function buy disney tokens and enjoy the attractions 
     function BuyTokens (uint _numTokens)public payable{
         //Stablish tokens price
         uint cost = TokenPrice(_numTokens);
         //The money that the client pays for the tokens is evaluated
         require(msg.value>=cost,"declined.");
         //Difference  what the customer pays
         uint returnValue = msg.value - cost;
         //Disney returns the amount of ethers to the client
         payable(msg.sender).transfer(returnValue);
         //Obtain the number of available tokens
         uint Balance = balanceOf();
         require(_numTokens<= Balance, "buy less tokens");
         //The number of tokens is transferred to the client
         token.transfer(msg.sender,_numTokens);
         //Record of purchased tokens
         customersExperience[msg.sender].buyed_tokens += _numTokens;
     }
     // Disney contract token balance
    function balanceOf() public view returns (uint) {
        return token.balanceOf(address(this));
    }
    // visualizes the number of customer tokens remaining 
    function MyTokens()public view returns(uint){
        return token.balanceOf(msg.sender);
    }
    //Function generate more tokens
    function generateTokens (uint _numTokens) public onlyByDisney(msg.sender){
        token.increaseTotalSupply(_numTokens);
    }
    //Modifier  controlling all the executable actions by Disney
    modifier onlyByDisney(address _address){
        require (_address== owner, "no permit.");
        _;
     }

     // ----------------------------Disney Management-------------------------------
     
     //events
     event enjoy_attraction(string,uint,address);
     event new_attraction(string, uint);
     event maintenance_attraction(string);
     event new_meal(string,uint);
     event noAvalaibility (string);
     event enjoy_yourMeal(string,uint,address);

     //Attraction structure
     struct attraction{
         string name_attraction;
         uint price_attraction;
         uint Maximum_capacity;
         bool state_attraction;
         
     }
     //Meal structure
     struct meal{
         string name_meal;
         uint price_meal;
         uint quantity_meal;
         bool avalaibilty_meal;

     }

     //Mapping to relate an attraction name to an attraction data structure
     mapping (string=>attraction) public MappingAtraction;

     //store the name of the atraction in an array
     string [] attractions;
     
     //Mapping to relate the identity (customer) his record on Disney
     mapping(address=>string[])AttractionRecord;

     // Peter's pan flight -> 1 Token
     // Haunted Mansion -> 3 Tokens
     // Seven Dwarfs Mine Train -> 2 Tokens

     //mapping to relate meal name to meal data structure
     mapping(string=>meal)MappingMeal;
     
     //store the name of the meal in an array
     string[]meals;

     //mapping to relate the customer and his record on DisneyFood
     mapping(address=>string [])Foodrecord;

     // Hamburguer -> 2 Tokens
     // Hot Dog-> 1 Token
     // Pizza -> 3 Tokens
    
     // function who permit create new Disney attraction (only executable by Disney)
     function NewAttraction(string memory _nameAttraction, uint _price,uint _MaximumCapacity) public onlyByDisney(msg.sender){
        // Create Disney Attraction
        MappingAtraction[_nameAttraction]= attraction (_nameAttraction,_price,_MaximumCapacity,true);
        // Store in an array the name of the attraction
        attractions.push(_nameAttraction);
        // Emition event of the new attractions
        emit new_attraction(_nameAttraction,_price);
     }
         // function who permit sell new food in Disney park (only executable by Disney
         function NewMeal (string memory _nameMeal, uint _price, uint quantity_meal) public onlyByDisney(msg.sender){
         //create new Disney meal
        MappingMeal[_nameMeal] = meal (_nameMeal,_price,quantity_meal,true);
        //Store in an array the name of the meal
        meals.push(_nameMeal);
        //Emition event of new meal 
        emit new_meal(_nameMeal,_price);
        }  

   
      // function who permit change status attraction (Obsolete Disney attraction) 
      function ObsoleteAttraction(string memory _nameAttraction)public onlyByDisney(msg.sender){
          //the state of the attraction becomes FALSE -> not in use
          MappingAtraction[_nameAttraction].state_attraction = false;
          //emit event
          emit maintenance_attraction(_nameAttraction);
      }

      // function who change the avalaibility of the meal (no avalaible)
      function NoAvalaibleMeal (string memory _nameMeal) public onlyByDisney(msg.sender){
           //the state  of the meal becpomes False -> not avalaible
           MappingMeal[_nameMeal].avalaibilty_meal = false;
           emit noAvalaibility (_nameMeal);
      }

      //visualize Disney Attractions
      function AttractionsAvalaible() public view returns(string []memory){
          return attractions;
      }

      // visualize Disney meals
      function MealsAvalaibles() public view returns(string []memory){
          return meals;
      }

      // function to get on a disney attraction and pay in tokens
     function Ride (string memory _nameAttraction) public{
          //price attraction (tokens)
          uint tokens_attractions = MappingAtraction [_nameAttraction].price_attraction;
          // verify status attraction
          require (MappingAtraction[_nameAttraction].state_attraction== true,
                       "the attraction is not avalaible");
          // Verify number of customer tokens to use the attraction 
          require (tokens_attractions <= MyTokens(),
                        "you need to have more tokens"); 
      /*  The client pays the attraction in tokens:
      - it has been necessary to create a function in ERC20.sol with the name: "transferDisney 
        because in case of using the Transfer or Transferfrom  
      the addresses that were chosen to carry out 
       the transaction were wrong. Since the msg.sender that
        received the Transfer Transferfrom method was the address of the contract                           
                                                                                */
                                                                                
      token.transferDisney(msg.sender,address(this),tokens_attractions);
      //Store the record of attractions of the customer
       AttractionRecord[msg.sender].push(_nameAttraction);
       //Emit of the event enjoy the attraction
       emit enjoy_attraction(_nameAttraction,tokens_attractions, msg.sender);
     }
     // Function to get a Disney meal and pay in tokens
     function BuyMeal(string memory _nameMeal) public{
         //Price meal(tokens)
         uint tokens_meals = MappingMeal [_nameMeal].price_meal;
         //Verify status meals
         require (MappingMeal [_nameMeal].avalaibilty_meal == true,
                        "the meal is not avaliable");
         //Verify number of customer tokens to buy a meal
         require(tokens_meals<= MyTokens(),
                         "you need to have more tokens");
      token.transferDisney(msg.sender,address(this), tokens_meals);
      //store the record of meals purchased by the customer
       Foodrecord [msg.sender].push(_nameMeal);
       //Emit of the event enjoy your meal
       emit enjoy_yourMeal (_nameMeal,tokens_meals,msg.sender);

     }

     //Visualize the complete record of the attractions enjoyed by the customer
     function recordAttraction()public view returns(string[] memory){
         return AttractionRecord[msg.sender];
     }
     // Visualize the complete record of meals enjoyed by the customer
     function recordfood() public view returns (string []memory){
         return Foodrecord[msg.sender];
     }

     //Function Disney customer can return tokens
     function returnTokens( uint _numTokens)public payable{
         //the number of return tokens has to be positive 
         require (_numTokens>0,"you only can return a positive quantity");
         // The customer must have the number of tokens who want to return
         require (_numTokens<= MyTokens(),"You do not have the tokens to perform this operation");
         // The customer return the tokens
         token.transferDisney(msg.sender,address (this),_numTokens);
         // return ethers of the customer
         payable(msg.sender).transfer(TokenPrice(_numTokens));

     }

 } 