<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Byte2Bite – Wait Staff Order Entry</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/waitStaff.css?v=<%= System.currentTimeMillis() %>" />
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"
        rel="stylesheet">
</head>
<body>

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
  <h2>Menu Placing</h2>
</div>

<%
  // — LOAD SESSIONS & MEALS —
  List<String> entrees   = new ArrayList<>();
  List<String> sides     = new ArrayList<>();
  List<String> desserts  = new ArrayList<>();
  List<String> beverages = new ArrayList<>();

  class SessionOption {
      int tableId;
      int sessionId;
  }
  List<SessionOption> sessions = new ArrayList<>();

  try {
      Class.forName("com.mysql.cj.jdbc.Driver");
      Connection con = DriverManager.getConnection(
          "jdbc:mysql://localhost:3306/byte2bite?autoReconnect=true&useSSL=false",
          "root", "");   //add your password

      PreparedStatement sessStmt = con.prepareStatement(
          "SELECT s.table_id, s.session_id "
        + "FROM sessions s "
        + "WHERE s.closed_at IS NULL "
        + "ORDER BY s.session_id DESC");
      ResultSet sessRs = sessStmt.executeQuery();
      while (sessRs.next()) {
          SessionOption so = new SessionOption();
          so.sessionId = sessRs.getInt("session_id");
          so.tableId   = sessRs.getInt("table_id");
          sessions.add(so);
      }
      sessRs.close();
      sessStmt.close();

      Statement stmt = con.createStatement();
      ResultSet rs = stmt.executeQuery(
          "SELECT meal_id, name, price, image_url, category "
        + "FROM meal ORDER BY category, name");
      while (rs.next()) {
          int    mealId    = rs.getInt("meal_id");
          String mealName  = rs.getString("name");
          String category  = rs.getString("category");
          double mealPrice = rs.getDouble("price");
          String imageUrl  = rs.getString("image_url");

          String row = String.format(
            "<div style='display:flex;align-items:center;margin-bottom:8px;'>"
          +   (imageUrl != null
              ? "<img src='%s%s' alt='%s' style='width:96px;height:96px;object-fit:cover;border-radius:6px;margin-right:1rem;'/>"
              : "")
          +   "<label>%s ($%.2f)</label>"
          +   "<input type='hidden' name='meal_id' value='%d'/>"
          +   "<input type='number' name='quantity' min='0' value='0' "
          +         "style='width:4em;padding:0.5rem;font-size:1rem;border:1px solid #ccc;border-radius:4px;text-align:center;margin-left:1rem;'/>"
          + "</div>",
            request.getContextPath(),
            (imageUrl == null ? "" : imageUrl),
            mealName,
            mealName,
            mealPrice,
            mealId
          );

          switch (category) {
              case "Entree":   entrees.add(row);   break;
              case "Side":     sides.add(row);     break;
              case "Dessert":  desserts.add(row);  break;
              case "Beverage": beverages.add(row); break;
          }
      }
      rs.close();
      stmt.close();
      con.close();
  } catch (Exception e) {
      out.println("<div class='alert alert-danger'>Error loading meals: "
                  + e.getMessage() + "</div>");
  }
%>

<form method="post" action="submitOrder.jsp">
  <div class="mb-3">
    <label for="session_id"><strong>Select Table:</strong></label>
    <select name="session_id" id="session_id" class="form-select">
      <option value="">Select Table</option>
      <%
        for (SessionOption s : sessions) {
      %>
      <option value="<%= s.sessionId %>">
        Table #<%= s.tableId %>
      </option>
      <%
        }
      %>
    </select>
  </div>

  <h2>Entree</h2>
  <table><tbody>
    <% for (String r : entrees) { out.println(r); } %>
  </tbody></table>

  <h2>Side</h2>
  <table><tbody>
    <% for (String r : sides) { out.println(r); } %>
  </tbody></table>

  <h2>Beverage</h2>
  <table><tbody>
    <% for (String r : beverages) { out.println(r); } %>
  </tbody></table>

  <h2>Dessert</h2>
  <table><tbody>
    <% for (String r : desserts) { out.println(r); } %>
  </tbody></table>

    <div class="mb-3">
        <label for="note" class="form-label"><strong>Order Note:</strong></label>
        <textarea name="note" id="note" class="form-control" rows="2"
                placeholder="Any special instructions…"></textarea>
    </div>


  <input type="submit" value="Submit Order" />
</form>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
