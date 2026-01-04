<%@page import="java.util.*"%>
<%@page import="java.sql.*"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="jdbc.Koneksi"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    // 1. PROTEKSI SESSION
    if (session.getAttribute("username") == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    // 2. INISIALISASI TANGGAL HARI INI
    String currentDate = new SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());

    // 3. INISIALISASI KERANJANG
    Map<Integer, Map<String, Object>> cart = (Map<Integer, Map<String, Object>>) session.getAttribute("cart");
    if (cart == null) {
        cart = new LinkedHashMap<>();
        session.setAttribute("cart", cart);
    }

    String action = request.getParameter("action");
    String search = (request.getParameter("search") != null) ? request.getParameter("search") : "";
    Connection conn = new Koneksi().bukaKoneksi();

    // 4. LOGIKA ACTION (TAMBAH, KURANG, HAPUS, CHECKOUT)
    if (action != null) {
        if (action.equals("add") || action.equals("quick_add")) {
            String idStr = request.getParameter("id");
            String codeStr = request.getParameter("kode_barang");
            
            String query = (idStr != null) ? "SELECT * FROM master_barang WHERE id = ?" : "SELECT * FROM master_barang WHERE kode_barang = ?";
            PreparedStatement ps = conn.prepareStatement(query);
            if (idStr != null) ps.setInt(1, Integer.parseInt(idStr)); else ps.setString(1, codeStr);
            
            ResultSet rsItem = ps.executeQuery();
            if (rsItem.next()) {
                int idBarang = rsItem.getInt("id");
                if (cart.containsKey(idBarang)) {
                    cart.get(idBarang).put("qty", (int) cart.get(idBarang).get("qty") + 1);
                } else {
                    Map<String, Object> item = new HashMap<>();
                    item.put("id", idBarang);
                    item.put("nama", rsItem.getString("nama_barang"));
                    item.put("harga", rsItem.getDouble("harga_jual"));
                    item.put("qty", 1);
                    cart.put(idBarang, item);
                }
            }
        } else if (action.equals("reduce")) {
            int id = Integer.parseInt(request.getParameter("id"));
            if (cart.containsKey(id)) {
                int newQty = (int) cart.get(id).get("qty") - 1;
                if (newQty <= 0) cart.remove(id);
                else cart.get(id).put("qty", newQty);
            }
        } else if (action.equals("remove")) {
            cart.remove(Integer.parseInt(request.getParameter("id")));
        } else if (action.equals("checkout") && !cart.isEmpty()) {
            try {
                conn.setAutoCommit(false);
                String sqlTrx = "INSERT INTO trx_penjualan (nomor_invoice, tanggal_transaksi, id_user, tipe_pelanggan, metode_pembayaran, total_bayar, catatan_tambahan) VALUES (?, ?, ?, ?, ?, ?, ?)";
                PreparedStatement psTrx = conn.prepareStatement(sqlTrx, Statement.RETURN_GENERATED_KEYS);
                psTrx.setString(1, "INV-" + System.currentTimeMillis());
                psTrx.setString(2, request.getParameter("tanggal")); // Mengambil tanggal dari input
                psTrx.setInt(3, Integer.parseInt(session.getAttribute("user_id").toString()));
                psTrx.setString(4, request.getParameter("tipe_pelanggan"));
                psTrx.setString(5, request.getParameter("metode_pembayaran"));
                psTrx.setDouble(6, Double.parseDouble(request.getParameter("total_bayar")));
                psTrx.setString(7, request.getParameter("catatan"));
                psTrx.executeUpdate();
                
                ResultSet generatedKeys = psTrx.getGeneratedKeys();
                if (generatedKeys.next()) {
                    int idTrx = generatedKeys.getInt(1);
                    String sqlDetail = "INSERT INTO trx_detail_penjualan (id_transaksi, id_barang, harga_satuan, jumlah_beli, subtotal_harga) VALUES (?, ?, ?, ?, ?)";
                    PreparedStatement psDet = conn.prepareStatement(sqlDetail);
                    for (Map<String, Object> item : cart.values()) {
                        psDet.setInt(1, idTrx);
                        psDet.setInt(2, (int) item.get("id"));
                        psDet.setDouble(3, (double) item.get("harga"));
                        psDet.setInt(4, (int) item.get("qty"));
                        psDet.setDouble(5, (double) item.get("harga") * (int) item.get("qty"));
                        psDet.addBatch();
                    }
                    psDet.executeBatch();
                }
                conn.commit();
                cart.clear();
                response.sendRedirect("cashier.jsp?status=success");
                return;
            } catch (Exception e) {
                conn.rollback();
                out.print("Error: " + e.getMessage());
            }
        }
    }

    // 5. QUERY PENCARIAN (MENGGUNAKAN PREPARED STATEMENT AGAR AMAN)
    String sqlBarang = "SELECT * FROM master_barang WHERE nama_barang LIKE ? OR kode_barang = ?";
    PreparedStatement psSearch = conn.prepareStatement(sqlBarang);
    psSearch.setString(1, "%" + search + "%");
    psSearch.setString(2, search);
    ResultSet rsBarang = psSearch.executeQuery();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>VEND.IO - Cashier</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;700;900&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Inter', sans-serif; background-color: #D1D5DB; }
        .neubrutalism-border { border: 4px solid black; }
        .neubrutalism-shadow { box-shadow: 6px 6px 0px 0px rgba(0,0,0,1); }
        .neubrutalism-shadow-lg { box-shadow: 10px 10px 0px 0px rgba(0,0,0,1); }
    </style>
