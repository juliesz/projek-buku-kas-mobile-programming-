const express = require('express');
const cors = require('cors');
const mysql = require('mysql2');

const app = express();
const PORT = 3000;

// Middleware
app.use(cors());
app.use(express.json());

// ==========================================
// KONEKSI KE DATABASE MYSQL
// ==========================================
// ⚠️ SESUAIKAN user & password dengan settingan MySQL Anda!
// Jika pakai XAMPP, biasanya user: 'root', password: ''
const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',      // Ganti jika user MySQL Anda berbeda
  password: '',      // Ganti jika MySQL Anda pakai password
  database: 'finote_db'
});

db.connect((err) => {
  if (err) {
    console.error('Gagal terhubung ke MySQL:', err);
    return;
  }
  console.log('Berhasil terhubung ke Database MySQL!');
});

// ==========================================
// 1. ENDPOINT AUTH
// ==========================================
app.post('/api/auth/login', (req, res) => {
  const { username, password } = req.body;
  
  const query = 'SELECT * FROM users WHERE username = ? AND password = ?';
  db.query(query, [username, password], (err, results) => {
    if (err) return res.status(500).json({ status: "error", message: err.message });
    
    if (results.length > 0) {
      const user = results[0];
      res.json({
        status: "success",
        message: "Login berhasil",
        token: "dummy-jwt-token-123",
        data: { id: user.id, username: user.username, fullName: user.fullName }
      });
    } else {
      res.status(401).json({ status: "error", message: "Username atau password salah" });
    }
  });
});

app.post('/api/auth/register', (req, res) => {
  const { username, password, fullName } = req.body;
  
  const checkQuery = 'SELECT * FROM users WHERE username = ?';
  db.query(checkQuery, [username], (err, results) => {
    if (err) return res.status(500).json({ status: "error", message: err.message });
    if (results.length > 0) return res.status(400).json({ status: "error", message: "Username sudah dipakai" });

    const insertQuery = 'INSERT INTO users (username, password, fullName) VALUES (?, ?, ?)';
    db.query(insertQuery, [username, password, fullName], (err, result) => {
      if (err) return res.status(500).json({ status: "error", message: err.message });
      res.status(201).json({ 
        status: "success", 
        message: "Registrasi berhasil", 
        data: { id: result.insertId, username, fullName } 
      });
    });
  });
});

// ==========================================
// 2. ENDPOINT TRANSAKSI
// ==========================================
app.get('/api/transactions', (req, res) => {
  const query = 'SELECT * FROM transactions ORDER BY date DESC';
  db.query(query, (err, results) => {
    if (err) return res.status(500).json({ status: "error", message: err.message });
    
    // Konversi isIncome dari MySQL (0/1) ke boolean
    const formatted = results.map(t => ({
      ...t,
      isIncome: t.isIncome === 1
    }));
    res.json({ status: "success", data: formatted });
  });
});

app.post('/api/transactions', (req, res) => {
  const { title, amount, isIncome, date } = req.body;
  
  const insertQuery = 'INSERT INTO transactions (title, amount, isIncome, date) VALUES (?, ?, ?, ?)';
  db.query(insertQuery, [title, amount, isIncome, date || new Date()], (err, result) => {
    if (err) return res.status(500).json({ status: "error", message: err.message });

    // Buat Notifikasi Otomatis
    const notifTitle = isIncome ? "Pemasukan Baru" : "Pengeluaran Baru";
    const notifMessage = `${title} — Rp${amount}`;
    const notifQuery = 'INSERT INTO notifications (title, message, isIncome) VALUES (?, ?, ?)';
    db.query(notifQuery, [notifTitle, notifMessage, isIncome], (errNotif) => {
      // Abaikan error notif agar transaksi tetap tersimpan
    });

    res.status(201).json({ 
      status: "success", 
      message: "Transaksi berhasil dicatat", 
      data: { id: result.insertId, title, amount, isIncome, date } 
    });
  });
});

app.delete('/api/transactions/:id', (req, res) => {
  const id = req.params.id;
  db.query('DELETE FROM transactions WHERE id = ?', [id], (err) => {
    if (err) return res.status(500).json({ status: "error", message: err.message });
    res.json({ status: "success", message: "Transaksi berhasil dihapus" });
  });
});

// ==========================================
// 3. ENDPOINT SUMMARY (SALDO)
// ==========================================
app.get('/api/summary', (req, res) => {
  const query = `
    SELECT 
      SUM(CASE WHEN isIncome = 1 THEN amount ELSE 0 END) as totalIncome,
      SUM(CASE WHEN isIncome = 0 THEN amount ELSE 0 END) as totalExpense
    FROM transactions
  `;
  db.query(query, (err, results) => {
    if (err) return res.status(500).json({ status: "error", message: err.message });
    
    const totalIncome = results[0].totalIncome || 0;
    const totalExpense = results[0].totalExpense || 0;
    
    res.json({
      status: "success",
      data: {
        totalIncome,
        totalExpense,
        balance: totalIncome - totalExpense
      }
    });
  });
});

// ==========================================
// 4. ENDPOINT NOTIFIKASI
// ==========================================
app.get('/api/notifications', (req, res) => {
  db.query('SELECT * FROM notifications ORDER BY time DESC', (err, results) => {
    if (err) return res.status(500).json({ status: "error", message: err.message });
    
    const formatted = results.map(n => ({
      ...n,
      isIncome: n.isIncome === 1
    }));
    res.json({ status: "success", data: formatted });
  });
});

app.delete('/api/notifications', (req, res) => {
  db.query('DELETE FROM notifications', (err) => {
    if (err) return res.status(500).json({ status: "error", message: err.message });
    res.json({ status: "success", message: "Semua notifikasi berhasil dihapus" });
  });
});

// ==========================================
// JALANKAN SERVER
// ==========================================
app.listen(PORT, () => {
  console.log(`Server FINOTE berjalan di http://localhost:${PORT}`);
});