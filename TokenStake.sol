// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
import "./TeebsToken.sol";

contract Stakeable {

    constructor(){
        owner = msg.sender;
        stakeholders.push();
    }

    struct Stake{
        address user;
        uint256 amount;
        uint256 since;
    }

    struct Stakeholder{
        address user;
        Stake[] address_stakes;
    }

    address owner;
    mapping(address => uint256) internal stakes;
    Stakeholder[] internal stakeholders;

    event Staked(address indexed user, uint256 amount, uint256 index, uint256 timeStamp);

    function _addStakeholder(address staker) internal returns (uint256){
        // Add empty stakeholder struct to end of array
        stakeholders.push();

        uint256 userIndex = stakeholders.length - 1;

        stakeholders[userIndex].user = staker;
        stakes[staker] = userIndex;

        return userIndex; 
    }

    function _stake(uint256 amount) public{
        require(amount > 0, "Cannot stake nothing");

        uint256 index = stakes[msg.sender];
        uint256 timeStamp = block.timestamp;

        if(index == 0){
            index = _addStakeholder(msg.sender);
        }

        stakeholders[index].address_stakes.push(Stake(msg.sender, amount, timeStamp));

        emit Staked(msg.sender, amount, index, timeStamp);

    }

}

