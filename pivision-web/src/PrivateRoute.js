// PrivateRoute.js
import React from 'react';
import { Route, Navigate } from 'react-router-dom';

const PrivateRoute = ({ path, element }) => {
  const isLoggedIn = localStorage.getItem('isLoggedIn') === 'true'; // Replace this with your actual authentication logic

  return isLoggedIn ? (
    <Route path={path} element={element} />
  ) : (
    <Navigate to="/login" />
  );
};

export default PrivateRoute;
