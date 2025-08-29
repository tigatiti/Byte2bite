<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         import="java.sql.*, java.text.SimpleDateFormat, java.util.Date" %>
<%
    String firstName = (String) session.getAttribute("FirstName");
    String lastName  = (String) session.getAttribute("LastName");
    String role      = (String) session.getAttribute("role");

    String JDBC_URL    = "jdbc:mysql://localhost:3306/byte2bite?autoReconnect=true&useSSL=false";
    String DB_USER     = "root";
    String DB_PASSWORD = "";   //add your password

    String newRole = request.getParameter("new_role");
    String staffIdToUpdate = request.getParameter("staff_id");

    if (newRole != null && staffIdToUpdate != null) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD);
                 PreparedStatement ps2 = conn.prepareStatement("UPDATE staff_role SET role_name=? WHERE staff_id=?")) {
                ps2.setString(1, newRole);
                ps2.setInt(2, Integer.parseInt(staffIdToUpdate));
                int updated = ps2.executeUpdate();
                if (updated > 0) 
                {
                    out.println("<p class='success'>Role updated!</p>");
                }
            }
        } catch (Exception e) {
            out.println("<p class='error'>Error updating role: " + e.getMessage() + "</p>");
        }
    }

    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd"); 
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Manager Page</title>
    <link rel="stylesheet" href="/byte2bite-web/css/manage_employee.css?v=<%= System.currentTimeMillis() %>" />
</head>
<body>

    <div class="user-info">
        <%= role %> : <%= firstName %> <%= lastName %>
    </div>


    <div class="main-link-container">
        <a class="main-btn" href="<%= request.getContextPath() %>/managerHub.jsp">Main Page</a>
    </div>

    <h3>Active Employees</h3>
    <div class="employee-tables">
    <%
        String sql = "SELECT s.staff_id, s.first_name, s.last_name, r.role_name, r.start_date " +
                     "FROM Staff s " +
                     "JOIN staff_role r ON s.staff_id = r.staff_id " +
                     "WHERE s.staff_id NOT IN ( " +
                         "SELECT staff_id FROM staff_role WHERE role_name IN ('Admin','Manager','Terminated')" +
                     ") " +
                     "ORDER BY s.staff_id";
        try (Connection conn = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD);
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
    %>
        <table>
            <thead>
                <tr>
                    <th><strong>Staff ID</strong></th>
                    <th><strong>First Name</strong></th>
                    <th><strong>Last Name</strong></th>
                    <th><strong>Employee Since</strong></th>
                    <th><strong>Role</strong></th>
                </tr>
            </thead>
            <tbody>
            <%
                while (rs.next()) {
                    int staffId = rs.getInt("staff_id");
                    String fName = rs.getString("first_name");
                    String lName = rs.getString("last_name");
                    String roleName = rs.getString("role_name");
                    Date startDateObj = rs.getDate("start_date");
                    String startDateStr = (startDateObj != null) ? sdf.format(startDateObj) : "-";
            %>
                <tr>
                    <td><%= staffId %></td>
                    <td><%= fName %></td>
                    <td><%= lName %></td>
                    <td><%= startDateStr %></td>
                    <td>
                        <form method="post">
                            <input type="hidden" name="staff_id" value="<%= staffId %>">
                            <div class="custom-select">
                                <select name="new_role" onchange="this.form.submit()">
                                    <option value="Wait Staff" <%= "Wait Staff".equals(roleName) ? "selected" : "" %>>Wait Staff</option>
                                    <option value="Kitchen Staff" <%= "Kitchen Staff".equals(roleName) ? "selected" : "" %>>Kitchen Staff</option>
                                    <option value="Terminated" <%= "Terminated".equals(roleName) ? "selected" : "" %>>Terminated</option>
                                </select>
                            </div>
                        </form>
                    </td>
                </tr>
            <%
                }
            %>
            </tbody>
        </table>
    <%
        } catch (Exception e) {
    %>
        <p style="color:red;">Error loading active employees: <%= e.getMessage() %></p>
    <%
        }
    %>
    </div>

    <h4>Terminated Employees</h4>
    <div class="employee-tables">
    <%
        String sqlTerminated =
            "SELECT s.staff_id, s.first_name, s.last_name, r.role_name, r.start_date " +
            "FROM Staff s " +
            "JOIN staff_role r ON s.staff_id = r.staff_id " +
            "WHERE r.role_name = 'Terminated' ORDER BY s.staff_id";
        try (Connection conn2 = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD);
             PreparedStatement ps2 = conn2.prepareStatement(sqlTerminated);
             ResultSet rs2 = ps2.executeQuery()) {
    %>
        <table>
            <thead>
                <tr>
                    <th><strong>Staff ID</strong></th>
                    <th><strong>First Name</strong></th>
                    <th><strong>Last Name</strong></th>
                    <th><strong>Hired Date</strong></th>
                    <th><strong>Role</strong></th>
                </tr>
            </thead>
            <tbody>
            <%
                while (rs2.next()) {
                    int staffId = rs2.getInt("staff_id");
                    String fName = rs2.getString("first_name");
                    String lName = rs2.getString("last_name");
                    String roleName = rs2.getString("role_name");
                    Date startDateObj = rs2.getDate("start_date");
                    String startDateStr = (startDateObj != null) ? sdf.format(startDateObj) : "-";
            %>
                <tr>
                    <td><%= staffId %></td>
                    <td><%= fName %></td>
                    <td><%= lName %></td>
                    <td><%= startDateStr %></td>
                    <td>
                        <form method="post">
                            <input type="hidden" name="staff_id" value="<%= staffId %>">
                            <div class="custom-select">
                                <select name="new_role" onchange="this.form.submit()">
                                    <option value="" disabled selected>Terminated</option>
                                    <option value="Wait Staff">Wait Staff</option>
                                    <option value="Kitchen Staff">Kitchen Staff</option>
                                </select>
                            </div>
                        </form>
                    </td>
                </tr>
            <%
                }
            %>
            </tbody>
        </table>
    <%
        } catch (Exception e) {
    %>
        <p style="color:red;">Error loading terminated employees: <%= e.getMessage() %></p>
    <%
        }
    %>
    </div>
</body>
</html>
