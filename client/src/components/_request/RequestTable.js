import React from "react";
import {Table} from "react-bootstrap"
import RequestRow from "./RequestRow";


class RequestTable extends React.Component {
  state = { dataKey: null };

  componentDidMount() {
    const { drizzle } = this.props;
    const contract = drizzle.contracts.ControlAcceso;

    // let drizzle know we want to watch the `myString` method
    const dataKey = contract.methods['getCountRequest'].cacheCall();
    // save the `dataKey` to local component state for later reference
    this.setState({ dataKey });
  }

  render() {
    const { ControlAcceso } = this.props.drizzleState.contracts;

    const countRequest = ControlAcceso.getCountRequest[this.state.dataKey];
    
    const rows = [];
    
    if(countRequest){
      console.log(countRequest.value)
      for(var i=0; i<countRequest.value; i++){
        rows.push(
          <RequestRow
            {...this.props}
            idReq={i}
            key={i}
          />
        )
      }
    }

    return (
      <>
      <h1 className="d-flex justify-content-center">Solicitudes</h1>
      <Table responsive>
        <thead>
          <tr>
            <th>Producto</th>
            <th>Solicitante</th>
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

export default RequestTable;
