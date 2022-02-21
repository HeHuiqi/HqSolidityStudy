// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
// 在 0.7.0 版本之前, 你需要通过 internal 或 public 指定构造函数的可见性。

contract owned {
    constructor() { owner = payable(msg.sender); }
    address owner;
}

contract Destructible is owned {
    function destroy() public virtual {
        if (msg.sender == owner) selfdestruct(payable(owner));
    }
}

contract Base1 is Destructible {
    function destroy() public virtual override  { /* 清除操作 1 */ super.destroy(); }
}

contract Base2 is Destructible {
    function destroy() public virtual override { /* 清除操作 2 */ super.destroy(); }
}

contract Final is Base1, Base2 {
    function destroy() public override(Base1, Base2) { super.destroy(); }
}