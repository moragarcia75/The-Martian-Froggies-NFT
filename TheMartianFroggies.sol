// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract MF7K is ERC721Enumerable, ERC721Royalty, Ownable {
    using Strings for uint256;

    uint256 public constant MAX_SUPPLY = 6000;
    uint256 public constant MAX_PER_WALLET = 50;
    uint256 public constant PRICE = 0.05 ether;
    string public baseTokenURI;
    bool public paused = false;

    address public nftHoldersWallet = ADDRESS_HERE; // Wallet to be used to hold the ETH for NFT holders and later on stake ETH
    address public ownerWallet = ADDRESS_HERE; 
    address public philanthropicWallet = ADDRESS_HERE; // The RVLT wallet in which teh people talkaboutcult
    address public shibaInuWallet = ADDRESS_HERE; // The wallet to swap ETH to SHIB and burn that SHIB

    uint96 public constant ROYALTY_FEE = 200;

    constructor(string memory baseURI) ERC721("TheMartianFroggiesArt", "TMFG") Ownable(msg.sender) {
        setBaseURI(baseURI);
        _setDefaultRoyalty(address(this), ROYALTY_FEE);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        baseTokenURI = baseURI;
    }

    function mint(uint256 _amount) public payable {
        uint256 totalMinted = totalSupply();
        require(!paused, "Minting is paused");
        require(_amount > 0 && _amount <= MAX_PER_WALLET, "Cannot mint specified number of NFTs");
        require(totalMinted + _amount <= MAX_SUPPLY, "Minting would exceed max supply");
        require(balanceOf(msg.sender) + _amount <= MAX_PER_WALLET, "Exceeds maximum NFTs per wallet");
        require(msg.value >= PRICE * _amount, "Ether sent is not correct");
        
        for (uint256 i = 0; i < _amount; i++) {
            _safeMint(msg.sender, totalSupply() + 1);
        }
        distributeFunds(msg.value);
    }

    function distributeFunds(uint256 amount) internal {
        uint256 nftHoldersShare = (amount * 20) / 100;
        uint256 ownerShare = (amount * 60) / 100;
        uint256 philanthropicShare = (amount * 10) / 100;
        uint256 shibaInuShare = (amount * 10) / 100;
        
        sendFunds(nftHoldersWallet, nftHoldersShare);
        sendFunds(ownerWallet, ownerShare);
        sendFunds(philanthropicWallet, philanthropicShare);
        sendFunds(shibaInuWallet, shibaInuShare);
    }

    function sendFunds(address recipient, uint256 amount) internal {
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Transfer failed");
    }

    function _distributeRoyalties(uint256 value) internal {
        uint256 halfFee = value / 2;
        if (ownerWallet != address(0)) {
            (bool success, ) = ownerWallet.call{value: halfFee}("");
            // No require, so failure doesn’t block the next transfer
        }
        if (nftHoldersWallet != address(0)) {
            (bool success, ) = nftHoldersWallet.call{value: halfFee}("");
            // No require, so failure doesn’t block
        }
    }

    receive() external payable {
        if (msg.value > 0) {
            _distributeRoyalties(msg.value);
        }
    }

    fallback() external payable {
        if (msg.value > 0) {
            _distributeRoyalties(msg.value);
        }
    }

    function pause(bool _state) public onlyOwner { 
        paused = _state;
    }

    function withdraw() public onlyOwner {
        sendFunds(owner(), address(this).balance);
        pause(true);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Enumerable, ERC721Royalty) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function _update(address to, uint256 tokenId, address auth) internal virtual override(ERC721, ERC721Enumerable) returns (address) {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 amount) internal virtual override(ERC721, ERC721Enumerable) {
        super._increaseBalance(account, amount);
    }
}

