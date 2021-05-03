// SPDX-License-Identifier: MIT

//** Cloak Bridge Contract*/
//** Author Alex Hong : Cloak Coin Team 2021.4 */

pragma solidity 0.6.6;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

struct UserInfo {
    address wallet;
    uint256 depositAmount;
    uint256 joinDate;
    bool active;
}

struct PoolInfo {
    uint256 identifier;
    uint256 generateDate;
    bool active;
    mapping(address => UserInfo) userList;
}

struct PoolToken {
    bool active;
    IERC20 token;
}

contract MatchPrediction is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    mapping(uint256 => PoolInfo) public cloakPools;
    mapping(address => PoolToken) public poolTokens;
    mapping(address => UserInfo) public memberPools;

    uint256 private poolCount;
    uint256[] private addressIndices;

    constructor() public {
        poolCount = 0;
    }

    /**
     * Add Token
     *
     * @param {token} IERC20 token
     * @return {true}
     */

    function addTokenToPool(IERC20 _token) external onlyOwner returns (bool) {
        require(!poolTokens[address(_token)].active, "Token found");

        poolTokens[address(_token)].active = true;
        poolTokens[address(_token)].token = _token;

        return true;
    }

    /**
     * Remove Token
     *
     * @param {token} IERC20 token
     * @return {true}
     */

    function removeTokenFromPool(address poolTokenAddress)
        external
        onlyOwner
        returns (bool)
    {
        require(poolTokens[poolTokenAddress].active, "Token not found");
        poolTokens[poolTokenAddress].active = false;
        return true;
    }

    /**
     * Get Token info
     *
     * @param {token} IERC20 token
     * @return {true}
     */

    function getTokenFromPool(address poolTokenAddress)
        public
        view
        returns (PoolToken memory)
    {
        return poolTokens[poolTokenAddress];
    }

    /**
     * Get Total Token Balance
     *
     * @param {address} token address
     * @return {balance} token balance
     */

    function getTotalToken(address poolTokenAddress)
        public
        view
        returns (uint256)
    {
        require(poolTokens[poolTokenAddress].active, "Token doensn't exist");

        return poolTokens[poolTokenAddress].token.balanceOf(address(this));
    }

    /**
     * math formular for amount
     * @param {address} address
     * @param {uint256} rate of calculation
     * @param {uint256} amount for calculation
     * @return {bool}
     */

    function calculateAmount(uint256 rate, uint256 amount)
        public
        view
        returns (uint256)
    {
        return amount.mul(rate);
    }

    /**
     * Register account to user list
     *
     * @param {address} token address
     * @return {bool}
     */
    function registerAccount(address poolTokenAddress)
        external
        payable
        returns (bool)
    {
        require(
            IERC20(poolTokenAddress).balanceOf(msg.sender) > 0,
            "amount should available"
        );
        require(!memberPools[msg.sender].active, "User already registered");

        memberPools[msg.sender].wallet = msg.sender;
        memberPools[msg.sender].joinDate = block.timestamp;
        memberPools[msg.sender].active = true;
        memberPools[msg.sender].depositAmount = 0;

        return true;
    }

    /**
     * Revert receive ether
     */

    fallback() external {
        revert();
    }

    /**
     * convert bytes32 to string
     */

    function bytes32ToString(bytes32 _bytes32)
        internal
        pure
        returns (string memory)
    {
        uint8 i = 0;
        while (i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }

    /**
     * convert string to bytes32
     */
    function stringToBytes32(string memory source)
        internal
        pure
        returns (bytes32 result)
    {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            // solhint-disable-line no-inline-assembly
            result := mload(add(source, 32))
        }
    }

    /**
     * add two strings and return string
     */
    function append(string memory a, string memory b)
        internal
        pure
        returns (string memory source)
    {
        source = string(abi.encodePacked(a, b));
    }

    /**
     * convert uint to string
     */
    function uint2str(uint256 _i)
        internal
        pure
        returns (string memory _uintAsString)
    {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len - 1;
        while (_i != 0) {
            bstr[k--] = bytes1(uint8(48 + (_i % 10)));
            _i /= 10;
        }
        return string(bstr);
    }
}
