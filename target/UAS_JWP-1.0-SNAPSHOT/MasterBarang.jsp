<%@page import="jdbc.Koneksi"%>
<%@page import="java.sql.*"%>
<%@page import="java.text.DecimalFormat"%>
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

        // --- LOGIKA CRUD ---
        if ("add".equals(action) && "POST".equalsIgnoreCase(request.getMethod())) {
            String sql = "INSERT INTO master_barang (kode_barang, nama_barang, kategori, satuan, harga_jual, stok_tersedia) VALUES (?, ?, ?, ?, ?, ?)";
            ps = conn.prepareStatement(sql);
            ps.setString(1, request.getParameter("kode_barang"));
            ps.setString(2, request.getParameter("nama_barang"));
            ps.setString(3, request.getParameter("kategori"));
            ps.setString(4, request.getParameter("satuan"));
            ps.setDouble(5, Double.parseDouble(request.getParameter("harga_jual")));
            ps.setInt(6, Integer.parseInt(request.getParameter("stok_tersedia")));
            ps.executeUpdate();
            response.sendRedirect("MasterBarang.jsp?status=added");
            return;
        }

        if ("update".equals(action) && "POST".equalsIgnoreCase(request.getMethod())) {
            String sql = "UPDATE master_barang SET kode_barang=?, nama_barang=?, kategori=?, satuan=?, harga_jual=?, stok_tersedia=? WHERE id=?";
            ps = conn.prepareStatement(sql);
            ps.setString(1, request.getParameter("kode_barang"));
            ps.setString(2, request.getParameter("nama_barang"));
            ps.setString(3, request.getParameter("kategori"));
            ps.setString(4, request.getParameter("satuan"));
            ps.setDouble(5, Double.parseDouble(request.getParameter("harga_jual")));
            ps.setInt(6, Integer.parseInt(request.getParameter("stok_tersedia")));
            ps.setInt(7, Integer.parseInt(request.getParameter("id")));
            ps.executeUpdate();
            response.sendRedirect("MasterBarang.jsp?status=updated");
            return;
        }

        if ("delete".equals(action)) {
            ps = conn.prepareStatement("DELETE FROM master_barang WHERE id = ?");
            ps.setInt(1, Integer.parseInt(request.getParameter("id")));
            ps.executeUpdate();
            response.sendRedirect("MasterBarang.jsp?status=deleted");
            return;
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (ps != null) try { ps.close(); } catch (Exception e) {}
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
        body { font-family: 'Inter', sans-serif; background-color: #D1D5DB; }
        .neubrutalism-border { border: 4px solid black; }
        .neubrutalism-shadow { box-shadow: 6px 6px 0px 0px rgba(0,0,0,1); }
        .neubrutalism-shadow-lg { box-shadow: 10px 10px 0px 0px rgba(0,0,0,1); }
        .sidebar-link:hover { background-color: #F3CE48; color: black; border: 4px solid black; }
        .active-menu { background-color: #F3CE48; color: black; border: 4px solid black; }
    </style>
</head>
<body class="flex h-screen overflow-hidden">

    <!-- SIDEBAR (Identik dengan Cashier) -->
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
                <a href="MasterBarang.jsp" class="block p-3 font-black uppercase active-menu transition-all">Master Items</a>
                <a href="MasterUser.jsp" class="block p-3 font-black uppercase sidebar-link transition-all border-4 border-transparent">Master User</a>
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
            <h1 class="text-4xl font-[900] uppercase italic tracking-tighter text-black">Inventory</h1>
        </header>

        <!-- Area Tabel -->
        <div class="flex-1 p-6 overflow-hidden">
            <div class="bg-white neubrutalism-border neubrutalism-shadow-lg h-full flex flex-col relative">
                
                <h3 class="bg-black text-white inline-block px-20 py-10 font-black uppercase w-full self-start text-4xl">Master Items</h3>

                <div class="flex-1 overflow-y-auto p-6">
                    <table class="w-full text-left">
                        <thead class="sticky top-0 bg-white border-b-4 border-black">
                            <tr class="text-xs uppercase font-black">
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
                                try {
                                    Statement stmt = conn.createStatement();
                                    ResultSet rs = stmt.executeQuery("SELECT * FROM master_barang ORDER BY id DESC");
                                    while(rs.next()) {
                            %>
                            <tr class="border-b-2 border-gray-200 hover:bg-gray-50">
                                <td class="py-4"><%= rs.getString("kode_barang") %></td>
                                <td class="py-4 uppercase"><%= rs.getString("nama_barang") %></td>
                                <td class="py-4">
                                    <span class="bg-[#2ECC71] px-3 py-1 neubrutalism-border text-[10px] font-black text-white uppercase">
                                        <%= rs.getString("kategori") %>
                                    </span>
                                </td>
                                <td class="py-4 font-black">Rp <%= df.format(rs.getDouble("harga_jual")) %></td>
                                <td class="py-4"><%= rs.getInt("stok_tersedia") %> <%= rs.getString("satuan") %></td>
                                <td class="py-4 text-center">
                                    <button onclick="openEditModal('<%= rs.getInt("id") %>', '<%= rs.getString("kode_barang") %>', '<%= rs.getString("nama_barang") %>', '<%= rs.getString("kategori") %>', '<%= rs.getString("satuan") %>', '<%= rs.getDouble("harga_jual") %>', '<%= rs.getInt("stok_tersedia") %>')" 
                                            class="text-blue-600 hover:underline font-black mx-1">EDIT</button>
                                    <span class="text-gray-300">|</span>
                                    <a href="MasterBarang.jsp?action=delete&id=<%= rs.getInt("id") %>" 
                                       onclick="return confirm('Hapus item ini?')" 
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

                <!-- Tombol Add Item -->
                <button onclick="openAddModal()" 
                    class="absolute bottom-6 right-6 bg-[#2ECC71] text-white neubrutalism-border px-8 py-3 font-black text-xl neubrutalism-shadow hover:translate-x-1 hover:translate-y-1 hover:shadow-none transition-all">
                    + ADD ITEM
                </button>
            </div>
        </div>
    </main>

    <!-- MODAL (Add/Edit) -->
    <div id="itemModal" class="hidden fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center p-4 z-50">
        <div class="bg-black p-1 neubrutalism-shadow-lg w-full max-w-2xl">
            <div class="bg-white neubrutalism-border p-8">
                <h3 id="modalTitle" class="bg-black text-white p-4 -mt-12 -mx-12 mb-8 text-2xl font-black uppercase">Add New Item</h3>
                
                <form id="itemForm" action="MasterBarang.jsp?action=add" method="POST" class="grid grid-cols-2 gap-6">
                    <input type="hidden" name="id" id="formId">
                    
                    <div>
                        <label class="block text-xs font-black uppercase mb-1 italic">Product Code</label>
                        <input type="text" name="kode_barang" id="formKode" required class="w-full neubrutalism-border p-3 font-bold focus:outline-none">
                    </div>
                    <div>
                        <label class="block text-xs font-black uppercase mb-1 italic">Product Name</label>
                        <input type="text" name="nama_barang" id="formNama" required class="w-full neubrutalism-border p-3 font-bold focus:outline-none uppercase">
                    </div>
                    <div>
                        <label class="block text-xs font-black uppercase mb-1 italic">Category</label>
                        <select name="kategori" id="formKategori" class="w-full neubrutalism-border p-3 font-bold bg-white focus:outline-none">
                            <option value="Food">Food</option>
                            <option value="Drink">Drink</option>
                            <option value="Snack">Snack</option>
                            <option value="Electronics">Electronics</option>
                        </select>
                    </div>
                    <div>
                        <label class="block text-xs font-black uppercase mb-1 italic">Unit</label>
                        <input type="text" name="satuan" id="formSatuan" placeholder="Pcs/Kg/Box" required class="w-full neubrutalism-border p-3 font-bold focus:outline-none">
                    </div>
                    <div>
                        <label class="block text-xs font-black uppercase mb-1 italic">Selling Price (IDR)</label>
                        <input type="number" name="harga_jual" id="formHarga" required class="w-full neubrutalism-border p-3 font-bold focus:outline-none">
                    </div>
                    <div>
                        <label class="block text-xs font-black uppercase mb-1 italic">Available Stock</label>
                        <input type="number" name="stok_tersedia" id="formStok" required class="w-full neubrutalism-border p-3 font-bold focus:outline-none">
                    </div>

                    <div class="col-span-2 flex gap-4 mt-4">
                        <button type="submit" class="flex-1 bg-[#3498DB] text-white neubrutalism-border p-4 font-black uppercase text-xl neubrutalism-shadow hover:shadow-none hover:translate-x-1 hover:translate-y-1 transition-all">
                            SAVE PRODUCT
                        </button>
                        <button type="button" onclick="closeModal()" class="bg-white neubrutalism-border p-4 px-10 font-black uppercase text-xl neubrutalism-shadow hover:shadow-none hover:translate-x-1 hover:translate-y-1 transition-all">
                            CANCEL
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

        function openAddModal() {
            title.innerText = "Add New Item";
            form.action = "MasterBarang.jsp?action=add";
            form.reset();
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
    </script>
</body>
</html>