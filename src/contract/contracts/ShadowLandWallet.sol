// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IAccount, Transaction} from "@matterlabs/zksync-contracts/l2/system-contracts/interfaces/IAccount.sol";
import {IPaymaster, ExecutionResult} from "@matterlabs/zksync-contracts/l2/contracts/interfaces/IPaymaster.sol";

contract MyWallet is IAccount {
    address public owner;
    bytes4 public constant ACCOUNT_VALIDATION_SUCCESS_MAGIC =
        IAccount.validateTransaction.selector;

    error OnlyOwnerCanCall();
    error InvalidSignature();
    error TransactionFailed();

    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert OnlyOwnerCanCall();
        _;
    }

    function validateTransaction(
        bytes32 _txHash,
        bytes32 _suggestedSignedHash,
        Transaction calldata _transaction
    ) external payable override onlyOwner returns (bytes4 magic) {
        if (!_validateSignature(_suggestedSignedHash, _transaction))
            revert InvalidSignature();
        return ACCOUNT_VALIDATION_SUCCESS_MAGIC;
    }

    function executeTransaction(
        bytes32 _txHash,
        bytes32 _suggestedSignedHash,
        Transaction calldata _transaction
    ) external payable override onlyOwner {
        _executTransaction(_transaction);
    }

    function executeTransactionFromOutside(
        Transaction calldata _transaction
    ) external payable {
        _executTransaction(_transaction);
    }

    function _executTransaction(Transaction calldata _transaction) internal {
        address to = address(uint160(_transaction.to));
        uint256 value = _transaction.reserved[1];
        bytes memory data = _transaction.data;

        if (to == address(this)) {
            // Call to this contract, execute directly
            (bool success, ) = address(this).call{value: value}(data);
            if (!success) revert TransactionFailed();
        } else {
            // Call to another contract, use the low-level call
            (bool success, ) = to.call{value: value}(data);
            if (!success) revert TransactionFailed();
        }
    }

    function postOp(
        bytes calldata _context,
        Transaction calldata _transaction,
        bytes32 _txHash,
        bytes32 _suggestedSignedHash,
        ExecutionResult _txResult,
        uint256 _maxRefundedGas
    ) external payable {
        // Implement post-operation logic if needed
    }

    function _validateSignature(
        bytes32 _suggestedSignedHash,
        Transaction calldata _transaction
    ) internal view returns (bool) {
        // Implement your signature validation logic here
        // Example: Check if the _suggestedSignedHash matches the hash of the transaction signed by the owner
        bytes32 txHash = keccak256(
            abi.encode(
                _transaction.txType,
                _transaction.from,
                _transaction.to,
                _transaction.gasLimit,
                _transaction.gasPerPubdataByteLimit,
                _transaction.maxFeePerGas,
                _transaction.maxPriorityFeePerGas,
                _transaction.paymaster,
                _transaction.nonce,
                _transaction.value,
                _transaction.reserved,
                _transaction.data
            )
        );
        return _suggestedSignedHash == txHash;
    }

    function payForTransaction(
        bytes32 _txHash,
        bytes32 _suggestedSignedHash,
        Transaction calldata _transaction
    ) external payable override {
        // Implement payment logic for the transaction if needed
    }

    function prepareForPaymaster(
        bytes32 _txHash,
        bytes32 _possibleSignedHash,
        Transaction calldata _transaction
    ) external payable override {
        // Implement preparation logic for the paymaster if needed
    }
}