</head>
<body class="flex h-screen overflow-hidden">

    <!-- SIDEBAR -->
    <aside class="w-64 bg-black text-white flex flex-col justify-between p-6">
        <div>
            <div class="flex items-center gap-3 mb-10">
                <div class="bg-[#F3CE48] p-2 neubrutalism-border">
                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="black" stroke-width="3"><circle cx="9" cy="21" r="1"></circle><circle cx="20" cy="21" r="1"></circle><path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"></path></svg>
                </div>
                <h1 class="text-2xl font-[900] italic uppercase">Vend.io</h1>
            </div>
            <nav class="space-y-4 font-black">
                <a href="cashier.jsp" class="block p-3 bg-[#F3CE48] text-black neubrutalism-border">CASHIER</a>
                <a href="MasterBarang.jsp" class="block p-3 hover:text-[#F3CE48]">MASTER ITEMS</a>
                <a href="MasterUser.jsp" class="block p-3 hover:text-[#F3CE48]">MASTER USER</a>
                <a href="SalesReport.jsp" class="block p-3 hover:text-[#F3CE48]">SALES REPORT</a>
            </nav>
        </div>
        <div class="border-t-4 border-white pt-6">
            <p class="text-xs text-gray-400 font-bold uppercase">Staff</p>
            <h2 class="text-xl font-black uppercase text-white"><%= session.getAttribute("nama_lengkap") %></h2>
            <a href="index.jsp" class="text-red-500 font-black text-sm uppercase">Log Out</a>
        </div>
    </aside>

    <main class="flex-1 flex flex-col">
        <header class="p-6 pb-0 flex justify-between items-center">
            <h1 class="text-4xl font-[900] uppercase italic">Cashier</h1>
            <% if("success".equals(request.getParameter("status"))) { %>
                <div class="bg-green-400 border-2 border-black px-4 py-1 font-black text-sm neubrutalism-shadow">TRANSACTION SUCCESS!</div>
            <% } %>
        </header>

        <div class="flex-1 flex p-6 gap-6 overflow-hidden">
            <!-- PRODUK & KERANJANG -->
            <div class="flex-[2] flex flex-col gap-6 overflow-y-auto pr-2">
                
                <!-- FILTER SEARCH -->
                <div class="bg-white neubrutalism-border p-4 flex gap-4">
                    <form action="cashier.jsp" method="GET" class="flex-1 flex gap-2">
                        <div class="flex-1">
                            <label class="block text-xs font-black uppercase mb-1">Find Product</label>
                            <input type="text" name="search" value="<%= search %>" placeholder="Type name..." class="w-full border-2 border-black p-2 font-bold focus:outline-none">
                        </div>
                        <button type="submit" class="mt-5 bg-black text-white px-6 font-black hover:bg-gray-800">SEARCH</button>
                    </form>
                </div>

                <!-- LIST PRODUK -->
                <div class="grid grid-cols-2 gap-4">
                    <% while(rsBarang.next()){ %>
                    <div class="bg-white neubrutalism-border p-4 neubrutalism-shadow relative group">
                        <h3 class="font-black text-lg uppercase"><%= rsBarang.getString("nama_barang") %></h3>
                        <p class="text-gray-400 font-bold text-xs"><%= rsBarang.getString("kode_barang") %></p>
                        <p class="text-[#2ECC71] font-black text-xl my-2">Rp <%= String.format("%,.0f", rsBarang.getDouble("harga_jual")) %></p>
                        <div class="bg-black text-white text-[10px] px-2 py-1 font-bold inline-block">STOCK: <%= rsBarang.getInt("stok_tersedia") %></div>
                        <!-- Tombol Add dengan menyertakan parameter search agar filter tidak hilang -->
                        <a href="cashier.jsp?action=add&id=<%= rsBarang.getInt("id") %>&search=<%= search %>" 
                           class="absolute bottom-4 right-4 bg-[#F3CE48] border-2 border-black p-2 font-black text-xs hover:bg-black hover:text-white transition-all">
                           + ADD
                        </a>
                    </div>
                    <% } %>
                </div>

                <!-- KERANJANG -->
                <div class="bg-white neubrutalism-border flex-1 flex flex-col min-h-[300px]">
                    <div class="bg-black text-white p-3 font-black uppercase">Shopping Cart</div>
                    <table class="w-full">
                        <thead class="border-b-4 border-black text-xs font-black uppercase">
                            <tr>
                                <th class="p-3 text-left">Product</th>
                                <th class="p-3 text-center">Qty</th>
                                <th class="p-3 text-left">Subtotal</th>
                                <th class="p-3">Action</th>
                            </tr>
                        </thead>
                        <tbody class="font-bold">
                            <% 
                                double total = 0;
                                for(Map<String, Object> item : cart.values()){ 
                                    double subtotal = (double)item.get("harga") * (int)item.get("qty");
                                    total += subtotal;
                            %>
                            <tr class="border-b-2 border-gray-100">
                                <td class="p-3"><%= item.get("nama") %></td>
                                <td class="p-3 flex justify-center items-center gap-2">
                                    <a href="cashier.jsp?action=reduce&id=<%= item.get("id") %>&search=<%= search %>" class="bg-red-400 border-2 border-black w-6 h-6 text-center leading-5 hover:bg-red-500">-</a>
                                    <span class="w-4 text-center"><%= item.get("qty") %></span>
                                    <a href="cashier.jsp?action=add&id=<%= item.get("id") %>&search=<%= search %>" class="bg-green-400 border-2 border-black w-6 h-6 text-center leading-5 hover:bg-green-500">+</a>
                                </td>
                                <td class="p-3">Rp <%= String.format("%,.0f", subtotal) %></td>
                                <td class="p-3 text-center">
                                    <a href="cashier.jsp?action=remove&id=<%= item.get("id") %>&search=<%= search %>" class="text-red-500 text-xs uppercase hover:underline">Remove</a>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- PAYMENT PANEL -->
            <div class="flex-1">
                <form action="cashier.jsp" method="POST" class="bg-[#F3CE48] neubrutalism-border p-6 neubrutalism-shadow-lg h-full flex flex-col">
                    <input type="hidden" name="action" value="checkout">
                    <input type="hidden" name="total_bayar" value="<%= total %>">
                    
                    <div class="bg-black text-white p-2 text-center font-black uppercase mb-6">Payment</div>
                    
                    <div class="space-y-4 flex-1">
                        <div>
                            <label class="block text-xs font-black uppercase italic">Date</label>
                            <input type="date" name="tanggal" value="<%= currentDate %>" class="w-full border-2 border-black p-2 font-bold focus:outline-none">
                        </div>
                        <div>
                            <label class="block text-xs font-black uppercase italic">Customer Type</label>
                            <div class="flex gap-4 mt-1 font-bold text-sm">
                                <label class="flex items-center gap-1 cursor-pointer">
                                    <input type="radio" name="tipe_pelanggan" value="umum" checked class="accent-black"> GENERAL
                                </label>
                                <label class="flex items-center gap-1 cursor-pointer">
                                    <input type="radio" name="tipe_pelanggan" value="member" class="accent-black"> MEMBER
                                </label>
                            </div>
                        </div>
                        <div>
                            <label class="block text-xs font-black uppercase italic">Payment Method</label>
                            <select name="metode_pembayaran" class="w-full border-2 border-black p-2 font-bold focus:outline-none">
                                <option>CASH</option>
                                <option>DEBIT</option>
                                <option>QRIS</option>
                            </select>
                        </div>
                        <div>
                            <label class="block text-xs font-black uppercase italic">Additional Notes</label>
                            <textarea name="catatan" class="w-full border-2 border-black p-2 font-bold h-24 focus:outline-none"></textarea>
                        </div>
                    </div>

                    <div class="mt-6 border-t-4 border-black pt-4">
                        <div class="flex justify-between items-end mb-4 font-[900]">
                            <span class="uppercase">Total:</span>
                            <span class="text-3xl">Rp <%= String.format("%,.0f", total) %></span>
                        </div>
                        <button type="submit" <%= (cart.isEmpty() ? "disabled" : "") %> 
                            class="<%= (cart.isEmpty() ? "bg-gray-400 cursor-not-allowed" : "bg-white hover:bg-black hover:text-white") %> w-full border-4 border-black p-4 text-2xl font-black uppercase transition-all">
                            PROCESS
                        </button>
                    </div>
                </form>
                <p class="text-center mt-4 text-gray-500 font-bold text-xs uppercase italic">Developed by Dandy & Verly</p>
            </div>
        </div>
    </main>

</body>
</html>
<%
    if(conn != null) conn.close();
%>