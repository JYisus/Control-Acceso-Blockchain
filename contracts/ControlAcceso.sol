pragma solidity ^0.5.0;

contract ControlAcceso {
    address public owner;
    address nullAddress = 0x0000000000000000000000000000000000000000;
    uint public userCount;
    uint public resourceCount;
    mapping(address => User) public addressToUser;
    // mapping(uint => address) public idToUserAddress;
    address[] public usersArray;

    mapping(uint => Resource) public idToResource;
    mapping(address => uint[]) public addressToResourcesId;
    mapping(address => Request[]) public addressToRequests;
    // User[] users;

    /*

     */
    struct User {
        address userAddress;
        string username;
        uint id;
        bool admin;
        uint resourcesCount;
        uint requestsCount;

    }

    /*
        id: Identificador del recurso.
        name: Nombre del recurso.
        description: Descripción del recurso.
        creationDate: Timestamp que indica la fecha de creación del recurso.
        creator: Address del creador del recurso.
     */
    struct Resource {
        uint id;
        string name;
        string description;
        uint creationDate;
        address creator;
    }

    /*
        Esta estructura representa una petición de un recurso.
        El usuario con address user solicita acceso al recurso
        con id resource.
     */
    struct Request {
        address user;
        uint resource;
    }

    constructor() public {
        owner = msg.sender;
        resourceCount = 0;
        userCount = 1;
        User memory _newUser = User(owner, "admin", userCount, true, 0, 0);
        addressToUser[owner] = _newUser;
        // idToUserAddress[userCount] = owner;
        usersArray.push(msg.sender);
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

    event CreateResource(
        uint id,
        string name,
        string description,
        address creator
    );

    event RemoveResource(
        uint id
    );

    function addUser(address _userAddress, string memory _username, bool _admin) public onlyAdmin {
        require(checkUsername(_username), "This username already exist");
        userCount++;
        User memory _newUser = User(_userAddress, _username, userCount,_admin, 0, 0);
        addressToUser[_userAddress] = _newUser;
        // idToUserAddress[userCount] = _userAddress;
        usersArray.push(_userAddress);
        emit CreateUser(_userAddress, _username, userCount, _admin);
    }


    /* 
        !!! Función de testeo, ELIMINAR O COMENTAR LUEGO.
    */
    function getUser(uint index) public view returns (string memory){
        require(index >= 0 && index < userCount);
        return addressToUser[usersArray[index]].username;
    }

    /*  Función que comprueba si un userame está en uso.
        Disminuye mucho la eficiencia del contrato, pues puede 
        conllevar un gran gasto de gas al crecer el
        número de usuarios. 
    */
    function checkUsername(string memory _username) public view returns(bool) {
         for(uint i=0; i<userCount; i++) {
            // address exu = usersArray[i];
            string memory aux = addressToUser[usersArray[i]].username;
            //string memory aux = addressToUser[idToUserAddress[i]].username;
            if(stringToBytes32(_username) == stringToBytes32(aux)) {
                return false;
            }
        } 
        return true;
    }

    // Utilidad para pasar pasar de string a bytes32 y poder comparar cadenas.
    function stringToBytes32(string memory source) public pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }

    /*
        Busca en el array de usuarios la posición del usuario con address _user.
        Devuelve una tupla con un booleano que indica si se ha encontrado y un 
        entero que indica la posición donde se ha encontrado.
     */
    function findUserIndex(address _user) private view returns (bool, uint) {
        for(uint i=0; i < userCount; i++) {
            if(_user == usersArray[i]) {
                return (true,i);
            }
        }
        return (false, 0);
    }

    function removeUser(address _userAddress) public {
        // requerir que sea admin o el propio usuario
        if (addressToUser[_userAddress].userAddress != nullAddress) {
            bool finded;
            uint index;
            (finded, index) = findUserIndex(_userAddress);

            if(finded) {
                address lastUser = usersArray[userCount-1];
                addressToUser[lastUser].id = index+1; // puede que sobre
                usersArray[index] = lastUser;
                delete addressToUser[_userAddress];
                delete usersArray[userCount-1];
                emit RemoveUser(_userAddress);
                userCount--;
            }
            /* uint _id = addressToUser[_userAddress].id;
            delete addressToUser[_userAddress];
            
            
            // address lastUser = idToUserAddress[userCount];
            address lastUser = usersArray[userCount-1];
            addressToUser[lastUser].id = _id;
            // idToUserAddress[_id] = lastUser;
            usersArray[_id-1] = lastUser;
            //delete idToUserAddress[userCount];
            delete usersArray[userCount-1];
            emit RemoveUser(_userAddress);
            userCount--; */
        }
    }

    function addResource(string memory _name, string memory _description) public {
        // requerir que el que añada un recurso sea un usuario registrado
        resourceCount++;
        Resource memory _newResource = Resource(resourceCount, _name, _description, now, msg.sender);
        idToResource[resourceCount] = _newResource;

        addressToUser[msg.sender].resourcesCount++;
        addressToResourcesId[msg.sender].push(resourceCount);

        emit CreateResource(resourceCount, _name, _description, msg.sender);
    }

    /*
        Busca en el array de recursos del usuario _user la posición del recurso 
        con identificador _id.
        Devuelve una tupla con un booleano que indica si se ha encontrado y un 
        entero que indica la posición donde se ha encontrado.
     */
    function findResourceIndex(address _user, uint _id) private view returns (bool, uint) {
        for(uint i=0; i < addressToUser[_user].resourcesCount; i++) {
            if(_id == addressToResourcesId[_user][i]) {
                return (true,i);
            }
        }
        return (false, 0);
    }

    function removeResource(uint _id) public {
        if (_id>0 && _id<=resourceCount) {
            resourceCount--;

            bool finded;
            uint index;
            (finded, index) = findResourceIndex(msg.sender, _id);

            if(finded == true) {
                delete addressToResourcesId[msg.sender][index];
            }
            addressToUser[msg.sender].resourcesCount--;
            
            delete idToResource[_id];
            emit RemoveResource(_id);
        }  
    }

    function requestResource(uint _id) public {
        require(_id != 0);
        User memory admin = addressToUser[idToResource[_id].creator];
        addressToUser[admin.userAddress].requestsCount++;
        // idToUser[admin.id].requestsCount++;
        addressToRequests[admin.userAddress].push(Request(msg.sender,_id));
    }


} 

/*     function remove(uint index)  returns(User[] memory) {
        if (index >= array.length) return;

        for (uint i = index; i<array.length-1; i++){
            array[i] = array[i+1];
        }
        delete array[array.length-1];
        array.length--;
        return array;
    } */

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