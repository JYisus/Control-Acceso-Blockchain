import React from "react";
import {Form, Button, Col, Row} from "react-bootstrap"

class ResourceRow extends React.Component {
  state = {stackId: null};
  constructor(props) {
    super(props);
    this.inputName = React.createRef();
    this.inputDescription = React.createRef();

    // this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
  }

  /* handleChange(event) {
    this.setState({value: event.target.value});
  } */
/*   componentDidMount() {
    const { drizzle } = this.props;
    const contract = drizzle.contracts.ControlAcceso;

    // let drizzle know we want to watch the `myString` method
    const dataKey = contract.methods['addResource'].cacheCall(this.props.userId);

    // save the `dataKey` to local component state for later reference
    this.setState({ dataKey });
  } */

  handleSubmit(event) {
    event.preventDefault();
    const { drizzle, drizzleState} = this.props;
    const contract = drizzle.contracts.ControlAcceso;
    console.log(drizzleState.accounts[0])
    // let drizzle know we want to watch the `myString` method
    // const stackId = contract.methods['addResource'].cacheSend(this.inputName.current.value, this.inputOrganization.current.value);
    const stackId = contract.methods.addResource.cacheSend(this.inputName.current.value, this.inputDescription.current.value, {gas:6721975});
    // save the `dataKey` to local component state for later reference
    this.setState({ stackId });

    //const form = event.target;
    //const data = new FormData(form);
    console.log(this.inputName.current.value)
    console.log(this.inputDescription.current.value)
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
      <h1 className="d-flex justify-content-center">Añadir recurso</h1>
      <Form>
        <Form.Group as={Row} controlId="formPlaintextResourceName">
          <Form.Label column sm="2">
            Nombre
          </Form.Label>
          <Col sm="10">
            <Form.Control name="resourceName" plaintext placeholder="Camillas" ref={this.inputName}/>
          </Col>
        </Form.Group>
      
        <Form.Group as={Row} controlId="formPlaintextOrganizationName">
          <Form.Label column sm="2">
            Descripción
          </Form.Label>
          <Col sm="10">
            <Form.Control name="resourceDescription" plaintext placeholder="Description" ref={this.inputDescription}/>
          </Col>
        </Form.Group>
        <div className="d-flex justify-content-center">
          <Button type="submit" onClick={this.handleSubmit}>Añadir</Button>
        </div>
      </Form>
      </>
    );
  }
}

export default ResourceRow;