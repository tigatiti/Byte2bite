<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Byte2Bite: View Feedback</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script>
        function filterFeedback() {
            const ratingFilter = document.getElementById("ratingFilter").value;
            const searchInput = document.getElementById("searchInput").value.toLowerCase();
            const rows = document.querySelectorAll(".feedback-row");

            rows.forEach(row => {
                const feedbackText = row.querySelector(".feedback-text").innerText.toLowerCase();
                const ratingValue = row.querySelector(".feedback-rating").innerText.trim();

                let matchesSearch = feedbackText.includes(searchInput);
                let matchesRating = (ratingFilter === "" || ratingValue === ratingFilter);

                row.style.display = (matchesSearch && matchesRating) ? "" : "none";
            });
        }

        function clearFilter() {
            document.getElementById("searchInput").value = "";
            document.getElementById("ratingFilter").value = "";
            filterFeedback();
        }
    </script>
</head>
<body class="container mt-5">

    <div class="position-relative mb-4">
        <a href="managerHub.jsp" class="btn btn-outline-secondary position-absolute top-0 start-0">&larr; Back to Hub</a>
        <h2 class="text-center">Customer Feedback</h2>
    </div>


    <form class="mb-4 text-center d-flex justify-content-center gap-2" onsubmit="event.preventDefault(); filterFeedback();">
        <input id="searchInput" type="text" class="form-control w-50" placeholder="Search feedback...">
        <select id="ratingFilter" class="form-select w-auto">
            <option value="">All Ratings</option>
            <option value="5">⭐ 5</option>
            <option value="4">⭐ 4</option>
            <option value="3">⭐ 3</option>
            <option value="2">⭐ 2</option>
            <option value="1">⭐ 1</option>
        </select>
        <button type="submit" class="btn btn-primary">Apply</button>
        <button type="button" class="btn btn-secondary"onclick="clearFilter()">Clear</button>
    </form>


    <div class="table-responsive">
        <table class="table table-bordered align-middle">
            <thead class="table-light">
                <tr>
                    <th>Feedback</th>
                    <th>Rating</th>
                    <th>Submitted At</th>
                </tr>
            </thead>
            <tbody>
            <%
                String JDBC_URL = "jdbc:mysql://localhost:3306/byte2bite?autoReconnect=true&useSSL=false";
                String DB_USER = "root";
                String DB_PASSWORD = "";   //add your password

                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    Connection con = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD);

                    String sql="SELECT feedback_text, rating, submitted_at FROM customer_feedback ORDER BY submitted_at DESC";
                    PreparedStatement stmt =con.prepareStatement(sql);
                    ResultSet rs=stmt.executeQuery();

                    boolean found= false;
                    while (rs.next()) {
                        found =true;
            %>
                <tr class="feedback-row">
                    <td class="feedback-text"><%= rs.getString("feedback_text") %></td>
                    <td class="feedback-rating"><%= rs.getInt("rating") %></td>
                    <td><%= rs.getTimestamp("submitted_at") %></td>
                </tr>
            <%
                    }
                    if(!found) {
            %>
                <tr><td colspan="3" class="text-center">No feedback submitted yet.</td></tr>
            <%
                    }
                    rs.close();
                    stmt.close();
                    con.close();
                } catch (Exception e) {
            %>
                <tr><td colspan="3" class="text-danger text-center">Error: <%= e.getMessage() %></td></tr>
            <%
                }
            %>
            </tbody>
        </table>
    </div>

</body>
</html>