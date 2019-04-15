import React from "react";
import {Button} from "react-bootstrap"

class ResourceRow extends React.Component {
  state = { dataKey: null };
  constructor(props) {
    super(props);

    // this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
    this.handleRemove = this.handleRemove.bind(this);
  }

  componentDidMount() {
    const { drizzle } = this.props;
    const contract = drizzle.contracts.ControlAcceso;

    // let drizzle know we want to watch the `myString` method
    const dataKey = contract.methods['idToResource'].cacheCall(this.props.userId);

    // save the `dataKey` to local component state for later reference
    this.setState({ dataKey });
  }

  handleRemove(id, event) {
    event.preventDefault();
    const { drizzle, drizzleState} = this.props;
    const contract = drizzle.contracts.ControlAcceso;
    console.log(drizzleState.accounts[0])
    // let drizzle know we want to watch the `myString` method
    // const stackId = contract.methods['addResource'].cacheSend(this.inputName.current.value, this.inputOrganization.current.value);
    const stackId = contract.methods.removeResource.cacheSend(id, {gas:300000});
    // save the `dataKey` to local component state for later reference
    this.setState({ stackId });

    this.input = '';
    //event.preventDefault();
  }

  handleSubmit(id, event) {
    event.preventDefault();
    const { drizzle, drizzleState} = this.props;
    const contract = drizzle.contracts.ControlAcceso;
    console.log(drizzleState.accounts[0])
    // let drizzle know we want to watch the `myString` method
    // const stackId = contract.methods['addResource'].cacheSend(this.inputName.current.value, this.inputOrganization.current.value);
    const stackId = contract.methods.requestResource.cacheSend(id, {gas:300000});
    // save the `dataKey` to local component state for later reference
    this.setState({ stackId });

    //const form = event.target;
    //const data = new FormData(form);
    console.log(id)
    // this.input = '';
    //event.preventDefault();
  }

  render() {
    // get the contract state from drizzleState
    const { ControlAcceso } = this.props.drizzleState.contracts;

    // using the saved `dataKey`, get the variable we're interested in
    const resource = ControlAcceso.idToResource[this.state.dataKey];
    let button;

    if(resource && resource.value[3] === this.props.drizzleState.accounts[0]) {
      button = <Button onClick={this.handleRemove.bind(this, resource && resource.value[0])} variant="danger" size="sm">Eliminar</Button>
    }
    else {
      button = <Button onClick={this.handleSubmit.bind(this, resource && resource.value[0])} variant="primary" size="sm">Solicitar</Button>
    }
    if (resource && (resource.value[0] == 0)) {
      return null;
    }
    return (
      <tr>
        <td>{resource && resource.value[0]}</td>
        <td>{resource && resource.value[1]}</td>
        <td>{resource && resource.value[2]}</td>
        <td>{button}</td>
      </tr>
    );
  }
}

export default ResourceRow;