import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
@WebServlet("/register_employee")
public class registerUser extends HttpServlet {
    private static final String JDBC_URL =
        "jdbc:mysql://localhost:3306/byte2bite?autoReconnect=true&useSSL=false";
    private static final String DB_USER     = "root";
    private static final String DB_PASSWORD = ""; //add your password

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
            throws ServletException, IOException {
        request.getRequestDispatcher("/register_employee.jsp").forward(request, response);
    }
   @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException 
            {
                String firstName = request.getParameter("first_name");
                String lastName = request.getParameter("last_name");
                String pin = request.getParameter("pin");
                String confirmPin = request.getParameter("confirm_pin");
                String role = request.getParameter("role");

                if (firstName == null || firstName.isEmpty() || lastName == null || lastName.isEmpty() || role== null || role.isEmpty() ||
                pin == null || pin.isEmpty() || confirmPin == null || confirmPin.isEmpty() )
                {
                    request.setAttribute("error", "All fields—including role—are required.");
                    request.getRequestDispatcher("/register_employee.jsp").forward(request, response);
                }
                else if (!pin.equals(confirmPin))
                {
                    request.setAttribute("error", "Pin Must Match.");
                    request.getRequestDispatcher("/register_employee.jsp").forward(request, response);
                    return;
                }


                String sql = "INSERT INTO Staff (first_name, last_name, pin) VALUES (?, ?, ?)";
                String sql2 = "INSERT INTO staff_role (role_name, staff_id) VALUES (?,?)";
               try (Connection conn = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD);
                PreparedStatement psStaff = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
                PreparedStatement psRole = conn.prepareStatement(sql2))
                {

                    psStaff.setString(1, firstName);
                    psStaff.setString(2, lastName);
                    psStaff.setString(3, pin);
                    psStaff.executeUpdate();

                    int staffId;
                    ResultSet rs = psStaff.getGeneratedKeys();
                    rs.next();
                    staffId = rs.getInt(1);

                    psRole.setString(1, role);
                    psRole.setInt(2, staffId);
                    psRole.executeUpdate();
                    response.sendRedirect(request.getContextPath() + "/manager.jsp");
                    return;
                }

            catch (SQLException e) 
            {
            throw new ServletException("Database error while registering user", e);
            }
        }
}
        