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


@WebServlet("/OrderServlet")
public class OrderServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

        String mealId = request.getParameter("meal_id");
        String quantity = request.getParameter("quantity");

        try {
            Class.forName("com.mysql.jdbc.Driver");
            Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/byte2bite?useSSL=false",
                "root", "PASSWORD"  //add your password
            );

            PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO contains (meal_id, order_id, quantity) VALUES (?, ?, ?)"
            );
            ps.setInt(1, Integer.parseInt(mealId));
            ps.setInt(2, 1); 
            ps.setInt(3, Integer.parseInt(quantity));

            ps.executeUpdate();
            conn.close();

            response.sendRedirect("waitStaff.jsp");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
