<%@ page import="java.sql.*" %>
<%@ page import="java.time.*" %>
<%@ page import="java.util.*" %>
<%@ page contentType="text/html; charset=UTF-8" %>

<!DOCTYPE html>
<html>
<head>
    <title>Byte2Bite: Revenue Report</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body class="container mt-5">
    <%  
      String firstName = (String) session.getAttribute("FirstName");
      String lastName  = (String) session.getAttribute("LastName");
      String role      = (String) session.getAttribute("role");
         

    String backPage = "managerHub.jsp";
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
        <h2>Payment Report</h2>
    </div>



<div class="mx-auto" style="max-width: 800px;">

    <form method="get" class="row g-3 mb-4 justify-content-center text-center">
        <div class="col-12 col-md-4">
            <label class="form-label">From:</label>
            <input type="date" name="start_date" class="form-control" value="<%= request.getParameter("start_date") != null ? request.getParameter("start_date") : "" %>">
        </div>
        <div class="col-12 col-md-4">
            <label class="form-label">To:</label>
            <input type="date" name="end_date" class="form-control" value="<%= request.getParameter("end_date") != null ? request.getParameter("end_date") : "" %>">
        </div>
        <div class="col-12 col-md-4">
            <label class="form-label">Group By:</label>
            <select name="group_by" class="form-select">
                <option value="" <%= request.getParameter("group_by") == null ? "selected" : "" %>>None</option>
                <option value="day" <%= "day".equals(request.getParameter("group_by")) ? "selected" : "" %>>Day</option>
                <option value="week" <%= "week".equals(request.getParameter("group_by")) ? "selected" : "" %>>Week</option>
                <option value="month" <%= "month".equals(request.getParameter("group_by")) ? "selected" : "" %>>Month</option>
            </select>
        </div>
        <div class="col-12 text-center">
            <button type="submit" class="btn btn-primary me-2">Apply Filters</button>
            <a href="revenueTracker.jsp" class="btn btn-secondary">Clear</a>
        </div>
    </form>

<%
    String JDBC_URL = "jdbc:mysql://localhost:3306/byte2bite?autoReconnect=true&useSSL=false";
    String DB_USER = "root";
    String DB_PASSWORD = "";  //add your password

    String startDate = request.getParameter("start_date");
    String endDate = request.getParameter("end_date");
    String groupBy = request.getParameter("group_by");

    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD);

    String query = "SELECT payment_id, amount, paid_at FROM payment WHERE 1=1";
    List<String> conditions = new ArrayList<>();
    if (startDate != null && !startDate.trim().isEmpty()) conditions.add("paid_at >= ?");
    if (endDate != null && !endDate.trim().isEmpty()) conditions.add("paid_at <= ?");
    for (String cond : conditions) query += " AND " + cond;
    query += " ORDER BY paid_at ASC";

    PreparedStatement stmt = con.prepareStatement(query);
    int idx = 1;
    if (startDate != null && !startDate.trim().isEmpty()) stmt.setString(idx++, startDate);
    if (endDate != null && !endDate.trim().isEmpty()) stmt.setString(idx++, endDate);

    ResultSet rs = stmt.executeQuery();

    Map<String, List<Map<String, Object>>> grouped = new LinkedHashMap<>();
    double total = 0.0;

    while (rs.next()) {
        Timestamp ts = rs.getTimestamp("paid_at");
        LocalDate date = ts.toLocalDateTime().toLocalDate();
        String groupKey = "All Payments";
        if ("week".equals(groupBy)) {
            groupKey = date.with(DayOfWeek.MONDAY).toString() + " (Week)";
        } else if ("month".equals(groupBy)) {
            groupKey = date.getYear() + "-" + String.format("%02d", date.getMonthValue()) + " (Month)";
        } else if ("day".equals(groupBy)) {
            groupKey = date.toString();
        }

        grouped.computeIfAbsent(groupKey, k -> new ArrayList<>());

        Map<String, Object> record = new HashMap<>();
        record.put("payment_id", rs.getInt("payment_id"));
        record.put("amount", rs.getDouble("amount"));
        record.put("paid_at", ts);
        grouped.get(groupKey).add(record);
        total += rs.getDouble("amount");
    }

    rs.close();
    stmt.close();
    con.close();
%>

    <div class="mb-4 text-center">
        <h4 class="text-success">Total Revenue: $<%= String.format("%.2f", total) %></h4>
    </div>

<%
int i = 0;
for (Map.Entry<String, List<Map<String, Object>>> entry : grouped.entrySet()) {
    String group = entry.getKey();
    List<Map<String, Object>> records = entry.getValue();
%>
    <div class="card mb-4">
        <div class="card-header bg-light text-center"><strong><%= group %></strong></div>
        <div class="card-body p-0">
            <table class="table table-striped mb-0 text-center">
                <thead>
                    <tr>
                        <th>Payment ID</th>
                        <th>Amount ($)</th>
                        <th>Paid At</th>
                    </tr>
                </thead>
                <tbody>
                <% for (Map<String, Object> r : records) { %>
                    <tr>
                        <td><%= r.get("payment_id") %></td>
                        <td><%= String.format("%.2f", r.get("amount")) %></td>
                        <td><%= r.get("paid_at") %></td>
                    </tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </div>
<% i++; } %>
</div>
</body>
</html>
