import React, { Component } from 'react';
// import logo from './logo.svg';
import './App.css';
import LoginUser from "./LoginUser";
import MainNavbar from "./components/MainNavbar"
import ResourcesView from "./components/_resources/ResourcesView"
import { BrowserRouter as Router, Route, Link } from "react-router-dom";
//import AddResource from "./components/_resources/AddResource"
import RequestView from "./components/_request/RequestView"
import {Container, Row, Col} from "react-bootstrap"
//import Example from './components/Collapse';
import AdminView from './components/_admin/AdminView';

class App extends Component {
  state = { loading: true, drizzleState: null };
  componentDidMount() {
    const { drizzle } = this.props;
  
    // subscribe to changes in the store
    this.unsubscribe = drizzle.store.subscribe(() => {
  
      // every time the store updates, grab the state from drizzle
      const drizzleState = drizzle.store.getState();
  
      // check to see if it's ready, if so, update local component state
      if (drizzleState.drizzleStatus.initialized) {
        this.setState({ loading: false, drizzleState });
      }
    });
  }
  componentWillUnmount() {
    this.unsubscribe();
  }
  render() {
    if (this.state.loading) return "Loading Drizzle...";
  return (
    <>
    <Router>
      <MainNavbar/>
      <Container fluid="true">
        <Row>
          <Col sm={12}>
            {/* <Example/> */}
            <Route path="/" exact render={
              (props) => <ResourcesView {...props} drizzle={this.props.drizzle}
              drizzleState={this.state.drizzleState} />} 
            />
            <Route path="/resources/" exact render={
              (props) => <ResourcesView {...props} drizzle={this.props.drizzle}
              drizzleState={this.state.drizzleState} />} 
            />
            <Route path="/request/" render={
              (props) => <RequestView {...props} drizzle={this.props.drizzle}
              drizzleState={this.state.drizzleState} />} 
            />
            <Route path="/history/" render={
              (props) => <LoginUser {...props} drizzle={this.props.drizzle}
              drizzleState={this.state.drizzleState} />} 
            />
            <Route path="/admin/" render={
              (props) => <AdminView {...props} drizzle={this.props.drizzle}
              drizzleState={this.state.drizzleState} />} 
            />
          </Col>
        </Row>
      </Container>
    </Router>
    </>
    
    
    
      
      /* <button type="button" className="btn btn-primary">Login</button>
      <div className="App">
        <LoginUser
          drizzle={this.props.drizzle}
          drizzleState={this.state.drizzleState}
        />
      </div> 
    </div>*/
  );
  }
}

export default App;
