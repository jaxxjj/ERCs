// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interfaces/IERC777.sol";
import "../interfaces/IERC777Recipient.sol";
import "../interfaces/IERC777Sender.sol";
import "../interfaces/IERC20.sol";
import "../interfaces/IERC1820Registry.sol";
import "../interfaces/Context.sol";


contract ERC777 is Context, IERC777, IERC20 {

    IERC1820Registry internal constant _ERC1820_REGISTRY = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

    mapping(address => uint256) private _balances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    // ERC777
    bytes32 private constant _TOKENS_SENDER_INTERFACE_HASH = keccak256("ERC777TokensSender");
    bytes32 private constant _TOKENS_RECIPIENT_INTERFACE_HASH = keccak256("ERC777TokensRecipient");
    
    // Operators
    mapping(address => mapping(address => bool)) private _operators;
    address[] private _defaultOperatorsList;
    mapping(address => bool) private _isDefaultOperator;

    constructor(
        string memory name_,
        string memory symbol_,
        address[] memory defaultOperators_
    ) {
        _name = name_;
        _symbol = symbol_;
        
        // Register interfaces in ERC1820 registry
        _ERC1820_REGISTRY.setInterfaceImplementer(address(this), keccak256("ERC777Token"), address(this));
        _ERC1820_REGISTRY.setInterfaceImplementer(address(this), keccak256("ERC20Token"), address(this));

        // Initialize default operators properly
        for(uint256 i = 0; i < defaultOperators_.length; i++) {
            address operator = defaultOperators_[i];
            require(operator != address(0), "ERC777: default operator cannot be zero address");
            require(!_isDefaultOperator[operator], "ERC777: duplicate default operator");
            
            _defaultOperatorsList.push(operator);
            _isDefaultOperator[operator] = true;
            _operators[operator][address(0)] = true;
        }
    }

    // ERC777 Interface Implementation
    function name() public view virtual override(IERC20, IERC777) returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override(IERC20, IERC777) returns (string memory) {
        return _symbol;
    }

    function decimals() public pure virtual override(IERC20) returns (uint8) {
        return 18;
    }

    function granularity() public pure virtual override(IERC777) returns (uint256) {
        return 1;
    }

    function totalSupply() public view virtual override(IERC20, IERC777) returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override(IERC20, IERC777) returns (uint256) {
        return _balances[account];
    }

    function send(address recipient, uint256 amount, bytes memory data) public virtual override(IERC777) {
        _send(_msgSender(), _msgSender(), recipient, amount, data, "", true);
    }

    function operatorSend(
        address sender,
        address recipient,
        uint256 amount,
        bytes memory data,
        bytes memory operatorData
    ) public virtual override {
        require(isOperatorFor(_msgSender(), sender), "ERC777: caller is not an operator for holder");
        _send(_msgSender(), sender, recipient, amount, data, operatorData, true);
    }

    function burn(uint256 amount, bytes memory data) public virtual override {
        _burn(_msgSender(), _msgSender(), amount, data, "");
    }

    function operatorBurn(
        address account,
        uint256 amount,
        bytes memory data,
        bytes memory operatorData
    ) public virtual override {
        require(isOperatorFor(_msgSender(), account), "ERC777: caller is not an operator for holder");
        _burn(_msgSender(), account, amount, data, operatorData);
    }

    function isOperatorFor(address operator, address tokenHolder) public view virtual override returns (bool) {
        return operator == tokenHolder ||
            _isDefaultOperator[operator] ||
            _operators[operator][tokenHolder];
    }

    function authorizeOperator(address operator) public virtual override {
        require(_msgSender() != operator, "ERC777: authorizing self as operator");
        _operators[operator][_msgSender()] = true;
        emit AuthorizedOperator(operator, _msgSender());
    }

    function revokeOperator(address operator) public virtual override {
        require(operator != _msgSender(), "ERC777: revoking self as operator");
        delete _operators[operator][_msgSender()];
        emit RevokedOperator(operator, _msgSender());
    }

    function defaultOperators() public view virtual override returns (address[] memory) {
        return _defaultOperatorsList;
    }

    // Internal functions
    function _send(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes memory data,
        bytes memory operatorData,
        bool requireReceptionAck
    ) internal virtual {
        require(from != address(0), "ERC777: send from the zero address");
        require(to != address(0), "ERC777: send to the zero address");

        _callTokensToSend(operator, from, to, amount, data, operatorData);

        _move(operator, from, to, amount, data, operatorData);

        _callTokensReceived(operator, from, to, amount, data, operatorData, requireReceptionAck);
    }

    function _burn(
        address operator,
        address from,
        uint256 amount,
        bytes memory data,
        bytes memory operatorData
    ) internal virtual {
        require(from != address(0), "ERC777: burn from the zero address");

        _callTokensToSend(operator, from, address(0), amount, data, operatorData);

        _balances[from] -= amount;
        _totalSupply -= amount;

        emit Burned(operator, from, amount, data, operatorData);
    }

    function _move(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes memory data,
        bytes memory operatorData
    ) internal virtual {
        _balances[from] -= amount;
        _balances[to] += amount;

        emit Sent(operator, from, to, amount, data, operatorData);
    }

    function _callTokensToSend(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes memory data,
        bytes memory operatorData
    ) private {
        address implementer = _ERC1820_REGISTRY.getInterfaceImplementer(from, _TOKENS_SENDER_INTERFACE_HASH);
        if (implementer != address(0)) {
            IERC777Sender(implementer).tokensToSend(operator, from, to, amount, data, operatorData);
        }
    }

    function _callTokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes memory data,
        bytes memory operatorData,
        bool requireReceptionAck
    ) private {
        address implementer = _ERC1820_REGISTRY.getInterfaceImplementer(to, _TOKENS_RECIPIENT_INTERFACE_HASH);
        if (implementer != address(0)) {
            IERC777Recipient(implementer).tokensReceived(operator, from, to, amount, data, operatorData);
        } else if (requireReceptionAck) {
            require(!_isContract(to), "ERC777: token recipient contract has no implementer for ERC777TokensRecipient");
        }
    }

    // ERC20 compatibility
    function transfer(address recipient, uint256 amount) public virtual override(IERC20) returns (bool) {
        require(recipient != address(0), "ERC777: transfer to the zero address");
        address from = _msgSender();
        _send(from, from, recipient, amount, "", "", false);
        return true;
    }

    function allowance(address holder, address spender) public view virtual override returns (uint256) {
        return _operators[spender][holder] ? type(uint256).max : 0;
    }

    function approve(address spender, uint256 value) public virtual override returns (bool) {
        address holder = _msgSender();
        if (value == 0) {
            revokeOperator(spender);
        } else {
            authorizeOperator(spender);
        }
        emit Approval(holder, spender, value);
        return true;
    }

    function transferFrom(
        address holder,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        require(recipient != address(0), "ERC777: transfer to the zero address");
        require(holder != address(0), "ERC777: transfer from the zero address");
        require(isOperatorFor(_msgSender(), holder), "ERC777: caller is not an operator for holder");
        _send(_msgSender(), holder, recipient, amount, "", "", false);
        return true;
    }

    function _isContract(address _addr) private view returns (bool) {
        uint256 codeLength;

        // Assembly required for versions < 0.8.0 to check extcodesize.
        assembly {
            codeLength := extcodesize(_addr)
        }

        return codeLength > 0;
    }

    function _mint(
        address account,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    ) internal virtual {
        require(account != address(0), "ERC777: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), account, amount);

        // Update state variables
        _totalSupply += amount;
        _balances[account] += amount;

        emit Minted(operator, account, amount, userData, operatorData);
        emit Transfer(address(0), account, amount);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        if (from == address(0)) {
            // minting
        } else if (to == address(0)) {
            // burning
        } else {
            // transferring
        }
    }
}