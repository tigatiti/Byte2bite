import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.sql.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/time-tracking")
public class TimeTrackingServlet extends HttpServlet 
{

    private static final DateTimeFormatter format = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");


    private static final String JDBC_URL    = "jdbc:mysql://localhost:3306/byte2bite?useSSL=false&serverTimezone=UTC";
    private static final String DB_USER     = "root";
    private static final String DB_PASSWORD = "";    //add your password


    @Override
    public void init() throws ServletException 
    {
        try 
        {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } 
        catch (ClassNotFoundException e) 
        {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException 
            {
        request.getRequestDispatcher("/timeTracking.jsp").forward(request, response);
            }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException 
        {


        HttpSession session = request.getSession();

        Integer staffId = (Integer) session.getAttribute("staffId");
        if (staffId == null) {
            response.sendError(403, "Not logged in");
            return;
        } 


        String action = request.getParameter("action");
        LocalDateTime now = LocalDateTime.now();
        String ts = now.format(format);

        try (Connection conn = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD)) 
        {
            if ("clockIn".equals(action)) {
                String sql = "INSERT INTO staff_log (staff_id, in_time) VALUES (?, ?)";
                try (PreparedStatement ps = conn.prepareStatement(sql)) 
                {
                    ps.setInt(1, staffId);
                    ps.setTimestamp(2, Timestamp.valueOf(now));
                    ps.executeUpdate();
                }
                session.setAttribute("lastClockIn", ts);



            } else if ("clockOut".equals(action)) {
                String sql = "UPDATE staff_log SET out_time = ? WHERE staff_id = ? AND out_time IS NULL";
                try (PreparedStatement ps = conn.prepareStatement(sql)) 
                {
                    ps.setTimestamp(1, Timestamp.valueOf(now));
                    ps.setInt(2, staffId);
                    ps.executeUpdate();
                }
                session.setAttribute("lastClockOut", ts);
            }
        } catch (SQLException e) 
        {
            throw new ServletException("DB error on " + action, e);
        }


        response.sendRedirect(request.getContextPath() + "/timeTracking.jsp");
    }

}

