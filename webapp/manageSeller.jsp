<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Byte2Bite: Manage Sellers</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function filterSellers() {
        const input = document.getElementById("filterInput").value.toLowerCase();
        const rows = document.querySelectorAll(".seller-row");
        rows.forEach(row => {
            const nameInput = row.querySelector('input[name="name"]');
            const itemInput = row.querySelector('input[name="item_name"]');
            const name = nameInput ? nameInput.value.toLowerCase() : "";
            const item = itemInput ? itemInput.value.toLowerCase() : "";
            row.style.display = (name.includes(input) || item.includes(input)) ? "" : "none";
            });
        }

    function clearFilter() {
        document.getElementById("filterInput").value = "";
        filterSellers();
    }
    </script>
</head>
<body class="container mt-5">

    <div class="position-relative mb-4">
        <a href="managerHub.jsp" class="btn btn-outline-secondary position-absolute top-0 start-0">&larr; Back to Hub</a>
        <h2 class="text-center">Manage Seller Information</h2>
    </div>


    <div class="card mb-5 shadow-sm">
        <div class="card-header bg-primary text-white">
            Register New Seller
        </div>
        <div class="card-body">
            <form action="modifySeller.jsp" method="post" class="row g-3">
                <input type="hidden" name="action" value="register">
                <div class="col-md-3">
                    <input type="text" name="name" class="form-control" placeholder="Seller Name" required>
                </div>
                <div class="col-md-2">
                    <input type="text" name="phone" class="form-control" placeholder="Phone Number" required>
                </div>
                <div class="col-md-3">
                    <input type="text" name="item_name" class="form-control" placeholder="Item Name" required>
                </div>
                <div class="col-md-2">
                    <input type="number" name="cost" step="0.01" class="form-control" placeholder="Price ($)" required>
                </div>
                <div class="col-md-2">
                    <button type="submit" class="btn btn-success w-100">Register</button>
                </div>
            </form>
        </div>
    </div>


    <form class="mb-4 text-center d-flex justify-content-center gap-2" onsubmit="event.preventDefault(); filterSellers();">
        <input id="filterInput" type="text" class="form-control w-50" placeholder="Filter by seller or item...">
        <button type="submit" class="btn btn-primary">Apply Filter</button>
        <button type="button" class="btn btn-secondary" onclick="clearFilter()">Clear</button>
    </form>


    
    <div class="table-responsive">
        <table class="table table-bordered align-middle">
            <thead class="table-light">
                <tr>
                    <th>Seller Name</th>
                    <th>Phone</th>
                    <th>Item</th>
                    <th>Price ($)</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
            <%
                String JDBC_URL = "jdbc:mysql://localhost:3306/byte2bite?autoReconnect=true&useSSL=false";
                String DB_USER = "root";
                String DB_PASSWORD = "";  //add your password

                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection con = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD);

                String sql = "SELECT s.seller_id, s.name AS seller_name, s.phone, f.inventory_id, f.name AS item_name, sb.cost " +
                             "FROM supplier s " +
                             "JOIN sold_by sb ON s.seller_id = sb.seller_id " +
                             "JOIN food_inventory f ON sb.inventory_id = f.inventory_id " +
                             "ORDER BY s.name, f.name";

                PreparedStatement stmt = con.prepareStatement(sql);
                ResultSet rs = stmt.executeQuery();

                while (rs.next()) {
                    int sellerId = rs.getInt("seller_id");
                    int inventoryId = rs.getInt("inventory_id");
                    String name = rs.getString("seller_name");
                    String phone = rs.getString("phone");
                    String itemName = rs.getString("item_name");
                    double cost = rs.getDouble("cost");
            %>
                <tr class="seller-row">
                    <form method="post" action="modifySeller.jsp">
                        <td><input type="text" name="name" class="form-control" value="<%= name %>"></td>
                        <td><input type="text" name="phone" class="form-control" value="<%= phone %>"></td>
                        <td><input type="text" name="item_name" class="form-control" value="<%= itemName %>"></td>
                        <td><input type="number" step="0.01" name="cost" class="form-control" value="<%= cost %>"></td>
                        <td class="d-flex gap-2">
                            <input type="hidden" name="seller_id" value="<%= sellerId %>">
                            <input type="hidden" name="inventory_id" value="<%= inventoryId %>">
                            <button type="submit" name="action" value="update" class="btn btn-success btn-sm">Update</button>
                            <button type="submit" name="action" value="delete" class="btn btn-danger btn-sm"
                                onclick="return confirm('Are you sure you want to remove this seller–item pair?');">Remove</button>
                        </td>
                    </form>
                </tr>
            <%
                }
                rs.close();
                stmt.close();
                con.close();
            %>
            </tbody>
        </table>
    </div>
</body>
</html>
