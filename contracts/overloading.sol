// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;

contract A {
    function f(uint256 _in) public pure returns (uint256 out) {
        out = _in;
    }
    //函数重载，函数名相同，参数个数不同
    function f(uint256 _in, bool _really) public pure returns (uint256 out) {
        if (_really) out = _in;
    }
}


// 除接口之外（因为接口会自动作为 virtual ），没有实现的函数必须标记为 virtual
contract Base{
    // 如果函数没有标记为 virtual ， 那么派生合约将不能更改函数的行为（即不能重写）
    // 如果这里的foo()没有标记 virtual ，则子类无法重载这个方法
    function foo() virtual external view {}
}
contract Middle is Base {}
contract Inherited is Middle
{   //重载父类方法
    function foo() override public pure {}
}

contract Base1{
    function foo() virtual public {}
}

contract Base2{
    function foo() virtual public {}
}

// 对于多重继承，如果有多个父合约有相同定义的函数， override 关键字后必须指定所有父合约
contract Inherited2 is Base1, Base2
{
    // 继承自两个基类合约定义的foo(), 必须显示的指定 override
    function foo() public override(Base1, Base2) {}
}
