// SPDX-License-Identifier: GNU GPLv3
// Warning: This contract is not audited and should not be used in production!!!
pragma solidity ^0.8.0;

struct TX {
    address to;
    uint256 value;
    uint256 gasLimit;
    bytes data;
}
library TXLib {
    event ExecutionFailed(address indexed to, uint256 value, uint256 gasLimit, bytes data, bytes ret);
    event ExecutionSuccess(address indexed to, uint256 value, uint256 gasLimit, bytes data, bytes ret);

    function execute(TX memory _tx) internal returns(bytes memory) {
        (bool success, bytes memory ret) = _tx.to.call{value: _tx.value, gas: _tx.gasLimit}(_tx.data);
        if(!success) {
            emit ExecutionFailed(_tx.to, _tx.value, _tx.gasLimit, _tx.data, ret);
        } else {
            emit ExecutionSuccess(_tx.to, _tx.value, _tx.gasLimit, _tx.data, ret);
        }
        return ret;
    }
}