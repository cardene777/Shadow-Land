// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract ShadowLandToken is ERC20, ERC20Burnable, Ownable, ERC20Permit {
    constructor()
        ERC20("ShadowLandToken", "SLT")
        Ownable(msg.sender)
        ERC20Permit("ShadowLandToken")
    {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}
