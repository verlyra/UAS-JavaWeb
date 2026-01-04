<%@page import="jdbc.Koneksi"%>
<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%!
    private String getParam(HttpServletRequest request, String name) {
        String value = request.getParameter(name);
        return (value == null) ? "" : value;
    }
%>

<%
    String errorMsg = "";
    String action = getParam(request, "action");

    if ("login".equals(action) && "POST".equalsIgnoreCase(request.getMethod())) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        String userParam = getParam(request, "username");
        String passParam = getParam(request, "password");

        try {
            Koneksi k = new Koneksi();
            conn = k.bukaKoneksi();
            
            if (conn == null) {
                throw new SQLException("Gagal membuat koneksi ke database.");
            }

            String sql = "SELECT * FROM master_user WHERE username = ? AND kata_sandi = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userParam);
            pstmt.setString(2, passParam); 
            
            rs = pstmt.executeQuery();

            if (rs.next()) {
                session.setAttribute("user_id", rs.getString("id"));
                session.setAttribute("username", rs.getString("username"));
                session.setAttribute("nama_lengkap", rs.getString("nama_lengkap"));
                response.sendRedirect("MasterUser.jsp"); 
                return;
            } else {
                errorMsg = "Username atau Password salah!";
            }
        } catch (Exception e) {
            errorMsg = "Error: " + e.getMessage();
        } finally {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>VEND.IO - Login</title>
    <!-- Tailwind CDN -->
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;700;900&display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Inter', sans-serif;
            background-color: #D1D5DB; /* Warna abu-abu background */
        }
        .neubrutalism-card {
            box-shadow: 10px 10px 0px 0px rgba(0,0,0,1);
        }
        .neubrutalism-btn:active {
            box-shadow: 2px 2px 0px 0px rgba(0,0,0,1);
            transform: translate(4px, 4px);
        }
    </style>
</head>
<body class="min-h-screen flex items-center justify-center p-4">

    <div class="bg-white border-[4px] border-black p-8 w-full max-w-[400px] neubrutalism-card">
        
        <!-- Logo Container -->
        <div class="flex flex-col items-center mb-8">
            <div class="bg-[#F3CE48] border-[4px] border-black p-3 mb-4">
                <!-- Icon Keranjang Belanja -->
                <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
                    <circle cx="9" cy="21" r="1"></circle>
                    <circle cx="20" cy="21" r="1"></circle>
                    <path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"></path>
                </svg>
            </div>
            
            <h1 class="text-5xl font-[900] italic tracking-tighter mb-1">VEND.IO</h1>
            <div class="h-2 w-48 bg-black"></div> <!-- Garis bawah tebal -->
        </div>

        <!-- Error Message -->
        <% if (!errorMsg.isEmpty()) { %>
            <div class="bg-red-200 border-2 border-black p-2 mb-4 text-sm font-bold text-center">
                <%= errorMsg %>
            </div>
        <% } %>

        <!-- Login Form -->
        <form action="index.jsp?action=login" method="POST" class="space-y-6">
            <div>
                <label class="block text-sm font-black tracking-widest uppercase mb-1">Username</label>
                <input type="text" name="username" placeholder="Enter username" required
                    class="w-full border-[4px] border-black p-3 font-bold focus:outline-none placeholder:text-gray-400">
            </div>

            <div>
                <label class="block text-sm font-black tracking-widest uppercase mb-1">Password</label>
                <input type="password" name="password" placeholder="Enter Password" required
                    class="w-full border-[4px] border-black p-3 font-bold focus:outline-none placeholder:text-gray-400">
            </div>

            <button type="submit" 
                class="w-full bg-[#F3CE48] border-[4px] border-black p-4 text-2xl font-black uppercase tracking-widest hover:bg-yellow-500 transition-all neubrutalism-btn">
                LOGIN
            </button>
        </form>

        <!-- Footer -->
        <div class="mt-12 text-center">
            <p class="text-gray-400 font-bold text-sm">Developed by Dandy & Verly</p>
        </div>
    </div>

</body>
</html>