// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DS_HearthGovernor {
    function getQuorum() public pure returns (uint256) {
        return 4;
    }
}