<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");

    String sessionIdStr = request.getParameter("session_id");
    String[] mealIds    = request.getParameterValues("meal_id");
    String[] quantities    = request.getParameterValues("quantity");


    if (mealIds == null || mealIds.length == 0) {
        response.sendRedirect("waitStaff.jsp");
        return;
        }

    int sessionId = Integer.parseInt(sessionIdStr);


    String JDBC_URL    = "jdbc:mysql://localhost:3306/byte2bite?autoReconnect=true&useSSL=false&serverTimezone=UTC";
    String DB_USER     = "root";
    String DB_PASSWORD = "";   //add your password

    Connection con                     = null;
    PreparedStatement createTicketStmt = null;
    PreparedStatement insertOrderStmt  = null;
    ResultSet rsKeys                   = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD);
        con.setAutoCommit(false);

        createTicketStmt = con.prepareStatement(
            "INSERT INTO tickets (session_id, status, placed_at) VALUES (?, 'Placed', NOW())",
            Statement.RETURN_GENERATED_KEYS
        );
        createTicketStmt.setInt(1, sessionId);
        int count = createTicketStmt.executeUpdate();  



        rsKeys = createTicketStmt.getGeneratedKeys();
        if (rsKeys == null || !rsKeys.next()) 
        {     
            throw new SQLException("No ticket_id returned.");
        }
        int ticketId = rsKeys.getInt(1);
        rsKeys.close();
        createTicketStmt.close();


        insertOrderStmt = con.prepareStatement(
        "INSERT INTO orders (ticket_id, meal_id, note) VALUES (?, ?, ?)"
        );

        for (int i = 0; i < mealIds.length; i++) 
        {
            int mealId = Integer.parseInt(mealIds[i]);
            int qty    = Integer.parseInt(quantities[i]);
            if (qty <= 0) continue;
            for (int c = 0; c < qty; c++) 
            {
                insertOrderStmt.setInt(1, ticketId);
                insertOrderStmt.setInt(2, mealId);
                insertOrderStmt.setString(3, request.getParameter("note"));
                insertOrderStmt.addBatch();
            }
        }


        insertOrderStmt.executeBatch();
        insertOrderStmt.close();

        con.commit();

        response.sendRedirect("waitStaff.jsp");
    } catch (Exception e) 
    {
        out.println("Error submitting order: " + e.getMessage() );
    }
%>
