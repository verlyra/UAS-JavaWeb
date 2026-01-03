/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package jdbc;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 *
 * @author Legion
 */
public class Koneksi {
    public Connection bukaKoneksi() {
        Connection connect = null; // Inisialisasi dengan null
        try {
            // 1. Perbaikan pada nama Driver (D harus kapital)
            Class.forName("com.mysql.cj.jdbc.Driver"); 
            
            // 2. Menghapus .newInstance() yang sudah usang dan tidak perlu
            
            // Pastikan detail koneksi ini sudah 100% benar
            String url = "jdbc:mysql://localhost:3306/uas_jwp";
            String user = "root";
            String password = "root"; // <-- Apakah password ini sudah benar untuk user 'root' Anda?

            connect = DriverManager.getConnection(url, user, password);
            System.out.println("Koneksi ke database berhasil dibuat!");
            
        } 
        catch (ClassNotFoundException | SQLException exc) {
            // 3. Perbaikan PENTING: Jangan pernah biarkan blok catch kosong!
            // Blok ini akan menampilkan error yang sebenarnya terjadi.
            System.err.println("Koneksi GAGAL! Error: " + exc.getMessage());
            exc.printStackTrace(); // Ini akan mencetak detail error ke log server
        }
        
        // Mengembalikan objek koneksi (akan null jika koneksi gagal)
        return connect;
    }
}
