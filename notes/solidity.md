函数声明为`view`类型，这种情况下要保证不修改状态.
下面的语句被认为是修改状态：
1. 修改状态变量。
2. 产生事件。
3. 创建其它合约。
4. 使用`selfdestruct`。
5. 通过调用发送以太币。
6. 调用任何没有标记为 `view` 或者 `pure` 的函数。
7. 使用低级调用。
8. 使用包含特定操作码的内联汇编。

Pure 纯函数
函数可以声明为 `pure` ，在这种情况下，承诺不读取也不修改状态。
以下被认为是读取状态：
1. 读取状态变量。
2. 访问 `address(this).balance` 或者 `<address>.balance`。
3. 访问 `block`，`tx`， `msg` 中任意成员 （除 `msg.sig` 和 `msg.data` 之外）。
4. 调用任何未标记为 `pure` 的函数。
5. 使用包含某些操作码的内联汇编。
纯函数能够使用 `revert()` 和 `require()` 在 发生错误 时去还原潜在状态更改。

receive 接收以太函数
一个合约最多有一个 `receive` 函数, 声明函数为： `receive() external payable { ... }`

不需要 `function` 关键字，也没有参数和返回值并且必须是　`external`　可见性和　`payable` 修饰． 它可以是 `virtual` 的，可以被重载也可以有修改器`modifier` 。

在对合约没有任何附加数据调用（通常是对合约转账）是会执行 `receive` 函数．　例如　通过 `.send()` or `.transfer()` 如果 `receive` 函数不存在，　但是有`payable`　的 `fallback` 回退函数 那么在进行纯以太转账时，`fallback` 函数会调用．如果两个函数都没有，这个合约就没法通过常规的转账交易接收ETH（会抛出异常)

Fallback 回退函数
合约可以最多有一个回退函数。函数声明为： `fallback () external [payable]` 或 `fallback (bytes calldata _input) external [payable] returns (bytes memory _output)`

没有`function`关键字。　必须是`external`可见性，它可以是`virtual` 的，可以被重载也可以有 修改器`modifier` 。

如果在一个对合约调用中，没有其他函数与给定的函数标识符匹配 `fallback`会被调用． 或者在没有`receive`函数　时，而没有提供附加数据对合约调用，那么`fallback` 函数会被执行。

`fallback`函数始终会接收数据，但为了同时接收以太时，必须标记为`payable` 。

如果使用了带参数的版本，_input 将包含发送到合约的完整数据（等于 `msg.data` ），并且通过` _output` 返回数据。返回数据不是ABI 编码过的数据，它返回原始数据。

事件Events
Solidity 事件是EVM的日志功能之上的抽象。 应用程序可以通过以太坊客户端的RPC接口订阅和监听这些事件。
事件签名的哈希值是一个 主题topic。
对于匿名事件无法通过名字来过滤。您可以仅按合约地址过滤。 匿名事件的优势是他们部署和调用的成本更低。


接口
接口类似于抽象合约，但是它们不能实现任何函数。还有进一步的限制：

* 无法继承其他合约,不过可以继承其他接口。
* 所有的函数都需要是 external
* 无法定义构造函数。
* 无法定义状态变量。

