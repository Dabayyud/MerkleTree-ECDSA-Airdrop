AI GENERATED READ ME FILE BECAUSE I CANT BE ASKED

# MerkleAirdrop - Gasless Token Distribution System

A Solidity smart contract system that enables efficient and secure token airdrops using Merkle tree verification and EIP712 signature-based claiming. This project implements gasless token claiming through meta-transactions, allowing users to claim airdropped tokens without paying gas fees.

## 🌟 Features

- **Gasless Token Claims**: Users can claim tokens without paying gas fees through signature-based verification
- **Merkle Tree Verification**: Efficient proof-of-eligibility using cryptographic Merkle proofs
- **EIP712 Signatures**: Secure, standardized signature verification for meta-transactions
- **Multi-Network Support**: Configurable deployment across different blockchain networks
- **Comprehensive Testing**: Full test suite with Foundry framework
- **Automated Deployment**: Script-based deployment with network-specific configurations.

## 📁 Project Structure

```
├── src/
│   ├── MerkleAirdrop.sol      # Main airdrop contract with signature verification
│   └── DabayyudToken.sol      # ERC20 token contract for testing
├── script/
│   ├── DeployScript.s.sol     # Deployment automation
│   ├── HelperConfig.s.sol     # Network configuration management
│   ├── MakeMerkle.s.sol       # Merkle tree generation from JSON input
│   ├── GenerateInput.s.sol    # Sample eligibility data generation
│   └── Interaction.s.sol      # Contract interaction scripts
├── test/
│   └── MerkleAirdropUnit.t.sol # Comprehensive unit tests
├── lib/                       # Dependencies (OpenZeppelin, Murky, etc.)
└── foundry.toml              # Foundry configuration
```

## 🔧 Technology Stack

- **Solidity ^0.8.0**: Smart contract development
- **Foundry**: Development framework and testing
- **OpenZeppelin**: Security-audited contract libraries
- **Murky**: Merkle tree generation and proof creation
- **EIP712**: Typed data signing standard
- **ECDSA**: Digital signature verification

## 🚀 Quick Start

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- Git

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd MerkleTrees&Signatures
```

2. Install dependencies:
```bash
forge install
```

3. Build the project:
```bash
forge build
```

4. Run tests:
```bash
forge test -vv
```

## 📋 How It Works

### 1. Merkle Tree Generation
The system uses Merkle trees to efficiently store and verify airdrop eligibility:

```solidity
// Eligible users and amounts are hashed into a Merkle tree
bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encodePacked(account, amount))));
```

### 2. Signature-Based Claiming
Users sign a message off-chain using EIP712 standard:

```solidity
function getMessage(address account, uint256 amount) external view returns (bytes32) {
    return _hashTypedDataV4(keccak256(abi.encode(MESSAGE_TYPEHASH, account, amount)));
}
```

### 3. Gasless Execution
A gas payer (relayer) can submit the transaction on behalf of the user:

```solidity
function claim(
    address account,
    uint256 amount,
    bytes32[] calldata merkleProof,
    uint8 v, bytes32 r, bytes32 s
) external {
    // Verify Merkle proof and signature
    // Transfer tokens to account
}
```

## 🔒 Security Features

- **Merkle Proof Verification**: Ensures only eligible users can claim
- **Signature Validation**: Prevents unauthorized claims through ECDSA verification
- **Double-Claim Prevention**: Mapping tracks claimed addresses
- **EIP712 Domain Separation**: Prevents cross-contract signature replay
- **SafeERC20**: Protected token transfers

## 🧪 Testing

Run the comprehensive test suite:

```bash
# Run all tests
forge test

# Run with verbose output
forge test -vv

# Run specific test
forge test --match-test testUsersCanClaim -vv

# Generate gas report
forge snapshot
```

### Test Coverage

- ✅ Successful token claiming with valid proofs and signatures
- ✅ Double-claim prevention
- ✅ Invalid proof rejection
- ✅ Signature verification
- ✅ Gas payer functionality
- ✅ Contract state management

## 🌐 Deployment

### Local Deployment (Anvil)

1. Start local node:
```bash
anvil
```

2. Deploy contracts:
```bash
forge script script/DeployScript.s.sol --rpc-url http://localhost:8545 --private-key <PRIVATE_KEY> --broadcast
```

### Network Deployment

The project supports multiple networks through `HelperConfig.s.sol`:

- Ethereum Mainnet
- Sepolia Testnet
- Local Anvil

```bash
# Deploy to Sepolia
forge script script/DeployScript.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify

# Deploy to Mainnet
forge script script/DeployScript.s.sol --rpc-url $MAINNET_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify
```

## 💡 Usage Examples

### Generating Merkle Tree

1. Create input data:
```bash
forge script script/GenerateInput.s.sol
```

2. Generate Merkle tree:
```bash
forge script script/MakeMerkle.s.sol
```

### Claiming Tokens

Users can claim tokens by providing:
- Their address and claim amount
- Merkle proof of eligibility
- EIP712 signature

```solidity
// Example claim call
merkleAirdrop.claim(
    userAddress,
    claimAmount,
    merkleProof,
    v, r, s  // Signature components
);
```

## 📊 Gas Optimization

The contract implements several gas optimization techniques:

- **Immutable Variables**: `merkleRoot` and `airdropToken` stored as immutable
- **Efficient Merkle Verification**: Using OpenZeppelin's optimized MerkleProof library
- **Packed Storage**: Minimal storage usage with mappings
- **SafeERC20**: Optimized token operations

## 🔍 Contract Addresses

After deployment, contract addresses will be logged and can be found in:
- Foundry broadcast logs
- Network explorer (when verified)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## 📄 License

This project is licensed under the UNLICENSED license.

## 🛠 Foundry Commands

### Build
```bash
forge build
```

### Test
```bash
forge test
```

### Format
```bash
forge fmt
```

### Gas Snapshots
```bash
forge snapshot
```

### Local Node
```bash
anvil
```

### Cast Interactions
```bash
cast <subcommand>
```

### Help
```bash
forge --help
anvil --help
cast --help
```

---

For more information about Foundry: https://book.getfoundry.sh/
