<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="container mt-5">
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
    String JDBC_URL    = "jdbc:mysql://localhost:3306/byte2bite?useSSL=false&serverTimezone=UTC";
    String DB_USER     = "root";
    String DB_PASSWORD = "";  //add your password

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try ( Connection con = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD) ) {
            for (String param : request.getParameterMap().keySet()) {
                if (param.startsWith("qty_")) {
                    String item = param.substring(4);
                    int newQty = Integer.parseInt(request.getParameter(param));
                    try ( PreparedStatement ps = con.prepareStatement(
                            "UPDATE food_inventory SET quantity = ? WHERE item_name = ?"
                        )) {
                        ps.setInt(1, newQty);
                        ps.setString(2, item);
                        ps.executeUpdate();
                    }
                }
            }
        }
        response.sendRedirect("InventoryTracker.jsp");
        return;
    }

    String ingredientFilter = request.getParameter("ingredient_filter");
    String maxQtyParam      = request.getParameter("max_quantity");

    Integer maxQty = null;
    if (maxQtyParam != null && !maxQtyParam.trim().isEmpty()) {
        try { maxQty = Integer.parseInt(maxQtyParam.trim()); } catch(Exception ignore) {}
    }

    Class.forName("com.mysql.cj.jdbc.Driver");
%>


    <form method="get" class="row g-3 mb-4 justify-content-center">
        <div class="col-auto">
            <input type="text" name="ingredient_filter" class="form-control" placeholder="Ingredient Name"
                   value="<%= ingredientFilter==null ? "" : ingredientFilter %>">
        </div>
        <div class="col-auto">
            <input type="number" name="max_quantity" class="form-control" placeholder="Max Available Quantity"
                   value="<%= maxQty==null ? "" : maxQty %>">
        </div>
        <div class="col-auto">
            <button type="submit" class="btn btn-primary">Apply Filter</button>
            <a href="InventoryTracker.jsp" class="btn btn-secondary">Clear</a>
        </div>
    </form>

<%

    try ( Connection con = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD) ) {
        String sql =
            "SELECT fi.item_name AS ingredient, fi.quantity AS available " +
            "FROM food_inventory fi ";


        List<Object> params = new ArrayList<>();
        StringBuilder where = new StringBuilder();
        if (ingredientFilter != null && !ingredientFilter.trim().isEmpty()) {
            where.append("fi.item_name LIKE ?");
            params.add("%"+ingredientFilter.trim()+"%");
        }
        if (maxQty != null) {
            if (where.length()>0) where.append(" AND ");
            where.append("fi.quantity <= ?");
            params.add(maxQty);
        }
        if (where.length()>0) sql += "WHERE " + where.toString();

        sql += " ORDER BY fi.item_name";

        try ( PreparedStatement ps = con.prepareStatement(sql) ) {
            for (int i=0; i<params.size(); i++) {
                ps.setObject(i+1, params.get(i));
            }
            try ( ResultSet rs = ps.executeQuery() ) {
%>
    <form method="post">
    <table class="table table-bordered">
      <thead class="table-light">
        <tr>
          <th>Ingredient</th>
          <th style="width:150px">Available Quantity</th>
        </tr>
      </thead>
      <tbody>
      <%
                while (rs.next()) {
                    String ing   = rs.getString("ingredient");
                    int avail    = rs.getInt("available");
      %>
        <tr>
          <td><%= ing %></td>
          <td>
            <input type="number"
                   name="qty_<%= ing %>"
                   value="<%= avail %>"
                   class="form-control form-control-sm" />
          </td>
        </tr>
      <%
                }
      %>
      </tbody>
    </table>
    <div class="text-end mb-5">
      <button type="submit" class="btn btn-success">Save Changes</button>
    </div>
    </form>
<%
            }
        }
    } catch (Exception e) {
        out.println("<div class='alert alert-danger'>Error loading inventory: "+e.getMessage()+"</div>");
    }
%>

</body>
</html>
