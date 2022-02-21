// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.9.0;

//抽象合约
// Feline 猫科
abstract contract Feline {
    //未实现的方法要标记 virtual
  function utterance() public virtual pure returns (bytes32);
}

contract Cat is Feline {
    //实现父类的方法除了标记 virtual 还要 标记 override
  function utterance() public virtual override pure returns (bytes32) { return "miaow"; }
}

// 如果合约继承自抽象合约，并且没有通过重写来实现所有未实现的函数， 它依然需要标记为抽象 abstract 合约.
abstract contract Tiger is Feline{
        //未实现的方法要标记 virtual
  function utterance() public virtual override pure returns (bytes32);
}