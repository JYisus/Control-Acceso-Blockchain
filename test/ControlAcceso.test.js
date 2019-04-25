const ControlAcceso = artifacts.require('./ControlAcceso.sol')

contract('ControlAcceso', (accounts) => {
    before(async() => {
        this.controlAcceso = await ControlAcceso.deployed()
        this.owner = await this.controlAcceso.owner()
        this.noUser = '0xeEF023076D61BBEC2855fe224f3A8Ac510D0bFf8'
        // this.secondUser = '0x35bb4f0b115f8f7d4EcF2de7Cdc041f47453fD0F'

        this.firstUser = { userAddress: this.owner, username: "admin", admin: true }
        this.secondUser = { 
            userAddress: '0x35bb4f0b115f8f7d4EcF2de7Cdc041f47453fD0F', 
            username: "Secondary", 
            admin: false
        }
        this.thirdUser = { 
            userAddress: '0xe9A4b8429Ce4edfA7503Bf12338F2c657AaE3be1', 
            username: "OtroMais", 
            admin: false
        }

        this.resource1 = { id:1, name: "Camilla", description: "Pues una camilla"}
        this.resource2 = { id:2, name: "Silla", description: "Pues una silla"}
    })

    it('deploys succesfully', async() => {
        const address = await this.controlAcceso.address
        assert.notEqual(address, 0x0)
        assert.notEqual(address, '')
        assert.notEqual(address, null)
        assert.notEqual(address, undefined)
    })
    it('list users - by address', async() => {
        const userCount = await this.controlAcceso.userCount()
        const usuario = await this.controlAcceso.addressToUser.call(this.firstUser.userAddress)
        assert.equal(userCount.toNumber(), 1)
        // assert.equal(usuario.id.toNumber(),1)
        assert.equal(usuario.userAddress, this.firstUser.userAddress)
        assert.equal(usuario.username, this.firstUser.username)
        assert.equal(usuario.admin, true)
        //assert.equal(usuario.admin, true)
    })
    it('adding user', async() => {
        const result = await this.controlAcceso.addUser(this.secondUser.userAddress, this.secondUser.username, false)
        const userCount = await this.controlAcceso.userCount()
        assert.equal(userCount.toNumber(), 2)
        const event = result.logs[0].args
        assert.equal(event.userAddress, this.secondUser.userAddress)
        assert.equal(event.admin, false)
    })
    it('adding another user', async() => {
        const result = await this.controlAcceso.addUser(this.thirdUser.userAddress, this.thirdUser.username, false)
        const userCount = await this.controlAcceso.userCount()
        assert.equal(userCount.toNumber(), 3)
        const event = result.logs[0].args
        assert.equal(event.userAddress, this.thirdUser.userAddress)
        assert.equal(event.admin, false)

        for(i=0; i<userCount; i++) {
            const user = await this.controlAcceso.getUser(i)
            console.log(`${i}: ${user}`)
        } 
    })
    it('remove user', async() => {
        const result = await this.controlAcceso.removeUser(this.secondUser.userAddress)
        const userCount = await this.controlAcceso.userCount()
        for(i=0; i<userCount; i++) {
            const user = await this.controlAcceso.getUser(i)
            console.log(`${i}: ${user}`)
        } 
        assert.equal(userCount.toNumber(), 2)
        const event = result.logs[0].args
        assert.equal(event.userAddress, this.secondUser.userAddress)
    })
    it('add resource', async() => {
        const result = await this.controlAcceso.addResource(this.resource1.name, this.resource1.description)
        const resourceCount = await this.controlAcceso.resourceCount()
        const event = result.logs[0].args
        const resource = await this.controlAcceso.idToResource.call(this.resource1.id)
        const usuario = await this.controlAcceso.addressToUser.call(this.firstUser.userAddress)

        assert.equal(resourceCount.toNumber(), 1)
        assert.equal(event.id.toNumber(), 1)
        assert.equal(event.name, this.resource1.name)
        assert.equal(resource.id.toNumber(),1)
        assert.equal(resource.name, this.resource1.name)
        assert.equal(resource.description, this.resource1.description)
        assert.equal(resource.creator, this.firstUser.userAddress)
        //assert.equal(usuario.adminResources, 1)
    })
    it('remove resource', async() => {
        const result = await this.controlAcceso.removeResource(this.resource1.id)
        const resourceCount = await this.controlAcceso.resourceCount()
        assert.equal(resourceCount.toNumber(), 0)
        const event = result.logs[0].args
        assert.equal(event.id.toNumber(), 1)
        const resource = await this.controlAcceso.idToResource.call(this.resource1.id)
        assert.equal(resource.id.toNumber(),0)
        assert.equal(resource.name, '')
        // const usuario = await this.controlAcceso.addressToUser.call(this.firstUser)
        // assert.equal(usuario.adminResources, 1)
    })
})
/* const ControlAcceso = artifacts.require('./ControlAcceso.sol')

contract('ControlAcceso', (accounts) => {
    before(async() => {
        this.controlAcceso = await ControlAcceso.deployed()
        this.firstUser = await this.controlAcceso.owner()
        this.noUser = '0xeEF023076D61BBEC2855fe224f3A8Ac510D0bFf8'
        this.secondUser = '0x35bb4f0b115f8f7d4EcF2de7Cdc041f47453fD0F'
s SL"
        this.resource1 = { id:1, name: "Camilla", organization: "Camillas SL"}
        this.resource2 = { id:2, name: "Silla", organization: "Sillas SL"}
    })

    it('deploys succesfully', async() => {
        const address = await this.controlAcceso.address
        assert.notEqual(address, 0x0)
        assert.notEqual(address, '')
        assert.notEqual(address, null)
        assert.notEqual(address, undefined)
    })
    it('list users - by address', async() => {
        const userCount = await this.controlAcceso.userCount()
        const usuario = await this.controlAcceso.addressToUser.call(this.firstUser)
        assert.equal(userCount.toNumber(), 1)
        assert.equal(usuario.id.toNumber(),1)
        assert.equal(usuario.user, this.firstUser)
        assert.equal(usuario.admin, true)
    })
    it('list users - by id', async() => {
        const userCount = await this.controlAcceso.userCount()
        const usuario = await this.controlAcceso.idToUser.call(1)
        assert.equal(userCount.toNumber(), 1)
        assert.equal(usuario.user, this.firstUser)
    })
    it('no user', async() => {
        const noUsuario = await this.controlAcceso.addressToUser.call(this.noUser)
        assert.equal(noUsuario.id.toNumber(),0)
    })
    it('add user', async() => {
        const result = await this.controlAcceso.addUser(this.secondUser, false)
        const userCount = await this.controlAcceso.userCount()
        assert.equal(userCount.toNumber(), 2)
        const event = result.logs[0].args
        assert.equal(event.id.toNumber(), 2)
        assert.equal(event.user, this.secondUser)
        const usuario = await this.controlAcceso.addressToUser.call(this.secondUser)
        assert.equal(usuario.id.toNumber(),2)
        assert.equal(usuario.admin, false)
        assert.equal(usuario.adminResources, 0)
        assert.equal(usuario.countRequests, 0)
    })
    it('remove user', async() => {
        const result = await this.controlAcceso.removeUser(this.secondUser)
        const userCount = await this.controlAcceso.userCount()
        assert.equal(userCount.toNumber(), 1)
        const event = result.logs[0].args
        assert.equal(event.id.toNumber(), 2)
        assert.equal(event.user, this.secondUser)
        const usuario = await this.controlAcceso.addressToUser.call(this.secondUser)
        assert.equal(usuario.id.toNumber(),0)
        assert.equal(usuario.user, '0x0000000000000000000000000000000000000000')
    })
    it('add resource', async() => {
        const result = await this.controlAcceso.addResource(this.resource1.name, this.resource1.organization)
        const resourceCount = await this.controlAcceso.resourceCount()
        assert.equal(resourceCount.toNumber(), 1)
        const event = result.logs[0].args
        assert.equal(event.id.toNumber(), 1)
        assert.equal(event.name, this.resource1.name)
        const resource = await this.controlAcceso.idToResource.call(this.resource1.id)
        assert.equal(resource.id.toNumber(),1)
        assert.equal(resource.name,"Camilla")
        assert.equal(resource.organization, "Camillas SL")
        assert.equal(resource.userAdmin, this.firstUser)
        const usuario = await this.controlAcceso.addressToUser.call(this.firstUser)
        assert.equal(usuario.adminResources, 1)
    })
    it('remove resource', async() => {
        const result2 = await this.controlAcceso.addResource(this.resource2.name, this.resource2.organization)
        const result = await this.controlAcceso.removeResource(this.resource2.id)
        const resourceCount = await this.controlAcceso.resourceCount()
        assert.equal(resourceCount.toNumber(), 1)
        const event = result.logs[0].args
        assert.equal(event.id.toNumber(), 2)
        const resource = await this.controlAcceso.idToResource.call(this.resource1.id)
        assert.equal(resource.id.toNumber(),1)
        assert.equal(resource.name, 'Camilla')
        const usuario = await this.controlAcceso.addressToUser.call(this.firstUser)
        assert.equal(usuario.adminResources, 1)
    })
    it('request resource', async() => {
        const result = await this.controlAcceso.requestResource(1)
        const resourceRequested = await this.controlAcceso.idToResource.call(this.resource1.id)
        const adminUser = await this.controlAcceso.addressToUser(resourceRequested[3])
        assert.equal(adminUser.user, this.firstUser)
        assert.equal(adminUser.countRequests.toNumber(),1)
        //const userRequest = await this.controlAcceso.userRequest(resourceRequested[3])
        const requester = await this.controlAcceso.isRequested(1)
        assert.equal(requester, this.firstUser)
    })
    it('get request', async() => {
        //const result = await this.controlAcceso.getRequest(0)
        const resourceRequested = await this.controlAcceso.getRequest.call(0)
        //const adminUser = await this.controlAcceso.addressToUser(resourceRequested[3])
        assert.equal(resourceRequested[0], this.firstUser)
        assert.equal(resourceRequested[1], this.resource1.id)
        //assert.equal(adminUser.countRequests.toNumber(),1)
        //const userRequest = await this.controlAcceso.userRequest(resourceRequested[3])
        //const requester = await this.controlAcceso.isRequested(1)
        //assert.equal(requester, this.firstUser)
    })
    it('allow resource', async() => {
        const result = await this.controlAcceso.acceptRequest(this.firstUser, 1, 1);
        const haveAccess = await this.controlAcceso.haveAccess(1);
        assert.equal(haveAccess, true)
    })
    // it('user added successfully' async() => {
    //     const userList
    // })
}) */