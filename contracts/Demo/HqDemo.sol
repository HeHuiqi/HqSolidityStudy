// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
contract HqDemo{

    struct User{
        uint256 id;
        uint256 age;
        uint256 sex;
    }
    //     "c21eb265": "getUser((uint256,uint256,uint256))"
    // 包含结构结构体参数的方法签名，结构体将转化为tuple类型
    // 调用此方法的时候参数则是将用数组包含所有参数
    // 0xc21eb265000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000001
    function getUser(User calldata u) public pure  returns(uint256){
        return  u.id;
    }

}