// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract HqMusic {

    string[] public allMusics;
    uint public playIndex;

    function musicCount() public view returns(uint){
        return allMusics.length;
    }
    function getPlayMusicName() public view returns(string memory){
        require(playIndex < allMusics.length,"no music,please add music");
        return allMusics[playIndex];
    }
    function playMusic(uint index) public  returns(string memory){
        require(index < allMusics.length,"no music,please add music to play");
        playIndex = index;
        return allMusics[playIndex];
    }
    function addMusic(string memory name) public returns(uint){
        allMusics.push(name);
        return allMusics.length;
    }

}