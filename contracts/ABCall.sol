// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.4.0 <0.9.0;

contract A {
    int256 public x;

    function inc_call(address _contractAddress) public returns (bool success, bytes memory returnData) {
        //函数签名
        bytes4 inc_4 = bytes4(keccak256("inc()"));
        //仅获取函数签名
        bytes memory inc = new bytes(4);
        for (uint256 i = 0; i < 4; i++) {
            inc[i] = inc_4[i];
        }
        //encodeWithSelector(bytes,args....)
        //传递参数就增加参数，可将函数签名和参数一起编码
        bytes memory f = abi.encodeWithSelector(inc_4);
        //call 只接收bytes类型的参数
        //这里是直接调用B合约的inc()函数，改变的也是B合约的值
        return _contractAddress.call(f);



        //仅用于无参数的函数，如本例子
        // return _contractAddress.call(inc);

        // bytes memory payload = abi.encodeWithSignature("inc()");
        //  return _contractAddress.call(payload);
    }

    function inc_callcode(address _contractAddress) public returns (bool success, bytes memory returnData){
        //encodeWithSignature(string,args....)
        //传递参数就增加参数，可将函数签名和参数一起编码
        bytes memory payload = abi.encodeWithSignature("inc()");
        //改变是本合约的x的值，只是用了B合于的inc()函数而已
        return _contractAddress.delegatecall(payload);
    }

    function inc_call_value(address _contractAddress, int256 _value)
        public
        returns (bool success, bytes memory returnData)
    {
        //encodeWithSignature(string,args....)
        //传递参数就增加参数，可将函数签名和参数一起编码，注意这里函数的签名
        //多个参数使用,隔开 如:inc3(int256,string)
        bytes memory payload = abi.encodeWithSignature("inc2(int256)", _value);
        //改变是B合约的x的值，传递_value参数
        return _contractAddress.call(payload);
    }
}

contract B {
    int256 public x;

    function inc() public {
        x++;
    }

    function inc2(int256 value) public {
        x += value;
    }
}

library L {
    function f(uint256) external {}
}

contract C {
    function g() public pure returns (bytes4) {
        //库函数签名 selector 属性
        return L.f.selector;
    }

    function a() public pure returns (bytes4) {
        //函数签名，这里返回和b返回相同
        return bytes4(keccak256("g()"));
    }

    function b() public pure returns (bytes4) {
        //合约函数签名 selector 属性
        return this.g.selector;
    }

    function c() public returns (bool, bytes memory) {
        bytes4 payload = this.b.selector;

        bytes memory func = new bytes(4);
        for (uint256 i = 0; i < 4; i++) {
            func[i] = payload[i];
        }
        //调用b()函数
        // return address(this).call(func);
        
        //调用方式2
        bytes memory fn = abi.encodeWithSelector(payload);
       return address(this).call(fn);
    }
}
