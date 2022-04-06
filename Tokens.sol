// SPDX-License-Identifier: MIT

//rinkeby test net 0x58EefE0e4A210Dd9cb4f9Ef724B460fc4B8f2050 contract address
pragma solidity >=0.5.0 <0.9.0;

interface ERC20Interface {
    function totalSupply() external view returns (uint256);

    function balanceOf(address tokenOwner) external view returns (uint256);

    function transfer(address recipient, uint256 tokens)
        external
        returns (bool);

    function allowance(address tokenOwner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 tokens) external returns (bool);

    function transferFrom(
        address from,
        address recipient,
        uint256 tokens
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 tokens
    );
}

//creating contract for the token names = "Invade"
contract Invade is ERC20Interface {
    string public name = "Invade"; //name of token
    string public symbol = "INV"; //symbol of token

    string public decimal = "0"; //genereally it has till 18'

    uint256 public override totalSupply;
    address public founder;
    mapping(address => uint256) public balances;

    //approval mapping
    mapping(address => mapping(address => uint256)) allowed;

    constructor() {
        totalSupply = 100000;
        founder = msg.sender;
        balances[founder] = totalSupply; //initally founder has all token i.e total supply [when contarct is first deployed]
    }

    function balanceOf(address tokenOwner)
        public
        view
        override
        returns (uint256)
    {
        return balances[tokenOwner];
    }

    //transfer token to recipeint
    function transfer(address recipient, uint256 tokens)
        public
        override
        returns (bool)
    {
        //check whether msg.sender has enough amount of token before sending
        require(balances[msg.sender] >= tokens);
        balances[recipient] += tokens;
        balances[msg.sender] -= tokens;

        emit Transfer(msg.sender, recipient, tokens);
        return true;
    }

    //person i am approving to use my token.. {you are auth to take money from account}
    function approve(address spender, uint256 tokens)
        public
        override
        returns (bool)
    {
        //check user has enough token
        require(balances[msg.sender] >= tokens);
        require(tokens > 0);

        //this means sender is allowing the spender address for the using token
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);

        return true;
    }

    function allowance(address tokenOwner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return allowed[tokenOwner][spender];
    }

    //transfer token from one address to another address
    function transferFrom(
        address from,
        address recipeint,
        uint256 tokens
    ) public override returns (bool) {
        require(allowed[from][recipeint] > tokens); //check allowed mapping has enough token
        require(balances[from] > tokens); //check if owner of tokens has enough token or not
        balances[from] -= tokens;
        balances[recipeint] += tokens;
        return true;
    }
}
