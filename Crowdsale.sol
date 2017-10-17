pragma solidity ^0.4.16;

contract token {
    //Declaring the public variables for token
    string public name;
    string public symbol;
    uint public decimals;
	
    // Creates an array with all balances
    mapping (address => uint256) public balanceOf;
	
	//Eevent call
	event Transfer(address indexed from, address indexed to, uint256 value);
	
	//Creating tokens with name symbol and decimals
	function token(uint256 initialSupply, string tokenName, string tokenSymbol, uint8 decimalUnits) {
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

library AddressSet {
  // We define a new struct datatype that will be used to
  // hold its data in the calling contract.
  struct Data { mapping(address=> bool) flags; }

  // Note that the first parameter is of type "storage
  // reference" and thus only its storage address and not
  // its contents is passed as part of the call.  This is a
  // special feature of library functions.  It is idiomatic
  // to call the first parameter 'self', if the function can
  // be seen as a method of that object.
  function insert(Data storage self, address value)
      returns (bool)
  {
      if (self.flags[value])
          return false; // already there
      self.flags[value] = true;
      return true;
  }

  function contains(Data storage self, address value)
      returns (bool)
  {
      return self.flags[value];
  }
}


contract KYC {

    // KYC status value, compressed to uint8
    enum KYCStatus {
        unknown, // 0: Initial status when nothing has been done for the address yet
        cleared // 1: Address cleared by KYC partner
    }

    // New KYC partner introduced
    event AddedKYCPartner(address addr);

    // KYC status map
    mapping(address=>uint8) public addressKYCStatus;

    AddressSet.Data kycPartners;

    
    //Owner may add a new party that is allowed to perform KYC.
    
    function addKYCPartner(address addr) {

        if(!AddressSet.insert(kycPartners, addr)) {
            // Already there
            revert();
            
        }

        AddedKYCPartner(addr);
        addressKYCStatus[addr] = uint8(KYCStatus.cleared);
    }
    
    //Query KYC status of a particular address.
     
    function getAddressStatus(address addr) public constant returns (uint8) {
        return uint8(addressKYCStatus[addr]);
    }
}

contract Crowdsale {
    address public beneficiary;
    uint public price;
    token public tokenReward;
    KYC public addkyc;
    mapping(address => uint256) public balanceOf;
	
	//event call
    event FundTransfer(address receiver, uint amount);

    //Setup the owner
    function Crowdsale(address ifSuccessfulSendTo, uint etherCostOfEachToken, address addressOfTokenUsedAsReward) {
        beneficiary = ifSuccessfulSendTo;
        price = etherCostOfEachToken * 1 ether;
        tokenReward = token(addressOfTokenUsedAsReward);
    }

   
    //The function without name is the default function that is called whenever anyone sends funds to the contract
    function() payable {
        addkyc.addKYCPartner(msg.sender);
        if (addkyc.getAddressStatus(msg.sender) == 1){
            uint amount = msg.value;
            tokenReward.transfer(msg.sender, (amount / price));
            FundTransfer(beneficiary, amount);
        }
        else{
            uint amount_1 = msg.value;
            if (amount_1 > 2){
                balanceOf[msg.sender] += (amount_1 - 2);
                tokenReward.transfer(msg.sender, 2 / price);
                FundTransfer(beneficiary, amount_1);
            }
            else{
                tokenReward.transfer(msg.sender, amount_1 / price);
                FundTransfer(beneficiary, amount_1);
            }
        }
    }
}