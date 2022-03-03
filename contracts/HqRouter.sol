// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;


contract HqPair{

    address public factory;
    address public token0;
    address public token1;
    constructor() public {
        factory = msg.sender;
    }
     // called once by the factory at time of deployment
    function initialize(address _token0, address _token1) external {
        require(msg.sender == factory, 'UniswapV2: FORBIDDEN'); // sufficient check
        token0 = _token0;
        token1 = _token1;
    }

    function myLockNumber() public pure  returns(uint num){
        return 100;
    }
}
contract HqFactory {
     mapping(address => mapping(address => address)) public  getPair;
     address[] public  allPairs;


        // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
    }

    function createPair(address tokenA, address tokenB) internal returns (address pair, uint num){
        require(tokenA != tokenB, "UniswapV2: IDENTICAL_ADDRESSES");
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        require(token0 != address(0), "UniswapV2: ZERO_ADDRESS");
        require(token1 != address(0), "UniswapV2: ZERO_ADDRESS");
        require(getPair[token0][token1] == address(0), 'UniswapV2-createPair: PAIR_EXISTS'); // single check is sufficient




        // https://eips.ethereum.org/EIPS/eip-1014
        // 方式1：通过 create2(endowment, memory_start, memory_length, salt) 来创建新的合约

        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        bytes memory bytecode = type(HqPair).creationCode;
        // 内嵌汇编
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        HqPair(pair).initialize(token0, token1);


        // 方式2：直接new来创建新的合约
        // pair = address(new HqPair{salt: salt}());

        num = HqPair(pair).myLockNumber();

        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
    }

     function createPair2(address tokenA, address tokenB) internal returns (address pair, uint num){
        require(tokenA != tokenB, "UniswapV3: IDENTICAL_ADDRESSES");
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        require(token0 != address(0), "UniswapV3: ZERO_ADDRESS");
        require(token1 != address(0), "UniswapV3: ZERO_ADDRESS");
        require(getPair[token0][token1] == address(0), 'UniswapV2-createPair2: PAIR_EXISTS'); // single check is sufficient



        // https://eips.ethereum.org/EIPS/eip-1014
        // 方式1：通过 create2(endowment, memory_start, memory_length, salt) 来创建新的合约
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        // bytes memory bytecode = type(HqPair).creationCode;
        // // 内嵌汇编
        // assembly {
        //     pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        // }

        // 方式2：直接new来创建新的合约
        pair = address(new HqPair{salt: salt}());
        HqPair(pair).initialize(token0, token1);

        num = HqPair(pair).myLockNumber();

        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
    }

    /*
        地址 0x0000000000000000000000000000000000000000
        盐 0x0000000000000000000000000000000000000000000000000000000000000000
        初始化代码0x00
        气体（假设没有内存扩展）：32006
        结果：0x4D1A2e2bB4F88F0250f26Ffff098B0b30B26BF38
    */
    /*
        地址 0x00000000000000000000000000000000deadbeef
        盐 0x00000000000000000000000000000000000000000000000000000000cafebabe
        初始化代码 0xdeadbeef
        气体（假设没有内存扩展）：32006
        0x70f2b2914A2a4b783FaEFb75f459A580616Fcb5e
    */

    function pairFor(address factory, bytes32 salt) internal  pure returns (address pair) {
        // keccak256( 0xff ++ address ++ salt ++ keccak256(init_code))[12:]
        // bytes memory rlp = abi.encodePacked(hex"ff",factory,salt,keccak256(hex"00"));
        // bytes memory rlp = abi.encodePacked(hex"ff",adr,salt,keccak256(hex"deadbeef"));

        bytes memory bytecode = type(HqPair).creationCode;
        bytes32 init_code = keccak256(bytecode);
        bytes memory rlp = abi.encodePacked(hex"ff",factory,salt,init_code);

        bytes32  keccak32 = keccak256(rlp);
        uint256  adr256 = uint256(keccak32);
        // address 允许和 uint160、 整型字面常量、bytes20 及合约类型相互转换
        uint160  adr160 = uint160(adr256);
        pair = address(adr160);
    }
    function testCreatePair() public returns(address pair, uint num) {
        address tokenA = 0x0000000000000000000000000000000000000001;
        address tokenB = 0x0000000000000000000000000000000000000002;
        (pair,num) = createPair(tokenA,tokenB);
    }
    function testCreatePair2() public returns(address pair, uint num) {
        address tokenA = 0x0000000000000000000000000000000000000001;
        address tokenB = 0x0000000000000000000000000000000000000002;
        (pair,num) = createPair2(tokenA,tokenB);
    }
    function testPairFor() public view returns(address,uint){
        address factory = address(this);
        address tokenA = 0x0000000000000000000000000000000000000001;
        address tokenB = 0x0000000000000000000000000000000000000002;
        bytes32 salt = keccak256(abi.encodePacked(tokenA, tokenB));
       address adr = pairFor(factory,salt);
       uint  num = HqPair(adr).myLockNumber();
       return (adr,num);
    }
}