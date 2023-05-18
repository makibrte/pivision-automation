import React, { useState } from 'react';
import './App.css';

function App() {
  const [date, setDate] = useState(new Date().toLocaleDateString());

  const updateDate = () => {
    setDate(new Date().toLocaleDateString());
  };

  return (
    <div className="App">
      <header className="App-header">
        <p>Last updated: {date}</p>
        <button onClick={updateDate}>Update Data</button>
      </header>
    </div>
  );
}

export default App;