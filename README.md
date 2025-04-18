# 🛸 The Martian Froggies NFT Minting DApp

This project includes a fully-functional **NFT minting interface** built with HTML + React + Ethers.js and connected to a custom ERC721 smart contract on Ethereum Mainnet.

## 🔥 Features

### 🎨 Front-End (HTML + React)
- **Wallet Support**: MetaMask, WalletConnect, and Phantom (EVM)
- **Real-Time ETH Balance**: Displays wallet balance and mint cost
- **Gas Estimation**: Dynamic gas limit calculation for mint transactions
- **Responsive UI**: Styled buttons, error messages, and transaction feedback
- **Minting Limit**: Up to 50 NFTs per wallet, with live ETH price calculation

### 🧠 Solidity Smart Contract (`MF7K`)
- Built with OpenZeppelin's ERC721Enumerable + Royalty extensions
- **Max Supply**: 6,000 NFTs  
- **Max Per Wallet**: 50 NFTs  
- **Price per NFT**: 0.05 ETH  
- **Royalty Fee**: 2% (divided evenly between owner and NFT holders)

#### ✨ ETH Distribution Breakdown
When someone mints NFTs:
- **20%** goes to NFT holders wallet (to be used for staking rewards)
- **60%** to the project owner wallet
- **10%** to a philanthropic wallet supporting CULTDAO missions
- **10%** to a wallet that buys and burns SHIBA INU tokens

## 🧱 Smart Contract Summary

```solidity
contract MF7K is ERC721Enumerable, ERC721Royalty, Ownable
