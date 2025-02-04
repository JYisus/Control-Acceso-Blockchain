import React from 'react';
import ReactDOM from 'react-dom';
import './index.css';
import App from './App';
import * as serviceWorker from './serviceWorker';
import 'bootstrap/dist/css/bootstrap.css';

// import drizzle functions and contract artifact
import { Drizzle, generateStore } from "drizzle";
import ControlAcceso from "./contracts/ControlAcceso.json";

// let drizzle know what contracts we want and how to access our test blockchain
const options = {
  contracts: [ControlAcceso],
  web3: {
    fallback: {
      type: "ws",
      url: "ws://127.0.0.1:7545",
    },
  },
};

// setup drizzle
const drizzle = new Drizzle(options);

// ReactDOM.render(<App />, document.getElementById('root'));
ReactDOM.render(<App drizzle={drizzle} />, document.getElementById('root'));

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
