<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Submit Feedback</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="container mt-5">

    <div class="position-relative mb-4">
        <a href="customerHub.jsp" class="btn btn-outline-secondary position-absolute top-0 start-0">&larr;Home</a>
        <h2 class="text-center">Submit Feedback</h2>
    </div>

    <div class="card shadow-sm mx-auto" style="max-width: 500px;">
        <div class="card-body">
            <form action="submitFeedback.jsp" method="post" class="d-flex flex-column gap-3">
                <div>
                    <label for="feedback" class="form-label">Your Feedback (anonymous):</label>
                    <textarea id="feedback" name="feedback" class="form-control" rows="3" required></textarea>
                </div>
                <div>
                    <label for="rating" class="form-label">Rating (1 to 5):</label>
                    <select id="rating" name="rating"class="form-select" required>
                        <option value="" selected disabled>Select rating</option>
                        <option value="5">⭐ 5 - Excellent</option>
                        <option value="4">⭐ 4 - Good</option>
                        <option value="3">⭐ 3 - Average</option>
                        <option value="2">⭐ 2 - Poor</option>
                        <option value="1">⭐ 1 - Very Poor</option>
                    </select>
                </div>
                <button type="submit" class="btn btn-primary w-100">Submit</button>
            </form>

            <%
                String feedback=request.getParameter("feedback");
                String ratingStr =request.getParameter("rating");

                if (feedback!=null && ratingStr!= null) {
                    int rating = Integer.parseInt(ratingStr);

                    String JDBC_URL ="jdbc:mysql://localhost:3306/byte2bite?autoReconnect=true&useSSL=false";
                    String DB_USER ="root";
                    String DB_PASSWORD= ""; //add your password

                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        Connection con=DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD);

                        String sql="INSERT INTO customer_feedback (feedback_text, rating) VALUES (?,?)";
                        PreparedStatement stmt=con.prepareStatement(sql);
                        stmt.setString(1,feedback);
                        stmt.setInt(2,rating);

                        stmt.executeUpdate();
                        stmt.close();
                        con.close();
            %>
                        <div class="alert alert-success mt-3">Thank you for your feedback!</div>
            <%
                    } catch (Exception e) {
            %>
                        <div class="alert alert-danger mt-3">Error:<%= e.getMessage() %></div>
            <%
                    }
                }
            %>
        </div>
    </div>
</body>
</html>