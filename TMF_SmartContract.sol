// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MartianFroggies is ERC721, ERC721Enumerable, ReentrancyGuard, PaymentSplitter, Ownable {
    uint256 public constant MAX_FROGGIES = 7777;
    uint256 public mintPrice = 0.08 ether;
    uint public whitelistmintPrice = 0.04 ether; // Whitelist mint price
    uint256 public constant royaltyFee = 200; // 2% royalty


    address public constant rvltWallet = 0x292877C901A129c4330aA845ebC5E4954126d543; // Replace with actual $RVLT wallet address
    address public constant cultWallet = 0x456; // Replace with actual $CULT wallet address
    address public constant shibWallet = 0x789; // Replace with actual $SHIB wallet address
    address public constant wFUNDWallet = 0xABC; // Replace with actual $wFUND wallet address
    address public artistWallet;
    address public stakingPool;

    bool public whitelistMintOpen = false;
    bool public publicMintOpen = false;
    mapping(address => bool) public whitelist;

    uint256 public whitelistMintStartTime;
    uint256 public publicMintStartTime;

    uint256[] private _shares = [45, 5, 5, 5, 25, 5]; // Updated shares: Artist, RVLT, CULT, SHIB, Staking, wFUND
    address[] private _shareholders = [artistWallet, rvltWallet, cultWallet, shibWallet, stakingPool, wFUNDWallet];

    constructor(string memory baseURI, address _artistWallet, address _stakingPool)
        ERC721("The Martian Froggies", "TMF")
        PaymentSplitter(_shareholders, _shares) {
        artistWallet = _artistWallet;
        stakingPool = _stakingPool;
        _setBaseURI(baseURI);
        transferOwnership(_artistWallet); // Set the artist as the owner
    }

    function whitelistMint(uint256 numberOfTokens) public payable nonReentrant {
        require(whitelistMintOpen && block.timestamp >= whitelistMintStartTime, "Whitelist mint is not open");
        require(whitelist[msg.sender], "Not on the whitelist");
        require(totalSupply() + numberOfTokens <= MAX_FROGGIES, "Sale would exceed max supply");
        require(whitelistmintPrice * numberOfTokens <= msg.value, "Ether value sent is not correct");

        for (uint256 i = 0; i < numberOfTokens; i++) {
            if (totalSupply() < MAX_FROGGIES) {
                _safeMint(msg.sender, totalSupply());
            }
        }
    }

    function publicMint(uint256 numberOfTokens) public payable nonReentrant {
        require(publicMintOpen && block.timestamp >= publicMintStartTime, "Public mint is not open");
        require(totalSupply() + numberOfTokens <= MAX_FROGGIES, "Sale would exceed max supply");
        require(mintPrice * numberOfTokens <= msg.value, "Ether value sent is not correct");

        for (uint256 i = 0; i < numberOfTokens; i++) {
            if (totalSupply() < MAX_FROGGIES) {
                _safeMint(msg.sender, totalSupply());
            }
        }
    }

    function setMintDates(uint256 _whitelistMintStartTime, uint256 _publicMintStartTime) public onlyOwner {
        whitelistMintStartTime = _whitelistMintStartTime;
        publicMintStartTime = _publicMintStartTime;
    }

    function toggleWhitelistMint(bool _state) public onlyOwner {
        whitelistMintOpen = _state;
    }

    function togglePublicMint(bool _state) public onlyOwner {
        publicMintOpen = _state;
    }

    function withdraw() public {
        require(msg.sender == artistWallet, "Only artist can withdraw");
        payable(artistWallet).transfer(address(this).balance);
    }

    // Royalty info for marketplaces
    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) external view returns (address, uint256) {
        uint256 royaltyAmount = (_salePrice * royaltyFee) / 10000;
        return (artistWallet, royaltyAmount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721) {
        super._burn(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
