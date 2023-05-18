import React, { useState } from 'react';

const DateComponent = () => {
  const [date, setDate] = useState(new Date().toLocaleDateString());

  const updateDate = () => {
    setDate(new Date().toLocaleDateString());
  };

  return (
    <div>
      <h1>{date}</h1>
      <button onClick={updateDate}>Update Data</button>
    </div>
  );
};

export default DateComponent;