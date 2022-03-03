
// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
contract Authorizable is Ownable {
    mapping(address => bool) public authorized;

    modifier onlyAuthorized() {
        require(authorized[msg.sender] || owner() == msg.sender, "caller is not authorized");
        _;
    }

    function addAuthorized(address _toAdd) public onlyOwner {
        authorized[_toAdd] = true;
    }

    function removeAuthorized(address _toRemove) public onlyOwner {
        require(_toRemove != msg.sender);
        authorized[_toRemove] = false;
    }
}

interface IERC20 {
    function mint(address account, uint256 amount) external;
    function burn(address account, uint256 amount) external;
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library SafeMath {
  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    require(c / a == b, 'INVALID_MUL');
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0, 'INVALID_DIV'); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, 'INVALID_SUB');
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, 'INVALID_ADD');
    return c;
  }
}

contract HqToken is IERC20,Ownable,Authorizable {

	using SafeMath for uint256;

	mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalLock; // 锁定总量
    mapping(address => uint256) private _locks;
    mapping(address => uint256) private _lastUnlockBlock;




    uint256 private _totalSupply;

    string public name;
    string public symbol;
    uint8 public decimals;

    event Lock(address indexed to, uint256 value);

    constructor() public {
        name = "HqToken";
        symbol = "HQT";
        decimals = 18;
    }

    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address _addr) public override view returns (uint256) {
        return _balances[_addr];
    }

      // 用户总的余额
    function totalBalanceOf(address _holder) public view returns (uint256) {
        return _locks[_holder].add(balanceOf(_holder));
    }

    // 用户总的锁定量
    function lockOf(address _holder) public view returns (uint256) {
        return _locks[_holder];
    }
        // 总锁定量
    function totalLock() public view returns (uint256) {
        return _totalLock;
    }

    // 由管理员转移用户锁定的token数量的，并标记
    function lock(address _holder, uint256 _amount) public onlyAuthorized {
        require(_holder != address(0), "Cannot lock to the zero address");
        require(
            _amount <= balanceOf(_holder),
            "Lock amount over balance"
        );
        // 如果调用这个方法，需要用户向HqManager授权
        // transferFrom(_holder,address(this),_amount);

        // 而调用此方法没有检查allowance()不需要用户授权
        // 所以由HqManager来分发奖励时，直接将用户锁定部分转移到token此合约当中
        _transfer(_holder,address(this),_amount);


        _locks[_holder] = _locks[_holder].add(_amount);
        _totalLock = _totalLock.add(_amount);
        emit Lock(_holder, _amount);
    }

    // 仅仅有管理员记录用户锁定的token数量
    function lockOnly(address _holder, uint256 _amount) public onlyAuthorized {
        require(_holder != address(0), "Cannot lock to the zero address");
        _locks[_holder] = _locks[_holder].add(_amount);
        _totalLock = _totalLock.add(_amount);
    }

    function allowance(address _owner, address _spender)
        public
        virtual
        override
        view
        returns (uint256)
    {
        return _allowances[_owner][_spender];
    }

     function mint(address account, uint256 amount) public virtual override  onlyOwner{
     	
        require(account != address(0), 'BEP20: mint to the zero address');

        _totalSupply = _totalSupply.add(amount);

        _balances[account] = _balances[account].add(amount);

        emit Transfer(address(0), account, amount);
    }

    function burn(address account, uint256 amount) public virtual override  {

        _balances[account] = _balances[account].sub(amount);

        _totalSupply = _totalSupply.sub(amount);

        emit Transfer(account, address(0), amount);
    }

    function approve(address _spender, uint256 _amount)
        public
        virtual
        override
        returns (bool)
    {
        require(_spender != address(0), "INVALID_SPENDER");

        _allowances[msg.sender][_spender] = _amount;

        emit Approval(msg.sender, _spender, _amount);

        return true;
    }

    function _transfer(address _from, address _to, uint256 _amount) internal returns(bool){
        require(_amount > 0, 'INVALID_AMOUNT');
        require(_balances[_from] >= _amount, 'INVALID_BALANCE');

        _balances[_from] = _balances[_from].sub(_amount);
        _balances[_to]   = _balances[_to].add(_amount);
        /*------------------------ emit event ------------------------*/
        emit Transfer(_from, _to, _amount);
        /*----------------------- response ---------------------------*/
        return true;
    }

    function transfer(address _to, uint256 _amount)
        public
        virtual
        override
        returns (bool)
    {
        
        // require(_amount > 0, 'INVALID_AMOUNT');
        // require(_balances[msg.sender] >= _amount, 'INVALID_BALANCE');

        // _balances[msg.sender] = _balances[msg.sender].sub(_amount);
        // _balances[_to]        = _balances[_to].add(_amount);
        // /*------------------------ emit event ------------------------*/
        // emit Transfer(msg.sender, _to, _amount);
        // /*----------------------- response ---------------------------*/
        // return true;

        return _transfer(msg.sender,_to,_amount);
        
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) public virtual override returns (bool) {
        require(_amount > 0, 'INVALID_AMOUNT');
        require(_balances[_from] >= _amount, 'INVALID_BALANCE');
        require(_allowances[_from][msg.sender] >= _amount, 'transferFrom: INVALID_PERMISTION 没有授权或授权额度不够');
        _allowances[_from][msg.sender] = _allowances[_from][msg.sender].sub(_amount);

        // _balances[_from]    = _balances[_from].sub(_amount);
        // _balances[_to]      = _balances[_to].add( _amount);
        // /*------------------------ emit event ------------------------*/
        // emit Transfer(_from, _to, _amount);
        // /*----------------------- response ---------------------------*/
        // return true;

        return _transfer(_from,_to,_amount);
    }
}

