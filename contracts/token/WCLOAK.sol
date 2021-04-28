// SPDX-License-Identifier: MIT

//** Wrapped Cloak Token*/
//** Author Alex Hong : Cloak Coin Team 2021.4 */

pragma solidity ^0.6.6;

import "@openzeppelin/contracts-upgradeable/presets/ERC20PresetMinterPauserUpgradeable.sol";

contract WCLOAK is ERC20PresetMinterPauserUpgradeable {
    address private _owner;
    address private _feeAddress;
    uint256 private _withdrawalFee;

    function initialize(string memory name, string memory symbol)
        public
        override
        initializer
    {
        __ERC20PresetMinterPauser_init(name, symbol);

        _feeAddress = msg.sender;
        _withdrawalFee = 400000;
        _setupDecimals(8);
    }

    event BurnedWithNote(address indexed a, uint256 v, string n);

    function burnWithNote(uint256 _value, string memory _note) public {
        require(_value > _withdrawalFee);
        super.burn(_value);
        emit BurnedWithNote(msg.sender, _value, _note);
    }

    mapping(string => bool) mints;

    event MintedWithNote(address indexed a, uint256 v, string n, uint256 f);

    function mint(
        address _to,
        uint256 _amount,
        string memory _note,
        uint256 _fee
    ) public {
        require(
            hasRole(MINTER_ROLE, _msgSender()),
            "ERROR: must have minter role to mint"
        );
        require(!existsMint(_note));
        require(isRegistered(_to));
        super._mint(_to, _amount);
        if (_fee != 0x0) {
            super._mint(_feeAddress, _fee);
        }
        mints[_note] = true;
        emit MintedWithNote(_to, _amount, _note, _fee);
    }

    function setFeeAddress(address _to) public {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "ERROR: must have admin role"
        );
        _feeAddress = _to;
    }

    function getFeeAddress() public view returns (address) {
        return _feeAddress;
    }

    function setMinFee(uint256 _fee) public {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "ERROR: must have admin role"
        );
        _withdrawalFee = _fee;
    }

    function getMinFee() public view returns (uint256) {
        return _withdrawalFee;
    }

    function existsMint(string memory _note) public view returns (bool) {
        return mints[_note] == true;
    }

    mapping(address => bool) cloakAddresses;

    event Registered(address indexed a);

    function register() public {
        require(!isRegistered(msg.sender));
        cloakAddresses[msg.sender] = true;
        emit Registered(msg.sender);
    }

    function isRegistered(address _native) public view returns (bool) {
        return cloakAddresses[_native] == true;
    }
}
