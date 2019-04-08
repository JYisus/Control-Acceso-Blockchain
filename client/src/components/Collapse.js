import React from "react";
import {Button, Collapse} from "react-bootstrap"

class Example extends React.Component {
  constructor(props, context) {
    super(props, context);
  
    this.state = {
      open: false,
    };
  }
  
  render() {
    const { open } = this.state;
    return (
      <>
        <div class="card-header" id="headingOne">
          <h2 class="mb-0">
            <Button 
              onClick={() => this.setState({ open: !open })}
              aria-controls="example-collapse-text"
              aria-expanded={open}>
              Collapsible Group Item #1
            </Button>
          </h2>
        </div>
        <Collapse in={this.state.open}>
          <div id="example-collapse-text">
            Anim pariatur cliche reprehenderit, enim eiusmod high life accusamus
            terry richardson ad squid. Nihil anim keffiyeh helvetica, craft beer
            labore wes anderson cred nesciunt sapiente ea proident.
          </div>
        </Collapse>
      </>
    );
  }
}
  
export default Example;