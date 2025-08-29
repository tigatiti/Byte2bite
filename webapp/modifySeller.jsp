<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    String action = request.getParameter("action");

    String JDBC_URL = "jdbc:mysql://localhost:3306/byte2bite?autoReconnect=true&useSSL=false";
    String DB_USER = "root";
    String DB_PASSWORD = " ";  //add your password

    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD);

    if ("register".equals(action)) {
        String name = request.getParameter("name");
        String phone = request.getParameter("phone");
        String itemName = request.getParameter("item_name").trim();
        double cost = Double.parseDouble(request.getParameter("cost"));

        // Check if item exists
        int inventoryId = -1;
        String checkItem = "SELECT inventory_id FROM food_inventory WHERE name = ?";
        PreparedStatement checkItemStmt = con.prepareStatement(checkItem);
        checkItemStmt.setString(1, itemName);
        ResultSet rs = checkItemStmt.executeQuery();
        if (rs.next()) {
            inventoryId = rs.getInt("inventory_id");
        } else {
            String insertItem = "INSERT INTO food_inventory (name, quantity, time_stamp) VALUES (?, 0, NOW())";
            PreparedStatement insertItemStmt = con.prepareStatement(insertItem, Statement.RETURN_GENERATED_KEYS);
            insertItemStmt.setString(1, itemName);
            insertItemStmt.executeUpdate();
            ResultSet keys = insertItemStmt.getGeneratedKeys();
            if (keys.next()) {
                inventoryId = keys.getInt(1);
            }
            insertItemStmt.close();
        }
        checkItemStmt.close();
        rs.close();


        int sellerId = -1;
        String insertSeller = "INSERT INTO supplier (name, phone) VALUES (?, ?)";
        PreparedStatement insertSellerStmt = con.prepareStatement(insertSeller, Statement.RETURN_GENERATED_KEYS);
        insertSellerStmt.setString(1, name);
        insertSellerStmt.setString(2, phone);
        insertSellerStmt.executeUpdate();
        ResultSet sellerKeys = insertSellerStmt.getGeneratedKeys();
        if (sellerKeys.next()) {
            sellerId = sellerKeys.getInt(1);
        }
        insertSellerStmt.close();

        String insertSoldBy = "INSERT INTO sold_by (inventory_id, seller_id, cost) VALUES (?, ?, ?)";
        PreparedStatement insertSoldByStmt = con.prepareStatement(insertSoldBy);
        insertSoldByStmt.setInt(1, inventoryId);
        insertSoldByStmt.setInt(2, sellerId);
        insertSoldByStmt.setDouble(3, cost);
        insertSoldByStmt.executeUpdate();
        insertSoldByStmt.close();

    } else if ("update".equals(action)) {
        int sellerId = Integer.parseInt(request.getParameter("seller_id"));
        int inventoryId = Integer.parseInt(request.getParameter("inventory_id"));
        String name = request.getParameter("name");
        String phone = request.getParameter("phone");
        String itemName = request.getParameter("item_name").trim();
        double cost = Double.parseDouble(request.getParameter("cost"));


        String updateSeller = "UPDATE supplier SET name = ?, phone = ? WHERE seller_id = ?";
        PreparedStatement updateSellerStmt = con.prepareStatement(updateSeller);
        updateSellerStmt.setString(1, name);
        updateSellerStmt.setString(2, phone);
        updateSellerStmt.setInt(3, sellerId);
        updateSellerStmt.executeUpdate();
        updateSellerStmt.close();


        String updateItem = "UPDATE food_inventory SET name = ? WHERE inventory_id = ?";
        PreparedStatement updateItemStmt = con.prepareStatement(updateItem);
        updateItemStmt.setString(1, itemName);
        updateItemStmt.setInt(2, inventoryId);
        updateItemStmt.executeUpdate();
        updateItemStmt.close();

        String updateSoldBy = "UPDATE sold_by SET cost = ? WHERE seller_id = ? AND inventory_id = ?";
        PreparedStatement updateSoldByStmt = con.prepareStatement(updateSoldBy);
        updateSoldByStmt.setDouble(1, cost);
        updateSoldByStmt.setInt(2, sellerId);
        updateSoldByStmt.setInt(3, inventoryId);
        updateSoldByStmt.executeUpdate();
        updateSoldByStmt.close();

    } else if ("delete".equals(action)) {
        int sellerId = Integer.parseInt(request.getParameter("seller_id"));
        int inventoryId = Integer.parseInt(request.getParameter("inventory_id"));

  
        String deleteSoldBy = "DELETE FROM sold_by WHERE seller_id = ? AND inventory_id = ?";
        PreparedStatement ps1 = con.prepareStatement(deleteSoldBy);
        ps1.setInt(1, sellerId);
        ps1.setInt(2, inventoryId);
        ps1.executeUpdate();
        ps1.close();


        String check = "SELECT COUNT(*) FROM sold_by WHERE seller_id = ?";
        PreparedStatement checkStmt = con.prepareStatement(check);
        checkStmt.setInt(1, sellerId);
        ResultSet rs = checkStmt.executeQuery();
        if (rs.next() && rs.getInt(1) == 0) {
            PreparedStatement ps2 = con.prepareStatement("DELETE FROM supplier WHERE seller_id = ?");
            ps2.setInt(1, sellerId);
            ps2.executeUpdate();
            ps2.close();
        }
        checkStmt.close();
        rs.close();
    }

    con.close();
    response.sendRedirect("manageSeller.jsp");
%>
