// SPDX-License-Identifier: GNU GPLv3
// Warning: This contract is not audited and should not be used in production!!!
pragma solidity ^0.8.0;

import "../shared/TX.sol";
import "lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
contract GOWallet {
    error InvalidSignature();

    error FallbakError(bytes ret);

    address public immutable fallbackHandler;

    address public owner;

    uint256 public nonce;

    constructor(address _fallbackHandler) {
        owner = msg.sender;
        fallbackHandler = _fallbackHandler;
    }

    fallback() external payable {
        (bool success, bytes memory _ret) = fallbackHandler.delegatecall(msg.data);
        if(!success) {
            revert FallbakError(_ret);
        }
        assembly {
            return(add(_ret, 0x20), mload(_ret))
        }
    }

    receive() external payable {}
    
    function execute(TX[] memory _txs, bytes memory _signature) public {
        _validateSignatures(_txs, _signature);
        for(uint256 i = 0; i < _txs.length; i++) {
            TXLib.execute(_txs[i]);
        }
    }

    function _validateSignatures(TX[] memory _txs, bytes memory _signature) internal {
        uint256 _nonce = nonce;
        _useNonce(_nonce);
        bytes memory packed = abi.encodePacked(address(this), _nonce, encodeTXs(_txs));
        address signer = ECDSA.recover(ECDSA.toEthSignedMessageHash(packed),_signature);
        if(signer != owner) {
            revert InvalidSignature();
        }
    }

    function encodeTXs(TX[] memory _txs) public pure returns(bytes memory packed) {
        unchecked {
            for(uint256 i = 0; i<_txs.length; i++){
                TX memory _tx = _txs[i];
                packed = abi.encodePacked(packed, _tx.to, _tx.gasLimit, _tx.value, _tx.data);
            }
        }
    }

    // This version of GOWallet only supports sequential nonces
    function isValidNonce(uint256 _nonce) public view returns(bool) {
        return _nonce == nonce;
    }

    function _useNonce(uint256) internal {
        // non need to check nonce here, because we only support sequential nonces
        unchecked {
            nonce++;
        }
    }
}

