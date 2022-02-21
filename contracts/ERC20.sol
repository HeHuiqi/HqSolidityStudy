// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/9b3710465583284b8c4c5d2245749246bb2e0094/contracts/token/ERC20/ERC20.sol

// SPDX-License-Identifier: GPL-3.0
// pragma solidity >=0.7.0 <0.9.0;
pragma solidity >=0.4.24;

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address _owner) external view returns (uint256);

    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256);


    //**********2个事件*******
    //1.发生转账时必须要触发的事件,transfer 和 transferFrom 成功执行时必须触发的事件
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    //2.当函数 approve(address _spender, uint256 _value)成功执行时必须触发的事件
    event Approval(address indexed _owner, address indexed _spender,uint256 _value);
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    /**
     * @dev Multiplies two numbers, throws on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
     * @dev Integer division of two numbers, truncating the quotient.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
     * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
     * @dev Adds two numbers, throws on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

contract ERC20 is IERC20{
    using SafeMath for uint256; // 引入库,并指定类型

    string private _name;
    string private _symbol;
    uint256 private _decimals;
    uint256 private _totalSupply;


    mapping(address => uint256) public _balances;
    mapping(address => mapping(address => uint256)) private _allowed;

    constructor(string memory name_, string  memory symbol_, uint256 decimals_, uint256 totalSupply_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _totalSupply = totalSupply_;
    }

    //**********9个函数*******
    //1.代币的名字，如："QQB"
    function name() public virtual returns (string memory) {
        return _name;
    }

    //2.代币的简称，例如：QB
    function symbol() public virtual returns (string memory) {
        return _symbol;
    }

    //3.代币的最小分割量 token使用的小数点后几位。比如如果设置为3，就是支持0.001表示
    function decimals() public virtual returns (uint256) {
        return _decimals;
    }

    //4.token的总量
    function totalSupply() public virtual view override returns (uint256) {
        return _totalSupply;
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function mint(address account, uint256 amount) public {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    //5.余额 返回某个地址(账户)的账户余额
    function balanceOf(address _owner) public virtual view override returns (uint256) {
        return _balances[_owner];
    }

    /*6.转账 交易代币 从消息发送者账户中往_to账户转数量为_value的token，
     从代币合约的调用者地址上转移 _value的数量token到的地址 _to
     【注意：并且必须触发Transfer事件】*/
    function transfer(address _to, uint256 _value) public virtual returns (bool){
        // _balances[msg.sender] -= _value;
        // _balances[_to] += _value;
        // return true;

        require(_value <= _balances[msg.sender]);
        require(_to != address(0));

        _balances[msg.sender] = _balances[msg.sender].sub(_value);
        _balances[_to] = _balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /*7.两个地址转账
    从账户_from中往账户_to转数量为_value的token，与approve方法配合使用
    从地址 _from发送数量为 _value的token到地址 _to
    【注意：并且必须触发Transfer事件】
    transferFrom方法用于允许合约代理某人转移token。条件是from账户必须经过了approve。*/
    function transferFrom(address _from, address _to,uint256 _value) public virtual returns (bool success) {
        // _balances[_from] -= _value;
        // _balances[_to] += _value;
        // return true;

        require(_value <= _balances[_from]);
        require(_value <= _allowed[_from][msg.sender]);
        require(_to != address(0));

        _balances[_from] = _balances[_from].sub(_value);
        _balances[_to] = _balances[_to].add(_value);
        _allowed[_from][msg.sender] = _allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    //8.批准_spender能从合约调用账户中转出数量为_value的token
    function approve(address _spender, uint256 _value) public virtual returns (bool success){
        require(_spender != address(0));

        _allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    //9.获取_spender可以从账户_owner中转出token的剩余数量
    function allowance(address _owner, address _spender) public virtual view override returns (uint256 remaining){
        return _allowed[_owner][_spender];
    }

    /**
        @dev 增加所有者允许给消费者的代币数量。
        allowed_[_spender] == 0 时应调用批准。
        允许值最好使用此函数来避免 2 次调用（并等到
        第一笔交易被挖掘）
        @param _spender 支出者将花费资金的地址。
        @param _addedValue 增加津贴的代币数量。
    */
    function increaseAllowance(address _spender, uint256 _addedValue) public returns (bool){
        require(_spender != address(0));

        _allowed[msg.sender][_spender] = (
            _allowed[msg.sender][_spender].add(_addedValue)
        );
        emit Approval(msg.sender, _spender, _allowed[msg.sender][_spender]);
        return true;
    }
}
