var ControlAcceso = artifacts.require("./ControlAcceso.sol");

module.exports = function(deployer) {
  deployer.deploy(ControlAcceso);
};
