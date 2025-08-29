import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;



/*javac \
  -cp "src/main/webapp/WEB-INF/lib/*" \
  -d src/main/webapp/WEB-INF/classes \
  src/main/java/LoginServlet.java
   */
@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private static final String JDBC_URL =
        "jdbc:mysql://localhost:3306/byte2bite?autoReconnect=true&useSSL=false";
    private static final String DB_USER     = "root";
    private static final String DB_PASSWORD = ""; //add your password

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String staffId = request.getParameter("staff_id");
        String pin     = request.getParameter("pin");

    
        if (staffId == null || staffId.isEmpty() || pin == null || pin.isEmpty()) {
            request.setAttribute("error", "Staff ID and PIN are required.");
            request.getRequestDispatcher("/index.jsp").forward(request, response);
            return;
        }

            String sql = "SELECT s.staff_id, s.first_name, s.last_name, r.role_name " +
             "FROM Staff s " +
             "JOIN staff_role r ON s.staff_id = r.staff_id " +
             "WHERE s.staff_id = ? AND s.pin = ?";


        try {
            Class.forName("com.mysql.cj.jdbc.Driver");

            try (Connection con = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD);
                 PreparedStatement ps = con.prepareStatement(sql)) {

                ps.setInt(1, Integer.parseInt(staffId));
                ps.setString(2, pin);

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {

                        HttpSession session = request.getSession();
                        session.setAttribute("FirstName", rs.getString("first_name"));
                        session.setAttribute("LastName",  rs.getString("last_name"));
                        session.setAttribute("staffId",   rs.getInt("staff_id"));
                        session.setAttribute("role",      rs.getString("role_name"));


                        String role = rs.getString("role_name");

                        if ("Admin".equalsIgnoreCase(role)) {
                            response.sendRedirect(request.getContextPath() + "/admin.jsp");
                        } else if ("Manager".equalsIgnoreCase(role)) {
                            response.sendRedirect(request.getContextPath() + "/managerHub.jsp");
                        } else if ("Wait Staff".equalsIgnoreCase(role)) {
                            response.sendRedirect(request.getContextPath() + "/employeeHub.jsp");
                        } else if ("Kitchen Staff".equalsIgnoreCase(role)) {
                            response.sendRedirect(request.getContextPath() + "/chefHub.jsp");
                        } else {
                            request.getRequestDispatcher("index.jsp").forward(request, response);
                        }
                    } else {
                        request.setAttribute("error", "Invalid Staff ID or PIN.");
                        request.getRequestDispatcher("/login.jsp").forward(request, response);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "An internal error occurred."); 
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }
}
