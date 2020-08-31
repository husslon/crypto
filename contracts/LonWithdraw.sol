pragma solidity ^0.4.24;

import './LonToken.sol';

contract LonWithdraw {

  struct Withdrawal {
    address requester;
    uint256 user_guid;
    uint256 gas;
    uint256 amount;
  }

  LonToken public token;
 
  mapping(uint256 => Withdrawal) public requests;

  /**
   * event upon requesting a withdrawal
   * @param requester who requested the withdrawal
   * @param user_guid the lon user guid of the requester
   * @param gas the amount in ethereum that was sent to cover the gas
   * @param amount weis requested
   */
  event WithdrawalRequest(address requester, uint256 user_guid, uint256 gas, uint256 amount);

  /**
   * event upon completing a withdrawal
   * @param requester who requested the withdrawal
   * @param user_guid the lon user guid of the requester
   * @param amount weis requested
   */
  event WithdrawalComplete(address requester, uint256 user_guid, uint256 amount);

  constructor(address _token) public {
    token = LonToken(_token);
  }

  function request(uint256 user_guid, uint256 amount) public payable {
    
    uint256 gas = msg.value;

    require(gas > 0);
    require(amount > 0);

    Withdrawal memory _withdrawal = Withdrawal(
      msg.sender,
      user_guid,
      msg.value,
      amount
    );
    
    requests[user_guid] = _withdrawal;

    emit WithdrawalRequest(msg.sender, user_guid, msg.value, amount);
  }

  // do nothing if we get sent ether
  function() external payable { 
    msg.sender.transfer(msg.value);
  }

  function complete(address requester, uint256 user_guid, uint256 gas, uint256 amount) public returns (bool) {
    
    require(requests[user_guid].user_guid == user_guid);
    require(requests[user_guid].gas == gas);
    require(requests[user_guid].amount == amount);

    token.transferFrom(msg.sender, requester, amount);

    emit WithdrawalComplete(requester, user_guid, amount);
    
    //zero the requested withdrawl amaount
    requests[user_guid].amount = 0;

    return true;
  }

}
