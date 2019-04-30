import React from "react";
import {Form, Button, Col, Row} from "react-bootstrap"

class AddUser extends React.Component {
  state = {stackId: null};
  constructor(props) {
    super(props);
    this.newUserAddress = React.createRef();
    this.newUserName = React.createRef();
    this.inputAdmin = React.createRef();

    // this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
  }

  handleSubmit(event) {
    event.preventDefault();
    const { drizzle, drizzleState} = this.props;
    const contract = drizzle.contracts.ControlAcceso;
    // console.log(drizzleState.accounts[0])
    // let drizzle know we want to watch the `myString` method
    // const stackId = contract.methods['addResource'].cacheSend(this.inputName.current.value, this.inputOrganization.current.value);
    let admin = false;
    if(this.inputAdmin.current.value === 'on')
    {
      admin = true;
    }
    const stackId = contract.methods.addUser.cacheSend(this.newUserAddress.current.value, this.newUserName.current.value, admin, {gas:6721975});
    // save the `dataKey` to local component state for later reference
    this.setState({ stackId });
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

    //const form = event.target;
    //const data = new FormData(form);
    //console.log(this.inputName.current.value)
    console.log(this.inputAdmin.current.value)
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
      <h1 className="d-flex justify-content-center">Añadir usuario</h1>
      <Form>
        <Form.Group as={Row} controlId="formPlaintextNewUserName">
          <Form.Label column sm="2">
            Dirección
          </Form.Label>
          <Col sm="10">
            <Form.Control name="newUserAddress" plaintext placeholder="address" ref={this.newUserAddress}/>
          </Col>
        </Form.Group>
        <Form.Group as={Row} controlId="formPlaintextNewUserName">
          <Form.Label column sm="2">
            Nombre
          </Form.Label>
          <Col sm="10">
            <Form.Control name="newUserName" plaintext placeholder="username" ref={this.newUserName}/>
          </Col>
        </Form.Group>

        <div key={`default-checkbox`} className="mb-3">
          <Form.Check 
            type='checkbox'
            id={`default-checkbox`}
            label={`Admin`}ref={this.inputAdmin}

          />
        </div>
        <div className="d-flex justify-content-center">
          <Button type="submit" onClick={this.handleSubmit}>Añadir</Button>
        </div>
      </Form>
      </>
    );
  }
}

export default AddUser;