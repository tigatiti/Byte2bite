<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.time.*" %>

<!DOCTYPE html>
<html>
<head>
    <title>Byte2Bite: Table Availability</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body class="container mt-5">
     <%  
      String firstName = (String) session.getAttribute("FirstName");
      String lastName  = (String) session.getAttribute("LastName");
      String role      = (String) session.getAttribute("role");
         

    String backPage = "employeeHub.jsp";
    if ("Kitchen Staff".equalsIgnoreCase(role)) {
        response.sendRedirect("chefHub.jsp");
    } else if ("Manager".equalsIgnoreCase(role)) {
        backPage = "managerHub.jsp";
    } else if ("Wait Staff".equalsIgnoreCase(role)) {
        backPage = ("employeeHub.jsp");
    }

  %>

<body class="container mt-2 mb-5">  

  <div class="position-relative mb-4" style="height:100px; margin-top:0;">

    <div class="position-absolute top-0 start-0 d-flex flex-column align-items-center mt-1 ms-3">
      <a href="<%= backPage %>">
        <img src="<%= request.getContextPath() %>/images/logo3.png"
             alt="Byte2Bite Logo"
             style="height:80px; display:block;" />
      </a>
      <a href="<%= backPage %>" class="btn btn-outline-secondary mt-1">
        &larr; Back to Hub
      </a>
    </div>

    <div class="position-absolute top-0 end-0 mt-1 me-3" style="height:40px;">
      <div class="bg-primary text-white px-3 rounded h-100 d-flex align-items-center">
        <%= role %> : <%= firstName %> <%= lastName %>
      </div>
    </div>
    <h2 class="text-center mb-0 pt-2">Table Dashboard</h2>
  </div>


    <form method="get" class="row g-3 mb-4 mt-4 justify-content-center">
        <div class="col-auto">
            <input type="number" name="capacity_filter" class="form-control" placeholder="# of Guests" value="<%= request.getParameter("capacity_filter") != null ? request.getParameter("capacity_filter") : "" %>">
        </div>
        <div class="col-auto">
            <select name="status_filter" class="form-select">
                <option value="">All Statuses</option>
                <option value="Available" <%= "Available".equals(request.getParameter("status_filter")) ? "selected" : "" %>>Available</option>
                <option value="Occupied" <%= "Occupied".equals(request.getParameter("status_filter")) ? "selected" : "" %>>Occupied</option>
                <option value="Reserved" <%= "Reserved".equals(request.getParameter("status_filter")) ? "selected" : "" %>>Reserved</option>
            </select>
        </div>
        <div class="col-auto">
            <button type="submit" class="btn btn-primary">Apply Filter</button>
            <a href="viewTables.jsp" class="btn btn-secondary">Clear Filter</a>
        </div>
    </form>

