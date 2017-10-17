pragma solidity ^0.4.16;
contract NewToken {
	//Declaring the public variables for token
    string public name;
    string public symbol;
    uint public decimals;
	
    // Creates an array with all balances
    mapping (address => uint256) public balanceOf;
	
	//Eevent call
	event Transfer(address indexed from, address indexed to, uint256 value);
	
	//Creating tokens with name symbol and decimals
	function NewToken(uint256 initialSupply, string tokenName, string tokenSymbol, uint8 decimalUnits) {
		balanceOf[msg.sender] = initialSupply;    // Give the creator all initial tokens
		name = tokenName;                         // Set the name for display purposes
		symbol = tokenSymbol;                     // Set the symbol for display purposes
		decimals = decimalUnits;                  // Amount of decimals for display purposes
	}
	
	//check balance then proceed transfer
	function transfer(address _to, uint256 _value) {
		// Check if sender has balance and for overflows
		require(balanceOf[msg.sender] >= _value && balanceOf[_to] + _value >= balanceOf[_to]);
	
		// Add and subtract new balances
		balanceOf[msg.sender] -= _value;
		balanceOf[_to] += _value;
		
		// Notify anyone listening that this transfer took place
		Transfer(msg.sender, _to, _value);
	}
}