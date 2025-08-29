<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.time.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Byte2Bite: Manage Tickets</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body class="container mt-5">

<%!
    String formatElapsed(Timestamp ts) {
        if (ts == null) return "N/A";
        Duration diff = Duration.between(ts.toInstant(), Instant.now());
        long totalMin = diff.toMinutes();
        long hours = totalMin / 60;
        long minutes = totalMin % 60;
        if (hours > 0) return hours + "h " + minutes + "m ago";
        return minutes + "m ago";
    }

    class TicketMeta {
        int ticketId;
        String status;
        Object tableId;
        Object capacity;
        Timestamp placedAt;
        String staffName;
        List<Map<String, Object>> meals = new ArrayList<>();
    }
%>
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
        <h2>Ticket Status</h2>
    </div>

    <form method="get" class="row g-3 mb-4 justify-content-center">
        <div class="col-auto">
            <input type="number" name="table_id" class="form-control" placeholder="Filter by Table #" value="<%= request.getParameter("table_id") != null ? request.getParameter("table_id") : "" %>">
        </div>
        <div class="col-auto">
            <input type="number" name="ticket_id" class="form-control" placeholder="Filter by Ticket #" value="<%= request.getParameter("ticket_id") != null ? request.getParameter("ticket_id") : "" %>">
        </div>
        <div class="col-auto">
            <select name="status_filter" class="form-select">
                <option value="">All Status</option>
                <option value="Placed" <%= "Placed".equals(request.getParameter("status_filter")) ? "selected" : "" %>>Placed</option>
                <option value="Preparing" <%= "Preparing".equals(request.getParameter("status_filter")) ? "selected" : "" %>>Being Prepared</option>
                <option value="Ready" <%= "Ready".equals(request.getParameter("status_filter")) ? "selected" : "" %>>Order Ready</option>
                <option value="Completed" <%= "Completed".equals(request.getParameter("status_filter")) ? "selected" : "" %>>Completed</option>
            </select>
        </div>
        <div class="col-auto">
            <button class="btn btn-primary" type="submit">Apply Filter</button>
            <a href="modifyOrderStatus.jsp" class="btn btn-secondary">Clear Filter</a>
        </div>
    </form>

<%
    String db = "byte2bite";
    String user = "root";
    String password = "";   //add your password
    String tableFilter = request.getParameter("table_id");
    String statusFilter = request.getParameter("status_filter");
    String ticketIdFilter = request.getParameter("ticket_id");

    Map<Integer, TicketMeta> activeMap = new LinkedHashMap<>();
    Map<Integer, TicketMeta> completedMap = new LinkedHashMap<>();

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
    } catch (ClassNotFoundException cnfe) {
        out.println("<div class='alert alert-danger'>JDBC driver load failed: " + cnfe.getMessage() + "</div>");
    }


    String query =
        "SELECT t.ticket_id, t.status, t.placed_at, tc.table_id, tc.capacity, " +
        "st.first_name AS staff_first, st.last_name AS staff_last, " +
        "m.name AS meal_name, m.price " +
        "FROM tickets t " +
        "LEFT JOIN sessions s ON t.session_id = s.session_id " +
        "LEFT JOIN TableChart tc ON s.table_id = tc.table_id " +
        "LEFT JOIN Staff st ON tc.table_staff_id = st.staff_id " +
        "JOIN orders o ON o.ticket_id = t.ticket_id " +
        "JOIN meal m ON o.meal_id = m.meal_id " +
        "WHERE 1=1";

    StringBuilder sb = new StringBuilder(query);
    List<Object> params = new ArrayList<>();

    if (tableFilter != null && !tableFilter.trim().isEmpty()) {
        sb.append(" AND tc.table_id = ?");
        try { params.add(Integer.parseInt(tableFilter.trim())); } catch (NumberFormatException ignored) {}
    }
    if (ticketIdFilter != null && !ticketIdFilter.trim().isEmpty()) {
        sb.append(" AND t.ticket_id = ?");
        try { params.add(Integer.parseInt(ticketIdFilter.trim())); } catch (NumberFormatException ignored) {}
    }
    if (statusFilter != null && !statusFilter.trim().isEmpty()) {
        sb.append(" AND t.status = ?");
        params.add(statusFilter.trim());
    }

    sb.append(" ORDER BY t.placed_at DESC, t.ticket_id");

    String jdbcUrl = "jdbc:mysql://localhost:3306/byte2bite?autoReconnect=true&useSSL=false";
    try (Connection con = DriverManager.getConnection(jdbcUrl, user, password);
         PreparedStatement ps = con.prepareStatement(sb.toString())) {

        for (int i = 0; i < params.size(); i++) {
            ps.setObject(i + 1, params.get(i));
        }

        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                int ticketId = rs.getInt("ticket_id");
                String status = rs.getString("status");
                Object tableId = rs.getObject("table_id");
                Object capacity = rs.getObject("capacity");
                Timestamp placedAt = rs.getTimestamp("placed_at");
                String mealName = rs.getString("meal_name");
                double price = rs.getDouble("price");
                String staffFirst = rs.getString("staff_first");
                String staffLast = rs.getString("staff_last");
                String staffName = null;
                if (staffFirst != null || staffLast != null) {
                    staffName = ((staffFirst != null ? staffFirst : "") + " " + (staffLast != null ? staffLast : "")).trim();
                }

                Map<String, Object> meal = new HashMap<>();
                meal.put("meal_name", mealName);
                meal.put("price", price);

                Map<Integer, TicketMeta> target = "Completed".equalsIgnoreCase(status) ? completedMap : activeMap;
                TicketMeta meta = target.get(ticketId);
                if (meta == null) {
                    meta = new TicketMeta();
                    meta.ticketId = ticketId;
                    meta.status = status;
                    meta.tableId = tableId;
                    meta.capacity = capacity;
                    meta.placedAt = placedAt;
                    meta.staffName = staffName;  
                    target.put(ticketId, meta);
                }
                meta.meals.add(meal);
            }
        }
    } catch (Exception e) {
        out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
    }
