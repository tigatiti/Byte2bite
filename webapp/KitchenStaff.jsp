<%@ page import="java.sql.*" %>
<%@ page import="java.time.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%!
    String formatElapsed(Timestamp ts) {
        if (ts == null) return "N/A";
        Instant created = ts.toInstant();
        Duration diff = Duration.between(created, Instant.now());
        long totalMinutes = diff.toMinutes();
        long hours = totalMinutes / 60;
        long minutes = totalMinutes % 60;
        if (hours > 0) return hours + "h " + minutes + "m ago";
        return minutes + "m ago";
    }
%>

<%
    // Database configuration
    String DB_USER     = "root";
    String DB_PASSWORD = "";   //add your password
    String JDBC_URL    = "jdbc:mysql://localhost:3306/byte2bite?autoReconnect=true&useSSL=false";

    // Handle status updates
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String updateTicketId = request.getParameter("update_ticket_id");
        String newStatus      = request.getParameter("new_status");

        if (updateTicketId != null && newStatus != null) {
            try (Connection conn = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD)) {
                conn.setAutoCommit(false);

                // Update ticket status
                try (PreparedStatement ps = conn.prepareStatement(
                            "UPDATE tickets SET status=? WHERE ticket_id=?")) {
                    ps.setString(1, newStatus);
                    ps.setInt(2, Integer.parseInt(updateTicketId));
                    ps.executeUpdate();
                }

                // Deduct inventory when moving to 'Ready' or 'Completed'
                if ("Ready".equalsIgnoreCase(newStatus)
                 || "Completed".equalsIgnoreCase(newStatus)) {

                    String deductSql =
                      "UPDATE Food_Inventory fi "
                    + "JOIN ( "
                    + "  SELECT mw.item_name, SUM(mw.quantity) AS total_qty "
                    + "  FROM made_with mw "
                    + "  JOIN orders o ON o.meal_id = mw.meal_id "
                    + "  WHERE o.ticket_id = ? "
                    + "  GROUP BY mw.item_name "
                    + ") t ON fi.item_name = t.item_name "
                    + "SET fi.quantity = fi.quantity - t.total_qty";

                    try (PreparedStatement psDeduct = conn.prepareStatement(deductSql)) {
                        psDeduct.setInt(1, Integer.parseInt(updateTicketId));
                        psDeduct.executeUpdate();
                    }
                }

                conn.commit();
                response.sendRedirect("KitchenStaff.jsp");
                return;
            } catch (Exception e) {
                out.println("<div class='alert alert-danger'>Error updating status: "
                          + e.getMessage() + "</div>");
            }
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8" />
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
  <title>Kitchen Staff Dashboard</title>
