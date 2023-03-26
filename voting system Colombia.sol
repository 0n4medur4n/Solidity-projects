 // SPDX-License-Identifier: MIT
 // Compiler version
 pragma solidity>=0.4.4<0.8.10;
 pragma experimental ABIEncoderV2;

 // ----------------------------------------------
 //  Candidate|      ID      | politic party     
 // ----------------------------------------------
 //  Petro    |    457224t   | Pacto_historico   
 //  Fico     |    427225t   | Equipo_por_Colombia   
 //  Rodolfo  |    547224t   | Free     

 contract ColombianPresidentElection2022{

 // Address of the contract owner
    address  consejo_nacional_electoral_Colombia;
    constructor ()public{
     consejo_nacional_electoral_Colombia = msg.sender;
 }
 // Relation between the name of the candidate and its personal hash
    mapping(string=>bytes32)Id_Candidate;

 // Relation between the name of te candidate and the number of votes
    mapping(string=>uint) Candidate_Votes;

 // Storage in an array "list of Candidates"
    string [] Colombian_Candidates;

 // Storage in an array "list voters (hash of the address)"
    bytes32[]voters;

 // Function allows anyone to candidate
   function participate(string memory _namecandidate, string memory _Idcandidate, string memory _politicparty) public{

     // hash cadidate data     
      bytes32 hash_candidate = keccak256(abi.encodePacked(_namecandidate,_Idcandidate,_politicparty));

      // Storage hash candidate data
      Id_Candidate [_namecandidate] = hash_candidate; 
      Colombian_Candidates;

    // update storage list  of candidates
      Colombian_Candidates.push (_namecandidate);
    }


 // Function which candidate is participating 
    function seeCandidates() public view returns(string [] memory) {
        //returns the candidate list participating
     return Colombian_Candidates;
    }

 // The voter can vote their candidate
    function vote(string memory _namecandidate)public{
        // calculate the hash of the address
      bytes32 hash_voter = keccak256(abi.encodePacked(msg.sender));
        // check if the voter has voted
        for (uint i=0; i<voters.length;i++){
            require (voters[i]!= hash_voter,"you have voted");
        }
        //store the hash voter inside the array voter
        voters.push(hash_voter);
        //add candidate vote 
        Candidate_Votes [_namecandidate]++;
    }

 // see how many votes per candidate
    function seeVotes (string memory _namecandidate)public view returns(uint){
        //return the number of votes of the candidate _namecandidate
    return Candidate_Votes[_namecandidate];
    }
 //Helper function that transforms a uint to a string

   function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }
 
 // see the result of the election
    function seeResults() public view returns(string memory){
    //save in a string the candidates with their votes
    string memory results = "";

    for(uint i=0;i<Colombian_Candidates.length;i++){
      //update string and add the candidate that occupies the position "i" of the candidates array 
      //and their number of votes 
     results = string(abi.encodePacked(results,"(",Colombian_Candidates[i],",", uint2str(seeVotes(Colombian_Candidates[i])),")----"));
     }
     return results;
     }
 //provides name of the winner
    function winner() public view returns (string memory){
        //variable winner contains the name of the winner candidate
      string memory winner = Colombian_Candidates[0];

      bool flag;
      // through the array of candidates to determine the candidate with the highest number of votes.
     for(uint i=1; i<Colombian_Candidates.length;i++){

      // comparison if the winner has been surpassed
        if(Candidate_Votes[winner] < Candidate_Votes[Colombian_Candidates[i]]){
         winner = Colombian_Candidates[i];
           flag = false;
         }else{ 
           // check if the election is tied   
             if(Candidate_Votes[winner]==Candidate_Votes[Colombian_Candidates[i]]){
                flag = true;
               }
             }
          }
             // the election is tied if
         if(flag==true){
             //info if the election is tied
            winner= "there is a tie between the candidates,¡runoff election needed!";
        }
        return winner;
     }
     
    }


