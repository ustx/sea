// TronSEA.sol
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "./IERC20.sol";
import "./Roles.sol";
import "./Initializable.sol";
import "./MerkleLib.sol";


/// @title Tron SEA (Safe and Efficient Airdrop) framework
/// @author USTX Team
/// @dev

contract TronSEA is Initializable{
	using Roles for Roles.Role;

	/***********************************|
	|        Variables && Events        |
	|__________________________________*/


	//Variables
	bool private _notEntered;			//reentrancyguard state
	Roles.Role private _administrators;
	uint256 private _numAdmins;
	uint256 private _minAdmins;

    IERC20 private _token;

    bytes32 private _root;


    //Last V1 variable
    uint256 public version;

	// Events
    event Claimed(address indexed user, uint256 amount);
    event AdminAdded(address indexed account);
    event AdminRemoved(address indexed account);

	/**
	* @dev initializer
	*
	*/
    function initialize() public initializer {
        version=1;
        _notEntered = true;
        _numAdmins=0;
		_addAdmin(msg.sender);		//default admin
		_minAdmins = 1;

    }


	/***********************************|
	|        AdminRole                  |
	|__________________________________*/

	modifier onlyAdmin() {
        require(isAdmin(msg.sender), "AdminRole: caller does not have the Admin role");
        _;
    }

    function isAdmin(address account) public view returns (bool) {
        return _administrators.has(account);
    }

    function addAdmin(address account) public onlyAdmin {
        _addAdmin(account);
    }

    function renounceAdmin() public {
        require(_numAdmins>_minAdmins, "There must always be a minimum number of admins in charge");
        _removeAdmin(msg.sender);
    }

    function _addAdmin(address account) internal {
        _administrators.add(account);
        _numAdmins++;
        emit AdminAdded(account);
    }

    function _removeAdmin(address account) internal {
        _administrators.remove(account);
        _numAdmins--;
        emit AdminRemoved(account);
    }

	/***********************************|
	|        ReentrancyGuard            |
	|__________________________________*/

	/**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_notEntered, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _notEntered = false;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _notEntered = true;
    }

    /* ========== VIEWS ========== */


    function verify(bytes32[] memory proof, address user, uint256 amount) public view returns(bool){
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(user, amount))));
        return MerkleLib.verify(proof, _root, leaf);
    }

    function verifySimple(bytes32[] memory proof, bytes32 leaf) public view returns(bool){
        return MerkleLib.verify(proof, _root, leaf);
    }

    /* ========== SETTERS ========== */

    function claim(bytes32[] memory proof, address user, uint256 amount) public {
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(user, amount))));
        require(MerkleLib.verify(proof, _root, leaf), "Invalid proof");

        _token.transfer(user,amount);
        emit Claimed(user,amount);

    }

    function setRoot(bytes32 root) public onlyAdmin {
        require(root!="", "Invalid root");
        _root = root;
    }

    function setToken(address token) public onlyAdmin {
        require(token!=address(0), "Cannot be address 0");
        _token = IERC20(token);
    }
}
