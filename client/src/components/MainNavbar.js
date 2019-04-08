import React from "react";
import {FormControl, Button, Navbar, Nav, Form} from "react-bootstrap"
import { BrowserRouter as Router, Route, Link } from "react-router-dom";

class MainNavbar extends React.Component {
  render() {
    return (
      <Navbar bg="primary" variant="dark">
        <Navbar.Brand href="#home">112 Canarias</Navbar.Brand>
          <div>
            <Nav className="mr-auto">
              <Nav.Link as={Link} to="/resources">Recursos</Nav.Link>
              <Nav.Link as={Link} to="/request">Solicitudes</Nav.Link>
              <Nav.Link as={Link} to="/history">Historial</Nav.Link>
              <Nav.Link as={Link} to="/admin">Administrador</Nav.Link>
              </Nav>
            </div>
        <Form inline>
          <FormControl type="text" placeholder="Search" className="mr-sm-2" />
          <Button variant="outline-light">Search</Button>
        </Form>
      </Navbar>
    );
  }
}

export default MainNavbar;