<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body class="container my-5">


    <%  
      String firstName = (String) session.getAttribute("FirstName");
      String lastName  = (String) session.getAttribute("LastName");
      String role      = (String) session.getAttribute("role");
         

    String backPage = "employeeHub.jsp";
    if ("Kitchen Staff".equalsIgnoreCase(role)) {
        backPage = "chefHub.jsp";
    } else if ("Manager".equalsIgnoreCase(role)) {
        backPage = "managerHub.jsp";
    } else if ("Wait Staff".equalsIgnoreCase(role)) {
        response.sendRedirect("employeeHub.jsp");
    }

  %>

  <div class="position-relative mb-4" style="height:100px;">
    <div class="position-absolute top-0 start-0 d-flex flex-column align-items-center mt-3 ms-3">
      <a href="<%= backPage %>">
        <img src="<%= request.getContextPath() %>/images/logo3.png"
             alt="Byte2Bite Logo"
             style="height:80px; display:block;" />
      </a>
      <a href="<%= backPage %>" 
         class="btn btn-outline-secondary mt-2">
        &larr; Back to Hub
      </a>
    </div>

    <div class="position-absolute top-0 end-0 mt-3 me-3" style="height:40px;">
      <div class="bg-primary text-white px-3 rounded h-100 d-flex align-items-center">
        <%= role %> : <%= firstName %> <%= lastName %>
      </div>
    </div>
  </div>


    <div class="text-center mb-4">
        <h2>Inventory</h2>
    </div>

<%
    String JDBC_URL    = "jdbc:mysql://localhost:3306/byte2bite?useSSL=false";
    String DB_USER     = "root";
    String DB_PASSWORD = "";   //add your password

    Class.forName("com.mysql.cj.jdbc.Driver");
    try ( Connection con = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD) ) {

        try ( PreparedStatement psCust = con.prepareStatement(
                  "SELECT name, phone FROM Customer ORDER BY name"
              );
              ResultSet rsCust = psCust.executeQuery()
        ) {
            while (rsCust.next()) {
                String cname  = rsCust.getString("name");
                String cphone = rsCust.getString("phone");
%>
  <div class="card mb-4">
<div class="card-header text-white" style="background-color: #316bf4;">
      <strong><%= cname %></strong> | <%= cphone %>
    </div>
    <div class="card-body">
<%
                try ( PreparedStatement psTick = con.prepareStatement(
                          "SELECT t.ticket_id, t.placed_at " +
                          "  FROM tickets t " +
                          "  JOIN sessions s ON t.session_id = s.session_id " +
                          " WHERE s.customer_phone = ? " +
                          " ORDER BY t.placed_at ASC"
                      )
                ) {
                    psTick.setString(1, cphone);
                    try ( ResultSet rsTick = psTick.executeQuery() ) {
                        if (!rsTick.isBeforeFirst()) {
%>
      <p class="text-muted">No tickets found.</p>
<%
                        } else {
                            while (rsTick.next()) {
                                int ticId = rsTick.getInt("ticket_id");
                                Timestamp tp = rsTick.getTimestamp("placed_at");
%>
      <div class="mb-3">
        <div>
          <strong>Ticket #<%= ticId %></strong>
          <br><small class="text-muted">Placed: <%= tp %></small>
        </div>

        <ul class="list-group ms-3 mt-2">
<%
                                try ( PreparedStatement psOrd = con.prepareStatement(
                                          "SELECT m.name AS meal_name, m.price " +
                                          "  FROM orders o " +
                                          "  JOIN meal m ON o.meal_id = m.meal_id " +
                                          " WHERE o.ticket_id = ?"
                                      )
                                ) {
                                    psOrd.setInt(1, ticId);
                                    try ( ResultSet rsOrd = psOrd.executeQuery() ) {
                                        while (rsOrd.next()) {
                                            String meal  = rsOrd.getString("meal_name");
                                            double price = rsOrd.getDouble("price");
%>
          <li class="list-group-item d-flex justify-content-between">
            <span><%= meal %></span>
            <span>$<%= String.format("%.2f", price) %></span>
          </li>
<%
                                        }
                                    }
                                }
%>
        </ul>
      </div>
<%
                            }
                        }
                    }
                }
%>
    </div>
  </div>
<%
            }
        }
    } catch (Exception e) {
    }
%>
</body>
</html>
