import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.Path;
import java.sql.*;
import java.util.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

@WebServlet("/manage-menu")
@MultipartConfig(
  fileSizeThreshold = 1024 * 1024,      
  maxFileSize       = 10 * 1024 * 1024,  
  maxRequestSize    = 15 * 1024 * 1024   
)
public class ManageMenuServlet extends HttpServlet {
    private static final String JDBC_URL    =
        "jdbc:mysql://localhost:3306/byte2bite?autoReconnect=true&useSSL=false";
    private static final String DB_USER     = "root";
    private static final String DB_PASSWORD = "";   //add your password

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        List<Map<String,Object>> menu = new ArrayList<>();
        String error = null;
        try (Connection con = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD);
             PreparedStatement ps = con.prepareStatement(
               "SELECT meal_id,name,price,category FROM meal ORDER BY category,name");
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String,Object> m = new HashMap<>();
                m.put("meal_id",  rs.getInt("meal_id"));
                m.put("name",     rs.getString("name"));
                m.put("price",    rs.getDouble("price"));
                m.put("category", rs.getString("category"));
                menu.add(m);
            }
        } catch (SQLException e) {
            error = "Error loading menu: " + e.getMessage();
        }
        req.setAttribute("menu", menu);
        req.setAttribute("error", error);
        req.getRequestDispatcher("/manageMenu.jsp").forward(req, res);
    }

   @Override
  protected void doPost(HttpServletRequest req, HttpServletResponse res)
      throws ServletException, IOException {
    req.setCharacterEncoding("UTF-8");
    String action = req.getParameter("action");
    String error  = null;

    try (Connection con = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD)) {
      con.setAutoCommit(false);

      if ("save".equals(action)) {
        String[] ids        = req.getParameterValues("meal_id");
        String[] names      = req.getParameterValues("name");
        String[] prices     = req.getParameterValues("price");
        String[] categories = req.getParameterValues("category");
        if (ids != null) {
          try (PreparedStatement ps = con.prepareStatement(
              "UPDATE meal SET name=?,price=?,category=? WHERE meal_id=?")) {
            for (int i = 0; i < ids.length; i++) {
              ps.setString(1, names[i]);
              ps.setDouble(2, Double.parseDouble(prices[i]));
              ps.setString(3, categories[i]);
              ps.setInt(4, Integer.parseInt(ids[i]));
              ps.addBatch();
            }
            ps.executeBatch();
          }
        }

      } else if ("add".equals(action)) {
        Part   imagePart   = req.getPart("new_image");
        String newName     = req.getParameter("new_name");
        String newPrice    = req.getParameter("new_price");
        String newCategory = req.getParameter("new_category");

        System.out.printf("DEBUG add→ name='%s',price='%s',category='%s',imgSize=%d%n",
          newName, newPrice, newCategory,
          (imagePart==null? -1 : imagePart.getSize()));

        if (newName!=null && !newName.isBlank()
         && newPrice!=null && !newPrice.isBlank()
         && newCategory!=null && !newCategory.isBlank()
         && imagePart!=null && imagePart.getSize()>0) {

          String filename  = Paths.get(imagePart.getSubmittedFileName())
                                 .getFileName().toString();
          String uploadDir = getServletContext().getRealPath("/images/meals");
          Files.createDirectories(Paths.get(uploadDir));
          imagePart.write(Paths.get(uploadDir, filename).toString());

          try (PreparedStatement ps = con.prepareStatement(
               "INSERT INTO meal (name,price,category,image_url) VALUES (?,?,?,?)")) {
            ps.setString(1, newName);
            ps.setDouble(2, Double.parseDouble(newPrice));
            ps.setString(3, newCategory);
            ps.setString(4, "/images/meals/"+filename);
            ps.executeUpdate();
          }
        } else {
          error = "Missing fields or image—check debug logs.";
        }
      }

      con.commit();
    } catch (Exception e) {
      error = e.getMessage();
    }

    req.setAttribute("error", error);
    doGet(req, res); 
  }
}