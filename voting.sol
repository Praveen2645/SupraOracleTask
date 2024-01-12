// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

contract DvotingSystem {
    bool isVotingOpen;
    bool isRegistrationOpen;
    address public owner;
    uint256 public startTime;
    uint256 public endTime;

    address[] candidates;
    address[] voters;

    mapping(address => bool) private registeredVoters;
    mapping(address => bool) private registeredCandidates;
    mapping(address => uint256) private votesReceived;
    mapping(address => bool) private hasVoted;

    event CandidateAdded(address indexed candidate);
    event VoteCasted(address indexed voter, address indexed candidate);
    event VoterRegistered(address indexed voter);
    event VotingStarted(uint256 startTime, uint256 endTime);
    event VotingEnded();

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    constructor() {
        owner = msg.sender;
        isRegistrationOpen = true;
        isVotingOpen = false;
    }

    function addCandidate(address candidate) external onlyOwner {
        require(
            !isVotingOpen,
            "Cannot add candidates after voting has started"
        );
        require(
            !registeredCandidates[candidate],
            "Candidate already registered"
        );

        candidates.push(candidate);
        registeredCandidates[candidate] = true;

        emit CandidateAdded(candidate);
    }

    function castVote(address candidate) external {
        require(
            block.timestamp >= startTime && block.timestamp <= endTime,
            "Voting not active"
        );
        require(!hasVoted[msg.sender], "You already voted");
        require(registeredCandidates[candidate], "Invalid candidate");
        require(registeredVoters[msg.sender], "Voter not registered");

        votesReceived[candidate]++;
        hasVoted[msg.sender] = true;

        emit VoteCasted(msg.sender, candidate);
    }

    function registerToVote() external {
        require(!registeredVoters[msg.sender], "You are already registered");
        require(!isVotingOpen, "Cannot register after voting has started");
        registeredVoters[msg.sender] = true;
        voters.push(msg.sender);

        emit VoterRegistered(msg.sender);
    }

    function startVoting(uint256 _duration) external onlyOwner {
        require(_duration != 0, "Invalid duration");
        require(!isVotingOpen, "Voting has already started");
        isRegistrationOpen = false;
        startTime = block.timestamp;
        endTime = startTime + _duration;

        emit VotingStarted(startTime, endTime);

        if (block.timestamp > endTime) {
            isVotingOpen = false;
            emit VotingEnded();
        }
    }

    function getWinner() public view returns (address) {
        require(!isVotingOpen, "Voting is still active");

        address currentWinner = candidates[0];
        uint256 maxVotes = votesReceived[currentWinner];

        for (uint256 i = 1; i < candidates.length; i++) {
            if (votesReceived[candidates[i]] > maxVotes) {
                currentWinner = candidates[i];
                maxVotes = votesReceived[currentWinner];
            }
        }

        return currentWinner;
    }

    function getAllCandidates() public view returns (address[] memory) {
        return candidates;
    }

    function getAllVoters() public view returns (address[] memory) {
        return voters;
    }
}
