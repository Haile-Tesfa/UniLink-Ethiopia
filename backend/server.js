const express = require('express');
const cors = require('cors');
const sql = require('mssql');
const bcrypt = require('bcryptjs'); // not used but ok

const app = express();
app.use(express.json());
app.use(cors());

const dbConfig = {
    user: 'sa',
    password: '123321',
    server: 'localhost',
    database: 'App',
    options: { trustServerCertificate: true },
};

// SIGNUP
app.post('/signup', async (req, res) => {
    const { fullName, email, phone, password } = req.body;

    if (!fullName || !email || !phone || !password) {
        return res.status(400).json({ error: 'All fields are required' });
    }

    try {
        const pool = await sql.connect(dbConfig);

        const existing = await pool
            .request()
            .input('email', sql.VarChar, email)
            .input('phone', sql.VarChar, phone)
            .query(`
        SELECT TOP 1 UserId
        FROM Users
        WHERE Email = @email OR Phone = @phone
      `);

        if (existing.recordset.length > 0) {
            return res
                .status(400)
                .json({ error: 'Email or phone already registered' });
        }

        await pool
            .request()
            .input('fullName', sql.VarChar, fullName)
            .input('email', sql.VarChar, email)
            .input('phone', sql.VarChar, phone)
            .input('password', sql.VarChar, password)
            .query(`
        INSERT INTO Users (FullName, Email, Phone, Password)
        VALUES (@fullName, @email, @phone, @password)
      `);

        return res.status(201).json({ message: 'User created successfully' });
    } catch (err) {
        console.error('Signup error:', err);
        return res.status(500).json({ error: 'Server error' });
    }
});

// LOGIN
app.post('/login', async (req, res) => {
    const { identifier, password } = req.body;

    if (!identifier || !password) {
        return res
            .status(400)
            .json({ error: 'Email/phone and password required' });
    }

    try {
        const pool = await sql.connect(dbConfig);

        const result = await pool
            .request()
            .input('identifier', sql.VarChar, identifier)
            .query(`
        SELECT TOP 1 UserId, Email, Phone, Password, FullName
        FROM Users
        WHERE Email = @identifier OR Phone = @identifier
      `);

        if (result.recordset.length === 0) {
            return res.status(401).json({ error: 'Invalid credentials' });
        }

        const user = result.recordset[0];

        if (user.Password !== password) {
            return res.status(401).json({ error: 'Invalid credentials' });
        }

        return res.json({
            message: 'Login successful',
            user: {
                userId: user.UserId,
                email: user.Email,
                phone: user.Phone,
                fullName: user.FullName,
            },
        });
    } catch (err) {
        console.error('Login error:', err);
        return res.status(500).json({ error: 'Server error' });
    }
});

// UPDATE PROFILE
app.put('/user/:id', async (req, res) => {
    const { id } = req.params;
    const { fullName, email } = req.body;

    if (!fullName || !email) {
        return res
            .status(400)
            .json({ error: 'Full name and email required' });
    }

    try {
        const pool = await sql.connect(dbConfig);

        await pool
            .request()
            .input('id', sql.Int, id)
            .input('fullName', sql.VarChar, fullName)
            .input('email', sql.VarChar, email)
            .query(`
        UPDATE Users
        SET FullName = @fullName,
            Email = @email
        WHERE UserId = @id
      `);

        return res.json({ message: 'Profile updated' });
    } catch (err) {
        console.error('Update profile error:', err);
        return res.status(500).json({ error: 'Server error' });
    }
});

// DELETE ACCOUNT
app.delete('/user/:id', async (req, res) => {
    const { id } = req.params;

    try {
        const pool = await sql.connect(dbConfig);

        await pool
            .request()
            .input('id', sql.Int, id)
            .query(`
        DELETE FROM Users
        WHERE UserId = @id
      `);

        return res.json({ message: 'Account deleted' });
    } catch (err) {
        console.error('Delete account error:', err);
        return res.status(500).json({ error: 'Server error' });
    }
});

app.listen(3000, () => {
    console.log('Auth server running on http://localhost:3000');
});
