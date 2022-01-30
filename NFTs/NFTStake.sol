// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFTStakeable{

    constructor(){
        owner = msg.sender;
        stakeholders.push();
    }

    struct Stake{
        address user;
        uint256 tokenId;
        uint256 since;
    }

    struct Stakeholder{
        address user;
        Stake[] address_stakes;
    }

    address owner;
    mapping(address => uint256) internal stakes;
    Stakeholder[] internal stakeholders;

    event Staked(address indexed user, uint256 tokenId, uint256 index, uint256 timeStamp);
    event Unstake(address indexed user, uint256 tokenId);

    function _addStakeholder(address staker) internal returns (uint256){
        // Add empty stakeholder struct to end of array
        stakeholders.push();

        uint256 userIndex = stakeholders.length - 1;

        stakeholders[userIndex].user = staker;
        stakes[staker] = userIndex;

        return userIndex; 
    }

    function _stake(uint256 tokenId) public{
        uint256 index = stakes[msg.sender];
        uint256 timeStamp = block.timestamp;

        if(index == 0){
            index = _addStakeholder(msg.sender);
        }

        stakeholders[index].address_stakes.push(Stake(msg.sender, tokenId, timeStamp));

        emit Staked(msg.sender, tokenId, index, timeStamp);

    }

    function _unstake(uint256 tokenId) public {
        uint256 index = stakes[msg.sender];
        
        if(index == 0){
            revert("Sender does not have staked tokens");
        }

        uint256 tokenIdStakeIndex;

        for(uint x = 0; x < stakeholders[index].address_stakes.length; x++)
        {
            if(stakeholders[index].address_stakes[x].tokenId == tokenId)
            {
                tokenIdStakeIndex = x;
                break;
            }
        }

        delete stakeholders[index].address_stakes[tokenIdStakeIndex];

        emit Unstake(msg.sender, tokenId);
    }

}

