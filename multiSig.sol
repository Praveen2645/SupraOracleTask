// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MultiSignatureWallet {
    address[] public owners;
    mapping(address => bool) public isOwner;
    uint256 public requiredApprovals;

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
        mapping(address => bool) approvals;
    }

    Transaction[] public transactions;

    event TransactionSubmitted(uint256 indexed transactionId, address indexed to, uint256 value, bytes data);
    event TransactionApproved(uint256 indexed transactionId, address indexed approver);
    event TransactionCancelled(uint256 indexed transactionId);
    event Execution(uint256 indexed transactionId);

    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not an owner");
        _;
    }

    modifier validTransaction(uint256 transactionId) {
        require(transactionId < transactions.length, "Invalid transaction ID");
        require(!transactions[transactionId].executed, "Transaction already executed");
        _;
    }

    modifier notApproved(uint256 transactionId) {
        require(!transactions[transactionId].approvals[msg.sender], "Transaction already approved");
        _;
    }

    constructor(address[] memory _owners, uint256 _requiredApprovals) {
        require(_owners.length > 0 && _requiredApprovals > 0 && _requiredApprovals <= _owners.length, "Invalid parameters");

        for (uint256 i = 0; i < _owners.length; i++) {
            require(_owners[i] != address(0), "Invalid owner address");
            require(!isOwner[_owners[i]], "Duplicate owner");
            isOwner[_owners[i]] = true;
        }

        owners = _owners;
        requiredApprovals = _requiredApprovals;
    }

 function submitTransaction(address _to, uint256 _value, bytes memory _data) external onlyOwner {
    uint256 transactionId = transactions.length;
    
    Transaction storage newTransaction = transactions.push();
    newTransaction.to = _to;
    newTransaction.value = _value;
    newTransaction.data = _data;
    newTransaction.executed = false;

    emit TransactionSubmitted(transactionId, _to, _value, _data);
}


    function approveTransaction(uint256 transactionId) external onlyOwner validTransaction(transactionId) notApproved(transactionId) {
        transactions[transactionId].approvals[msg.sender] = true;
        emit TransactionApproved(transactionId, msg.sender);

        if (isTransactionReady(transactionId)) {
            executeTransaction(transactionId);
        }
    }

    function cancelTransaction(uint256 transactionId) external onlyOwner validTransaction(transactionId) {
        transactions[transactionId].executed = true;
        emit TransactionCancelled(transactionId);
    }

    function isTransactionReady(uint256 transactionId) public view returns (bool) {
        uint256 approvalsCount = 0;
        for (uint256 i = 0; i < owners.length; i++) {
            if (transactions[transactionId].approvals[owners[i]]) {
                approvalsCount++;
            }
        }
        return approvalsCount >= requiredApprovals;
    }

    function executeTransaction(uint256 transactionId) internal {
        transactions[transactionId].executed = true;
        (bool success, ) = transactions[transactionId].to.call{value: transactions[transactionId].value}(transactions[transactionId].data);
        require(success, "Transaction execution failed");

        emit Execution(transactionId);
    }

    receive() external payable {
        // Receive ether
    }
}
//["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4","0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2","0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db"]
