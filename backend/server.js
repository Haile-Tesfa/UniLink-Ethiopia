require('dotenv').config();
const express = require('express');
const sql = require('mssql');
const cors = require('cors');
const multer = require('multer');
const path = require('path');

const app = express();
const port = 5000;

const dbConfig = {
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    server: process.env.DB_SERVER,
    database: process.env.DB_NAME,
    options: {
        encrypt: process.env.DB_ENCRYPT === 'true',
        trustServerCertificate: process.env.DB_TRUST_CERT === 'true',
    },
};

app.use(cors());
app.use(express.json());

sql
    .connect(dbConfig)
    .then((pool) => {
        console.log('Connected to SQL Server');
        app.locals.db = pool;
    })
    .catch((err) => {
        console.error('SQL connection error:', err);
    });


// AUTH: SIGNUP
app.post('/api/auth/signup', async (req, res) => {
    const { fullName, email, studentId, department, yearOfStudy, password } =
        req.body;

    if (
        !fullName ||
        !email ||
        !studentId ||
        !department ||
        !yearOfStudy ||
        !password
    ) {
        return res.status(400).json({ message: 'All fields are required' });
    }

    const strongPasswordRegex =
        /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[#$@$!%*?&])[A-Za-z\d#$@$!%*?&]{8,}$/;

    if (!strongPasswordRegex.test(password)) {
        return res.status(400).json({
            message:
                'Password must be at least 8 characters and include lowercase, uppercase, number, and special character.',
        });
    }

    const gmailRegex = /^[^@\s]+@gmail\.com$/;

    if (!gmailRegex.test(email)) {
        return res.status(400).json({
            message:
                'Email must be a valid Gmail address like username@gmail.com.',
        });
    }

    try {
        const pool = req.app.locals.db;

        const dupCheck = await pool
            .request()
            .input('Email', sql.NVarChar(150), email)
            .input('StudentId', sql.NVarChar(50), studentId)
            .query(`
        SELECT 1 AS ExistsFlag
        FROM Users
        WHERE UniversityEmail = @Email OR StudentId = @StudentId
      `);

        if (dupCheck.recordset.length > 0) {
            return res
                .status(409)
                .json({ message: 'Email or Student ID already registered' });
        }

        await pool
            .request()
            .input('FullName', sql.NVarChar(100), fullName)
            .input('Email', sql.NVarChar(150), email)
            .input('StudentId', sql.NVarChar(50), studentId)
            .input('Department', sql.NVarChar(100), department)
            .input('YearOfStudy', sql.Int, yearOfStudy)
            .input('Password', sql.NVarChar(256), password)
            .query(`
        INSERT INTO Users (
          FullName,
          UniversityEmail,
          StudentId,
          Department,
          YearOfStudy,
          PasswordHash
        )
        VALUES (
          @FullName,
          @Email,
          @StudentId,
          @Department,
          @YearOfStudy,
          HASHBYTES('SHA2_256', @Password)
        );
      `);

        return res.status(201).json({ message: 'Account created successfully' });
    } catch (err) {
        console.error('Signup error:', err);
        return res.status(500).json({ message: 'Server error' });
    }
});

// AUTH: LOGIN
app.post('/api/auth/login', async (req, res) => {
    const { email, password } = req.body;

    if (!email || !password) {
        return res
            .status(400)
            .json({ message: 'Email and password are required' });
    }

    try {
        const pool = req.app.locals.db;

        const result = await pool
            .request()
            .input('Email', sql.NVarChar(150), email)
            .input('Password', sql.NVarChar(256), password)
            .query(`
        SELECT
          UserId,
          FullName,
          UniversityEmail,
          StudentId,
          Department,
          YearOfStudy,
          CreatedAt
        FROM Users
        WHERE UniversityEmail = @Email
          AND PasswordHash = HASHBYTES('SHA2_256', @Password);
      `);

        if (result.recordset.length === 0) {
            return res
                .status(401)
                .json({ message: 'Invalid email or password' });
        }

        const user = result.recordset[0];

        return res.status(200).json({
            message: 'Login successful',
            user: {
                id: user.UserId,
                name: user.FullName,
                email: user.UniversityEmail,
                studentId: user.StudentId,
                department: user.Department,
                yearOfStudy: user.YearOfStudy,
                createdAt: user.CreatedAt,
            },
        });
    } catch (err) {
        console.error('Login error:', err);
        return res.status(500).json({ message: 'Server error' });
    }
});

// AUTH: FORGOT PASSWORD (check email)
app.post('/api/auth/forgot-password', async (req, res) => {
    const { email } = req.body;

    if (!email) {
        return res.status(400).json({ message: 'Email is required' });
    }

    try {
        const pool = req.app.locals.db;

        const result = await pool
            .request()
            .input('Email', sql.NVarChar(150), email)
            .query(`
        SELECT UserId
        FROM Users
        WHERE UniversityEmail = @Email;
      `);

        if (result.recordset.length === 0) {
            return res.status(404).json({ message: 'No account with this email' });
        }

        return res.status(200).json({
            message: 'Email found. You can reset your password now.',
        });
    } catch (err) {
        console.error('Forgot password error:', err);
        return res.status(500).json({ message: 'Server error' });
    }
});

// AUTH: RESET PASSWORD
app.post('/api/auth/reset-password', async (req, res) => {
    const { email, newPassword } = req.body;

    if (!email || !newPassword) {
        return res
            .status(400)
            .json({ message: 'Email and new password are required' });
    }

    const strongPasswordRegex =
        /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[#$@$!%*?&])[A-Za-z\d#$@$!%*?&]{8,}$/;

    if (!strongPasswordRegex.test(newPassword)) {
        return res.status(400).json({
            message:
                'Password must be at least 8 characters and include lowercase, uppercase, number, and special character.',
        });
    }

    try {
        const pool = req.app.locals.db;

        const result = await pool
            .request()
            .input('Email', sql.NVarChar(150), email)
            .input('Password', sql.NVarChar(256), newPassword)
            .query(`
        UPDATE Users
        SET PasswordHash = HASHBYTES('SHA2_256', @Password)
        WHERE UniversityEmail = @Email;
      `);

        if (result.rowsAffected[0] === 0) {
            return res.status(404).json({ message: 'No account with this email' });
        }

        return res.status(200).json({ message: 'Password updated successfully' });
    } catch (err) {
        console.error('Reset password error:', err);
        return res.status(500).json({ message: 'Server error' });
    }
});

// AUTH: GOOGLE DUMMY LOGIN
app.post('/api/auth/google', async (req, res) => {
    const { idToken } = req.body;
    console.log('Google fake login, idToken:', idToken);

    if (!idToken) {
        return res.status(400).json({ message: 'Missing idToken' });
    }

    // TODO: verify real Google token here
    return res.status(200).json({
        message: 'Google login success (dummy)',
        user: { id: 0, name: 'Google User' },
    });
});

// AUTH: FACEBOOK DUMMY LOGIN
app.post('/api/auth/facebook', async (req, res) => {
    const { accessToken } = req.body;
    console.log('Facebook fake login, accessToken:', accessToken);

    if (!accessToken) {
        return res.status(400).json({ message: 'Missing accessToken' });
    }

    // TODO: verify real Facebook token here
    return res.status(200).json({
        message: 'Facebook login success (dummy)',
        user: { id: 0, name: 'Facebook User' },
    });
});

// MARKETPLACE: GET ITEMS
app.get('/api/marketplace/items', async (req, res) => {
    const category = req.query.category;
    try {
        const pool = req.app.locals.db;
        let query = `
      SELECT ItemId, SellerId, Title, Description, Price, ImageUrl,
             Category, Condition, IsNegotiable, IsActive, PostedDate
      FROM MarketplaceItems
      WHERE IsActive = 1
    `;
        const request = pool.request();
        if (category && category !== 'All') {
            query += ' AND Category = @Category';
            request.input('Category', sql.NVarChar(50), category);
        }
        query += ' ORDER BY PostedDate DESC';

        const result = await request.query(query);
        return res.status(200).json({ items: result.recordset });
    } catch (err) {
        console.error('Get marketplace items error:', err);
        return res.status(500).json({ message: 'Server error' });
    }
});

// MARKETPLACE: CREATE ITEM
app.post('/api/marketplace/items', async (req, res) => {
    const {
        sellerId,
        title,
        description,
        price,
        imageUrl,
        category,
        condition,
        isNegotiable,
    } = req.body;

    if (
        !sellerId ||
        !title ||
        !description ||
        price == null ||
        !category ||
        !condition
    ) {
        return res.status(400).json({ message: 'Missing required fields' });
    }

    try {
        const pool = req.app.locals.db;
        await pool
            .request()
            .input('SellerId', sql.Int, sellerId)
            .input('Title', sql.NVarChar(150), title)
            .input('Description', sql.NVarChar(1000), description)
            .input('Price', sql.Decimal(18, 2), price)
            .input('ImageUrl', sql.NVarChar(300), imageUrl || null)
            .input('Category', sql.NVarChar(50), category)
            .input('Condition', sql.NVarChar(50), condition)
            .input('IsNegotiable', sql.Bit, isNegotiable ?? true)
            .query(`
        INSERT INTO MarketplaceItems (
          SellerId, Title, Description, Price, ImageUrl,
          Category, Condition, IsNegotiable, IsActive
        )
        VALUES (
          @SellerId, @Title, @Description, @Price, @ImageUrl,
          @Category, @Condition, @IsNegotiable, 1
        );
      `);

        return res.status(201).json({ message: 'Item created successfully' });
    } catch (err) {
        console.error('Create marketplace item error:', err);
        return res.status(500).json({ message: 'Server error' });
    }
});




// POSTS: CREATE
app.post('/api/posts', async (req, res) => {
    const { userId, content, mediaUrl, mediaType, privacy } = req.body;

    if (!userId || !content || !privacy) {
        return res.status(400).json({ message: 'Missing required fields' });
    }

    try {
        const pool = req.app.locals.db;
        await pool
            .request()
            .input('UserId', sql.Int, userId)
            .input('Content', sql.NVarChar(2000), content)
            .input('MediaUrl', sql.NVarChar(300), mediaUrl || null)
            .input('MediaType', sql.NVarChar(20), mediaType || null)
            .input('Privacy', sql.NVarChar(20), privacy)
            .query(`
                INSERT INTO Posts (UserId, Content, MediaUrl, MediaType, Privacy)
                VALUES (@UserId, @Content, @MediaUrl, @MediaType, @Privacy);
            `);

        return res.status(201).json({ message: 'Post created successfully' });
    } catch (err) {
        console.error('Create post error:', err);
        return res.status(500).json({ message: 'Server error' });
    }
});




// NOTIFICATIONS: GET
app.get('/api/notifications/:userId', async (req, res) => {
    const userId = parseInt(req.params.userId, 10);
    if (!userId) return res.status(400).json({ message: 'Invalid user id' });

    try {
        const pool = req.app.locals.db;
        const result = await pool
            .request()
            .input('UserId', sql.Int, userId)
            .query(`
        SELECT NotificationId, UserId, Type, Title, Body, SenderId,
               SenderName, SenderImage, PostId, ItemId,
               Timestamp, IsRead
        FROM Notifications
        WHERE UserId = @UserId
        ORDER BY Timestamp DESC;
      `);

        return res.status(200).json({ notifications: result.recordset });
    } catch (err) {
        console.error('Get notifications error:', err);
        return res.status(500).json({ message: 'Server error' });
    }
});

// NOTIFICATIONS: MARK ALL READ
app.post('/api/notifications/:userId/mark-all-read', async (req, res) => {
    const userId = parseInt(req.params.userId, 10);
    if (!userId) return res.status(400).json({ message: 'Invalid user id' });

    try {
        const pool = req.app.locals.db;
        await pool
            .request()
            .input('UserId', sql.Int, userId)
            .query(`
        UPDATE Notifications
        SET IsRead = 1
        WHERE UserId = @UserId AND IsRead = 0;
      `);
        return res.status(200).json({ message: 'All notifications marked as read' });
    } catch (err) {
        console.error('Mark all notifications read error:', err);
        return res.status(500).json({ message: 'Server error' });
    }
});

// CHAT: GET MESSAGES
app.get('/api/chat/:userId/:otherUserId', async (req, res) => {
    const userId = parseInt(req.params.userId, 10);
    const otherUserId = parseInt(req.params.otherUserId, 10);
    if (!userId || !otherUserId) {
        return res.status(400).json({ message: 'Invalid user ids' });
    }

    try {
        const pool = req.app.locals.db;
        const result = await pool
            .request()
            .input('UserId', sql.Int, userId)
            .input('OtherUserId', sql.Int, otherUserId)
            .query(`
        SELECT MessageId, SenderId, ReceiverId, Content, Timestamp, IsRead
        FROM ChatMessages
        WHERE (SenderId = @UserId AND ReceiverId = @OtherUserId)
           OR (SenderId = @OtherUserId AND ReceiverId = @UserId)
        ORDER BY Timestamp ASC;
      `);

        return res.status(200).json({ messages: result.recordset });
    } catch (err) {
        console.error('Get chat messages error:', err);
        return res.status(500).json({ message: 'Server error' });
    }
});

// CHAT: SEND MESSAGE
app.post('/api/chat/send', async (req, res) => {
    const { senderId, receiverId, content } = req.body;
    if (!senderId || !receiverId || !content) {
        return res.status(400).json({ message: 'Missing fields' });
    }

    try {
        const pool = req.app.locals.db;
        await pool
            .request()
            .input('SenderId', sql.Int, senderId)
            .input('ReceiverId', sql.Int, receiverId)
            .input('Content', sql.NVarChar(2000), content)
            .query(`
        INSERT INTO ChatMessages (SenderId, ReceiverId, Content)
        VALUES (@SenderId, @ReceiverId, @Content);
      `);

        return res.status(201).json({ message: 'Message sent' });
    } catch (err) {
        console.error('Send chat message error:', err);
        return res.status(500).json({ message: 'Server error' });
    }
});

// EVENTS: GET
app.get('/api/events', async (req, res) => {
    try {
        const pool = req.app.locals.db;
        const result = await pool.request().query(`
      SELECT EventId, Title, Description, EventDate, EventTime,
             Location, ImageUrl, Organizer, Attendees, CreatedAt
      FROM Events
      ORDER BY EventDate, EventTime;
    `);
        return res.status(200).json({ events: result.recordset });
    } catch (err) {
        console.error('Get events error:', err);
        return res.status(500).json({ message: 'Server error' });
    }
});

// EVENTS: CREATE
app.post('/api/events', async (req, res) => {
    const {
        title,
        description,
        eventDate,
        eventTime,
        location,
        imageUrl,
        organizer,
    } = req.body;

    if (
        !title ||
        !description ||
        !eventDate ||
        !eventTime ||
        !location ||
        !organizer
    ) {
        return res.status(400).json({ message: 'Missing fields' });
    }

    try {
        const pool = req.app.locals.db;
        await pool
            .request()
            .input('Title', sql.NVarChar(150), title)
            .input('Description', sql.NVarChar(1000), description)
            .input('EventDate', sql.Date, eventDate)
            .input('EventTime', sql.Time, eventTime)
            .input('Location', sql.NVarChar(200), location)
            .input('ImageUrl', sql.NVarChar(300), imageUrl || null)
            .input('Organizer', sql.NVarChar(100), organizer)
            .query(`
        INSERT INTO Events (
          Title, Description, EventDate, EventTime,
          Location, ImageUrl, Organizer
        )
        VALUES (
          @Title, @Description, @EventDate, @EventTime,
          @Location, @ImageUrl, @Organizer
        );
      `);

        return res.status(201).json({ message: 'Event created' });
    } catch (err) {
        console.error('Create event error:', err);
        return res.status(500).json({ message: 'Server error' });
    }
});

// CLUBS: GET
app.get('/api/clubs', async (req, res) => {
    try {
        const pool = req.app.locals.db;
        const result = await pool.request().query(`
      SELECT ClubId, Name, Category, Members, ImageUrl
      FROM Clubs
      ORDER BY Name;
    `);
        return res.status(200).json({ clubs: result.recordset });
    } catch (err) {
        console.error('Get clubs error:', err);
        return res.status(500).json({ message: 'Server error' });
    }
});

app.listen(port, () => {
    console.log(`UniLink backend running on port ${port}`);
});
