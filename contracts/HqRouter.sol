// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

// import "./HqPair.sol";

contract HqPair{

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
        require(getPair[token0][token1] == address(0), 'UniswapV2: PAIR_EXISTS'); // single check is sufficient

        bytes memory bytecode = type(HqPair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        // https://eips.ethereum.org/EIPS/eip-1014
        // 通过 create2(endowment, memory_start, memory_length, salt) 来创建新的合约
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
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

    function pairFor(address factory, bytes32 salt) internal view returns (address pair) {
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