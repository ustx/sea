# Tron SEA public repository

**Contracts -> Solidity smart contracts**

**PHP -> PHP code to implement the tree and Merkle proof generation**

mTree.php -> creates the Merkle tree of the following distribution

`[
  {"user":"TJHYbk7q2EuMJJZeEF6cxPBEDg9kG1sR1j","amount":"100000000"},
  {"user":"TRc7JCUtMopM3sADYDj5KUBhzD1K3q1JsR","amount":"200000000"},
  {"user":"TGpSjS9wg4tJRVv69bnCJCq9mGAmkMaSFC","amount":"300000000"},
  {"user":"TLx5zMUwqcTu9iUmqpZsFMCRnNA2c1cAxt","amount":"400000000"},
  {"user":"TJriuKLDcDjHrKUZvaoQvX84zLT2vy5GJv","amount":"500000000"},
  {"user":"TAPobz7nvpNBJcqwv6zenuSGwscd47ToaN","amount":"500000000"},
  {"user":"TKWmf2LbTjS4esYd1XfbZi5FWsZfrAphPX","amount":"600000000"}
]`

returns the hased Merkle tree

mProof.php -> creates the Merkle proof for a specific user/amount pair

e.g. mProof.php?user=TGpSjS9wg4tJRVv69bnCJCq9mGAmkMaSFC&amount=300000000

returns the Merkle proof and root for the input pair

*More details in the README.md inside php and contracts folder*

*Requirements for php code execution IEXbase Tron php API https://github.com/iexbase/tron-api*
