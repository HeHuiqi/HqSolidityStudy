// SPDX-License-Identifier: GPL-3.0
pragma solidity >0.7.4;
uint constant X = 32**22 + 8;

// 也可以在文件级别定义 constant 变量（注：0.7.2 之后加入的特性）。

contract C {

    // constant 或 immutable， 目前仅支持字符串或值类型

    // constant 编译时确定值
    // immutable 部署时确定值

    string constant TEXT = "abc";
    bytes32 constant MY_HASH = keccak256("abc");
  
    uint immutable decimals;
    uint immutable maxBalance;
    address immutable owner = msg.sender;

    constructor(uint _decimals, address _reference) {
        decimals = _decimals;
        // Assignments to immutables can even access the environment.
        maxBalance = _reference.balance;
    }

    function isBalanceTooHigh(address _other) public view returns (bool) {
        return _other.balance > maxBalance;
    }
}