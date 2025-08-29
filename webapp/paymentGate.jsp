<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html>
<head>
  <title>Payment Gateway — Open Sessions</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="container my-5">
  <h2 class="mb-4">Open Sessions &amp; Their Orders</h2>


      <%  
      String firstName = (String) session.getAttribute("FirstName");
      String lastName  = (String) session.getAttribute("LastName");
      String role      = (String) session.getAttribute("role");
         

    String backPage = "managerHub.jsp";
    if ("Kitchen Staff".equalsIgnoreCase(role)) {
        response.sendRedirect("chefHub.jsp");
    } else if ("Manager".equalsIgnoreCase(role)) {
        backPage = "managerHub.jsp";
    } else if ("Wait Staff".equalsIgnoreCase(role)) {
        backPage = "employeeHub.jsp";
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
        <h2>Payment Gate</h2>
    </div>


<%
    String JDBC_URL    = "jdbc:mysql://localhost:3306/byte2bite?autoReconnect=true&useSSL=false&serverTimezone=UTC";
    String DB_USER     = "root";
    String DB_PASSWORD = "";  //add your password

    String closeSessionId = request.getParameter("close_session_id");
    if (closeSessionId != null) {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try ( Connection con = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD) ) {
            con.setAutoCommit(false);

            try ( PreparedStatement psClose = con.prepareStatement(
                      "UPDATE sessions SET closed_at = NOW() WHERE session_id = ?"
                  ) ) {
                psClose.setInt(1, Integer.parseInt(closeSessionId));
                psClose.executeUpdate();
            }

            try ( PreparedStatement psPay = con.prepareStatement(
                      "INSERT INTO payment (session_id, amount, paid_at) " +
                      "VALUES (?, (SELECT SUM(m.price) " +
                                 "FROM tickets t " +
                                 " JOIN orders o ON t.ticket_id = o.ticket_id " +
                                 " JOIN meal m   ON o.meal_id   = m.meal_id " +
                                 "WHERE t.session_id = ?), NOW())"
                  ) ) {
                int sid = Integer.parseInt(closeSessionId);
                psPay.setInt(1, sid);
                psPay.setInt(2, sid);
                psPay.executeUpdate();
            }

            con.commit();
            response.sendRedirect("paymentGate.jsp");

            return;
        } catch (Exception e) {
            out.println(String.format(
              "Error closing session %s: %s",
              closeSessionId, e.getMessage()
            ));
        }
    }


    try ( Connection con = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD);
          PreparedStatement psSess = con.prepareStatement(
              "SELECT session_id, table_id, started_at " +
              "FROM sessions WHERE closed_at IS NULL ORDER BY started_at ASC"
          );
          ResultSet rsSess = psSess.executeQuery()
    ) {
        while (rsSess.next()) {
            int sessionId   = rsSess.getInt("session_id");
            Integer tableId = rsSess.getObject("table_id") != null
                              ? rsSess.getInt("table_id") : null;
            Timestamp startedAt = rsSess.getTimestamp("started_at");
%>
  <div class="card mb-4">
    <div class="card-header bg-primary text-white">
      <div class="d-flex justify-content-between align-items-center">
        <div>
          <strong>Receipt #<%= sessionId %></strong>
          <% if (tableId != null) { %>| Table <%= tableId %><% } %>
          — Started <%= new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(startedAt) %>
        </div>
        <form method="post" style="margin:0;">
          <input type="hidden" name="close_session_id" value="<%= sessionId %>"/>
          <button type="submit" class="btn btn-sm btn-success">Mark as Paid</button>
        </form>
      </div>
    </div>
    <div class="card-body">
<%
            String ordersSql =
                "SELECT m.name AS meal_name, m.price " +
                "FROM tickets t " +
                " JOIN orders o ON t.ticket_id = o.ticket_id " +
                " JOIN meal m   ON o.meal_id   = m.meal_id " +
                "WHERE t.session_id = ? ORDER BY m.name";
            try ( PreparedStatement psAll = con.prepareStatement(ordersSql) ) {
                psAll.setInt(1, sessionId);
                try ( ResultSet rsAll = psAll.executeQuery() ) {
                    if (!rsAll.isBeforeFirst()) {
%>
      <p class="text-muted">No orders yet.</p>
<%
                    } else {
                        double total = 0.0;  
                        while (rsAll.next()) {
                            String meal  = rsAll.getString("meal_name");
                            double price = rsAll.getDouble("price");
                            total += price;
%>
        <li class="list-group-item d-flex justify-content-between">
          <span><%= meal %></span>
          <span>$<%= String.format("%.2f", price) %></span>
        </li>
<%
    }
%>
      </ul>
      <div class="mt-3 text-end">
        <strong>Total: $<%= String.format("%.2f", total) %></strong>
      </div>
<%
                    }
                }
            }
%>
    </div>
  </div>
<%
        }
    } catch (Exception e) {
    }
%>
</body>
</html>
