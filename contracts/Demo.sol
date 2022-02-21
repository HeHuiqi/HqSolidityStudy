// SPDX-License-Identifier: GPL-3.0
pragma solidity  >=0.7.0 <0.9.0;

contract Demo{

    // 可见性标识符的定义位置，
    // 对于状态变量来说是在类型后面
    // 对于函数是在参数列表和返回关键字中间

    //编译器自动为所有 public 状态变量创建 getter 函数
    // 如下会生成一个 function nickname() public view returns(string memory){ return nickname; } 方法
    string public nickname;
    

    function hello() external pure returns(string memory){
        return "hello";
    }

    function toHello() internal view returns(string memory) {
        //外部函数要使用this调用
       return this.hello();
    }

}