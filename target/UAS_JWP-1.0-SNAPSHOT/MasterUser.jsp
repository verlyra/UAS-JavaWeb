<%-- 
    Document   : MasterUser
    Created on : Jan 4, 2026
    Author     : Verly
--%>

<%@page import="jdbc.Koneksi"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.UUID"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    if (session.getAttribute("username") == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    String action = request.getParameter("action");
    String msg = "";
    String msgType = "";

    Connection conn = null;
    PreparedStatement ps = null;

    try {
        Koneksi k = new Koneksi();
        conn = k.bukaKoneksi();

        // 1. TAMBAH USER
        if ("add".equals(action) && "POST".equalsIgnoreCase(request.getMethod())) {
            try {
                // Tidak perlu insert ID karena AUTO_INCREMENT
                String sql = "INSERT INTO master_user (username, kata_sandi, nama_lengkap) VALUES (?, ?, ?)";
                ps = conn.prepareStatement(sql);
                ps.setString(1, request.getParameter("username"));
                ps.setString(2, request.getParameter("kata_sandi"));
                ps.setString(3, request.getParameter("nama_lengkap"));
                
                int rows = ps.executeUpdate();
                
                ps.close();
                conn.close();
                
                if (rows > 0) {
                    response.sendRedirect("MasterUser.jsp?added=true");
                } else {
                    response.sendRedirect("MasterUser.jsp?error=add");
                }
                return;
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("MasterUser.jsp?error=" + e.getMessage());
                return;
            }
        }

        // 2. EDIT / UPDATE USER
        if ("update".equals(action) && "POST".equalsIgnoreCase(request.getMethod())) {
            try {
                String sql = "UPDATE master_user SET username=?, kata_sandi=?, nama_lengkap=? WHERE id=?";
                ps = conn.prepareStatement(sql);
                ps.setString(1, request.getParameter("username"));
                ps.setString(2, request.getParameter("kata_sandi"));
                ps.setString(3, request.getParameter("nama_lengkap"));
                ps.setInt(4, Integer.parseInt(request.getParameter("id"))); // Ubah ke INT
                
                int rows = ps.executeUpdate();
                
                ps.close();
                conn.close();
                
                if (rows > 0) {
                    response.sendRedirect("MasterUser.jsp?updated=true");
                } else {
                    response.sendRedirect("MasterUser.jsp?error=update");
                }
                return;
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("MasterUser.jsp?error=" + e.getMessage());
                return;
            }
        }

        // 3. HAPUS USER
        if ("delete".equals(action)) {
            try {
                String id = request.getParameter("id");
                String sql = "DELETE FROM master_user WHERE id = ?";
                ps = conn.prepareStatement(sql);
                ps.setInt(1, Integer.parseInt(id)); // Ubah ke INT
                
                int rows = ps.executeUpdate();
                
                ps.close();
                conn.close();
                
                if (rows > 0) {
                    response.sendRedirect("MasterUser.jsp?deleted=true");
                } else {
                    response.sendRedirect("MasterUser.jsp?error=delete");
                }
                return;
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("MasterUser.jsp?error=" + e.getMessage());
                return;
            }
        }

        if (conn != null) conn.close();

    } catch (Exception e) {
        msg = "Error: " + e.getMessage();
        msgType = "error";
        e.printStackTrace();
        try {
            if (ps != null) ps.close();
            if (conn != null) conn.close();
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>VEND.IO - Master Users</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;700;900&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Inter', sans-serif; background-color: #E5E5E5; }
        .neo-shadow { box-shadow: 6px 6px 0px 0px rgba(0,0,0,1); }
        .neo-shadow-lg { box-shadow: 10px 10px 0px 0px rgba(0,0,0,1); }
        .neo-border { border: 4px solid black; }
        .active-menu { background-color: #F3CE48; color: black; border: 4px solid black; }
        
        @keyframes slideIn {
            from { transform: translateY(-100%); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
        }
        @keyframes slideOut {
            from { transform: translateY(0); opacity: 1; }
            to { transform: translateY(-100%); opacity: 0; }
        }
        .notification-enter { animation: slideIn 0.3s ease-out; }
        .notification-exit { animation: slideOut 0.3s ease-in; }
    </style>
</head>
<body class="flex min-h-screen">

    <!-- SIDEBAR -->
    <div class="w-64 bg-black text-white flex flex-col justify-between p-6 shrink-0">
        <div>
            <div class="flex flex-col items-center mb-10">
                <div class="bg-[#F3CE48] border-[3px] border-white p-2 mb-2">
                    <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="black" stroke-width="3">
                        <circle cx="9" cy="21" r="1"></circle><circle cx="20" cy="21" r="1"></circle>
                        <path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"></path>
                    </svg>
                </div>
                <h1 class="text-3xl font-[900] italic tracking-tighter">VEND.IO</h1>
                <div class="h-1 w-full bg-white mt-1"></div>
            </div>
            <nav class="space-y-2">
                <a href="#" class="block font-black uppercase tracking-widest p-3 hover:bg-[#F3CE48] hover:text-black">Cashier</a>
                <a href="MasterBarang.jsp" class="block font-black uppercase tracking-widest p-3 hover:bg-[#F3CE48] hover:text-black">Master Items</a>
                <a href="MasterUser.jsp" class="block font-black uppercase tracking-widest p-3 active-menu">Master User</a>
                <a href="#" class="block font-black uppercase tracking-widest p-3 hover:bg-[#F3CE48] hover:text-black">Sales Report</a>
            </nav>
        </div>
        <div class="border-t-2 border-white pt-6">
            <p class="text-xs font-bold text-gray-400 uppercase">Staff</p>
            <p class="font-black text-xl uppercase"><%= session.getAttribute("nama_lengkap") %></p>
            <a href="logout.jsp" class="text-red-500 font-black text-sm hover:underline">LOG OUT</a>
        </div>
    </div>

    <!-- MAIN CONTENT -->
    <main class="flex-1 p-10">
        <h2 class="text-5xl font-[900] uppercase mb-10">Users</h2>

        <!-- Notifikasi -->
        <div id="notification" class="hidden fixed top-6 right-6 z-50"></div>

        <div class="bg-white neo-border p-6 neo-shadow-lg relative min-h-[500px]">
            <h3 class="text-2xl font-black uppercase mb-6">Master Users</h3>

            <table class="w-full text-left">
                <thead>
                    <tr class="border-b-[4px] border-black text-sm uppercase font-black">
                        <th class="py-4">Username</th>
                        <th class="py-4">Full Name</th>
                        <th class="py-4">Password</th>
                        <th class="py-4 text-center">Action</th>
                    </tr>
                </thead>
                <tbody class="font-bold">
                    <%
                        Connection connRead = null;
                        Statement stmt = null;
                        ResultSet rs = null;
                        try {
                            Koneksi k = new Koneksi();
                            connRead = k.bukaKoneksi();
                            stmt = connRead.createStatement();
                            rs = stmt.executeQuery("SELECT * FROM master_user ORDER BY nama_lengkap ASC");
                            
                            boolean hasData = false;
                            while(rs.next()) {
                                hasData = true;
                    %>
                    <tr class="border-b-2 border-black/10">
                        <td class="py-4"><%= rs.getString("username") %></td>
                        <td class="py-4 uppercase"><%= rs.getString("nama_lengkap") %></td>
                        <td class="py-4">
                            <span class="text-gray-400">
                                <%= "********" %>
                            </span>
                        </td>
                        <td class="py-4 text-center">
                            <button onclick="openEditModal(
                                '<%= rs.getInt("id") %>',
                                '<%= rs.getString("username") %>',
                                '<%= rs.getString("kata_sandi") %>',
                                '<%= rs.getString("nama_lengkap").replace("'", "\\'") %>'
                            )"
                            class="text-blue-500 hover:underline mx-1 font-black">
                                EDIT
                            </button>

                            <span class="text-gray-300">|</span>
                            <button onclick="confirmDelete('<%= rs.getInt("id") %>', '<%= rs.getString("username") %>')" 
                               class="text-red-500 hover:underline mx-1 font-black">DELETE</button>
                        </td>
                    </tr>
                    <% 
                            }
                            
                            if (!hasData) {
                    %>
                    <tr>
                        <td colspan="4" class="py-8 text-center text-gray-400 italic">
                            Belum ada data user. Klik tombol "+ ADD USER" untuk menambahkan.
                        </td>
                    </tr>
                    <%
                            }
                            
                        } catch(Exception e) {
                            out.println("<tr><td colspan='4' class='text-red-500 p-4'>");
                            out.println("Error loading data: " + e.getMessage());
                            out.println("</td></tr>");
                            e.printStackTrace();
                        } finally {
                            try {
                                if (rs != null) rs.close();
                                if (stmt != null) stmt.close();
                                if (connRead != null) connRead.close();
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        }
                    %>
                </tbody>
            </table>

            <button onclick="openAddModal()" 
                class="absolute bottom-6 right-6 bg-[#F3CE48] text-black neo-border px-6 py-3 font-black neo-shadow hover:translate-x-1 hover:translate-y-1 hover:shadow-none transition-all">
                + ADD USER
            </button>
        </div>
    </main>

    <!-- MODAL DELETE CONFIRMATION -->
    <div id="deleteModal" class="hidden fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center p-4 z-50">
        <div class="bg-black p-1 neo-shadow-lg">
            <div class="bg-white neo-border p-8 max-w-md w-full">
                <div class="text-center">
                    <div class="bg-red-500 w-20 h-20 rounded-full flex items-center justify-center mx-auto mb-4 neo-border">
                        <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="3">
                            <path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path>
                            <circle cx="8.5" cy="7" r="4"></circle>
                            <line x1="18" y1="8" x2="23" y2="13"></line>
                            <line x1="23" y1="8" x2="18" y2="13"></line>
                        </svg>
                    </div>
                    <h3 class="text-2xl font-black uppercase mb-2">Delete User?</h3>
                    <p class="font-bold text-gray-600 mb-6">Are you sure you want to delete user<br><span id="deleteUserName" class="text-black font-black uppercase"></span>?</p>
                    
                    <div class="flex gap-4">
                        <button onclick="closeDeleteModal()" class="flex-1 bg-white neo-border p-4 font-black uppercase neo-shadow hover:shadow-none hover:translate-x-1 hover:translate-y-1 transition-all">
                            Cancel
                        </button>
                        <button onclick="executeDelete()" class="flex-1 bg-red-500 text-white neo-border p-4 font-black uppercase neo-shadow hover:shadow-none hover:translate-x-1 hover:translate-y-1 transition-all">
                            Delete
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- MODAL (Add/Edit) -->
    <div id="userModal" class="hidden fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center p-4 z-50">
        <div class="bg-black p-1 neo-shadow-lg">
            <div class="bg-white neo-border p-8 max-w-lg w-full relative">
                <!-- Close Button -->
                <button onclick="closeModal()" class="absolute top-4 right-4 text-3xl font-black hover:text-red-500 leading-none">
                    ×
                </button>
                
                <h3 id="modalTitle" class="bg-black text-white p-4 -mt-12 -mx-12 mb-8 text-2xl font-black uppercase">Tambah Admin Baru</h3>
                
                <form id="userForm" action="MasterUser.jsp?action=add" method="POST" class="space-y-6">
                    <input type="hidden" name="id" id="formId">
                    
                    <div>
                        <label class="block text-sm font-black uppercase mb-2">Username</label>
                        <input type="text" name="username" id="formUsername" required 
                            placeholder="e.g. johndoe"
                            class="w-full neo-border p-3 font-bold outline-none focus:ring-4 focus:ring-[#F3CE48]">
                    </div>
                    
                    <div>
                        <label class="block text-sm font-black uppercase mb-2">Password</label>
                        <input type="password" name="kata_sandi" id="formPassword" required 
                            placeholder="Min 6 characters"
                            minlength="6"
                            class="w-full neo-border p-3 font-bold outline-none focus:ring-4 focus:ring-[#F3CE48]">
                    </div>
                    
                    <div>
                        <label class="block text-sm font-black uppercase mb-2">Nama Lengkap</label>
                        <input type="text" name="nama_lengkap" id="formNamaLengkap" required 
                            placeholder="e.g. John Doe"
                            class="w-full neo-border p-3 font-bold outline-none focus:ring-4 focus:ring-[#F3CE48]">
                    </div>

                    <div class="flex gap-4 pt-4">
                        <button type="submit" id="submitBtn" class="flex-1 bg-[#2ECC71] text-white neo-border p-4 font-black uppercase neo-shadow hover:shadow-none hover:translate-x-1 hover:translate-y-1 transition-all">
                            Simpan User
                        </button>
                        <button type="button" onclick="closeModal()" class="bg-white neo-border p-4 px-8 font-black uppercase neo-shadow hover:shadow-none hover:translate-x-1 hover:translate-y-1 transition-all">
                            Batal
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
        const deleteModal = document.getElementById('deleteModal');
        const notification = document.getElementById('notification');
        let deleteUserId = null;

        window.onload = function() {
            const urlParams = new URLSearchParams(window.location.search);
            // Hanya tampilkan notifikasi untuk error
            if (urlParams.get('error')) {
                showNotification('Error: ' + urlParams.get('error'), 'error');
            }
            // Clean URL untuk semua parameter
            window.history.replaceState({}, document.title, 'MasterUser.jsp');
        };

        function showNotification(message, type) {
            let bgColor, icon;
            
            if (type === 'delete') {
                // Delete menggunakan warna hijau dengan icon checkmark (sukses)
                bgColor = '#2ECC71';
                icon = `<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="3">
                    <polyline points="20 6 9 17 4 12"></polyline>
                </svg>`;
            } else if (type === 'success') {
                bgColor = '#2ECC71';
                icon = `<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="3">
                    <polyline points="20 6 9 17 4 12"></polyline>
                </svg>`;
            } else {
                bgColor = '#E74C3C';
                icon = `<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="3">
                    <circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line>
                </svg>`;
            }

            notification.innerHTML = `
                <div style="background: ${bgColor};" class="neo-border p-6 neo-shadow-lg min-w-[300px] max-w-md">
                    <div class="flex items-center gap-4">
                        <div class="flex-shrink-0">${icon}</div>
                        <p class="text-white font-black uppercase flex-1">${message}</p>
                        <button onclick="hideNotification()" class="text-white hover:text-gray-200 font-black text-2xl leading-none">×</button>
                    </div>
                </div>
            `;
            
            notification.classList.remove('hidden');
            notification.classList.add('notification-enter');
            
            setTimeout(() => {
                hideNotification();
            }, 4000);
        }

        function hideNotification() {
            notification.classList.add('notification-exit');
            setTimeout(() => {
                notification.classList.add('hidden');
                notification.classList.remove('notification-enter', 'notification-exit');
            }, 300);
        }

        function confirmDelete(id, username) {
            deleteUserId = id;
            document.getElementById('deleteUserName').innerText = username;
            deleteModal.classList.remove('hidden');
        }

        function closeDeleteModal() {
            deleteModal.classList.add('hidden');
            deleteUserId = null;
        }

        function executeDelete() {
            if (deleteUserId) {
                window.location.href = 'MasterUser.jsp?action=delete&id=' + deleteUserId;
            }
        }

        function openAddModal() {
            title.innerText = "Tambah Admin Baru";
            form.action = "MasterUser.jsp?action=add";
            form.reset();
            document.getElementById('formId').value = "";
            document.getElementById('formPassword').setAttribute('required', 'required');
            modal.classList.remove('hidden');
        }

        function openEditModal(id, username, password, namaLengkap) {
            title.innerText = "Edit User";
            form.action = "MasterUser.jsp?action=update";
            
            document.getElementById('formId').value = id;
            document.getElementById('formUsername').value = username;
            document.getElementById('formPassword').value = password;
            document.getElementById('formNamaLengkap').value = namaLengkap;
            
            modal.classList.remove('hidden');
        }

        function closeModal() {
            modal.classList.add('hidden');
        }

        modal.addEventListener('click', function(e) {
            if (e.target === modal) {
                closeModal();
            }
        });

        deleteModal.addEventListener('click', function(e) {
            if (e.target === deleteModal) {
                closeDeleteModal();
            }
        });
    </script>

</body>
</html>