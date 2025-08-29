<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Register Employee</title>
    <link rel="stylesheet" href="/byte2bite-web/css/register_employee.css?v=<%= System.currentTimeMillis() %>" />
</head>
<body>
    <%
    String firstName = (String) session.getAttribute("FirstName");
    String lastName = (String) session.getAttribute("LastName");
    String role = (String) session.getAttribute("role");
    %>

    <div class="user-info">
        <%= role %> : <%= firstName %> <%= lastName %>
    </div>


    <div class="main-link-container">
        <a class="main-btn" href="<%= request.getContextPath() %>/managerHub.jsp">Main Page</a>
    </div>

    <main class="page-center">
        <div class="form-container">
            <h2>Register Employee</h2>
            <% if (error != null) { %>
                <div class="error-message"><%= error %></div>
            <% } %>

            <form action="<%= request.getContextPath() %>/register_employee" method="post">
                <div class="form-group">
                    <label for="first_name">First Name:</label>
                    <input type="text" id="first_name" name="first_name" required>
                </div>

                <div class="form-group">
                    <label for="last_name">Last Name:</label>
                    <input type="text" id="last_name" name="last_name" required>
                </div>

                <div class="form-group">
                    <label for="pin">PIN:</label>
                    <input type="password" id="pin" name="pin" required>
                </div>

                <div class="form-group">
                    <label for="confirm_pin">Confirm PIN:</label>
                    <input type="password" id="confirm_pin" name="confirm_pin" required>
                </div>

                <div class="form-group">
                    <label for="role">Role:</label>
                    <select id="role" name="role" required>
                        <option value="" disabled selected hidden>Select a Role</option>
                        <option value="Wait Staff">Wait Staff</option>
                        <option value="Kitchen Staff">Kitchen Staff</option>
                    </select>
                </div>

                <button type="submit">Register</button>
            </form>
        </div>
    </main>
</body>

</html>