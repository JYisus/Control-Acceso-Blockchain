pragma solidity ^0.5.0;

contract ControlAcceso {
    address public owner;
    address nullAddress = 0x0000000000000000000000000000000000000000;
    uint public userCount;
    uint public resourceCount;
    uint public actualResourceId;
    mapping(address => User) public addressToUser;
    // mapping(uint => address) public idToUserAddress;
    address[] public usersArray;

    mapping(uint => Resource) public idToResource;
    mapping(address => uint[]) public addressToResourcesId;
    mapping(address => Request[]) public addressToRequests;
    uint[] public resourcesArray;
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
        uint[] allowedResources;

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
        state:
        - 0 Rechazado
        - 1 Aceptado
        - 2 Pendiente
     */
    struct Request {
        address user;
        uint resource;
        uint state;
    }

    constructor() public {
        owner = msg.sender;
        resourceCount = 0;
        actualResourceId = 0;
        userCount = 1;
        User memory _newUser = User(owner, "admin", userCount, true, 0, 0, new uint[](0));
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

    event RequestResource(
        address user,
        uint resource
    );

    event AcceptRequest(
        address user,
        uint resource,
        bool allowed
    );

    function addUser(address _userAddress, string memory _username, bool _admin) public onlyAdmin {
        require(checkUsername(_username), "This username already exist");
        userCount++;
        User memory _newUser = User(_userAddress, _username, userCount,_admin, 0, 0, new uint[](0));
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
    function stringToBytes32(string memory source) private pure returns (bytes32 result) {
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
        actualResourceId++;
        Resource memory _newResource = Resource(actualResourceId, _name, _description, now, msg.sender);
        idToResource[actualResourceId] = _newResource;

        addressToUser[msg.sender].resourcesCount++;
        addressToResourcesId[msg.sender].push(actualResourceId);
        resourcesArray.push(actualResourceId);

        

        emit CreateResource(actualResourceId, _name, _description, msg.sender);
    }

    /*
        Busca en el array de recursos del usuario _user la posición del recurso 
        con identificador _id.
        Devuelve una tupla con un booleano que indica si se ha encontrado y un 
        entero que indica la posición donde se ha encontrado.
     */
    function findUserResourceIndex(address _user, uint _id) private view returns (bool, uint) {
        for(uint i=0; i < addressToUser[_user].resourcesCount; i++) {
            if(_id == addressToResourcesId[_user][i]) {
                return (true,i);
            }
        }
        return (false, 0);
    }

    function findResourceIndex(uint _id) private view returns (bool, uint) {
        for(uint i=0; i < resourceCount; i++) {
            if(_id == resourcesArray[i]) {
                return (true,i);
            }
        }
        return (false, 0);
    }



    function removeResource(uint _id) public {
        require (_id!=0 && _id <= actualResourceId);
            bool finded;
            uint index;
            (finded, index) = findResourceIndex(_id);
            if(finded) {
                uint lastResource = resourcesArray[resourceCount-1];
                resourcesArray[index] = lastResource;
                delete resourcesArray[resourceCount-1];
                (finded, index) = findUserResourceIndex(msg.sender, _id);

                if(finded == true) {
                    delete addressToResourcesId[msg.sender][index];
                }
                addressToUser[msg.sender].resourcesCount--;

                
                
            } 
            delete idToResource[_id];
                emit RemoveResource(_id);
                resourceCount--;

    }
    /* 
        !!! Función de testeo, ELIMINAR O COMENTAR LUEGO.
    */
    function getResource(uint index) public view returns (string memory){
        require(index >= 0, 'index fuera de rango');
        return idToResource[resourcesArray[index]].name;
    }

    function requestResource(uint _id) public {
        require(_id > 0 && idToResource[_id].id != 0, 'id fuera de rango');
        User memory admin = addressToUser[idToResource[_id].creator];
        addressToUser[admin.userAddress].requestsCount++;
        // idToUser[admin.id].requestsCount++;
        addressToRequests[admin.userAddress].push(Request(msg.sender,_id, 2));
        emit RequestResource(msg.sender, _id);
    }

    function isRequested(uint _id) public view returns (address) {
        require(msg.sender == idToResource[_id].creator, 'usuario no autorizado');
        if(addressToUser[msg.sender].requestsCount == 0) {
            return 0x0000000000000000000000000000000000000000;
        }
        else {
            // Resource memory resource = idToResource[_id];
            for(uint i = 0; i<addressToUser[msg.sender].requestsCount; i++) {
                if(addressToRequests[msg.sender][i].resource == _id) {
                    return addressToRequests[msg.sender][i].user;
                }
            }
        }
        return 0x0000000000000000000000000000000000000000;
    }

    /*
        Si _accept = true, permite el acceso al usuario con
        address _user el acceso al recurso _id.
    */
    function acceptRequest(address _user, uint _id, bool _accept) public {
        require(_id != 0);
        if(_accept) {
            addressToUser[_user].allowedResources.push(_id);
            emit AcceptRequest(_user, _id, _accept);
            //User storage userAllowed = addressToUser[_user];
            //userAllowed.allowedResources++;
            //idToUser[userAllowed.id].allowedResources++;
        }
        for(uint i = 0; i < addressToUser[msg.sender].requestsCount; i++) {
            if ((addressToRequests[msg.sender][i].resource == _id) && (addressToRequests[msg.sender][i].user == _user)) {
                if(_accept) {
                    addressToRequests[msg.sender][i].state = 1;
                }
                else {
                    addressToRequests[msg.sender][i].state = 0;
                }
            }
        }
    }

    /*
        Devuelve la cantidad de peticiones que se le han hecho al usuario.
    */
    function getCountRequest() public view returns (uint) {
        return addressToUser[msg.sender].requestsCount;
    }

    function getRequest(uint _id) public view returns (string memory, uint, address) {
        //require(_id < addressToUser[msg.sender].countRequests && _id!=0);
        Request memory _req = addressToRequests[msg.sender][_id];
        return (addressToUser[_req.user].username, _req.resource, _req.user);
    }

    /*
        Devuelve la cantidad de recursos a los que el usuario
        tiene acceso.
    */
    function allowedCount() public view returns (uint) {
        return(addressToUser[msg.sender].allowedResources.length);
    }

    function haveAccess(uint _id) public view returns (bool) {
        require(_id != 0);
        User memory _user = addressToUser[msg.sender];

        if(_user.userAddress == idToResource[_id].creator) return true;

        for(uint i = 0; i < _user.allowedResources.length; i++) {
            if(_user.allowedResources[i] == _id) {
                return true;
            }
        }
        return false;
    }

    function getRequestState(uint _id) public view returns (uint) {
        address _owner = idToResource[_id].creator;
        for(uint i = 0; i < addressToUser[_owner].requestsCount; i++) {
            if((addressToRequests[_owner][i].user == msg.sender) && (addressToRequests[_owner][i].resource == _id)) {
                return addressToRequests[_owner][i].state;
            }
        }
        return 0;
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