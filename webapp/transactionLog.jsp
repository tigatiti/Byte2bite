<%@ page import="java.sql.*, java.util.*" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Byte2Bite: Transaction Log</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body class="container mt-5">

   
    <div class="position-relative mb-4">
        <a href="managerHub.jsp" class="btn btn-outline-secondary position-absolute top-0 start-0">&larr; Back to Hub</a>
        <h2 class="text-center">Transaction Log</h2>
    </div>


    <form method="get" class="mb-4 row g-2">
        <div class="col-md-2">
            <input type="date" name="startDate" class="form-control"
                   value="<%= request.getParameter("startDate") != null ? request.getParameter("startDate") : "" %>">
        </div>
        <div class="col-md-2">
            <input type="date" name="endDate" class="form-control"
                   value="<%= request.getParameter("endDate") != null ? request.getParameter("endDate") : "" %>">
        </div>
        <div class="col-md-2">
            <input type="text" name="staff" placeholder="Staff Name" class="form-control"
                   value="<%= request.getParameter("staff") != null ? request.getParameter("staff") : "" %>">
        </div>
        <div class="col-md-2">
            <input type="text" name="meal" placeholder="Meal Name" class="form-control"
                   value="<%= request.getParameter("meal") != null ? request.getParameter("meal") : "" %>">
        </div>
        <div class="col-md-2">
            <select name="role" class="form-select">
                <option value="">All Roles</option>
                <option value="Manager"<%= "Manager".equals(request.getParameter("role")) ? "selected" : "" %>>Manager</option>
                <option value="Wait Staff" <%= "Wait Staff".equals(request.getParameter("role")) ? "selected" : "" %>>Wait Staff</option>
                <option value="Kitchen Staff" <%= "Kitchen Staff".equals(request.getParameter("role")) ? "selected" : "" %>>Kitchen Staff</option>
            </select>
        </div>
        <div class="col-md-2 d-flex gap-2">
            <button type="submit" class="btn btn-primary w-50">Apply</button>
            <a href="transactionLog.jsp" class="btn btn-secondary w-50">Clear</a>
        </div>
    </form>

    <!-- Transactions Table -->
    <div class="table-responsive">
        <table class="table table-bordered align-middle">
            <thead class="table-light">
                <tr>
                    <th>Transaction ID</th>
                    <th>Date</th>
                    <th>Staff</th>
                    <th>Role</th>
                    <th>Order ID</th>
                    <th>Meal</th>
                    <th>Qty</th>
                    <th>Price Each ($)</th>
                    <th>Total ($)</th>
                </tr>
            </thead>
            <tbody>
            <%
                String JDBC_URL = "jdbc:mysql://localhost:3306/byte2bite?autoReconnect=true&useSSL=false";
                String DB_USER = "root";
                String DB_PASSWORD = "";  //add your password

                String startDate = request.getParameter("startDate");
                String endDate = request.getParameter("endDate");
                String staff = request.getParameter("staff");
                String meal = request.getParameter("meal");
                String role = request.getParameter("role");

                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    Connection con = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD);

                    StringBuilder sql = new StringBuilder(
                        "SELECT p.payment_id AS transaction_id, p.paid_at, CONCAT(s.first_name, ' ', s.last_name) AS staff_name, " +
                        "sr.role_name, tk.ticket_id AS order_id, m.name AS meal_name, COUNT(o.meal_id) AS quantity, " +
                        "m.price, (COUNT(o.meal_id) * m.price) AS total_price " +
                        "FROM payment p " +
                        "JOIN sessions sess ON p.session_id = sess.session_id " +
                        "JOIN Staff s ON sess.staff_id = s.staff_id " +
                        "JOIN staff_role sr ON s.staff_id = sr.staff_id " +
                        "JOIN tickets tk ON sess.session_id = tk.session_id " +
                        "JOIN orders o ON tk.ticket_id = o.ticket_id " +
                        "JOIN meal m ON o.meal_id = m.meal_id " +
                        "WHERE 1=1"
                    );

                    List<Object> params = new ArrayList<>();

                    if (startDate != null && !startDate.isEmpty()) {
                        sql.append(" AND p.paid_at >= ?");
                        params.add(startDate + " 00:00:00");
                    }
                    if (endDate != null && !endDate.isEmpty()) {
                        sql.append(" AND p.paid_at <= ?");
                        params.add(endDate + " 23:59:59");
                    }
                    if (staff != null && !staff.isEmpty()) {
                        sql.append(" AND CONCAT(s.first_name, ' ', s.last_name) LIKE ?");
                        params.add("%" + staff + "%");
                    }
                    if (meal != null && !meal.isEmpty()) {
                        sql.append(" AND m.name LIKE ?");
                        params.add("%" + meal + "%");
                    }
                    if (role != null && !role.isEmpty()) {
                        sql.append(" AND sr.role_name = ?");
                        params.add(role);
                    }

                    sql.append(" GROUP BY p.payment_id, p.paid_at, staff_name, sr.role_name, tk.ticket_id, m.name, m.price ORDER BY p.paid_at ASC");


                    PreparedStatement stmt = con.prepareStatement(sql.toString());
                    for (int i = 0; i < params.size(); i++) {
                        stmt.setObject(i + 1, params.get(i));
                    }

                    ResultSet rs = stmt.executeQuery();
                    boolean hasData = false;

                    while (rs.next()) {
                        hasData = true;
            %>
                        <tr>
                            <td><%= rs.getInt("transaction_id") %></td>
                            <td><%= rs.getTimestamp("paid_at") %></td>
                            <td><%= rs.getString("staff_name") %></td>
                            <td><%= rs.getString("role_name") %></td>
                            <td><%= rs.getInt("order_id") %></td>
                            <td><%= rs.getString("meal_name") %></td>
                            <td><%= rs.getInt("quantity") %></td>
                            <td><%= rs.getDouble("price") %></td>
                            <td><%= rs.getDouble("total_price") %></td>
                        </tr>
            <%
                    }

                    if (!hasData) {
            %>
                        <tr><td colspan="9" class="text-center">No transactions found</td></tr>
            <%
                    }

                    rs.close();
                    stmt.close();
                    con.close();

                } catch (Exception e) {
            %>
                    <tr><td colspan="9" class="text-danger">Error: <%= e.getMessage() %></td></tr>
            <%
                }
            %>
            </tbody>
        </table>
    </div>
</body>
</html>