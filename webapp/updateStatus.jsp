<%@ page import="java.sql.*" %>
<%@ page import="java.time.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    request.setCharacterEncoding("UTF-8");

    String ticketIdStr = request.getParameter("ticket_id");
    String newStatus = request.getParameter("new_status");

    if (ticketIdStr == null || ticketIdStr.isBlank()) {
        out.println("<div class='alert alert-danger'>Error: missing ticket_id.</div>");
        return;
    }
    if (newStatus == null || newStatus.isBlank()) {
        out.println("<div class='alert alert-danger'>Error: missing new_status.</div>");
        return;
    }

    int ticketId;
    try {
        ticketId = Integer.parseInt(ticketIdStr.trim());
    } catch (NumberFormatException nfe) {
        out.println("<div class='alert alert-danger'>Error: invalid ticket_id.</div>");
        return;
    }

    String JDBC_URL = "jdbc:mysql://localhost:3306/byte2bite?autoReconnect=true&useSSL=false&serverTimezone=UTC";
    String DB_USER = "root";
    String DB_PASSWORD = "";  //add your password

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
    } catch (ClassNotFoundException cnfe) {
        out.println("<div class='alert alert-danger'>JDBC driver load failed: " + cnfe.getMessage() + "</div>");
        return;
    }

    try (Connection con = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD)) {
        try (PreparedStatement ps = con.prepareStatement("UPDATE tickets SET status = ? WHERE ticket_id = ?")) {
            ps.setString(1, newStatus);
            ps.setInt(2, ticketId);
            int affected = ps.executeUpdate();
            if (affected == 0) {
                out.println("<div class='alert alert-warning'>No ticket found with ID " + ticketId + ".</div>");
                return;
            }
        }

        response.sendRedirect("modifyOrderStatus.jsp");
    } catch (Exception e) {
        out.println("<div class='alert alert-danger'>Update failed: " + e.getMessage() + "</div>");
    }
%>
