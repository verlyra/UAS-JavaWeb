<%-- 
    Document   : MasterBarang
    Created on : Jan 4, 2026, 6:03:23 PM
    Author     : Verly
--%>

<%@page import="jdbc.Koneksi"%>
<%@page import="java.sql.*"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="java.util.UUID"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    if (session.getAttribute("username") == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    String action = request.getParameter("action");
    String msg = "";
    String msgType = ""; // success, error, atau delete
    boolean operationSuccess = false;

    Connection conn = null;
    PreparedStatement ps = null;

    try {
        Koneksi k = new Koneksi();
        conn = k.bukaKoneksi();

        // 1. TAMBAH BARANG
        if ("add".equals(action) && "POST".equalsIgnoreCase(request.getMethod())) {
            // Tidak perlu insert ID karena AUTO_INCREMENT
            String sql = "INSERT INTO master_barang (kode_barang, nama_barang, kategori, satuan, harga_jual, stok_tersedia) VALUES (?, ?, ?, ?, ?, ?)";
            ps = conn.prepareStatement(sql);
            ps.setString(1, request.getParameter("kode_barang"));
            ps.setString(2, request.getParameter("nama_barang"));
            ps.setString(3, request.getParameter("kategori"));
            ps.setString(4, request.getParameter("satuan"));
            ps.setDouble(5, Double.parseDouble(request.getParameter("harga_jual")));
            ps.setInt(6, Integer.parseInt(request.getParameter("stok_tersedia")));
            
            int rows = ps.executeUpdate();
            if (rows > 0) {
                operationSuccess = true;
                msg = "Item berhasil ditambahkan!";
                msgType = "success";
            }
            
            ps.close();
            conn.close();
            response.sendRedirect("MasterBarang.jsp");
            return;
        }

        // 2. EDIT / UPDATE BARANG
        if ("update".equals(action) && "POST".equalsIgnoreCase(request.getMethod())) {
            String sql = "UPDATE master_barang SET kode_barang=?, nama_barang=?, kategori=?, satuan=?, harga_jual=?, stok_tersedia=? WHERE id=?";
            ps = conn.prepareStatement(sql);
            ps.setString(1, request.getParameter("kode_barang"));
            ps.setString(2, request.getParameter("nama_barang"));
            ps.setString(3, request.getParameter("kategori"));
            ps.setString(4, request.getParameter("satuan"));
            ps.setDouble(5, Double.parseDouble(request.getParameter("harga_jual")));
            ps.setInt(6, Integer.parseInt(request.getParameter("stok_tersedia")));
            ps.setInt(7, Integer.parseInt(request.getParameter("id"))); // Ubah ke setInt
            
            int rows = ps.executeUpdate();
            if (rows > 0) {
                operationSuccess = true;
                msg = "Item berhasil diupdate!";
                msgType = "success";
            }
            
            ps.close();
            conn.close();
            response.sendRedirect("MasterBarang.jsp");
            return;
        }

        // 3. HAPUS BARANG
        if ("delete".equals(action)) {
            String id = request.getParameter("id");
            String sql = "DELETE FROM master_barang WHERE id = ?";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, Integer.parseInt(id)); // Ubah ke setInt
            
            int rows = ps.executeUpdate();
            if (rows > 0) {
                operationSuccess = true;
                msg = "Item berhasil dihapus!";
            }
            
            ps.close();
            conn.close();
            response.sendRedirect("MasterBarang.jsp");
            return;
        }

        // Tutup koneksi jika tidak ada operasi
        if (conn != null) conn.close();

    } catch (Exception e) {
        msg = "Error: " + e.getMessage();
        msgType = "error";
        e.printStackTrace();
        // Pastikan koneksi ditutup meskipun ada error
        try {
            if (ps != null) ps.close();
            if (conn != null) conn.close();
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    DecimalFormat df = new DecimalFormat("###,###");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>VEND.IO - Master Items</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;700;900&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Inter', sans-serif; background-color: #E5E5E5; }
        .neo-shadow { box-shadow: 6px 6px 0px 0px rgba(0,0,0,1); }
        .neo-shadow-lg { box-shadow: 10px 10px 0px 0px rgba(0,0,0,1); }
        .neo-border { border: 4px solid black; }
        .active-menu { background-color: #F3CE48; color: black; border: 4px solid black; }
        
        /* Notification Animation */
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
                <a href="MasterBarang.jsp" class="block font-black uppercase tracking-widest p-3 active-menu">Master Items</a>
                <a href="#" class="block font-black uppercase tracking-widest p-3 hover:bg-[#F3CE48] hover:text-black">Master User</a>
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
        <h2 class="text-5xl font-[900] uppercase mb-10">Inventory</h2>

        <!-- Notifikasi Success/Error dengan Neobrutalism Style -->
        <div id="notification" class="hidden fixed top-6 right-6 z-50"></div>

        <div class="bg-white neo-border p-6 neo-shadow-lg relative min-h-[500px]">
            <h3 class="text-2xl font-black uppercase mb-6">Master Items</h3>

            <table class="w-full text-left">
                <thead>
                    <tr class="border-b-[4px] border-black text-sm uppercase font-black">
                        <th class="py-4">Code</th>
                        <th class="py-4">Name</th>
                        <th class="py-4">Category</th>
                        <th class="py-4">Price</th>
                        <th class="py-4">Stock</th>
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
                            rs = stmt.executeQuery("SELECT * FROM master_barang ORDER BY nama_barang ASC");
                            
                            boolean hasData = false;
                            while(rs.next()) {
                                hasData = true;
                    %>
                    <tr class="border-b-2 border-black/10">
                        <td class="py-4"><%= rs.getString("kode_barang") %></td>
                        <td class="py-4 uppercase"><%= rs.getString("nama_barang") %></td>
                        <td class="py-4">
                            <span class="bg-[#2ECC71] px-3 py-1 neo-border text-xs text-white">
                                <%= rs.getString("kategori") %>
                            </span>
                        </td>
                        <td class="py-4">Rp <%= df.format(rs.getDouble("harga_jual")) %></td>
                        <td class="py-4"><%= rs.getInt("stok_tersedia") %> <%= rs.getString("satuan") %></td>
                        <td class="py-4 text-center">
                            <button onclick="openEditModal(
                                '<%= rs.getInt("id") %>',
                                '<%= rs.getString("kode_barang") %>',
                                '<%= rs.getString("nama_barang").replace("'", "\\'") %>',
                                '<%= rs.getString("kategori") %>',
                                '<%= rs.getString("satuan") %>',
                                '<%= rs.getDouble("harga_jual") %>',
                                '<%= rs.getInt("stok_tersedia") %>'
                            )"
                            class="text-blue-500 hover:underline mx-1 font-black">
                                EDIT
                            </button>

                            <span class="text-gray-300">|</span>
                            <button onclick="confirmDelete(<%= rs.getInt("id") %>, '<%= rs.getString("nama_barang").replace("'", "\\'") %>')" 
                               class="text-red-500 hover:underline mx-1 font-black">DELETE</button>
                        </td>
                    </tr>
                    <% 
                            }
                            
                            if (!hasData) {
                    %>
                    <tr>
                        <td colspan="6" class="py-8 text-center text-gray-400 italic">
                            Belum ada data barang. Klik tombol "+ ADD ITEM" untuk menambahkan.
                        </td>
                    </tr>
                    <%
                            }
                            
                        } catch(Exception e) {
                            out.println("<tr><td colspan='6' class='text-red-500 p-4'>");
                            out.println("Error loading data: " + e.getMessage());
                            out.println("</td></tr>");
                            e.printStackTrace();
                        } finally {
                            // Tutup semua resource
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
                class="absolute bottom-6 right-6 bg-[#2ECC71] text-white neo-border px-6 py-3 font-black neo-shadow hover:translate-x-1 hover:translate-y-1 hover:shadow-none transition-all">
                + ADD ITEM
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
                            <path d="M3 6h18M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path>
                        </svg>
                    </div>
                    <h3 class="text-2xl font-black uppercase mb-2">Delete Item?</h3>
                    <p class="font-bold text-gray-600 mb-6">Are you sure you want to delete<br><span id="deleteItemName" class="text-black font-black uppercase"></span>?</p>
                    
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
    <div id="itemModal" class="hidden fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center p-4 z-50">
        <div class="bg-black p-1 neo-shadow-lg">
            <div class="bg-white neo-border p-8 max-w-2xl w-full">
                <h3 id="modalTitle" class="bg-black text-white p-4 -mt-12 -mx-12 mb-8 text-2xl font-black uppercase">Add New Items</h3>
                
                <form id="itemForm" action="MasterBarang.jsp?action=add" method="POST" class="grid grid-cols-2 gap-6">
                    <!-- ID Tersembunyi untuk Update (tipe number) -->
                    <input type="hidden" name="id" id="formId">
                    
                    <div>
                        <label class="block text-sm font-black uppercase mb-1">Product Code</label>
                        <input type="text" name="kode_barang" id="formKode" required class="w-full neo-border p-3 font-bold outline-none">
                    </div>
                    <div>
                        <label class="block text-sm font-black uppercase mb-1">Product Name</label>
                        <input type="text" name="nama_barang" id="formNama" required class="w-full neo-border p-3 font-bold outline-none">
                    </div>
                    <div>
                        <label class="block text-sm font-black uppercase mb-1">Category</label>
                        <select name="kategori" id="formKategori" class="w-full neo-border p-3 font-bold bg-white">
                            <option value="Food">Food</option>
                            <option value="Drink">Drink</option>
                            <option value="Electronics">Electronics</option>
                            <option value="Stationary">Stationary</option>
                            <option value="Household">Household</option>
                            <option value="Others">Others</option>
                        </select>
                    </div>
                    <div>
                        <label class="block text-sm font-black uppercase mb-1">Unit</label>
                        <select name="satuan" id="formSatuan" class="w-full neo-border p-3 font-bold bg-white">
                            <option value="Pcs">Pcs</option>
                            <option value="Kg">Kg</option>
                            <option value="Liter">Liter</option>
                            <option value="Box">Box</option>
                            <option value="Pack">Pack</option>
                            <option value="Bottle">Bottle</option>
                        </select>
                    </div>
                    <div>
                        <label class="block text-sm font-black uppercase mb-1">Selling Price (IDR)</label>
                        <input type="number" name="harga_jual" id="formHarga" required min="0" step="0.01" class="w-full neo-border p-3 font-bold outline-none">
                    </div>
                    <div>
                        <label class="block text-sm font-black uppercase mb-1">Available Stock</label>
                        <input type="number" name="stok_tersedia" id="formStok" required min="0" class="w-full neo-border p-3 font-bold outline-none">
                    </div>

                    <div class="col-span-2 flex gap-4 mt-4">
                        <button type="submit" id="submitBtn" class="flex-1 bg-[#3498DB] text-white neo-border p-4 font-black uppercase neo-shadow hover:shadow-none hover:translate-x-1 hover:translate-y-1 transition-all">
                            Save Product
                        </button>
                        <button type="button" onclick="closeModal()" class="bg-white neo-border p-4 px-8 font-black uppercase neo-shadow hover:shadow-none hover:translate-x-1 hover:translate-y-1 transition-all">
                            Cancel
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script>
        const modal = document.getElementById('itemModal');
        const form = document.getElementById('itemForm');
        const title = document.getElementById('modalTitle');
        const deleteModal = document.getElementById('deleteModal');
        const notification = document.getElementById('notification');
        let deleteItemId = null;

        // Cek apakah ada notifikasi delete success
        window.onload = function() {
            const urlParams = new URLSearchParams(window.location.search);
            if (urlParams.get('deleted') === 'true') {
                showNotification('Item berhasil dihapus dari inventory!', 'delete');
                // Hapus parameter dari URL tanpa reload
                window.history.replaceState({}, document.title, 'MasterBarang.jsp');
            }
        };

        function showNotification(message, type) {
            let bgColor, borderColor, icon;
            
            if (type === 'delete') {
                bgColor = '#EF4444';
                borderColor = 'black';
                icon = `<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="3">
                    <polyline points="9 11 12 14 22 4"></polyline><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"></path>
                </svg>`;
            } else if (type === 'success') {
                bgColor = '#2ECC71';
                borderColor = 'black';
                icon = `<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="3">
                    <polyline points="20 6 9 17 4 12"></polyline>
                </svg>`;
            } else {
                bgColor = '#E74C3C';
                borderColor = 'black';
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

        function confirmDelete(id, name) {
            deleteItemId = id;
            document.getElementById('deleteItemName').innerText = name;
            deleteModal.classList.remove('hidden');
        }

        function closeDeleteModal() {
            deleteModal.classList.add('hidden');
            deleteItemId = null;
        }

        function executeDelete() {
            if (deleteItemId) {
                window.location.href = 'MasterBarang.jsp?action=delete&id=' + deleteItemId;
            }
        }

        function openAddModal() {
            title.innerText = "Add New Items";
            form.action = "MasterBarang.jsp?action=add";
            form.reset();
            document.getElementById('formId').value = "";
            modal.classList.remove('hidden');
        }

        function openEditModal(id, kode, nama, kategori, satuan, harga, stok) {
            title.innerText = "Edit Item";
            form.action = "MasterBarang.jsp?action=update";
            
            document.getElementById('formId').value = id;
            document.getElementById('formKode').value = kode;
            document.getElementById('formNama').value = nama;
            document.getElementById('formKategori').value = kategori;
            document.getElementById('formSatuan').value = satuan;
            document.getElementById('formHarga').value = harga;
            document.getElementById('formStok').value = stok;
            
            modal.classList.remove('hidden');
        }

        function closeModal() {
            modal.classList.add('hidden');
        }

        // Close modal when clicking outside
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