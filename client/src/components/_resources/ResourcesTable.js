import React from "react";
import {Table} from "react-bootstrap"
import ResourceRow from "./ResourceRow";


class ResourcesTable extends React.Component {
  state = { dataKey: null };

  componentDidMount() {
    const { drizzle } = this.props;
    const contract = drizzle.contracts.ControlAcceso;

    // let drizzle know we want to watch the `myString` method
    const dataKey = contract.methods['resourceCount'].cacheCall();
    const dataKey2 = contract.methods['actualResourceId'].cacheCall();
    // save the `dataKey` to local component state for later reference
    this.setState({ dataKey, dataKey2});
  }

  render() {
    const { ControlAcceso } = this.props.drizzleState.contracts;
    const resourceCount = ControlAcceso.resourceCount[this.state.dataKey];
    const actualResourceId = ControlAcceso.actualResourceId[this.state.dataKey2];
    const rows = [];
    
    if(actualResourceId){
      for(var i=1; i<=actualResourceId.value; i++){
        let row = <ResourceRow
          {...this.props}
          userId={i}
          key={i}
        />;
        if(row != null) {
          rows.push(row)
        }
      }
    }

    return (
      <>
      <h1 className="d-flex justify-content-center">Recursos</h1>
      <Table responsive>
        <thead>
          <tr>
            <th>#</th>
            <th>Producto</th>
            <th>Empresa</th>
            <th>#</th>
          </tr>
        </thead>
        <tbody>
          {rows}
          {/* <tr>
            <td>1</td>
            <td>Camilla</td>
            <td>Camillas SL</td>
            <td><Button variant="primary" size="sm">Solicitar</Button></td>
          </tr>
          <tr>
            <td>2</td>
            <td>Silla de ruedas</td>
            <td>Sillas SL</td>
            <td><Button variant="primary" size="sm" >Solicitar</Button></td>
          </tr>
          <tr>
            <td>3</td>
            <td>Lo que tal</td>
            <td>Tal SL</td>
            <td><Button variant="primary" size="sm">Solicitar</Button></td>
          </tr> */}
        </tbody>
      </Table>
      </>
    );
  }
}

export default ResourcesTable;
