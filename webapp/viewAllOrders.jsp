<%@ page import="java.sql.*" %>
<html>
<head><title>All Orders Overview</title></head>
<body>
    <h1>All Active Orders</h1>

    <table border="1">
        <tr>
            <th>Order ID</th>
            <th>Table #</th>
            <th>Customer ID</th>
            <th>Meal ID</th>
            <th>Status</th>
        </tr>

<%
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/byte2bite?autoReconnect=true&useSSL=false",
            "root", ""  //add your password
        );

        Statement stmt = con.createStatement();
        ResultSet rs = stmt.executeQuery(
            "SELECT order_id, table_id, customer_id, meal_id, status FROM `order` ORDER BY table_id, order_id"
        );

        while (rs.next()) {
            out.println("<tr>");
            out.println("<td>" + rs.getInt("order_id") + "</td>");
            out.println("<td>" + rs.getInt("table_id") + "</td>");
            out.println("<td>" + rs.getInt("customer_id") + "</td>");
            out.println("<td>" + rs.getInt("meal_id") + "</td>");
            out.println("<td>" + rs.getString("status") + "</td>");
            out.println("</tr>");
        }

        rs.close();
        stmt.close();
        con.close();
    } catch (Exception e) {
        out.println("<tr><td colspan='5' style='color:red;'>Error: " + e.getMessage() + "</td></tr>");
    }
%>
    </table>

    <br/><a href="orderViewMenu.jsp">← Back to Table Selection</a>
</body>
</html>
