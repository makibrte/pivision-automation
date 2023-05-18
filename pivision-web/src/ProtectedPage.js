import React, { useState } from 'react';

const ProtectedPage = () => {
  const [date, setDate] = useState(new Date().toLocaleDateString());

  const updateDate = () => {
    setDate(new Date().toLocaleDateString());
  };

  return (
    <div>
      <p>Current date: {date}</p>
      <button onClick={updateDate}>Update Data</button>
    </div>
  );
};

export default ProtectedPage;