// SPDX-License-Identifier: GNU GPLv3
// Warning: This contract is not audited and should not be used in production!!!
pragma solidity ^0.8.0;
contract FallbackHandler {
    bytes4 constant ERC1155_RECEIVED = bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));

    bytes4 constant ERC1155_BATCH_RECEIVED = bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"));

    bytes4 constant ERC721_RECEIVED = bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));

    fallback() external payable {
        if(msg.data.length > 4) {
            bytes4 selector = bytes4(msg.data[0:4]);
            if(selector == ERC1155_RECEIVED || selector == ERC721_RECEIVED || selector == ERC1155_BATCH_RECEIVED) {
                assembly {
                    //return selector
                    mstore(0, selector)
                    return(0, 4)
                }
            }
        }
    }
}
