import React, { useContext } from "react";
import { AuthContext } from "./AuthContext";
import { useNavigate } from "react-router-dom";

const LoginPage = () => {
  const { login } = useContext(AuthContext);
  const navigate = useNavigate();

  const handleLogin = () => {
    login();
    navigate("/");
  };

  return (
    <div style={{ textAlign: "center" }}>
      <h1>Login</h1>
      <form>
        <div>
          <input
            type="text"
            placeholder="Username"
            style={{ display: "block", margin: "0 auto" }}
          />
        </div>
        <div>
          <input
            type="password"
            placeholder="Password"
            style={{ display: "block", margin: "0 auto" }}
          />
        </div>
        <button
          type="button"
          onClick={handleLogin}
          style={{ fontSize: "18px", padding: "10px", marginTop: "10px" }}
        >
          Login
        </button>
      </form>
    </div>
  );
};

export default LoginPage;