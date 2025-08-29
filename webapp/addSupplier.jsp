<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
  <title>Byte2Bite: Suppliers & Ingredients</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="container mt-5">

<%
    String JDBC_URL    = "jdbc:mysql://localhost:3306/byte2bite?autoReconnect=true&useSSL=false&serverTimezone=UTC";
    String DB_USER     = "root";
    String DB_PASSWORD = "";  //add your password 

    String supplierName = request.getParameter("supplier_name");
    String phone        = request.getParameter("phone");
    String itemName     = request.getParameter("item_name");
    if (supplierName != null && phone != null && itemName != null) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection con = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD)) {
                try (PreparedStatement psIng = con.prepareStatement(
                        "INSERT IGNORE INTO Food_Inventory (item_name) VALUES (?)"
                    )) {
                    psIng.setString(1, itemName);
                    psIng.executeUpdate();
                }
                int sellerId;
                try (PreparedStatement psSup = con.prepareStatement(
                         "INSERT INTO supplier (name,phone) VALUES (?,?) " +
                         "ON DUPLICATE KEY UPDATE phone = VALUES(phone)",
                         Statement.RETURN_GENERATED_KEYS
                     )) {
                    psSup.setString(1, supplierName);
                    psSup.setString(2, phone);
                    psSup.executeUpdate();
                    try (ResultSet rs = psSup.getGeneratedKeys()) {
                        rs.next();
                        sellerId = rs.getInt(1);
                    }
                }
                try (PreparedStatement psLink = con.prepareStatement(
                         "INSERT IGNORE INTO sold_by (item_name, seller_id) VALUES (?,?)"
                     )) {
                    psLink.setString(1, itemName);
                    psLink.setInt(2, sellerId);
                    psLink.executeUpdate();
                }
            }
            response.sendRedirect("sellerInfo.jsp");
            return;
        } catch (Exception e) {
            out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
        }
    }
%>

    <div class="row mb-4">
      <div class="col-md-8 offset-md-2">
        <h2>Add Supplier</h2>
        <form method="post" class="mt-3">
          <div class="mb-3">
            <label class="form-label">Supplier Name</label>
            <input type="text" name="supplier_name" class="form-control" required>
          </div>
          <div class="mb-3">
            <label class="form-label">Phone Number</label>
            <input type="text" name="phone" class="form-control" required>
          </div>
          <div class="mb-3">
            <label class="form-label">Ingredient Name</label>
            <input type="text" name="item_name" class="form-control" required>
          </div>
          <button type="submit" class="btn btn-primary">Add Supplier–Ingredient</button>
        </form>
      </div>
    </div>

    <hr>


    <h3>Current Suppliers</h3>
<%

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
    } catch (ClassNotFoundException ignore) {}
    try (Connection con = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD);
         PreparedStatement ps = con.prepareStatement(
           "SELECT s.seller_id, s.name AS supplier_name, s.phone, sb.item_name " +
           "FROM supplier s " +
           "JOIN sold_by sb ON s.seller_id = sb.seller_id " +
           "ORDER BY s.name, sb.item_name"
         );
         ResultSet rs = ps.executeQuery()) {

        int currentId = -1;
        while (rs.next()) {
            int sid = rs.getInt("seller_id");
            if (sid != currentId) {
                if (currentId != -1) {
%>
        </ul>
      </div>
    </div>
<%
                }
                currentId = sid;
%>
    <div class="card mb-3">
      <div class="card-header bg-light">
        <strong><%= rs.getString("supplier_name") %></strong>
        <span class="text-muted">(<%= rs.getString("phone") %>)</span>
      </div>
      <div class="card-body">
        <ul class="list-group">
<%
            }
%>
          <li class="list-group-item"><%= rs.getString("item_name") %></li>
<%
        }
        if (currentId != -1) {
%>
        </ul>
      </div>
    </div>
<%
        }
    } catch (Exception e) {
        out.println("<div class='alert alert-danger'>Listing error: " + e.getMessage() + "</div>");
    }
%>

</body>
</html>
