// SPDX-License-Identifier: MIT

// Deployed at 0xC4cBB6561EC3ad224157F261c4053E7d66Ba2FD4 on Goerli Testnet Network
// Recipient 0x0aa6Fd75BC5fc9bC18591b3644eDe5C435aA165e
// Birthday date : 05/14/2021 | contributors : 1

pragma solidity ^0.8.0;
    
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";
    
contract Birthday {
    // library usage
    using Address for address payable;
    
    // State variables
    address private _recipient;
    uint256 private _gift;
    uint256 private _contributions;
    mapping (address => bool) private _contributors;
    uint256 private _birthdayDate;
    
    // Events
    event Contribution(address indexed recipient_,address contributor_,uint256 amount);

    // Constructor
    constructor (address recipient_,uint256 year,uint256 month,uint256 day){
        _birthdayDate = _humanReadDateTime(year,month,day);
        require(_birthdayDate > block.timestamp,"Birthday: This date is already passed.");
        _recipient = recipient_;
    }
    
    // Modifiers
    modifier afterDay (){
        require(block.timestamp >= _birthdayDate, "Birthday: You have to wait your birthday to withdraw your present.");
        _;
    }
    
    modifier onlyRecipient (){
        require(msg.sender == _recipient, "Birthday: You are not the recipient of this present.");
        _;
    }
    
    // Function declarations
    receive()external payable {
        _deposit(msg.value);
    }
    
    function offer() external payable{
        _deposit(msg.value);
    }
    
    function getPresent() public onlyRecipient afterDay {
        require (_gift !=0,"Birthday: Sorry, nobody have done any contributions for your present..");
        _gift = 0;
        payable(msg.sender).sendValue(address(this).balance);
    }
    
    function present() public view returns(uint256){
        return  _gift;
    }
    
    function nbContributors() public view returns(uint256){
        return _contributions;
    }
    
    function timeBeforeBirthday() public view returns(uint256){
        return _birthdayDate - block.timestamp;
    }
    
    
    function _deposit(uint256 amount) private {
        if (_contributors[msg.sender] == false){
            _contributions ++;
            _contributors[msg.sender] == true;
        }
        _gift += amount;
        emit Contribution(_recipient,msg.sender,amount);
    }
    
    function _humanReadDateTime(uint256 year,uint256 month, uint256 day) private pure returns (uint256){
        require(year > 1970 && month <= 12 && day <= 31,"Birthday: wrong input in the date");
        return ((year - 1970)*31556926) + (2629743*(month - 1) + (86400*(day - 1)) + 36000);
    }
}