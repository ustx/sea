# Tron SEA solidity implementation

**TronSEA.sol -> main contract to verify Merkle proof and distribute tokens**

What to edit to adapt to specific project: *verify* and *claim* functions
```
//Verify Merkle proof and leaf reconstruction
function verify(bytes32[] memory proof, address user, uint256 amount) public view returns(bool){
    bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(user, amount))));
    return MerkleLib.verify(proof, _root, leaf);
}

//User claim function, caller is the recipient
function claim(bytes32[] memory proof, uint256 amount) public nonReentrant {
    require(!isClaimed[msg.sender], 'Already claimed.');
    bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(msg.sender, amount))));
    require(MerkleLib.verify(proof, _root, leaf), "Invalid proof");
    
    _token.transfer(msg.sender,amount);
    isClaimed[msg.sender] = true;
    emit Claimed(msg.sender,amount);
    
} 
    
//User claim function, third party recipient
function claim(bytes32[] memory proof, address user, uint256 amount) public nonReentrant {
    require(!isClaimed[user], 'Already claimed.');
    bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(user, amount))));
    require(MerkleLib.verify(proof, _root, leaf), "Invalid proof");
    
    _token.transfer(user,amount);
    isClaimed[user] = true;
    emit Claimed(user,amount);
    
}
```

**The keccak256 hash MUST match what is defined in the hashLeaf() function**