<%
    String JDBC_URL = "jdbc:mysql://localhost:3306/byte2bite?autoReconnect=true&useSSL=false";
    String DB_USER = "root";
    String DB_PASSWORD = "";   //add your password
    String capacityFilter = request.getParameter("capacity_filter");
    String statusFilter = request.getParameter("status_filter");

    Class.forName("com.mysql.cj.jdbc.Driver");
    try (Connection con = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD)) {

        Map<Integer,String> staffMap = new LinkedHashMap<>();
        try (Statement staffStmt = con.createStatement();
             ResultSet staffRs = staffStmt.executeQuery(
                 "SELECT s.staff_id, s.first_name, s.last_name FROM Staff s " +
                 "JOIN staff_role r ON s.staff_id = r.staff_id " +
                 "WHERE r.role_name = 'Wait Staff' ORDER BY s.last_name, s.first_name")) {

            while (staffRs.next()) {
                int id = staffRs.getInt("staff_id");
                String name = staffRs.getString("first_name") + " " + staffRs.getString("last_name");
                staffMap.put(id, name);
            }
        }

        int guests = -1;
        if (capacityFilter != null && !capacityFilter.isEmpty()) {
            try {
                guests = Integer.parseInt(capacityFilter);
            } catch (NumberFormatException ignored) {}
        }

        String query =
            "SELECT t.table_id, t.capacity, t.status, t.table_staff_id, t.staff_assigned_time, " +
            "t.customer_phone, c.name AS customer_name " +
            "FROM TableChart t " +
            "LEFT JOIN Customer c ON t.customer_phone = c.phone " +
            "WHERE 1=1";

        if (statusFilter != null && !statusFilter.isEmpty()) {
            query += " AND t.status = '" + statusFilter + "'";
        }
        if (guests > 0) {
            query += " AND t.capacity >= " + guests;
        }
        query += " ORDER BY t.status ASC, t.capacity ASC";

        try (Statement stmt = con.createStatement();
             ResultSet rs = stmt.executeQuery(query)) {
%>
    <div class="row justify-content-center" style="margin-top:3rem;">
        <div class="col-md-6">
<%
            while (rs.next()) {
                int tableId = rs.getInt("table_id");
                int cap = rs.getInt("capacity");
                int staffIdRaw = rs.getInt("table_staff_id");
                Integer staffId = (!rs.wasNull()) ? staffIdRaw : null;
                String status = rs.getString("status");
                Timestamp assignedTs = rs.getTimestamp("staff_assigned_time");
                String customerPhone = rs.getString("customer_phone");
                String customerName = rs.getString("customer_name");

                String assignedAgo = "n/a";
                if (assignedTs != null) {
                    Instant assignedInstant = assignedTs.toInstant();
                    Duration d = Duration.between(assignedInstant, Instant.now());
                    long hours = d.toHoursPart();
                    long minutes = d.toMinutesPart();
                    assignedAgo = (hours > 0) ? hours + "h " + minutes + "m ago" : minutes + "m ago";
                }

                String bgClass = "bg-success text-white";
                if ("Reserved".equalsIgnoreCase(status)) bgClass = "bg-warning";
                else if ("Occupied".equalsIgnoreCase(status)) bgClass = "bg-danger text-white";
%>
            <div class="card mb-4">
                <div class="card-header d-flex justify-content-between align-items-center <%= bgClass %>" data-bs-toggle="collapse" data-bs-target="#table-<%= tableId %>">
                    <span>Table #<%= tableId %> Capacity: <%= cap %></span>
                    <span><%= status %></span>
                </div>
                <div id="table-<%= tableId %>" class="collapse card-body">
                    <form method="post" action="updateTable.jsp" class="mb-2">
                        <input type="hidden" name="table_id" value="<%= tableId %>" />
                        <div class="mb-2">
                            <label class="form-label">Assign Staff:</label>
                            <select name="new_staff_id" class="form-select" <%= ("Occupied".equalsIgnoreCase(status) || "Reserved".equalsIgnoreCase(status)) ? "disabled" : "" %>>
                                <option value=""></option>
<% for (Map.Entry<Integer,String> e : staffMap.entrySet()) {
       String sel = (staffId != null && e.getKey().equals(staffId)) ? "selected" : ""; %>
                                <option value="<%= e.getKey() %>" <%= sel %>><%= e.getValue() %></option>
<% } %>
                            </select>
                            <% if (!"n/a".equals(assignedAgo)) { %>
                                <div class="text-muted small">Assigned: <%= assignedAgo %></div>
                            <% } %>
                        </div>

                        <% if ("Available".equalsIgnoreCase(status)) { %>
                            <div class="mb-2">
                                <label class="form-label">Status:</label>
                                <select name="new_status" class="form-select">
                        <% for (String s : new String[] {"Available","Occupied","Reserved"}) {
                               if (!s.equalsIgnoreCase(status)) { %>
                                    <option value="<%= s %>"><%= s %></option>
                        <%     } } %>
                                </select>
                            </div>
                        <% } %>

<% if (!"Available".equalsIgnoreCase(status) && (customerName != null || customerPhone != null)) { %>
                        <div class="mb-2">
                            <label class="form-label">Customer:</label>
                            <input type="text" class="form-control" value="<%= customerName != null ? customerName : "" %>" disabled>
                            <input type="hidden" name="existing_customer_name" value="<%= customerName != null ? customerName : "" %>">
                        </div>
                        <div class="mb-2">
                            <label class="form-label">Phone:</label>
                            <input type="text" class="form-control" value="<%= customerPhone != null ? customerPhone : "" %>" disabled>
                            <input type="hidden" name="existing_customer_phone" value="<%= customerPhone != null ? customerPhone : "" %>">
                        </div>
<% } else if ("Available".equalsIgnoreCase(status)) { %>
                        <div class="mb-2">
                            <label class="form-label">Customer Name:</label>
                            <input type="text" name="customer_name" class="form-control" list="customerList">
                            <datalist id="customerList">
<% try (Statement custStmt = con.createStatement(); ResultSet custRs = custStmt.executeQuery("SELECT name FROM Customer")) {
       while (custRs.next()) { %>
                                <option value="<%= custRs.getString("name") %>">
<%     } } catch (SQLException ignore) {} %>
                            </datalist>
                        </div>
                        <div class="mb-2">
                            <label class="form-label">Customer Phone:</label>
                            <input type="text" name="customer_phone" class="form-control" placeholder="e.g. 555-123-4567">
                        </div>
<% } %>

                        <div class="d-flex justify-content-between">
                            <% if ("Available".equalsIgnoreCase(status)) { %>
                            <form method="post" action="updateTable.jsp" class="me-auto">
                                <input type="hidden" name="table_id" value="<%= tableId %>" />
                                <input type="hidden" name="new_staff_id" value="<%= staffId != null ? staffId : "" %>">
                                <button type="submit" class="btn btn-primary">Confirm</button>
                            </form>
                            <% } else { %><div></div><% } %>

                            <form method="post" action="updateTable.jsp">
                                <input type="hidden" name="clear" value="<%= tableId %>" />
                                <button type="submit" class="btn btn-sm btn-danger">Clear Table</button>
                            </form>
                        </div>
                    </form>
                </div>
            </div>
<% } %>
        </div>
    </div>
<% } } catch (Exception e) { out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>"); } %>
</body>
</html>