import React from "react";
import {Table} from "react-bootstrap"
import ResourceRow from "./ResourceRow";


class ResourcesTable extends React.Component {
  state = { dataKey: null };

  componentDidMount() {
    const { drizzle } = this.props;
    const contract = drizzle.contracts.ControlAcceso;

    // let drizzle know we want to watch the `myString` method
    const dataKey = contract.methods['actualResourceId'].cacheCall();
    // const dataKey2 = contract.methods['actualResourceId'].cacheCall();
    // save the `dataKey` to local component state for later reference
    this.setState({ dataKey });
  }

  render() {
    const { ControlAcceso } = this.props.drizzleState.contracts;
    const actualResourceId = ControlAcceso.actualResourceId[this.state.dataKey];
    // const actualResourceId = ControlAcceso.actualResourceId[this.state.dataKey2];
    const rows = [];
    
    if(actualResourceId){
      //console.log(resourceCount)
      let i = 1;
      let j = 1;
      while (i <= actualResourceId.value) {
        //console.log(`i: ${i}`)
        //console.log(`j: ${j}`)
        let row = <ResourceRow
          {...this.props}
          resourceId={j}
          key={j}
        />;
        j++;
        
        if(row != null) {
          rows.push(row)
          i++;      
        }
        
      }
      /* for(var i=1; i<=resourceCount.value; i++){
        let row = <ResourceRow
          {...this.props}
          resourceId={i}
          key={i}
        />;
        if(row != null) {
          rows.push(row)
        }
      } */
    }

    return (
      <>
      <h1 className="d-flex justify-content-center">Recursos</h1>
      <Table responsive>
        <thead>
          <tr>
            <th>#</th>
            <th>Producto</th>
            <th>Descripción</th>
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
