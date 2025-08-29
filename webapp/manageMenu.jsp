<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%

  if (request.getAttribute("menu")==null) {
    response.sendRedirect(request.getContextPath() + "/manage-menu");
    return;
  }
%>



<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Manage Menu</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"
        rel="stylesheet">
</head>
<body class="container my-5">

    <%  
      String firstName = (String) session.getAttribute("FirstName");
      String lastName  = (String) session.getAttribute("LastName");
      String role      = (String) session.getAttribute("role");
         

    String backPage = "employeeHub.jsp";
    if ("Kitchen Staff".equalsIgnoreCase(role)) {
        backPage = "chefHub.jsp";
    } else if ("Manager".equalsIgnoreCase(role)) {
        backPage = "managerHub.jsp";
    } else if ("Wait Staff".equalsIgnore
        response.sendRedirect("employeeHub.jsp");
    }

  %>

  <div class="position-relative mb-4" style="height:100px;">
    <div class="position-absolute top-0 start-0 d-flex flex-column align-items-center mt-3 ms-3">
      <a href="<%= backPage %>">
        <img src="<%= request.getContextPath() %>/images/logo3.png"
             alt="Byte2Bite Logo"
             style="height:80px; display:block;" />
      </a>
      <a href="<%= backPage %>" 
         class="btn btn-outline-secondary mt-2">
        &larr; Back to Hub
      </a>
    </div>

    <div class="position-absolute top-0 end-0 mt-3 me-3" style="height:40px;">
      <div class="bg-primary text-white px-3 rounded h-100 d-flex align-items-center">
        <%= role %> : <%= firstName %> <%= lastName %>
      </div>
    </div>
  </div>

  
    <div class="text-center mb-4">
        <h2>Manage Menu</h2>
    </div>


  <c:if test="${not empty error}">
    <div class="alert alert-danger">${error}</div>
  </c:if>

  <form action="${pageContext.request.contextPath}/manage-menu"
        method="post">
    <input type="hidden" name="action" value="save"/>

    <table class="table table-bordered mb-4">
      <thead class="table-light">
        <tr><th>Name</th><th>Price ($)</th><th>Category</th></tr>
      </thead>
      <tbody>
        <c:forEach var="item" items="${menu}">
          <tr>
            <td>
              <input type="hidden" name="meal_id"  value="${item.meal_id}"/>
              <input type="text"   name="name"     class="form-control"
                     value="${item.name}"/>
            </td>
            <td>
              <input type="number" name="price" step="0.01"
                     class="form-control" value="${item.price}"/>
            </td>
            <td>
              <select name="category" class="form-select">
                <option ${item.category=='Entree'   ? 'selected':''}>Entree</option>
                <option ${item.category=='Side'     ? 'selected':''}>Side</option>
                <option ${item.category=='Dessert'  ? 'selected':''}>Dessert</option>
                <option ${item.category=='Beverage' ? 'selected':''}>Beverage</option>
              </select>
            </td>
          </tr>
        </c:forEach>
      </tbody>
    </table>


    <div class="d-flex justify-content-between mb-5">
      <button type="submit" class="btn btn-primary">
        Save Changes
      </button>
      <button type="button" class="btn btn-success"
              data-bs-toggle="modal" data-bs-target="#addItemModal">
        Add New Item
      </button>
    </div>
  </form>


  <div class="modal fade" id="addItemModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
      <div class="modal-content">
        <form action="${pageContext.request.contextPath}/manage-menu"
              method="post"
              enctype="multipart/form-data">
          <input type="hidden" name="action" value="add"/>

          <div class="modal-header">
            <h5 class="modal-title">Add New Menu Item</h5>
            <button type="button" class="btn-close"
                    data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body">
            <div class="mb-3">
              <label class="form-label">Name</label>
              <input type="text" name="new_name" class="form-control" required>
            </div>
            <div class="mb-3">
              <label class="form-label">Price ($)</label>
              <input type="number" name="new_price" step="0.01"
                     class="form-control" required>
            </div>
            <div class="mb-3">
              <label class="form-label">Category</label>
              <select name="new_category" class="form-select" required>
                <option>Entree</option>
                <option>Side</option>
                <option>Dessert</option>
                <option>Beverage</option>
              </select>
            </div>
            <div class="mb-3">
              <label class="form-label">Image</label>
              <input type="file" name="new_image" class="form-control"
                     accept="image/*" required>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary"
                    data-bs-dismiss="modal">Cancel</button>
            <button type="submit" class="btn btn-success">
              Add Item
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>

  <script
    src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js">
  </script>
</body>
</html>
