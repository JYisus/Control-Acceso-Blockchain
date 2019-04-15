import React from "react";
import {Row, Col} from "react-bootstrap"
import ResourcesTable from "./ResourcesTable"
import AddResource from "./AddResource"
import RemoveResource from "./RemoveResource"

class ResourcesView extends React.Component {
  componentDidMount() {
    const { drizzle } = this.props;
    const contract = drizzle.contracts.ControlAcceso;

    // let drizzle know we want to watch the `myString` method
    const dataKey = contract.methods['resourceCount'].cacheCall();

    // save the `dataKey` to local component state for later reference
    this.setState({ dataKey });
  }
  render() {
    return (
      <Row>
        <Col sm={6}>
          <ResourcesTable {...this.props} />
          
        </Col>
        <Col sm={6}>
          <AddResource {...this.props} />
        </Col>
      </Row>
    );
  }
}

export default ResourcesView;