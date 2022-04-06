//SPDX-License-Identifier: GPL-3.0
import "./Tokens.sol";

contract ICO is Invade {
    address public manager;
    address payable public deposit; //address at which our investor will deposit ether

    uint256 tokenPrice = 0.1 ether;

    uint256 public cap = 300 ether; //how much amnt of tokens we want in circulation

    uint256 public raisedAmount;

    uint256 public icoStart = block.timestamp;
    uint256 public icoEnd = block.timestamp + 3600; // 1hr=3600sec

    uint256 public tokenTradeTime = icoEnd + 3600;

    uint256 public maxInvest = 10 ether;
    uint256 public minInvest = 0.1 ether;

    enum State {
        beforeStart,
        afterEnd,
        running,
        halted
    }
    State public icoState;

    event Invest(address investor, uint256 value, uint256 tokens);

    constructor(address payable _deposit) payable {
        manager = msg.sender;
        deposit = _deposit;
        icoState = State.beforeStart;
    }

    modifier onlyManager() {
        require(msg.sender == manager);
        _;
    }

    function halt() public onlyManager {
        icoState = State.halted;
    }

    function resume() public onlyManager {
        icoState = State.running;
    }

    function changeDepositAddress(address payable _newDeposit)
        public
        onlyManager
    {
        //for safety measure
        deposit = _newDeposit;
    }

    function getState() public view returns (State) {
        if (icoState == State.halted) {
            return State.halted;
        } else if (block.timestamp < icoStart) {
            return State.beforeStart;
        } else if (block.timestamp >= icoStart && block.timestamp <= icoEnd) {
            return State.running;
        } else {
            return State.afterEnd;
        }
    }

    function invest() public payable returns (bool) {
        //people can invest ether in return ether
        icoState = getState();
        require(icoState == State.running);
        require(msg.value >= minInvest && msg.value <= maxInvest);

        raisedAmount += msg.value;

        require(raisedAmount <= cap);

        uint256 tokens = msg.value / tokenPrice; //investor --> 10 ether then, tokens = 10/0.1 = 100 token
        //from block contract
        balances[msg.sender] += tokens;
        balances[founder] -= tokens;
        deposit.transfer(msg.value);

        emit Invest(msg.sender, msg.value, tokens);
        return true;
    }

    function burn() public returns (bool) {
        icoState = getState();
        require(icoState == State.afterEnd);
        balances[founder] = 0;
        return true;
    }

    function transfer(address to, uint256 tokens)
        public
        override
        returns (bool)
    {
        require(block.timestamp > tokenTradeTime);
        super.transfer(to, tokens); //super will make sure to call transfer function from the parent also can be BLock.trasnfer
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokens
    ) public override returns (bool) {
        require(block.timestamp > tokenTradeTime);
        super.transferFrom(from, to, tokens);
        return true;
    }

    receive() external payable {
        invest();
    }
}
