<%@page import="jdbc.Koneksi"%>
<%@page import="java.sql.*"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    // 1. PROTEKSI SESSION
    if (session.getAttribute("username") == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    Connection conn = null;
    DecimalFormat df = new DecimalFormat("###,###");
    SimpleDateFormat sdfInput = new SimpleDateFormat("yyyy-MM-dd");
    SimpleDateFormat sdfOutput = new SimpleDateFormat("dd-MM-yyyy");

    try {
        Koneksi k = new Koneksi();
        conn = k.bukaKoneksi();
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>VEND.IO - Sales Report</title>
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
                <h1 class="text-2xl font-[900] italic uppercase tracking-tighter">VEND.IO</h1>
            </div>

            <!-- Menu -->
            <nav class="space-y-4">
                <a href="cashier.jsp" class="block p-3 font-black uppercase sidebar-link transition-all border-4 border-transparent">Cashier</a>
                <a href="MasterBarang.jsp" class="block p-3 font-black uppercase sidebar-link transition-all border-4 border-transparent">Master Items</a>
                <a href="MasterUser.jsp" class="block p-3 font-black uppercase sidebar-link transition-all border-4 border-transparent">Master User</a>
                <a href="SalesReport.jsp" class="block p-3 font-black uppercase active-menu transition-all">Sales Report</a>
            </nav>
        </div>

        <!-- User Info -->
        <div class="border-t-4 border-white pt-6">
            <p class="text-xs font-bold text-gray-400 uppercase">Staff</p>
            <h2 class="text-xl font-black uppercase text-white"><%= session.getAttribute("nama_lengkap") %></h2>
            <a href="index.jsp" class="text-red-500 font-black text-sm hover:underline uppercase">Log Out</a>
        </div>
    </aside>

    <!-- MAIN CONTENT -->
    <main class="flex-1 flex flex-col">
        <!-- Header -->
        <header class="p-6">
            <h1 class="text-4xl font-[900] uppercase italic tracking-tighter text-black">Sales Report</h1>
        </header>

        <!-- Area Content -->
        <div class="flex-1 p-6 overflow-hidden">
            <div class="bg-white neubrutalism-border neubrutalism-shadow-lg h-full flex flex-col relative">
                
                <!-- Title Header Card -->
                <h3 class="bg-black text-white inline-block px-10 py-6 font-black uppercase w-full self-start text-2xl tracking-tight">
                    Sales History Detail
                </h3>

                <div class="flex-1 overflow-y-auto p-6">
                    <table class="w-full text-left">
                        <thead class="sticky top-0 bg-white border-b-4 border-black">
                            <tr class="text-xs uppercase font-black text-center">
                                <th class="py-4">Invoice</th>
                                <th class="py-4 text-center">Date</th>
                                <th class="py-4 text-center">Staff</th>
                                <th class="py-4 text-center">Total</th>
                            </tr>
                        </thead>
                        <tbody class="font-bold">
                            <%
                                try {
                                    // Query Join untuk mendapatkan nama staff dari tabel master_user
                                    String sql = "SELECT p.*, u.nama_lengkap " +
                                                 "FROM trx_penjualan p " +
                                                 "LEFT JOIN master_user u ON p.id_user = u.id " +
                                                 "ORDER BY p.tanggal_transaksi DESC, p.id DESC";
                                    
                                    Statement stmt = conn.createStatement();
                                    ResultSet rs = stmt.executeQuery(sql);
                                    
                                    boolean adaData = false;
                                    while(rs.next()) {
                                        adaData = true;
                                        String tglDb = rs.getString("tanggal_transaksi");
                                        String tglFormat = sdfOutput.format(sdfInput.parse(tglDb));
                            %>
                            <tr class="border-b-2 border-gray-100 hover:bg-gray-50 transition-colors">
                                <td class="py-6 text-center text-sm uppercase tracking-wider">
                                    <%= rs.getString("nomor_invoice") %>
                                </td>
                                <td class="py-6 text-center text-sm">
                                    <%= tglFormat %>
                                </td>
                                <td class="py-6 text-center text-sm uppercase">
                                    <%= (rs.getString("nama_lengkap") != null) ? rs.getString("nama_lengkap") : "Unknown" %>
                                </td>
                                <td class="py-6 text-center text-lg font-black">
                                    Rp <%= df.format(rs.getDouble("total_bayar")) %>
                                </td>
                            </tr>
                            <% 
                                    }
                                    
                                    if(!adaData) {
                            %>
                                <tr>
                                    <td colspan="4" class="py-20 text-center text-gray-400 italic font-bold">
                                        Belum ada data transaksi tersimpan.
                                    </td>
                                </tr>
                            <%
                                    }
                                } catch(Exception e) { 
                                    out.println("<tr><td colspan='4' class='text-red-500 p-4'>" + e.getMessage() + "</td></tr>"); 
                                }
                            %>
                        </tbody>
                    </table>
                </div>

                <!-- Footer developed by -->
                <div class="p-4 text-right">
                     <p class="text-gray-300 font-bold text-xs uppercase italic">Developed by Dandy & Verly</p>
                </div>
            </div>
        </div>
    </main>

</body>
</html>
<%
    if(conn != null) conn.close();
%>