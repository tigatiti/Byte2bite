<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         import="java.sql.*, java.util.*" %>
<%
    request.setCharacterEncoding("UTF-8");

    String tableIdParam    = request.getParameter("table_id");
    String newStatus       = request.getParameter("new_status");
    String newStaffId      = request.getParameter("new_staff_id");
    String customerName    = request.getParameter("customer_name");
    String customerPhone   = request.getParameter("customer_phone");
    String clearParam      = request.getParameter("clear");

    boolean success = true;
    Connection con = null;

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String JDBC_URL    = "jdbc:mysql://localhost:3306/byte2bite?autoReconnect=true&useSSL=false&serverTimezone=UTC";
        String DB_USER     = "root";
        String DB_PASSWORD = "";   //add your password

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD);
            con.setAutoCommit(false);

  
            if (clearParam != null && !clearParam.isBlank()) {
                int tableId = Integer.parseInt(clearParam);

 
                Long existingSessionId = null;
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT session_id FROM TableChart WHERE table_id = ?")) {
                    ps.setInt(1, tableId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next() && rs.getObject("session_id") != null) {
                            existingSessionId = rs.getLong("session_id");
                        }
                    }
                }
                if (existingSessionId != null) {
                    try (PreparedStatement ps = con.prepareStatement(
                            "UPDATE sessions SET closed_at = CURRENT_TIMESTAMP WHERE session_id = ? AND closed_at IS NULL")) {
                        ps.setLong(1, existingSessionId);
                        ps.executeUpdate();
                    }
                }


                try (PreparedStatement ps = con.prepareStatement(
                        "UPDATE TableChart "
                      + "SET status = 'Available', "
                      + "    table_staff_id = NULL, "
                      + "    staff_assigned_time = NULL, "
                      + "    customer_phone = NULL, "
                      + "    session_id = NULL "
                      + "WHERE table_id = ?")) {
                    ps.setInt(1, tableId);
                    ps.executeUpdate();
                }
            }


            else if (tableIdParam != null && newStatus != null) {
                int tableId = Integer.parseInt(tableIdParam);
                Integer staffId = null;
                if (newStaffId != null && !newStaffId.isBlank()) {
                    staffId = Integer.valueOf(newStaffId);
                }


                String  currentTableStatus = null;
                Long    currentSessionId   = null;
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT status, session_id FROM TableChart WHERE table_id = ?")) {
                    ps.setInt(1, tableId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            currentTableStatus = rs.getString("status");
                            if (rs.getObject("session_id") != null) {
                                currentSessionId = rs.getLong("session_id");
                            }
                        }
                    }
                }


                String resolvedPhone = (customerPhone != null) ? customerPhone.trim() : null;
                if (resolvedPhone != null && !resolvedPhone.isBlank()) {
                    boolean exists = false;
                    try (PreparedStatement ps = con.prepareStatement(
                            "SELECT 1 FROM Customer WHERE phone = ?")) {
                        ps.setString(1, resolvedPhone);
                        try (ResultSet rs = ps.executeQuery()) {
                            exists = rs.next();
                        }
                    }
                    if (exists) {
                        if (customerName != null && !customerName.isBlank()) {
                            try (PreparedStatement ps = con.prepareStatement(
                                    "UPDATE Customer SET name = ? WHERE phone = ?")) {
                                ps.setString(1, customerName.trim());
                                ps.setString(2, resolvedPhone);
                                ps.executeUpdate();
                            }
                        }
                    } else {
                        try (PreparedStatement ps = con.prepareStatement(
                                "INSERT INTO Customer (phone, name) VALUES (?, ?)")) {
                            ps.setString(1, resolvedPhone);
                            ps.setString(2, (customerName != null ? customerName.trim() : ""));
                            ps.executeUpdate();
                        }
                    }
                } else {
                    resolvedPhone = null;
                }


                if (!"Available".equalsIgnoreCase(newStatus)) {
                    if ((currentSessionId == null || "Available".equalsIgnoreCase(currentTableStatus))
                        && staffId != null) {

                        String insertSessionSql =
                           "INSERT INTO sessions (table_id, staff_id, customer_phone) "
                         + "VALUES (?, ?, ?)";

                        try (PreparedStatement ps = con.prepareStatement(
                                 insertSessionSql, Statement.RETURN_GENERATED_KEYS)) {
                            ps.setInt(1, tableId);
                            ps.setInt(2, staffId);
                            if (resolvedPhone != null) ps.setString(3, resolvedPhone);
                            else                        ps.setNull(3, Types.VARCHAR);

                            ps.executeUpdate();
                            try (ResultSet gen = ps.getGeneratedKeys()) {
                                if (gen.next()) {
                                    currentSessionId = gen.getLong(1);
                                }
                            }
                        }
                    }


                    String updateChartSql =
                       "UPDATE TableChart SET "
                     + "  status              = ?, "
                     + "  table_staff_id      = ?, "
                     + "  staff_assigned_time = CURRENT_TIMESTAMP, "
                     + "  customer_phone      = ?, "
                     + "  session_id          = ? "
                     + "WHERE table_id = ?";
                    try (PreparedStatement ps = con.prepareStatement(updateChartSql)) {
                        int idx = 1;
                        ps.setString(idx++, newStatus);
                        if (staffId != null) ps.setInt(idx++, staffId);
                        else                  ps.setNull(idx++, Types.INTEGER);

                        if (resolvedPhone != null) ps.setString(idx++, resolvedPhone);
                        else                        ps.setNull(idx++, Types.VARCHAR);

                        if (currentSessionId != null) ps.setLong(idx++, currentSessionId);
                        else                          ps.setNull(idx++, Types.BIGINT);

                        ps.setInt(idx++, tableId);
                        ps.executeUpdate();
                    }
                }

                else {
                    if (currentSessionId != null) {
                        try (PreparedStatement ps = con.prepareStatement(
                                "UPDATE sessions SET closed_at = CURRENT_TIMESTAMP WHERE session_id = ? AND closed_at IS NULL")) {
                            ps.setLong(1, currentSessionId);
                            ps.executeUpdate();
                        }
                    }
                    try (PreparedStatement ps = con.prepareStatement(
                            "UPDATE TableChart "
                          + "SET status = 'Available', "
                          + "    table_staff_id = NULL, "
                          + "    staff_assigned_time = NULL, "
                          + "    customer_phone = NULL, "
                          + "    session_id = NULL "
                          + "WHERE table_id = ?")) {
                        ps.setInt(1, tableId);
                        ps.executeUpdate();
                    }
                }
            }

            con.commit();
        } catch (Exception ex) {
            success = false;
            if (con != null) try { con.rollback(); } catch (Exception ignore) {}
            out.println("<div style='color:red;'>Update failed: " + ex.getMessage() + "</div>");
        } finally {
            if (con != null) try { con.close(); } catch (Exception ignore) {}
        }

        if (success) {
            response.sendRedirect("viewTables.jsp");
            return;
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Update Table Status</title>
</head>
<body>
  <h1>Change Table Status</h1>
  <form method="post" action="updateTable.jsp">
    <label>Table ID:
      <input type="number" name="table_id" required
             value="<%= tableIdParam != null ? tableIdParam : "" %>">
    </label><br/><br/>

    <label>New Status:
      <select name="new_status">
        <option value="Available"
         <%= "Available".equalsIgnoreCase(newStatus) ? "selected" : "" %>>
          Available
        </option>
        <option value="Occupied"
         <%= "Occupied".equalsIgnoreCase(newStatus) ? "selected" : "" %>>
          Occupied
        </option>
        <option value="Reserved"
         <%= "Reserved".equalsIgnoreCase(newStatus) ? "selected" : "" %>>
          Reserved
        </option>
      </select>
    </label><br/><br/>

    <label>Staff ID:
      <input type="number" name="new_staff_id"
             value="<%= newStaffId != null ? newStaffId : "" %>">
    </label><br/><br/>

    <label>Customer Name:
      <input type="text" name="customer_name"
             value="<%= customerName != null ? customerName : "" %>">
    </label><br/><br/>

    <label>Customer Phone:
      <input type="text" name="customer_phone"
             value="<%= customerPhone != null ? customerPhone : "" %>">
    </label><br/><br/>

    <button type="submit">Update</button>
    <button type="submit" name="clear" value="<%= tableIdParam != null ? tableIdParam : "" %>">
      Clear &amp; Make Available
    </button>
  </form>
</body>
</html>
