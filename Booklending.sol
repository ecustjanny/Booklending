/**
	@Description:   coontract  code for Book lending project 
	图书服务包含两方：借出者和借入者。
	借出者发布当前书可以借出状态，借入者点击该书请求借阅。
	借出者可以点评该书（1-5星）。
    线下交书（线下当面，放在线下书柜中，并将箱子号码及密码发给借阅者，或者快递等）
	借阅者拿到书籍后，确认数据完好，点击确认，交易完成；或者发现书本有破损，拒绝借阅。
	（借出者拿到拒绝的书籍向图书馆发起还书或者回收请求。图书馆完成后续处理。不在这里实现）
 
	* @author          Janny (yonglin_guo@hotmail.com)
	* @version         V1.0  
	* @Date            04/02/2020
 */ 

//这里指明solidity 编译版本。
pragma solidity >=0.4.22 <0.6.4;

contract Booklending {
    
	//读者对该书的点评（1-5星）
	uint public score;
	//借出者	
    address public lender;
	//借入者
    address public borrower;
	// 图书状态：请求借出，借出过程中，借出已完成，借出已失效
    enum State { Created, Locked, Release, Inactive }
    // The state variable has a default score of the first member, `State.created`
    State public state;

    modifier condition(bool _condition) {
        require(_condition);
        _;
    }

    modifier onlyLender() {
        require(
            msg.sender == lender,
            "借出者账号错误."
        );
        _;
    }

    modifier onlyBorrower() {
        require(
            msg.sender == borrower,
            "借入者账号错误."
        );
        _;
    }

    modifier inState(State _state) {
		
        require(
            state == _state,
            "图书状态不正确。"
        );
		//下划线_是一个占位符，代表了执行函数接下来的代码。
        _;
    }

 	//定义一些事件，前端页面上可以使用Web3监听事件，更新页面展示的信息。
	event Aborted();
    event BorrowingConfirmed();
    event ItemReceived();
    event LenderRefunded();

    constructor() public payable {
        lender = msg.sender;
     }
 	function setInfo(uint _score) 
		public 
		onlyLender 
		payable  {
		score = _score;
   }
	
	// 中止 “可借出状态”.
    function abort() public 
        onlyLender
        inState(State.Created)
    {
        emit Aborted();
        state = State.Inactive;
    }

    // 借入人提交了借阅请求.
    function confirmBorrowing()
        public
        inState(State.Created)
         payable
    {
        emit BorrowingConfirmed();
        borrower = msg.sender;
        state = State.Locked;
    }

    // 接入者确认收到书本，完成借阅过程.
     function confirmReceived()
        public
        onlyBorrower
        inState(State.Locked)
    {
        emit ItemReceived();
        state = State.Release;
    }

    //借入者拒绝，回退结束请求
    function refundLender()
        public
        onlyLender
        inState(State.Release)
    {
        emit LenderRefunded();
        state = State.Inactive;
    }
}