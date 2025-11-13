// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {ERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
// ^ Importing Ownable from OpenZeppelin, we want our contract to have a owner so we can mint new tokens to whomever we choose.

contract DabbayudToken is ERC20, Ownable {
    constructor() ERC20("Dabbayud Token", "DAB") Ownable(msg.sender) {}
    // We do not need an initial supply, because we will be minting tokens as needed.

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}
