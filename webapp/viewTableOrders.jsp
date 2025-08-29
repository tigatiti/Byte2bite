<%@ page import="java.sql.*" %>
<%
    String tableIdStr = request.getParameter("table_id");
    int tableId = Integer.parseInt(tableIdStr);
%>
<html>
<head><title>Orders for Table <%= tableId %></title></head>
<body>
    <h1>Orders for Table <%= tableId %></h1>

    <table border="1">
        <tr>
            <th>Order ID</th>
            <th>Customer ID</th>
            <th>Meal ID</th>
            <th>Status</th>
        </tr>

<%
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/byte2bite?autoReconnect=true&useSSL=false",
            "root", ""   //add your password
        );

        PreparedStatement ps = con.prepareStatement(
            "SELECT order_id, customer_id, meal_id, status " +
            "FROM `order` WHERE table_id = ? ORDER BY order_id"
        );
        ps.setInt(1, tableId);

        ResultSet rs = ps.executeQuery();
        boolean hasResults = false;

        while (rs.next()) {
            hasResults = true;
            out.println("<tr>");
            out.println("<td>" + rs.getInt("order_id") + "</td>");
            out.println("<td>" + rs.getInt("customer_id") + "</td>");
            out.println("<td>" + rs.getInt("meal_id") + "</td>");
            out.println("<td>" + rs.getString("status") + "</td>");
            out.println("</tr>");
        }

        if (!hasResults) {
            out.println("<tr><td colspan='4'>No orders for this table.</td></tr>");
        }

        rs.close();
        ps.close();
        con.close();
    } catch (Exception e) {
        out.println("<tr><td colspan='4' style='color:red;'>Error: " + e.getMessage() + "</td></tr>");
    }
%>
    </table>

    <br/><a href="orderViewMenu.jsp">← Back to Table Selection</a>
</body>
</html>
