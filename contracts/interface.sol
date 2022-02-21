// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.2 <0.9.0;

interface ParentA {
    function test() external returns (uint256);
}

interface ParentB {
    function test() external returns (uint256);
}

interface SubInterface is ParentA, ParentB {
    // 必须重新定义 test 函数，以表示兼容父合约含义
    function test() external override(ParentA, ParentB) returns (uint256);
}

interface Token {
    enum TokenType { Fungible, NonFungible }
    struct Coin { string obverse; string reverse; }
    function transfer(address recipient, uint amount) external;
}
// 定义在接口或其他类合约（ contract-like）结构体里的类型，可以在其他的合约里用这样的方式访问： Token.TokenType 或 Token.Coin.