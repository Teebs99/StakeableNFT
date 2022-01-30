// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "./NFTStake.sol";

contract MyNFT is ERC721URIStorage, IERC721Receiver, NFTStakeable{
    using Strings for *;
    uint256 public tokenCounter;
    address private StakingContract;
    address private admin;
    mapping(uint256 => address) ownerOfStakedToken;

    event TokenPurchased(uint256, address);
    event NFTStake(address, uint256);

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol){
        tokenCounter = 0;
    }

    modifier OnlyAdmin(){
        require(msg.sender == admin);
        _;
    }

    function buyToken() payable public returns (uint256)
    {
        require(msg.value == 10000000000000000);
        admin = msg.sender;
        uint256 newItemId = tokenCounter;
        _safeMint(msg.sender, newItemId);
        _setTokenURI(newItemId, createTokenUri(newItemId));
        tokenCounter += 1;
        emit TokenPurchased(newItemId, msg.sender);

        return newItemId;
    }

    function approveStake() external
    {
        ERC721.setApprovalForAll(address(this), true);
    }

    function stakeNFT(uint256 tokenId) public
    {
        require(ERC721.ownerOf(tokenId) == msg.sender);
        require(ERC721.isApprovedForAll(msg.sender, address(this)));

        _stake(tokenId);

        ERC721.safeTransferFrom(msg.sender, address(this), tokenId);

        ownerOfStakedToken[tokenId] = msg.sender;

        emit NFTStake(msg.sender, tokenId);
    }

    function unstakeNFT(uint256 tokenId) public {
        require(ownerOfStakedToken[tokenId] == msg.sender);

        _unstake(tokenId);
        delete ownerOfStakedToken[tokenId];

        _safeTransfer(address(this), msg.sender, tokenId, "");
    }

    function setStakingContract(address contractAddress) public OnlyAdmin{
        StakingContract = contractAddress;
    }

    function createTokenUri(uint256 tokenId) internal pure returns(string memory)
    {
        string memory url = string(abi.encodePacked("somefakeurlfortheimage/", tokenId));

        return url;
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4)
    {
        return IERC721Receiver.onERC721Received.selector;
    }

    
}