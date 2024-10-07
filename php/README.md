# PHP backend support files

**mTree.php -> outputs the hashed Merkle tree**

Data to be encoded is curretly inside the script file but in a production environment should be read from file

The most important part of code to be customized is the leaf hashing function:

```
function hashLeaf($addr,$amount) {
  if(mb_strlen($addr) == 34 && mb_substr($addr, 0, 1) === 'T') {
    $tempadd= Base58Check::decode($addr,0,3);
    if(strlen($tempadd) == 42 && mb_strpos($tempadd, '41') == 0) {
        $hexadd = $tempadd;
    }
  } else {
    $hexadd = bin2hex($addr);
  }
  $hexadd = mb_substr($hexadd,2,40);
  $hexadd = str_pad($hexadd, 64, "0", STR_PAD_LEFT);

  $biga = gmp_init($amount);
  $stra = str_pad(gmp_strval($biga,16), 64, "0", STR_PAD_LEFT);
  $packet = hex2bin($hexadd.$stra);
  $leafhash = Keccak::hash(hex2bin(Keccak::hash($packet,256)),256);

  return $leafhash;
}
```

**mProof.php -> outputs the Merkle proof for a specific user/amount pair (must be in the tree)**

The output is json formatted data including the proof in vector form and the Merkle root that must match the one loaded in the smart contract
