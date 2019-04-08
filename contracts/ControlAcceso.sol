pragma solidity ^0.5.0;

contract ControlAcceso {
    address public owner;
    uint public userCount;
    uint public resourceCount;
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
        uint _id = resourceCount;
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
