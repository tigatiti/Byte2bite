<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="java.time.LocalDateTime, java.time.format.DateTimeFormatter, java.time.Duration" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.List, java.util.ArrayList" %>

<%
    String lastIn   = (String) session.getAttribute("lastClockIn");
    String lastOut  = (String) session.getAttribute("lastClockOut");

    String firstName = (String) session.getAttribute("FirstName");
    String lastName = (String) session.getAttribute("LastName");
    String role = (String) session.getAttribute("role");

    Integer staffIdObj = (Integer) session.getAttribute("staffId");
    int staffId = (staffIdObj != null) ? staffIdObj : -1; 

    DateTimeFormatter FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    boolean clockedIn = false;
    if (lastIn != null) {
        if (lastOut == null) {
            clockedIn = true;
        } else {
            try {
                LocalDateTime timeIn  = LocalDateTime.parse(lastIn,  FMT);
                LocalDateTime timeOut = LocalDateTime.parse(lastOut, FMT);
                if (timeIn.isAfter(timeOut)) {
                    clockedIn = true;
                }
            } catch (Exception e) {
                if (lastIn.compareTo(lastOut) > 0) {
                    clockedIn = true;
                }
            }
        }
    }

    String buttonAction = clockedIn ? "clockOut" : "clockIn";
    String buttonLabel  = clockedIn ? "Clock Out" : "Clock In";


class Period {
    String inStr = "-";
    String outStr = "-";
    long minutes = 0;
    LocalDateTime in = null;
    LocalDateTime out = null;

    String decimalHours() {
        if (in != null && out != null) {
            long totalMinutes = Duration.between(in, out).toMinutes();
            if (totalMinutes < 0) totalMinutes = 0;
            double hours = totalMinutes / 60.0;

            String s = String.format("%.2f", hours);
            if (s.endsWith("00")) 
            {
                s = s.substring(0, s.indexOf('.'));
            } else if (s.endsWith("0")) 
            {
                s = s.substring(0, s.length() - 1);
            }
            return s;
        }
        return "--";
    }
}
  
  List<Period> periods = new ArrayList<>();

  final String JDBC_URL = "jdbc:mysql://localhost:3306/byte2bite?useSSL=false&serverTimezone=UTC";
  final String DB_USER = "root";
  final String DB_PASSWORD = "Password12!"; 

  boolean firstRow = true;

  try (Connection conn = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD);
       PreparedStatement ps = conn.prepareStatement("SELECT in_time, out_time FROM staff_log WHERE staff_id = ? ORDER BY in_time DESC")) 
       {
        ps.setInt(1, staffId);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) 
        {
            Period p = new Period();
            Timestamp inTimestamp = rs.getTimestamp("in_time");
            Timestamp outTimestamp = rs.getTimestamp("out_time");

                      if (inTimestamp != null) 
                      {
                          p.in = inTimestamp.toLocalDateTime();
                          p.inStr = p.in.format(FMT);
                      }
                      if (outTimestamp != null) 
                      {
                          p.out = outTimestamp.toLocalDateTime();
                          p.outStr = p.out.format(FMT);
                      }

                      if (p.in != null && p.out != null) 
                      {
                          Duration dur = Duration.between(p.in, p.out);
                          p.minutes = Math.max(0, dur.toMinutes());
                      }

                      periods.add(p);

                      if (firstRow) {
                          lastIn = p.inStr.equals("-") ? null : p.inStr;
                          lastOut = p.outStr.equals("-") ? null : p.outStr;


                          if (p.in != null && p.out == null) 
                          {
                              clockedIn = true;
                          } else if (p.in != null && p.out != null && p.in.isAfter(p.out)) 
                          {
                              clockedIn = true;
                          }
                          firstRow = false;
                      }
                  }
            
        } catch (SQLException e) {
            out.println("Error loading time logs. " + e.getMessage());
        }
%>



<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
</head>
<link rel="stylesheet" href="<%= request.getContextPath() %>/css/timeTracking.css?v=<%= System.currentTimeMillis() %>" />
<body>

    <div class="user-info">
        <%= role %> : <%= firstName %> <%= lastName %>
    </div>

  <div class="main-link-container">
    <a class="main-btn" href="<%= request.getContextPath() %>/managerHub.jsp">Main Page</a>
  </div>

    <div class="clock-container">
      <div class="clock">
        Current Time: <span id="liveClock">--:--:--</span>
      </div>
    </div>

    <% String inDisplay  = (clockedIn && lastIn != null) ? lastIn : "";
      String outDisplay = (clockedIn && lastOut != null) ? lastOut : "";
    %>
    <div class="times">
      <p><strong> Clock In:</strong> <%= inDisplay %></p>
      <p><strong>Clock Out:</strong> <%= outDisplay %></p>
    </div>

    <form action="${pageContext.request.contextPath}/time-tracking" method="post">
    <button type="submit" name="action" value="<%= buttonAction %>">
        <%= buttonLabel %>
    </button>
    </form>

    <h3>Work History</h3>
    <table border="1" cellpadding="6" cellspacing="0">
      <thead>
      <tr>
        <th>Clock In</th>
        <th>Clock Out</th>
        <th>Hours Worked</th>
      </tr>
      </thead>
      <tbody>
      <%
        for (Period p : periods) {
      %>
        <tr>
          <td><%= p.inStr %></td>
          <td><%= p.outStr %></td>
          <td><%= p.decimalHours() %></td>
        </tr>
      <%
        }
      %>
      </tbody>
    </table>

    <script>
      function updateClock() {
        document.getElementById('liveClock').textContent = new Date().toLocaleTimeString();
      }
      window.addEventListener('load', () => {
        updateClock();
        setInterval(updateClock, 1000);
      });
    </script>
</body>
</html>
