<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function filterSuppliers() {
            const input = document.getElementById("filterInput").value.toLowerCase();
            document.querySelectorAll(".accordion-item").forEach(item => {
                item.style.display = item.innerText.toLowerCase().includes(input) ? "" : "none";
            });
        }
        function clearFilter() {
            document.getElementById("filterInput").value = "";
            filterSuppliers();
        }
    </script>

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
        <h2>Suppliers & Their Ingredients</h2>
    </div>

</head>
<body class="container mt-5">
    <div class="position-relative mb-4">
        <!-- <a href="managerHub.jsp" class="btn btn-outline-secondary position-absolute top-0 start-0">&larr; Back to Hub</a>
        <h2 class="text-center">Suppliers & Their Ingredients</h2> -->
    </div>

    <div class="mb-4 d-flex justify-content-between align-items-center">
        <div class="d-flex gap-2">
            <input id="filterInput" type="text" class="form-control" style="width:300px;"
                   placeholder="Filter by supplier or ingredient…" onkeyup="filterSuppliers()">
            <button class="btn btn-secondary" onclick="clearFilter()">Clear</button>
        </div>
        <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addModal">
            Add Supplier
        </button>
    </div>

    <div class="accordion" id="accordionSuppliers">
<%
    String JDBC_URL    = "jdbc:mysql://localhost:3306/byte2bite?autoReconnect=true&useSSL=false";
    String DB_USER     = "root";
    String DB_PASSWORD = "";  //add your password

    Class.forName("com.mysql.cj.jdbc.Driver");
    try (Connection con = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD)) {
        String sql =
            "SELECT s.seller_id, s.name AS supplier_name, s.phone, f.item_name AS ingredient " + 
            "FROM supplier s " + 
            "JOIN sold_by sb ON s.seller_id = sb.seller_id " +        
            "JOIN food_inventory f ON sb.item_name = f.item_name " +  
            "ORDER BY s.name, f.item_name";

        try (PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            Map<Integer, Map<String,Object>> supMap = new LinkedHashMap<>();
            while (rs.next()) {
                int supId        = rs.getInt("seller_id");
                String supName   = rs.getString("supplier_name");
                String phone     = rs.getString("phone");
                String ingredient= rs.getString("ingredient");

                supMap.computeIfAbsent(supId, k -> {
                    Map<String,Object> data = new HashMap<>();
                    data.put("name", supName);
                    data.put("phone", phone);
                    data.put("items", new ArrayList<String>());
                    return data;
                });

                @SuppressWarnings("unchecked")
                List<String> items = (List<String>) supMap.get(supId).get("items");
                items.add(ingredient);
            }

            int idx = 0;
            for (Map<String,Object> supData : supMap.values()) {
                String supplierName = (String) supData.get("name");
                String phone        = (String) supData.get("phone");
                @SuppressWarnings("unchecked")
                List<String> items = (List<String>) supData.get("items");
%>
        <div class="accordion-item">
            <h2 class="accordion-header" id="heading<%=idx%>">
                <button class="accordion-button <%= idx>0 ? "collapsed":"" %>"
                        type="button"
                        data-bs-toggle="collapse"
                        data-bs-target="#collapse<%=idx%>">
                    <%= supplierName %> — <span class="text-muted"><%= phone %></span>
                </button>
            </h2>
            <div id="collapse<%=idx%>"
                 class="accordion-collapse collapse <%= idx==0 ? "show":"" %>"
                 data-bs-parent="#accordionSuppliers">
                <div class="accordion-body">
                    <ul class="list-group">
                    <% for (String ingr : items) { %>
                        <li class="list-group-item"><%= ingr %></li>
                    <% } %>
                    </ul>
                </div>
            </div>
        </div>
<%
                idx++;
            }
        }
    } catch(Exception e) {
    }
%>
    </div>

    <div class="modal fade" id="addModal" tabindex="-1">
      <div class="modal-dialog">
        <form method="post" action="addSupplier.jsp" class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Add Supplier</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
          </div>
          <div class="modal-body">
            <div class="mb-3">
              <label for="supplier_name" class="form-label">Supplier Name</label>
              <input id="supplier_name" name="supplier_name" type="text"
                     class="form-control"required>
            </div>
            <div class="mb-3">
              <label for="phone" class="form-label">Phone Number</label>
              <input id="phone" name="phone" type="tel"
                     class="form-control" required>
            </div>
            <div class="mb-3">
              <label for="item_name" class="form-label">Ingredient</label>
              <input id="item_name" name="item_name" type="text"
                     class="form-control" required>    
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary"
                    data-bs-dismiss="modal">Cancel</button>
            <button type="submit" class="btn btn-primary">Add</button>
          </div>
        </form>
      </div>
    </div>
</body>
</html>
