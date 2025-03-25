// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IOng1 {
    function receiveProgramData(uint256 _id, string calldata _name, address _sponsor, uint256 _amount) external payable;
    function withdrawFunds(uint256 _id, address payable _sponsor, uint256 _amount) external;
    function getBalance(uint256 _id) external view returns (uint256);
}
