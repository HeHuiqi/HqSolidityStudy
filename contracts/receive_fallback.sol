// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.6.2 <0.9.0;

contract Test {
    // 发送到这个合约的所有消息都会调用此函数（因为该合约没有其它函数）。
    // 向这个合约发送以太币会导致异常，因为 fallback 函数没有 `payable` 修饰符
    fallback() external { x = 1; }
    uint x;
}


// 这个合约会保留所有发送给它的以太币，没有办法返还。
contract TestPayable {
    // 除了纯转账外，所有的调用都会调用这个函数．
    // (因为除了 receive 函数外，没有其他的函数).
    // 任何对合约非空calldata 调用会执行回退函数(即使是调用函数附加以太).
    fallback() external payable { x = 1; y = msg.value; }

    // 纯转账调用这个函数，例如对每个空empty calldata的调用
    receive() external payable { x = 2; y = msg.value; }
    uint x;
    uint y;
}

contract Caller {
    function callTest(Test test) public returns (bool) {
        (bool success,) = address(test).call(abi.encodeWithSignature("nonExistingFunction()"));
        require(success);
        //  test.x 结果变成 == 1。

        // address(test) 不允许直接调用 ``send`` ,  因为 ``test`` 没有 payable 回退函数
        //  转化为 ``address payable`` 类型 , 然后才可以调用 ``send``
        address payable testPayable = payable(address(test));


        // 以下将不会编译，但如果有人向该合约发送以太币，交易将失败并拒绝以太币。
        // test.send(2 ether）;
    }

    function callTestPayable(TestPayable test) public returns (bool) {
        (bool success,) = address(test).call(abi.encodeWithSignature("nonExistingFunction()"));
        require(success);
        // 结果 test.x 为 1  test.y 为 0.
        (success,) = address(test).call{value: 1}(abi.encodeWithSignature("nonExistingFunction()"));
        require(success);
        // 结果test.x 为1 而 test.y 为 1.

        // 发送以太币, TestPayable 的 receive　函数被调用．
        require(payable(test).send(2 ether));
        // 结果 test.x 为 2 而 test.y 为 2 ether.

        return true;
    }

}