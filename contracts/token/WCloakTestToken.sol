// SPDX-License-Identifier: MIT

//** Standard ERC20 - WCloak Test Token */
//** Author Alex Hong : Cloak Coin Team 2021.4 */

pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract WCloakTest is ERC20 {
    constructor() public ERC20("WCloak Test Token", "WCLKT") {}

    function mintToWallet(address address_, uint256 amount)
        public
        payable
        returns (bool)
    {
        _mint(address_, amount);
        return true;
    }
}
