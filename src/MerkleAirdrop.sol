// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import {IERC20, SafeERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";
import {EIP712} from "lib/openzeppelin-contracts/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";

contract Merkle_Airdrop is EIP712 {
    using SafeERC20 for IERC20;
    // The using directive allows us to use SafeERC20 functions on IERC20 tokens.
    // It is essentially a library attachment, allowing us to add functionality without inheritance. Kinda like an update

    address[] public claimers;
    bytes32 private immutable merkleRoot;
    IERC20 private immutable airdropToken;
    mapping(address => bool) private s_hasClaimed;

    error Merkle_Airdrop__InvalidProof();
    error Merkle_Airdrop__AlreadyClaimed();
    error Merkle_Airdrop__NotEligible();
    error Merkle_Airdrop__SignatureNotValid();

    
    bytes32 private constant MESSAGE_TYPEHASH = keccak256("AirdropClaim(address account,uint256 amount)");

    struct AirdropClaim {
        address account;
        uint256 amount;
    }

    event AirdropClaimed(address indexed account, uint256 amount);

    constructor(bytes32 _merkleRoot, IERC20 _airdropToken) EIP712("DabayyudMerkleAirdrop", "1") {
        // Initialize with the given Merkle root
        merkleRoot = _merkleRoot;
        airdropToken = _airdropToken;
    }

    function claim(address account, uint256 amount, bytes32[] calldata Merkleproof,
    uint8 v, bytes32 r, bytes32 s) external {
        // Verify the Merkle proof using the provided account, amount, and Merkle proof
        // Use the same leaf construction as MakeMerkle script
        if (!_isValidSignature(account, getMessage(account, amount), v, r, s)) {
            revert Merkle_Airdrop__SignatureNotValid();
        // Creates consent to claim on behalf of another user but only if they signed the claim
        // This allows a relayer to submit the claim on behalf of the user
        // User with no eth wants to claim, so they sign the message off-chain, as ECDSA is precompiled
        // The relayer then submits the claim with the user's signature (of which they choose who to send to)
        }
            
        bytes32[] memory data = new bytes32[](2);
        data[0] = bytes32(uint256(uint160(account)));
        data[1] = bytes32(amount);
        
        // This should match the MakeMerkle script's leaf construction with ltrim64
        bytes memory encoded = abi.encode(data);
        bytes memory trimmed = new bytes(encoded.length - 64); // Remove first 64 bytes (ltrim64 equivalent)
        for (uint i = 0; i < trimmed.length; i++) {
            trimmed[i] = encoded[i + 64];
        }
        
        bytes32 leaf = keccak256(bytes.concat(keccak256(trimmed)));
        // The reason we hash the leaf this way is to prevent second preimage attacks.
        if (!MerkleProof.verify(Merkleproof, merkleRoot, leaf)) {
            revert Merkle_Airdrop__InvalidProof();
        }
        if (s_hasClaimed[account]) {
            revert Merkle_Airdrop__AlreadyClaimed();
        }

        s_hasClaimed[account] = true;
        emit AirdropClaimed(account, amount);
        airdropToken.safeTransfer(account, amount);
        claimers.push(account);
    }

    function getMerkleRoot() external view returns (bytes32) {
        return merkleRoot;
    }

    function getAirdropToken() external view returns (IERC20) {
        return airdropToken;

    }

    function getMessage(address account, uint256 amount) public view returns (bytes32) {
        return _hashTypedDataV4(keccak256(abi.encode(
            MESSAGE_TYPEHASH,
            AirdropClaim({
                account: account,
                amount: amount
                
            })
            // This is to ensure the encoding matches the struct (not needed if using individual parameters)
            // This matches the structure of the signed data from openZeppelin
            // In the original code, the input was only a message typehash.
        )));
    }

    function _isValidSignature(address account, bytes32 digest, uint8 v, bytes32 r, bytes32 s) internal view returns (bool) {
        address actualSigner = ECDSA.recover(digest, v, r, s);
        // ECDSA.recover returns only the address, not multiple values
        // It will revert on invalid signatures, so we don't need error handling
        // It checks if s is in lower half order and v is 27 or 28, checks if the signer is not the zero address.
        return actualSigner == account;
        // We create a digest and pass it through with the account to the ECDSA recover function to check signature
    }
}
