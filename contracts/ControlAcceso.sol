pragma solidity ^0.5.0;

contract ControlAcceso {
    address public owner;
    address nullAddress = 0x0000000000000000000000000000000000000000;
    uint public userCount;
    uint public resourceCount;
    mapping(address => User) public addressToUser;
    mapping(uint => User) public idToUser;
    // User[] users;
    struct User {
        address userAddress;
        string username;
        uint id;
        bool admin;
    }

    struct Resource {
        uint id;
        string name;
        string description;
        string creationDate;
        uint creatorId;
    }

    constructor() public {
        owner = msg.sender;
        resourceCount = 0;
        userCount = 1;
        User memory _newUser = User(owner, "admin", userCount, true);
        addressToUser[owner] = _newUser;
        idToUser[userCount] = _newUser;
        emit CreateUser(owner, "admin", userCount, true);
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier onlyAdmin {
        // require(addressToUser[msg.sender].userAddress != nullAddress && addressToUser[msg.sender].admin == true, "Only admins can call this function");
        require(addressToUser[msg.sender].admin == true, "Only admins can call this function");
        _;
    }

    event CreateUser(
        address userAddress,
        string username,
        uint id,
        bool admin
    );

    event RemoveUser(
        address userAddress
    );

    function addUser(address _userAddress, string memory _username, bool _admin) public onlyAdmin {
        userCount++;
        require(checkUsername(_username), "This username already exist");
        User memory _newUser = User(_userAddress, _username, userCount,_admin);
        addressToUser[_userAddress] = _newUser;
        idToUser[userCount] = _newUser;
        emit CreateUser(_userAddress, _username, userCount, _admin);
    }

    /*  Función que comprueba si un userame está en uso.
        Disminuye mucho la eficiencia del contrato, pues puede 
        conllevar un gran gasto de gas al crecer el
        número de usuarios. */
    function checkUsername(string memory _username) public view returns(bool) {
        for(uint i=1; i<=userCount; i++) {
            string memory aux = idToUser[i].username;
            if(stringToBytes32(_username) == stringToBytes32(aux)) {
                return false;
            }
        }
        return true;
    }

    function stringToBytes32(string memory source) public pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }

    function removeUser(address _userAddress) public {
        if (addressToUser[_userAddress].userAddress != nullAddress) {
            delete addressToUser[_userAddress];
            emit RemoveUser(_userAddress);
            userCount--;
        }
    }

    //function addResource(string memory _name, string memory _description) public {
    //    require(addressToUser[msg.sender].id != 0, "Only registered users can add resources");
    //    Resource _newResource = Resource(userCount, _name, _description)
    //}    

/*     function remove(uint index)  returns(User[] memory) {
        if (index >= array.length) return;

        for (uint i = index; i<array.length-1; i++){
            array[i] = array[i+1];
        }
        delete array[array.length-1];
        array.length--;
        return array;
    } */

} 

