// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

contract Bank{
    mapping (address => uint) private debt;
    address payable lender;  
    constructor () payable {
        lender = payable(address(this));
    }

    event Borrow(address who, address _from, uint debt, uint _balance);
    event PayBack(address who, address _to, uint debt, uint _balance);

    function lend(address payable borrower, uint money) external payable{
        uint discount = money / 10; // 可以从银行借入零息债券，利率为10%
        require(lender.balance >= money, "Not enough money");
        debt[borrower] += money;
        borrower.transfer(money - discount);
        emit Borrow(borrower, lender, debt[borrower], lender.balance);
    }

    function payBack(address payable borrower, uint money) public payable{
        require(debt[borrower] >= money,  "Don't have to pay that much");
        debt[borrower] -= money;
        emit PayBack(borrower, lender, debt[borrower], lender.balance);
    }

    function showDebt(address payable borrower)external view returns(address, uint){
        return(borrower, debt[borrower]);
    }
    fallback() external{}
    receive() payable external{
        //使得合约可以收款
    }
}

contract Borrower{
    //需要bank合约的地址
    Bank private bank;
    address payable lender;
    constructor(address payable _addr) payable {
        bank = Bank(_addr);
        lender = _addr;
    }

    function borrow(uint money) external payable{
        bank.lend(payable(msg.sender), money);
    }

    function payBack(uint money) external payable {
        lender.transfer(money);
        bank.payBack(payable(msg.sender), money);
    }

    function showDebt() external view returns(address, uint){
        return bank.showDebt(payable(msg.sender));
    }

    function showBalance() external view returns(uint){
        return address(this).balance;
    }
    fallback() external{
    }
    receive() payable external{
    }
}