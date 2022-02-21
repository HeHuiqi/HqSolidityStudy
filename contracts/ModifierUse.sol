// SPDX-License-Identifier: GPL-3.0
pragma solidity >0.7.0 <0.9.0;

contract owned {
    constructor() {
         owner = payable(msg.sender); 
    }

    address owner;

    // 这个合约只定义一个修改器，但并未使用： 它将会在派生合约中用到。
    // 修改器所修饰的函数体会被插入到特殊符号 _; 的位置。
    // 这意味着如果是 owner 调用这个函数，则函数会被执行，否则会抛出异常。
    // 其实相当于给函数调用者限制了条件
    modifier onlyOwner {
        require(
            msg.sender == owner,
            "Only owner can call this function."
        );
        _;
    }
}

contract destructible is owned {
    // 这个合约从 `owned` 继承了 `onlyOwner` 修饰符，并将其应用于 `destroy` 函数，
    // 只有在合约里保存的 owner 调用 `destroy` 函数，才会生效。
    function destroy() public onlyOwner {
        selfdestruct(payable(owner));
    }
}

contract priced {
    // 修改器可以接收参数：
    modifier costs(uint price) {
        if (msg.value >= price) {
            _;
        }
    }
}

contract Register is priced, destructible {
    mapping (address => bool) registeredAddresses;
    uint price;

    constructor(uint initialPrice) { price = initialPrice; }

    // 在这里也使用关键字 `payable` 非常重要，否则函数会自动拒绝所有发送给它的以太币。
    function register() public payable costs(price) {
        registeredAddresses[msg.sender] = true;
    }

    function changePrice(uint _price) public onlyOwner {
        price = _price;
    }
}

contract Mutex {
    bool locked;
    modifier noReentrancy() {
        require(
            !locked,
            "Reentrant call."
        );
        locked = true;
        _;
        locked = false;
    }

    // 这个函数受互斥量保护，这意味着 `msg.sender.call` 中的重入调用不能再次调用  `f`。
    // `return 7` 语句指定返回值为 7，但修改器中的语句 `locked = false` 仍会执行。
    function f() public noReentrancy returns (uint) {
        (bool success,) = msg.sender.call("");
        require(success);
        return 7;
    }
}