/* contract ControlAcceso {
    address public owner;
    uint public userCount;
    uint public resourceCount;
    uint public actualResourceId;
    address public user;
    mapping (address => User) public addressToUser;
    mapping (uint => User) public idToUser;
    mapping (uint => Resource) public idToResource;
    mapping (address => uint[]) userResources;
    mapping (address => Request[]) userRequest;
    mapping (address => uint[]) allowedResources;

    struct Resource {
        uint id;
        string name;
        string organization;
        address userAdmin;
    }

    struct User {
        address user;
        uint id;
        bool admin;
        uint adminResources;
        uint countRequests;
        uint allowedResources;
    }

    struct Request {
        address user;
        uint resource;
    }

    event CreateResource(
        uint id,
        string name,
        string organization,
        address userAdmin
    );

    event RemoveResource(
        uint id
    );

    event CreateUser(
        address user,
        uint id,
        bool admin,
        uint adminResources,
        uint countRequests,
        uint allowedResources
    );

    event RemoveUser(
        address user,
        uint id
    );

    modifier onlyOwner {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier onlyAdmin {
        require(addressToUser[msg.sender].id != 0 && addressToUser[msg.sender].admin == true, "Only admins can call this function");
        _;
    }

    //mapping(uint => address) public users;
    constructor() public {
        owner = msg.sender;
        userCount = 0;
        resourceCount = 0;
        actualResourceId = 0;
        // userCount ++;
        user = 0xAf212b1d492E73c6bF1F542A703dAEB877f42e89;
        addUser(owner, true);
    }

    function addUser(address _userAddress, bool _admin) public {
        uint id = addressToUser[_userAddress].id;
        if (id == 0) {
            userCount++;
            id = userCount; 
            addressToUser[_userAddress] = User(_userAddress, id, _admin, 0, 0, 0);
            idToUser[id] = User(_userAddress, id, _admin, 0, 0, 0);
            emit CreateUser(_userAddress, id, _admin, 0, 0, 0);
        }
        // users[id] = _userAddress; // Por esto falla el migrate
    }

    function removeUser(address _userAddress) public {
        uint id = addressToUser[_userAddress].id;
        if (id != 0) {
            userCount--;
            delete addressToUser[_userAddress];
            delete idToUser[id];
            emit RemoveUser(_userAddress, id);
        }
        // users[id] = _userAddress; // Por esto falla el migrate
    }

    function addResource(string memory _name, string memory _organization) public {
        resourceCount++;
        actualResourceId++;
        uint _id = actualResourceId;
        userResources[msg.sender].push(_id);
        addressToUser[msg.sender].adminResources++;
        idToResource[_id] = Resource(_id, _name, _organization, msg.sender);
        emit CreateResource(_id, _name, _organization, msg.sender);       
    }

    function removeResource(uint _id) public {
        if (_id!=0) {
            resourceCount--;
            addressToUser[msg.sender].adminResources--;
            delete idToResource[_id];
            emit RemoveResource(_id);
        }      
    }

    function requestResource(uint _id) public {
        require(_id != 0);
        User storage admin = addressToUser[idToResource[_id].userAdmin];
        idToUser[admin.id].countRequests++;
        addressToUser[idToResource[_id].userAdmin].countRequests++;
        userRequest[admin.user].push(Request(msg.sender,_id));
    }

    function isRequested(uint _id) public view returns (address) {
        require(msg.sender == idToResource[_id].userAdmin);
        if(addressToUser[msg.sender].countRequests == 0) {
            return 0x0000000000000000000000000000000000000000;
        }
        else {
            // Resource memory resource = idToResource[_id];
            for(uint i = 0; i<addressToUser[msg.sender].countRequests; i++) {
                if(userRequest[msg.sender][i].resource == _id) {
                    return userRequest[msg.sender][i].user;
                }
            }
        }
        return 0x0000000000000000000000000000000000000000;
    }

    function acceptRequest(address _user, uint _id, bool _accept) public {
        require(_id != 0);
        if(_accept) {
            allowedResources[_user].push(_id);
            User storage userAllowed = addressToUser[_user];
            userAllowed.allowedResources++;
            idToUser[userAllowed.id].allowedResources++;
        }
    }

    function haveAccess(uint _id) public view returns (bool) {
        require(_id != 0);
        User memory _user = addressToUser[msg.sender];
        for(uint i=0; i<_user.allowedResources; i++) {
            if(allowedResources[_user.user][i] == _id) {
                return true;
            }
        }
        return false;
    }

    function getCountRequest() public view returns (uint) {
        return addressToUser[msg.sender].countRequests;
    }

    function getRequest(uint _id) public view returns (address, uint) {
        //require(_id < addressToUser[msg.sender].countRequests && _id!=0);
        return (userRequest[msg.sender][_id].user, userRequest[msg.sender][_id].resource);
    }

    function getRequestUser(uint _id) public view returns (address)  {
        require(_id < addressToUser[msg.sender].countRequests && _id!=0);
        return userRequest[msg.sender][_id].user;

    }

    function getRequestResource(uint _id) public view returns (uint)  {
        require(_id < addressToUser[msg.sender].countRequests && _id!=0);

        return userRequest[msg.sender][_id].resource;
    }
}
 */