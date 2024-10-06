// TronSEA.sol
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "./IERC20.sol";
import "./Roles.sol";
import "./MerkleLib.sol";


/// @title Tron SEA (Safe and Efficient Airdrop) platfrom
/// @author USTX Team

contract TronSEA {
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

	// Events
    event Claimed(address indexed user, uint256 amount);
    event AdminAdded(address indexed account);
    event AdminRemoved(address indexed account);

	/**
	* @dev initializer
	*
	*/
    constructor() {
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

	//Prevents a contract from calling itself, directly or indirectly.
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

    //Verify Merkle proof and leaf reconstruction
    function verify(bytes32[] memory proof, address user, uint256 amount) public view returns(bool){
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(user, amount))));
        return MerkleLib.verify(proof, _root, leaf);
    }

    //Verify Merlke proof, simple version
    function verifySimple(bytes32[] memory proof, bytes32 leaf) public view returns(bool){
        return MerkleLib.verify(proof, _root, leaf);
    }

    /* ========== ACTIONS ========== */

    //User claim function
    function claim(bytes32[] memory proof, uint256 amount) public nonReentrant {
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(msg.sender, amount))));
        require(MerkleLib.verify(proof, _root, leaf), "Invalid proof");

        _token.transfer(msg.sender,amount);
        emit Claimed(msg.sender,amount);

    }

    /* ========== SETTERS ========== */

    //Set Merkle root, onlyAdmin
    function setRoot(bytes32 root) public onlyAdmin {
        require(root!="", "Invalid root");
        _root = root;
    }

    //Set airdrop token, onlyAdmin
    function setToken(address token) public onlyAdmin {
        require(token!=address(0), "Cannot be address 0");
        _token = IERC20(token);
    }

    /* ========== HOUSEKEEPING ========== */

	//Withdraw lost tokens, onlyAdmin. If amount == 0, withdraw all
	function withdrawToken(address tokenAddr, uint256 amount) public onlyAdmin returns(uint256) {
	    require(tokenAddr != address(0), "INVALID_ADDRESS");

		IERC20 token = IERC20(tokenAddr);

		uint256 balance = amount;
		if (amount==0) {
		    balance = token.balanceOf(address(this));
		}

		token.transfer(msg.sender,balance);

		return balance;
	}

    //Withdraw lost TRX, onlyAdmin. If amount == 0, withdraw all
    function withdrawTrx(uint256 amount) public onlyAdmin returns(uint256){
        uint256 balance = amount;
		if (amount==0) {
		    balance = address(this).balance;
		}
		address payable rec = payable(msg.sender);
		(bool sent, ) = rec.call{value: balance}("");
		require(sent, "Failed to send TRX");
		return balance;
    }
}
