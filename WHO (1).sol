 // SPDX-License-Identifier: MIT
 // Compiler version
 pragma solidity>=0.4.4<0.8.10;
 pragma experimental ABIEncoderV2;

contract WHO_COVID19{
 // ----------------------------Opening Statements-----------------------------
        //WHO address -> owner 
        address public WHO;
        //Constructor
        constructor () {
           WHO = msg.sender;    
        }
        // Mapping relating the primary health care center (address)with the validity of the management system
        mapping (address => bool)public validation_WHO_health_centers;

        //Relate one address of the primary health care center with his contract
        mapping (address=>address) public HealthCareCenterContract;

        //Example 1:0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db
        //Example 2:0x17F6AD8Ef982297579C203069C1DbfFE4348c372

        //Array storing the address of the primary health centers validated
        address[] public Address_Health_contracts;

        //array storing the address of primary health center requesting access
        address [] Requests;  

        //events to be emit in the contract
        event RequestAccess(address);
        event NewHealthCenter_Validated (address);
        event NewContract (address,address);

        //Modifier that allows only the execution of functions by the Who
        modifier onlyByWHO(address _address){
        require (_address== WHO, "no permit.");
        _;
     }
        // function to request access to the medical system
        function RequestingAccess()public{
            Requests.push(msg.sender);
            //emit the event
            emit RequestAccess(msg.sender);
        }
        //Function to visualize the address who have requested
        function VisualizeRequests()public view onlyByWHO (msg.sender)returns (address []memory){
            return Requests;


        }


        // Function to validate new health centers that can self-manage
        function NewWho_HealthCare_Center (address _HealthCareCenter)public onlyByWHO(msg.sender){
            //Assignment of validity status to the health center
            validation_WHO_health_centers[_HealthCareCenter] = true;
            //emit of the event
            emit NewHealthCenter_Validated (_HealthCareCenter);

        }
        // Function that allows create Smart Contracts
        function factoryHealthCareCenter() public {
            //filtered so that only validated slaud centers are able to execute this function
            require(validation_WHO_health_centers[msg.sender]==true,"You dont have the permit");
            //Generate a Smart Contract -> generate his address
            address contract_HealthCenter = address(new HealthCareCenter(msg.sender));
            //Store the address of the contract in the array
            Address_Health_contracts.push(contract_HealthCenter);
            //Relation between the health primary center and his contract
            HealthCareCenterContract[msg.sender]= contract_HealthCenter;
            // emit of the event
            emit NewContract (contract_HealthCenter,msg.sender);
        }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////



//contract self-managed by the health center
contract HealthCareCenter{

    //intial address
    address public PHCC;
    address public AddressContract;

    constructor (address _address)public{
        AddressContract = address(this);
        PHCC =_address;
    }
    //Mapping relating an ID with a covid pcr
    //mapping(bytes32=>bool)ResultTestCovid;

    //Mapping relating the hash with IPFS code
    //mapping(bytes32=>string)ResultTestCovid_IPFS;

    //Mapping relating the hash of the patient with result of the Covid test
    mapping (bytes32=>Results) CovidResults;

    //Results structure
    struct Results{
        string _namePatient;
        bool diagnosis;
        string IPFScode;
    }

    //events 
    event NewResult (string,bool);

    //Modifier that allows only the execution of functions by the primary Health care center
     modifier onlyByPHCC(address _address){
        require (_address== PHCC, "no permit.");
        _;
     }

     // Fnction to issue a result for a covid test
     function CovidTestResult(string memory _idPatient, string memory _namePatient,bool _COVIDResult,string memory _IPFScode) public onlyByPHCC(msg.sender){
         // Id patient hash
         bytes32 hash_IdPatient = keccak256(abi.encodePacked(_idPatient));
         //Relate the hash  between the patient and the result of the covid test
         // ResultTestCovid[hash_IdPatient]= _COVIDResult;
         // Relate IPFS code
         // ResultTestCovid_IPFS[hash_IdPatient]= _IPFScode;
        CovidResults[hash_IdPatient] = Results(_namePatient,_COVIDResult,_IPFScode);
     }
     //function who permit visualize the results
     function VisualizeResults(string memory _idPatient)public view returns (string memory, string memory){
         // Id patient hash
         bytes32 hash_IdPatient = keccak256(abi.encodePacked(_idPatient));
         //Return  a boolean as a string
         string memory TestResult;

         if (CovidResults[hash_IdPatient].diagnosis == true){
             TestResult ="positive ";
         }else{
             TestResult = "negative";
         }
         return (TestResult,CovidResults[hash_IdPatient].IPFScode);
     }

}