</head>
<body class="container position-relative mt-5">

  <%  // Header and navigation %>
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
        <img src="<%= request.getContextPath() %>/images/logo3.png" alt="Byte2Bite Logo" style="height:80px; display:block;" />
      </a>
      <a href="<%= backPage %>" class="btn btn-outline-secondary mt-2">&larr; Back to Hub</a>
    </div>

    <div class="position-absolute top-0 end-0 mt-3 me-3" style="height:40px;">
      <div class="bg-primary text-white px-3 rounded h-100 d-flex align-items-center">
        <%= role %> : <%= firstName %> <%= lastName %>
      </div>
    </div>
  </div>

  <div class="text-center mb-4">
    <h2>Ticket Status</h2>
  </div>

  <%-- Active Tickets --%>
  <%
    String activeSql =
      "SELECT t.ticket_id, t.status AS ticket_status, t.placed_at, "
    + "       o.meal_id, o.note, m.name AS meal_name "
    + "FROM tickets t "
    + "JOIN orders o ON o.ticket_id = t.ticket_id "
    + "JOIN meal m   ON o.meal_id    = m.meal_id "
    + "WHERE t.status NOT IN ('Ready','Completed') "
    + "ORDER BY t.placed_at DESC, t.ticket_id";

    try (Connection conn = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD);
         PreparedStatement ps = conn.prepareStatement(activeSql);
         ResultSet rs = ps.executeQuery()) {

        long lastTicketId = -1;
        boolean anyActive = false;

        while (rs.next()) {
            anyActive = true;
            int ticketId       = rs.getInt("ticket_id");
            Timestamp placedAt = rs.getTimestamp("placed_at");
            String mealName    = rs.getString("meal_name");
            String note        = rs.getString("note");
            String elapsed     = formatElapsed(placedAt);

            if (ticketId != lastTicketId) {
                // close previous card
                if (lastTicketId != -1) { %>
      </div>
    </div>
<%          }
%>  <div class="card mb-4 mt-4">
      <div class="card-header d-flex justify-content-between align-items-center">
        <div>
          <strong>Ticket #<%= ticketId %></strong>
          <div class="small text-muted">Placed: <%= elapsed %></div>
        </div>
        <div class="d-flex align-items-center gap-2">
          <form method="post" class="d-inline">
            <input type="hidden" name="update_ticket_id" value="<%= ticketId %>">
            <input type="hidden" name="new_status" value="Preparing">
            <button class="btn btn-sm btn-warning"
                    <%= "Preparing".equalsIgnoreCase(rs.getString("ticket_status")) ? "disabled" : "" %>>
              Preparing</button>
          </form>
          <form method="post" class="d-inline ms-1">
            <input type="hidden" name="update_ticket_id" value="<%= ticketId %>">
            <input type="hidden" name="new_status" value="Ready">
            <button class="btn btn-sm btn-success"
                    <%= "Ready".equalsIgnoreCase(rs.getString("ticket_status")) ? "disabled" : "" %>>
              Ready</button>
          </form>
        </div>
      </div>
      <div class="card-body">
        <% if (note != null && !note.isBlank()) { %>
          <div class="alert alert-secondary mb-3">
            <strong>Note:</strong> <%= note %>
          </div>
        <% } %>
<%              lastTicketId = ticketId;
            }
%>        <div class="mb-2"><strong><%= mealName %></strong></div>
<%        }
        if (anyActive) { %>
      </div>
    </div>
<%    } else { %>
    <p>No active tickets.</p>
<%    }
    } catch (Exception e) {
        out.println("<div class='alert alert-danger'>Error loading active tickets: "
                  + e.getMessage() + "</div>");
    }
  %>

  <h3 class="mt-5">Ready Tickets</h3>
  <%
    String readySql =
      "SELECT t.ticket_id, t.placed_at, o.note, m.name AS meal_name "
    + "FROM tickets t "
    + "JOIN orders o ON o.ticket_id = t.ticket_id "
    + "JOIN meal m   ON o.meal_id    = m.meal_id "
    + "WHERE t.status = 'Ready' "
    + "ORDER BY t.placed_at ASC, t.ticket_id";

    try (Connection conn2 = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD);
         PreparedStatement ps2 = conn2.prepareStatement(readySql);
         ResultSet rs2 = ps2.executeQuery()) {

        long lastReadyId = -1;
        boolean anyReady = false;

        while (rs2.next()) {
            anyReady = true;
            int ticketId    = rs2.getInt("ticket_id");
            Timestamp placedAt = rs2.getTimestamp("placed_at");
            String mealName = rs2.getString("meal_name");
            String note     = rs2.getString("note");
            String elapsed  = formatElapsed(placedAt);

            if (ticketId != lastReadyId) {
                if (lastReadyId != -1) { %>
      </div>
    </div>
<%              }
%>    <div class="card mb-4">
      <div class="card-header">
        <strong>Ticket #<%= ticketId %></strong>
        <div class="small text-muted">Placed: <%= elapsed %></div>
      </div>
      <div class="card-body">
        <% if (note != null && !note.isBlank()) { %>
          <div class="alert alert-secondary mb-3">
            <strong>Note:</strong> <%= note %>
          </div>
        <% } %>
<%              lastReadyId = ticketId;
            }
%>        <div class="mb-2"><strong><%= mealName %></strong></div>
<%        }
        if (anyReady) { %>
      </div>
    </div>
<%    } else { %>
    <p>No ready tickets.</p>
<%    }
    } catch (Exception e) {
        out.println("<div class='alert alert-danger'>Error loading ready tickets: "
                  + e.getMessage() + "</div>");
    }
  %>

</body>
</html>
