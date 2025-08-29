

<!DOCTYPE html>
<html>
<head>
    <title>Byte2Bite: Manager Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/managerHub.css?v=<%= System.currentTimeMillis() %>" />

</head>
<body class="container mt-5">

<%
    String firstName = (String) session.getAttribute("FirstName");
    String lastName = (String) session.getAttribute("LastName");
    String role = (String) session.getAttribute("role");
%>

    <div class="position-absolute top-0 start-0 mt-3 ms-3">
      <a href="chefHub.jsp">
        <img src="<%= request.getContextPath() %>/images/logo3.png"
             alt="Byte2Bite Logo"
             style="height:110px; width:auto;">
      </a>
    </div>



    <div class="top-right">
    <div class="user-info">
        <%= role %> : <%= firstName %> <%= lastName %>
    </div>
    <div class="user-icon">
        <a href="timeTracking.jsp">
        <img src="<%= request.getContextPath() %>/images/clock.png" alt="Clock" />
        </a>
    </div>
    </div>


    <div class="row justify-content-center">
        <div class="col-md-8 text-center">
            <h2 class="mb-4">Manager Hub</h2>


            <div class="card mb-3 shadow-sm mx-auto" style="max-width: 500px;">    
                <div class="card-body py-3 px-4">
                    <h5 class="card-title mb-2">Submit New Order</h5>
                    <p class="card-text mb-3">- Place a new meal order for a customer's table.</p>
                    <a href="waitStaff.jsp" class="btn btn-primary btn-sm">Submit Order</a>
                </div>
            </div>


            <div class="card mb-3 shadow-sm mx-auto" style="max-width: 500px;">
                <div class="card-body py-3 px-4">
                    <h5 class="card-title mb-2">Order Overview</h5>
                    <p class="card-text mb-3">- View active and completed orders.<br>- View and modify order details including staff, table, and status.</p>
                    <a href="modifyOrderStatus.jsp" class="btn btn-primary btn-sm">Go to Order Overview</a>
                </div>
            </div>


            <div class="card mb-3 shadow-sm mx-auto" style="max-width: 500px;">
                <div class="card-body py-3 px-4">
                    <h5 class="card-title mb-2">Dining Overview</h5>
                    <p class="card-text mb-3">- Monitor table statuses including occupancy, staff, and customer info.</p>
                    <a href="viewTables.jsp" class="btn btn-primary btn-sm">Go to Dining Overview</a>
                </div>
            </div>


            <div class="card mb-3 shadow-sm mx-auto" style="max-width: 500px;">
                <div class="card-body py-3 px-4">
                    <h5 class="card-title mb-2">Inventory Control</h5>
                    <p class="card-text mb-3">- View/Modify food inventory and supplier info.</p>
                    <a href="InventoryTracker.jsp" class="btn btn-primary btn-sm">Food Inventory</a>
                    <a href="sellerInfo.jsp" class="btn btn-outline-secondary btn-sm ms-2">Suppliers</a>
                </div>
            </div>

            <div class="card mb-3 shadow-sm mx-auto" style="max-width: 500px;">
                <div class="card-body py-3 px-4">
                    <h5 class="card-title mb-2">Menu</h5>
                    <p class="card-text mb-3">- Add new menu items to the Menu.</p>
                    <a href="manageMenu.jsp" class="btn btn-primary btn-sm">Add New Menu Item</a>
                </div>
            </div>


            <div class="card mb-3 shadow-sm mx-auto" style="max-width: 500px;">
                <div class="card-body py-3 px-4">
                    <h5 class="card-title mb-2">Payment Log</h5>
                    <p class="card-text mb-3">- View all transactions regarding date, staff, and meals.</p>
                    <a href="transactionLog.jsp" class="btn btn-primary btn-sm">Payment Log</a>
                </div>
            </div>



            <div class="card mb-3 shadow-sm mx-auto" style="max-width: 500px;">
                <div class="card-body py-3 px-4">
                    <h5 class="card-title mb-2">Manage Employees</h5>
                    <p class="card-text mb-3">- Register and manage staff roles and details.</p>
                    <a href="register_employee.jsp" class="btn btn-primary btn-sm">Register Staff</a>
                    <a href="manage_employee.jsp" class="btn btn-outline-secondary btn-sm ms-2">Manage Staff</a>
                </div>
            </div>


            <div class="card mb-3 shadow-sm mx-auto" style="max-width: 500px;">
                <div class="card-body py-3 px-4">
                    <h5 class="card-title mb-2">View Feedback</h5>
                    <p class="card-text mb-3">- View and manage customer feedback and reviews.</p>
                    <a href="viewFeedback.jsp" class="btn btn-primary btn-sm">View Feedback</a>
                </div>
            </div>




            <div class="card mb-3 shadow-sm mx-auto" style="max-width: 500px;">
                <div class="card-body py-3 px-4">
                    <h5 class="card-title mb-2">Customer Info</h5>
                    <p class="card-text mb-3">- View customer profiles and order history.</p>
                    <a href="customerInfo.jsp" class="btn btn-primary btn-sm">View Customer Info</a>
                </div>
            </div>


            <div class="card mb-3 shadow-sm mx-auto" style="max-width: 500px;">
                <div class="card-body py-3 px-4">
                    <h5 class="card-title mb-2">Financial Reports</h5>
                    <p class="card-text mb-3">- View revenue breakdown and transaction logs.</p>
                    <a href="revenueTracker.jsp" class="btn btn-primary btn-sm">Payment Report</a>
                </div>
            </div>
        </div>
    </div>
</body>
</html>