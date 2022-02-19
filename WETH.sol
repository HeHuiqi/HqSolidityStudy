// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.16;


interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);
    function transfer(address to, uint amount) external returns (bool);
    function transferFrom(address from, address to, uint amount) external returns (bool);
}
// https://rinkeby.etherscan.io/address/0xc778417e063141139fce010982780140aa0cd5ab#contracts
contract WETH9 is IERC20{
    string private _name;  
    string private _symbol;
    uint8  private _decimals;
    uint private _totalSupply;

    event  Deposit(address indexed to, uint amount);
    event  Withdrawal(address indexed account, uint amount);

    mapping (address => uint)                       public  balanceOf;
    mapping (address => mapping (address => uint))  public  allowance;

    constructor() public{
        _name = "Wrapped Ether";
        _symbol = "WETH";
        _decimals = 18;
        _totalSupply = 200000000*1e18;
        balanceOf[msg.sender] = _totalSupply;
    }

    function()  external payable {
        deposit();
    }
    function mint(address account, uint amount) public {
        balanceOf[account] += amount;
        _totalSupply +=  amount;
        emit Transfer(address(0), account, amount);
    }
    function deposit() public payable {
        balanceOf[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }
    function withdraw(uint amount) public {
        require(balanceOf[msg.sender] >= amount);
        balanceOf[msg.sender] -= amount;
        msg.sender.transfer(amount);
        emit Withdrawal(msg.sender, amount);
    }

    function name() public view returns (string memory){
        return _name;
    }

    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }
    function symbol() public view returns (string memory){
        return _symbol;
    }
    function decimals() public view returns (uint8){
        return _decimals;
    }
    // 向 sender 授权 amount 数量的代币，然后 sender 就可以代替自己 调用 transferFrom
    // 给别人转账了,sender可以是别的钱包地址或合约地址
    function approve(address sender, uint amount) public returns (bool) {
        allowance[msg.sender][sender] = amount;
        emit Approval(msg.sender, sender, amount);
        return true;
    }

    function transfer(address to, uint amount) public returns (bool) {
        return transferFrom(msg.sender, to, amount);
    }
    // 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
    // 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2

    function transferFrom(address from, address to, uint amount)
        public
        returns (bool)
    {
        require(balanceOf[from] >= amount,"transferFrom: from地址 余额不足");
        if (from != msg.sender && allowance[from][msg.sender] != uint(-1)) {
            // msg.sender 为调用这个合约此方法的钱包地址或其地合约地址
            require(allowance[from][msg.sender] >= amount,"transferFrom: from地址 对当前msg.sender地址权转账金额不足");
            allowance[from][msg.sender] -= amount;
        }

        balanceOf[from] -= amount;
        balanceOf[to] += amount;

        emit Transfer(from, to, amount);

        return true;
    }
}

contract HqTranserHelper{


    // 代替from转账，首先from要那个调用token的 approve() 给这个合约授权 >=amount 额度
    function deledateTransferFrom(address token, address from, address to,uint amount) public{
        // 代替form开始转账
        IERC20(token).transferFrom(from,to,amount);
    }
}


