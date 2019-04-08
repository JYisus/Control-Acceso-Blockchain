import React from "react";

class LoginUser extends React.Component {
  state = { dataKey: null };

  componentDidMount() {
    const { drizzle } = this.props;
    const contract = drizzle.contracts.ControlAcceso;

    // let drizzle know we want to watch the `myString` method
    const dataKey = contract.methods['userCount'].cacheCall();

    // save the `dataKey` to local component state for later reference
    this.setState({ dataKey });
  }

  render() {
    // get the contract state from drizzleState
    const { ControlAcceso } = this.props.drizzleState.contracts;

    // using the saved `dataKey`, get the variable we're interested in
    const userCount = ControlAcceso.userCount[this.state.dataKey];

    // if it exists, then we display its value
    return <p>Usuario: {userCount && userCount.value}</p>;
  }
}

export default LoginUser;