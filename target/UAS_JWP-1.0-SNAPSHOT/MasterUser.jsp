<%@page import="jdbc.Koneksi"%>
<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    // 1. PROTEKSI SESSION
    if (session.getAttribute("username") == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    String action = request.getParameter("action");
    Connection conn = null;
    PreparedStatement ps = null;

    try {
        Koneksi k = new Koneksi();
        conn = k.bukaKoneksi();

        // --- LOGIKA CRUD USER ---
        if ("add".equals(action) && "POST".equalsIgnoreCase(request.getMethod())) {
            String sql = "INSERT INTO master_user (username, kata_sandi, nama_lengkap) VALUES (?, ?, ?)";
            ps = conn.prepareStatement(sql);
            ps.setString(1, request.getParameter("username"));
            ps.setString(2, request.getParameter("kata_sandi"));
            ps.setString(3, request.getParameter("nama_lengkap"));
            ps.executeUpdate();
            response.sendRedirect("MasterUser.jsp?status=added");
            return;
        }

        if ("update".equals(action) && "POST".equalsIgnoreCase(request.getMethod())) {
            String sql = "UPDATE master_user SET username=?, kata_sandi=?, nama_lengkap=? WHERE id=?";
            ps = conn.prepareStatement(sql);
            ps.setString(1, request.getParameter("username"));
            ps.setString(2, request.getParameter("kata_sandi"));
            ps.setString(3, request.getParameter("nama_lengkap"));
            ps.setInt(4, Integer.parseInt(request.getParameter("id")));
            ps.executeUpdate();
            response.sendRedirect("MasterUser.jsp?status=updated");
            return;
        }

        if ("delete".equals(action)) {
            ps = conn.prepareStatement("DELETE FROM master_user WHERE id = ?");
            ps.setInt(1, Integer.parseInt(request.getParameter("id")));
            ps.executeUpdate();
            response.sendRedirect("MasterUser.jsp?status=deleted");
            return;
        }
    } catch (Exception e) {
        e.printStackTrace();
    } 
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>VEND.IO - Master User</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;700;900&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Inter', sans-serif; background-color: #D1D5DB; }
        .neubrutalism-border { border: 4px solid black; }
        .neubrutalism-shadow { box-shadow: 6px 6px 0px 0px rgba(0,0,0,1); }
        .neubrutalism-shadow-lg { box-shadow: 10px 10px 0px 0px rgba(0,0,0,1); }
        .sidebar-link:hover { background-color: #F3CE48; color: black; border: 4px solid black; }
        .active-menu { background-color: #F3CE48; color: black; border: 4px solid black; }
    </style>
</head>
<body class="flex h-screen overflow-hidden">

    <!-- SIDEBAR -->
    <aside class="w-64 bg-black text-white flex flex-col justify-between p-6">
        <div>
            <!-- Logo -->
            <div class="flex items-center gap-3 mb-10">
                <div class="bg-[#F3CE48] p-2 neubrutalism-border">
                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="black" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="21" r="1"></circle><circle cx="20" cy="21" r="1"></circle><path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"></path></svg>
                </div>
                <h1 class="text-2xl font-[900] italic uppercase">VEND.IO</h1>
            </div>

            <!-- Menu -->
            <nav class="space-y-4">
                <a href="cashier.jsp" class="block p-3 font-black uppercase sidebar-link transition-all border-4 border-transparent">Cashier</a>
                <a href="MasterBarang.jsp" class="block p-3 font-black uppercase sidebar-link transition-all border-4 border-transparent">Master Items</a>
                <a href="MasterUser.jsp" class="block p-3 font-black uppercase active-menu transition-all">Master User</a>
                <a href="SalesReport.jsp" class="block p-3 font-black uppercase sidebar-link transition-all border-4 border-transparent">Sales Report</a>
            </nav>
        </div>

        <!-- User Info -->
        <div class="border-t-4 border-white pt-6">
            <p class="text-xs font-bold text-gray-400 uppercase">Staff</p>
            <h2 class="text-xl font-black uppercase"><%= session.getAttribute("nama_lengkap") %></h2>
            <a href="index.jsp" class="text-red-500 font-black text-sm hover:underline">LOG OUT</a>
        </div>
    </aside>

    <!-- MAIN CONTENT -->
    <main class="flex-1 flex flex-col">
        <!-- Header -->
        <header class="p-6">
            <h1 class="text-4xl font-[900] uppercase italic tracking-tighter text-black">Users</h1>
        </header>

        <!-- Area Tabel -->
        <div class="flex-1 p-6 overflow-hidden">
            <div class="bg-white neubrutalism-border neubrutalism-shadow-lg h-full flex flex-col relative">
                
                <!-- Header Card Hitam (Sama dengan MasterBarang) -->
                <h3 class="bg-black text-white inline-block px-20 py-10 font-black uppercase w-full self-start text-4xl">Master Users</h3>

                <div class="flex-1 overflow-y-auto p-6">
                    <table class="w-full text-left">
                        <thead class="sticky top-0 bg-white border-b-4 border-black">
                            <tr class="text-xs uppercase font-black">
                                <th class="py-4 text-center">Username</th>
                                <th class="py-4 text-center">Full Name</th>
                                <th class="py-4 text-center">Password</th>
                                <th class="py-4 text-center">Action</th>
                            </tr>
                        </thead>
                        <tbody class="font-bold">
                            <%
                                try {
                                    Statement stmt = conn.createStatement();
                                    ResultSet rs = stmt.executeQuery("SELECT * FROM master_user ORDER BY id DESC");
                                    while(rs.next()) {
                            %>
                            <tr class="border-b-2 border-gray-200 hover:bg-gray-50">
                                <td class="py-4 text-center"><%= rs.getString("username") %></td>
                                <td class="py-4 text-center uppercase"><%= rs.getString("nama_lengkap") %></td>
                                <td class="py-4 text-center">
                                    <span class="text-gray-400">********</span>
                                </td>
                                <td class="py-4 text-center">
                                    <button onclick="openEditModal('<%= rs.getInt("id") %>', '<%= rs.getString("username") %>', '<%= rs.getString("kata_sandi") %>', '<%= rs.getString("nama_lengkap") %>')" 
                                            class="text-blue-600 hover:underline font-black mx-1">EDIT</button>
                                    <span class="text-gray-300">|</span>
                                    <a href="MasterUser.jsp?action=delete&id=<%= rs.getInt("id") %>" 
                                       onclick="return confirm('Hapus user ini?')" 
                                       class="text-red-500 hover:underline font-black mx-1">DELETE</a>
                                </td>
                            </tr>
                            <% 
                                    }
                                } catch(Exception e) { out.println(e.getMessage()); }
                            %>
                        </tbody>
                    </table>
                </div>

                <!-- Tombol Add User (Warna Kuning Sesuai Gambar) -->
                <button onclick="openAddModal()" 
                    class="absolute bottom-6 right-6 bg-[#F3CE48] text-black neubrutalism-border px-8 py-3 font-black text-xl neubrutalism-shadow hover:translate-x-1 hover:translate-y-1 hover:shadow-none transition-all">
                    + ADD USER
                </button>
            </div>
        </div>
    </main>

    <!-- MODAL (Add/Edit) -->
    <div id="userModal" class="hidden fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center p-4 z-50">
        <div class="bg-black p-1 neubrutalism-shadow-lg w-full max-w-md">
            <div class="bg-white neubrutalism-border p-8">
                <h3 id="modalTitle" class="bg-black text-white p-4 -mt-12 -mx-12 mb-8 text-2xl font-black uppercase">Add New User</h3>
                
                <form id="userForm" action="MasterUser.jsp?action=add" method="POST" class="space-y-6">
                    <input type="hidden" name="id" id="formId">
                    
                    <div>
                        <label class="block text-sm font-black uppercase mb-1">Username</label>
                        <input placeholder="e.g. verly" type="text" name="username" id="formUsername" required class="w-full neubrutalism-border p-3 font-bold focus:outline-none">
                    </div>
                    <div>
                        <label class="block text-sm font-black uppercase mb-1">Password</label>
                        <input placeholder="min. 6 character" type="password" name="kata_sandi" id="formPassword" required class="w-full neubrutalism-border p-3 font-bold focus:outline-none">
                    </div>
                    <div>
                        <label class="block text-sm font-black uppercase mb-1">Full Name</label>
                        <input placeholder="e.g. verly" type="text" name="nama_lengkap" id="formNama" required class="w-full neubrutalism-border p-3 font-bold focus:outline-none uppercase">
                    </div>

                    <div class="flex gap-4 mt-6">
                        <button type="submit" class="flex-1 bg-[#3498DB] text-white neubrutalism-border p-4 font-black uppercase text-xl neubrutalism-shadow hover:shadow-none hover:translate-x-1 hover:translate-y-1 transition-all">
                            SAVE
                        </button>
                        <button type="button" onclick="closeModal()" class="bg-white neubrutalism-border p-4 px-6 font-black uppercase text-xl neubrutalism-shadow hover:shadow-none hover:translate-x-1 hover:translate-y-1 transition-all">
                            CANCEL
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script>
        const modal = document.getElementById('userModal');
        const form = document.getElementById('userForm');
        const title = document.getElementById('modalTitle');

        function openAddModal() {
            title.innerText = "Add New User";
            form.action = "MasterUser.jsp?action=add";
            form.reset();
            document.getElementById('formId').value = "";
            modal.classList.remove('hidden');
        }

        function openEditModal(id, username, password, nama) {
            title.innerText = "Edit User";
            form.action = "MasterUser.jsp?action=update";
            document.getElementById('formId').value = id;
            document.getElementById('formUsername').value = username;
            document.getElementById('formPassword').value = password;
            document.getElementById('formNama').value = nama;
            modal.classList.remove('hidden');
        }

        function closeModal() {
            modal.classList.add('hidden');
        }
    </script>
</body>
</html>
<%
    if(conn != null) conn.close();
%>