%>

<div class="row justify-content-center">
    <div class="col-md-6">
        <h4 class="mb-3">Active Tickets</h4>
        <% if (activeMap.isEmpty()) { %>
            <p>No active tickets.</p>
        <% } else {
            for (TicketMeta ticket : activeMap.values()) {
                String status = ticket.status;
                String statusLabel;
                String statusClass;
                boolean completeEnabled = false;
                if ("Ready".equalsIgnoreCase(status)) {
                    statusLabel = "Order Ready";
                    statusClass = "info";
                    completeEnabled = true;
                } else if ("Preparing".equalsIgnoreCase(status)) {
                    statusLabel = "Being Prepared";
                    statusClass = "warning";
                } else if ("Pending".equalsIgnoreCase(status) || "Placed".equalsIgnoreCase(status)) {
                    statusLabel = "Placed";
                    statusClass = "secondary";
                } else {
                    statusLabel = status;
                    statusClass = "secondary";
                }
        %>
        <div class="card mb-4">
            <div class="card-header d-flex justify-content-between align-items-center">
                <div>
                    <strong>Ticket #<%= ticket.ticketId %></strong>
                    <div class="small text-muted">
                        Table: <%= ticket.tableId != null ? ticket.tableId : "N/A" %>
                        <% if (ticket.staffName != null && !ticket.staffName.isBlank()) { %>
                            | Served by: <%= ticket.staffName %>
                        <% } %>
                        | Placed: <%= formatElapsed(ticket.placedAt) %>
                    </div>
                </div>
                <div class="d-flex align-items-center gap-2">
                    <span class="badge bg-<%= statusClass %>"><%= statusLabel %></span>
                    <form method="post" action="updateStatus.jsp" class="d-inline">
                        <input type="hidden" name="ticket_id" value="<%= ticket.ticketId %>">
                        <input type="hidden" name="new_status" value="Completed">
                        <button class="btn btn-sm btn-success" type="submit" <%= "Ready".equalsIgnoreCase(status) ? "" : "disabled" %>>Mark as Completed</button>
                    </form>
                </div>
            </div>
            <div class="card-body">
                <% for (Map<String, Object> meal : ticket.meals) { %>
                    <div class="mb-2">
                        <strong><%= meal.get("meal_name") %></strong> - $<%= String.format("%.2f", (Double) meal.get("price")) %>
                    </div>
                <% } %>
            </div>
        </div>
        <%  }
        } %>

        <h4 class="mt-5 mb-3">Completed Tickets</h4>
        <% if (completedMap.isEmpty()) { %>
            <p>No completed tickets.</p>
        <% } else {
            for (TicketMeta ticket : completedMap.values()) {
        %>
        <div class="card mb-4">
            <div class="card-header d-flex justify-content-between align-items-center">
                <div>
                    <strong>Ticket #<%= ticket.ticketId %></strong>
                    <div class="small text-muted">
                        Table: <%= ticket.tableId != null ? ticket.tableId : "N/A" %>
                        <% if (ticket.staffName != null && !ticket.staffName.isBlank()) { %>
                            | Served by: <%= ticket.staffName %>
                        <% } %>
                        | Placed: <%= formatElapsed(ticket.placedAt) %>
                    </div>
                </div>
                <div>
                    <span class="badge bg-success">Completed</span>
                </div>
            </div>
            <div class="card-body">
                <% for (Map<String, Object> meal : ticket.meals) { %>
                    <div class="mb-2">
                        <strong><%= meal.get("meal_name") %></strong> - $<%= String.format("%.2f", (Double) meal.get("price")) %>
                    </div>
                <% } %>
            </div>
        </div>
        <%  }
        } %>
    </div>
</div>

</body>
</html>