contract HqManager is Ownable, Authorizable{
    using SafeMath for uint256;
    HqToken public token;
    uint256 public rewardCap = 10000000*1e18; //奖励上限
    uint256 public mintedRewardTotal; //已经铸造奖励
    constructor(HqToken _token) public{
        token = _token;
    }

    function managerBalance() public view returns(uint256) {
        return token.balanceOf(address(this));
    }
    function restCanMintReward() public view returns(uint256){
        return rewardCap - mintedRewardTotal;
    }
    function mintReward(uint256 amount) public {
        uint256 _restCanMintReward = restCanMintReward();
        require(amount <= _restCanMintReward, "铸造的奖励不能大于 restCanMintReward");
        token.mint(address(this),amount);
        mintedRewardTotal = mintedRewardTotal.add(amount);
    }

    // 释放奖励方式1
    function dispatchRewardToUser(uint256 amount) public {

        // 管理员将用户所有奖励转给用户
        token.transfer(msg.sender,amount);

        uint256 lockPecent = 25;
        uint256 lockAmount = amount.mul(lockPecent).div(100);

        // 将锁定部分转给token,token内部会将用户的锁定部分的奖励转到token中
        token.lock(msg.sender, lockAmount);
        
    }

    function dispatchRewardToUser2(uint256 amount) public {
        
        uint256 lockPecent = 25;
        uint256 lockAmount = amount.mul(lockPecent).div(100);
        uint256 unlockAmount = amount.sub(lockAmount);

        // 管理员直接将用户解锁部分转给用户
        token.transfer(msg.sender,unlockAmount);
        // 将用户奖励的锁定部分转移给token
        token.transfer(address(token),lockAmount);
        // 记录(标记)用户奖励的锁定部分
        token.lockOnly(msg.sender, lockAmount);

        
    }
    // 返还token的owner权限
    function reclaimTokenOwnership(address _newOwner) public onlyAuthorized() {
        token.transferOwnership(_newOwner);
    }
}

/*
部署步骤
1. 部署HqToken
2. 使用HqToken的地址部署HqManager
3. 调用HqToken的transferOwnership(HqManager_address)给HqManager授权铸造奖励的权限

使用：
1. 首先调用HqManager的mintReward()铸造奖励
2. 然后调用HqManager的dispatchRewardToUser1()或dispatchRewardToUser2()来分发奖励
3. 当奖励铸造到上限并完成分发，调用HqManager的reclaimTokenOwnership()返还权限
*/