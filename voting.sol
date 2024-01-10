// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*

● Registered voters can cast their votes for a specific candidate.
● The voting process should be transparent, and the results should be publicly accessible.
Requirements:
● Implement the smart contract in Solidity.
● Use appropriate data structures to store voter information and election results.
● Ensure that voters can only vote once.
● Include events to log important actions.
*/

contract DvotingSystem {


        
    bool public votingOpen;
    bool public registrationIsOpen;
    address public owner;

    string[] candidates;
    address[] voters;

    mapping(address voters=> bool) private  registeredVoters;
    mapping(string  candidate=> uint256 votes) private votesReceived; 
    mapping(address  => bool) private hasVoted;

    modifier onlyOwner(){
        require(msg.sender == owner,"you are not the owner");
        _;
    }

      constructor() {
        owner = msg.sender;
        registrationIsOpen = true;
        votingOpen = false;
    }

       function addCandidate(string memory candidate) external onlyOwner {
        require(!votingOpen, "Cannot add candidates after voting has started");
        candidates.push(candidate);
    }

      function registerToVote() external  {
        require(!registeredVoters[msg.sender], "You are already registered");
        
        registeredVoters[msg.sender] = true;
        voters.push(msg.sender);
    }

     function startVoting() external onlyOwner {
        require(registrationIsOpen, "Voter registration must be closed before starting the voting");
        registrationIsOpen = false;
        votingOpen = true;
    }

        function castVote(string memory candidate) external  {
        require(!hasVoted[msg.sender], "You have already voted");
        require(votesReceived[candidate] != 0, "Invalid candidate");

        votesReceived[candidate]++;
        hasVoted[msg.sender] = true;

        
    }

       function stopVoting() external onlyOwner {
        require(votingOpen, "Voting is not open");
        votingOpen = false;
    }


    function getAllCandidates() public view returns(string[] memory){
        return candidates;
    }

    function getAllVoters() public view returns(address[] memory){
        return voters;
    }


}
