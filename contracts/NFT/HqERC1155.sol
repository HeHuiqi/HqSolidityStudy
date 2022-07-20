
// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
contract HqERC1155 {
    
    // @dev Mapping from owner to list of owned token IDs.
    mapping(address => uint256[])  private  _ownedTokens;
    // @dev Mapping from token ID to owner.
    mapping(uint256 => address) private _tokenOwner;

    function addTokenIdToOwner(address owner,uint256 tokenId) public {
        (,bool suc) = getOwnerTokenIdIndex(tokenId);
        require(suc == false,"addTokenIdToOwner: tokenid is  exist!");
        _ownedTokens[owner].push(tokenId);
        _tokenOwner[tokenId] =  owner;
    }
    function getOwnerTokenIdIndex(uint256 tokenId) public view returns(uint256 index,bool exist){
        uint256 len = _ownedTokens[msg.sender].length;
        for(uint256 i = 0; i < len; i++){
            if(_ownedTokens[msg.sender][i] == tokenId){
                index = i; exist = true;
                return (index,exist);
            }
        }
        return (index,exist);

    }
    function deleteOwnerTokenId(uint256 tokenId) public {
        (uint256 index,bool suc) = getOwnerTokenIdIndex(tokenId);
        require(suc == true,"deleteOwnerTokenId: tokenid is not exist!");
        deleteOneOwnerTokenIdByIndex(index);
    }
    function deleteOneOwnerTokenIdByIndex(uint256 index) public {

        require(_ownedTokens[msg.sender][index] != 0," deleteOneOwnerTokenIdByIndex: tokenid is not exist!");
        uint256 len = _ownedTokens[msg.sender].length;
        uint256 tokenId;
        if( len == 1){
            tokenId = _ownedTokens[msg.sender][0];
            _ownedTokens[msg.sender].pop();

        }else{
            tokenId = _ownedTokens[msg.sender][index];
            // 将最后一个元素复制到此位置
            _ownedTokens[msg.sender][index] = _ownedTokens[msg.sender][len-1];
            // 删除最后一个元素
            _ownedTokens[msg.sender].pop();

        }
        _tokenOwner[tokenId] = address(0);
    }
 
    function getMyOwnerTokenIds() public view returns(uint256[] memory){
        return _ownedTokens[msg.sender];
    }
    function getOwnerTokenIds(address owner) public view returns(uint256[] memory){
        return _ownedTokens[owner];
    }
    function ownerOf(uint256 tokenId) public view returns(address){
        return _tokenOwner[tokenId];
    }

}
