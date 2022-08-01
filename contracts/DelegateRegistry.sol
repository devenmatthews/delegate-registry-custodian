// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.8.0;

contract DelegateRegistry {
    
    // The first key is the delegator and the second key a id. 
    // The value is the address of the delegate 
    mapping (address => mapping (bytes32 => address)) public delegation;

    // The first key is the custodian and the second key a id. 
    // The value is the address of the whitelisted delegator
    // The delegator is allowed to call SetDelegate and ClearDelegation on the token custodian's behalf
    mapping (address => mapping (bytes32 => address)) public whitelistedDelegator;
    
    // Using these events it is possible to process the events to build up reverse lookups.
    // The indeces allow it to be very partial about how to build this lookup (e.g. only for a specific delegate).
    event SetDelegate(address indexed delegator, bytes32 indexed id, address indexed delegate);
    event ClearDelegate(address indexed delegator, bytes32 indexed id, address indexed delegate);
    
    event SetDelegator(address indexed custodian, bytes32 indexed id, address indexed delegator);
    event ClearDelegator(address indexed custodian, bytes32 indexed id, address indexed delegator);
    
    /// @dev Sets a delegate for the msg.sender and a specific id.
    ///      The combination of msg.sender and the id can be seen as a unique key.
    /// @param id Id for which the delegate should be set
    /// @param delegate Address of the delegate
    function setDelegate(bytes32 id, address delegate) public {
        require (delegate != msg.sender, "Can't delegate to self");
        require (delegate != address(0), "Can't delegate to 0x0");
        address currentDelegate = delegation[msg.sender][id];
        require (delegate != currentDelegate, "Already delegated to this address");
        
        // Update delegation mapping
        delegation[msg.sender][id] = delegate;
        
        if (currentDelegate != address(0)) {
            emit ClearDelegate(msg.sender, id, currentDelegate);
        }

        emit SetDelegate(msg.sender, id, delegate);
    }

    /// @dev Sets a delegate for the msg.sender and a specific id from a whitelisted delegator address.
    ///      The combination of msg.sender and the id can be seen as a unique key.
    /// @param custodian Address which the delegator is setting the delegate for.
    /// @param id Id for which the delegate should be set
    /// @param delegate Address of the delegate
    function setDelegateByDelegator(address custodian, bytes32 id, address delegate) public {
        require (whitelistedDelegator[custodian][id] == msg.sender, "msg.sender is not a whitelisted delegator");
        require (delegate != custodian, "Can't delegate to custodian"); // to give the custodian the voting power, the delegator should call clearDelegate()
        require (delegate != address(0), "Can't delegate to 0x0");
        address currentDelegate = delegation[custodian][id];
        require (delegate != currentDelegate, "Already delegated to this address");
        
        // Update delegation mapping
        delegation[custodian][id] = delegate;
        
        if (currentDelegate != address(0)) {
            emit ClearDelegate(custodian, id, currentDelegate);
        }

        emit SetDelegate(custodian, id, delegate);
    }
    
    /// @dev Clears a delegate for the msg.sender and a specific id.
    ///      The combination of msg.sender and the id can be seen as a unique key.
    /// @param id Id for which the delegate should be set
    function clearDelegate(bytes32 id) public {
        address currentDelegate = delegation[msg.sender][id];
        require (currentDelegate != address(0), "No delegate set");
        
        // update delegation mapping
        delegation[msg.sender][id] = address(0);
        
        emit ClearDelegate(msg.sender, id, currentDelegate);
    }

    /// @dev Clears a delegate for the msg.sender and a specific id.
    ///      The combination of msg.sender and the id can be seen as a unique key.
    /// @param id Id for which the delegate should be set
    function clearDelegateByDelegator(address custodian, bytes32 id) public {
        require (whitelistedDelegator[custodian][id] == msg.sender, "msg.sender is not a whitelisted delegator");
        address currentDelegate = delegation[custodian][id];
        require (currentDelegate != address(0), "No delegate set");
        
        // update delegation mapping
        delegation[custodian][id] = address(0);
        
        emit ClearDelegate(custodian, id, currentDelegate);
    }

    /// @dev Sets a delegator for the msg.sender and a specific id.
    ///      The combination of msg.sender and the id can be seen as a unique key.
    /// @param id Id for which the delegate should be set
    /// @param delegator Address of the whitelisted delegator
    function setWhitelistedDelegator(bytes32 id, address delegator) public {
        require (delegator != msg.sender, "Can't set self as delegator");
        require (delegate != address(0), "Can't set 0x0 as delegator");
        address currentDelegate = delegation[msg.sender][id];
        require (delegate != currentDelegate, "address is already a whitelisted delegator");
        
        // Update delegation mapping
        whitelistedDelegator[msg.sender][id] = delegator;
        
        if (currentDelegate != address(0)) {
            emit ClearDelegator(msg.sender, id, currentDelegate);
        }

        emit SetDelegator(msg.sender, id, delegator);
    }

    /// @dev Clears a delegator for the msg.sender and a specific id.
    ///      The combination of msg.sender and the id can be seen as a unique key.
    /// @param id Id for which the delegate should be set
    function clearWhitelistedDelegator(bytes32 id) public {
        address currentDelegator = whitelistedDelegator[msg.sender][id];
        require (currentDelegate != address(0), "No delegate set");
        
        // update delegator mapping
        whitelistedDelegator[msg.sender][id] = address(0);
        
        emit ClearDelegator(msg.sender, id, currentDelegate);
    }
}