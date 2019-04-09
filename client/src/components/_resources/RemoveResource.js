import React from "react";
import {Form, Button, Col, Row} from "react-bootstrap"

class RemoveResource extends React.Component {
  state = {stackId: null};
  constructor(props) {
    super(props);
    this.resourceId = React.createRef();

    this.handleSubmit = this.handleSubmit.bind(this);
  }

  handleSubmit(event) {
    event.preventDefault();
    const { drizzle, drizzleState} = this.props;
    const contract = drizzle.contracts.ControlAcceso;
    console.log(drizzleState.accounts[0])
    // let drizzle know we want to watch the `myString` method
    // const stackId = contract.methods['addResource'].cacheSend(this.inputName.current.value, this.inputOrganization.current.value);
    const stackId = contract.methods.removeResource.cacheSend(this.resourceId.current.value, {gas:300000});
    // save the `dataKey` to local component state for later reference
    this.setState({ stackId });

    this.input = '';
    //event.preventDefault();
  }

/*   state = { dataKey: null };
*/

  render() {
    // get the contract state from drizzleState
    // const { ControlAcceso } = this.props.drizzleState.contracts;

    // using the saved `dataKey`, get the variable we're interested in
   //  const user = ControlAcceso.idToUser[this.state.dataKey];

    // if it exists, then we display its value
    return (
      <>
      <h1 className="d-flex justify-content-center">Eliminar recurso</h1>
      <Form>
        <Form.Group as={Row} controlId="formPlaintextResourceName">
          <Form.Label column sm="2">
            Indentificador
          </Form.Label>
          <Col sm="10">
            <Form.Control name="resourceId" type="number" placeholder="#" ref={this.resourceId}/>
          </Col>
        </Form.Group>
        <div className="d-flex justify-content-center">
          <Button type="submit" onClick={this.handleSubmit}>Eliminar</Button>
        </div>
      </Form>
      </>
    );
  }
}

export default RemoveResource;