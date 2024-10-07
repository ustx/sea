<?php
require_once("vendor/autoload.php");
use IEXBase\TronAPI\Support\{Base58Check, BigInteger, Keccak};

//json data can be read from file
$ljson = '[
  {"user":"TJHYbk7q2EuMJJZeEF6cxPBEDg9kG1sR1j","amount":"100000000"},
  {"user":"TRc7JCUtMopM3sADYDj5KUBhzD1K3q1JsR","amount":"200000000"},
  {"user":"TGpSjS9wg4tJRVv69bnCJCq9mGAmkMaSFC","amount":"300000000"},
  {"user":"TLx5zMUwqcTu9iUmqpZsFMCRnNA2c1cAxt","amount":"400000000"},
  {"user":"TJriuKLDcDjHrKUZvaoQvX84zLT2vy5GJv","amount":"500000000"},
  {"user":"TAPobz7nvpNBJcqwv6zenuSGwscd47ToaN","amount":"500000000"},
  {"user":"TKWmf2LbTjS4esYd1XfbZi5FWsZfrAphPX","amount":"600000000"}
]';

$leavesraw=json_decode($ljson);
$leaveshash=array();


try {
      foreach ($leavesraw as $l) {

        $leafhash= hashLeaf($l->user,$l->amount);
        array_push($leaveshash,$leafhash);
      }

      sort($leaveshash);
      $numl = count($leavesraw);

      $levels = ceil(log($numl,2));

      $startidx = 0;
      $prev=$numl;
      $levelc = array($prev);
      $leveli = array();
      for ($i=0;$i<$levels;$i++){
        $startidx += ceil($prev/2);
        $prev = ceil($prev/2);
        array_push($levelc,$prev);
      }
      $startidx += 1;
      sort($levelc);
      $leveli = array();
      for ($i=0;$i<$levels;$i++){
        $leveli[$i]=pow(2,$i);
      }
      array_push($leveli,$startidx);
      $tree = array();
      $tree = array_pad($tree,$startidx+$numl,"");

      for ($i=0;$i<$numl;$i++){
        $tree[$i+$startidx]=$leaveshash[$i];
      }

      for ($k=$levels;$k>0;$k--){
        for ($i=0;$i<$levelc[$k];$i+=2){
          $idx=($leveli[$k]+$i);
          if ($idx+1<$levelc[$k]+$leveli[$k]){
            //Commutative hash
            if (hex2bin($tree[$idx])<hex2bin($tree[$idx+1])){
              $tree[ceil($idx/2)]=Keccak::hash(hex2bin($tree[$idx].$tree[$idx+1]), 256);
            } else {
              $tree[ceil($idx/2)]=Keccak::hash(hex2bin($tree[$idx+1].$tree[$idx]), 256);
            }
          } else {
            $tree[ceil($idx/2)]=$tree[$idx];
          }
        }
      }

      echo json_encode($tree);


} catch (Exception $e) {
    echo $e->getMessage();
}

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

?>
