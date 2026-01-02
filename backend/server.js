require('dotenv').config();
const express = require('express');
const sql = require('mssql');
const cors = require('cors');
const multer = require('multer');
const path = require('path');

const app = express();

// OLD: const port = 5000;
// NEW:
const PORT = process.env.PORT || 5000;

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

// ====== FILE UPLOAD CONFIG ======
const uploadDir = path.join(__dirname, 'uploads');
app.use('/uploads', express.static(uploadDir));

const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, uploadDir);
    },
    filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
        const ext = path.extname(file.originalname);
        cb(null, 'media-' + uniqueSuffix + ext);
    },
});

const upload = multer({ storage });

// ====== DB CONNECT ======
sql
    .connect(dbConfig)
    .then((pool) => {
        console.log('Connected to SQL Server');
        app.locals.db = pool;
    })
    .catch((err) => {
        console.error('SQL connection error:', err);
    });

/* ========== AUTH ROUTES ========== */

// SIGNUP
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

// LOGIN
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
          CreatedAt,
          ProfileImageUrl
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
                profileImageUrl: user.ProfileImageUrl || null,
            },
        });
    } catch (err) {
        console.error('Login error:', err);
        return res.status(500).json({ message: 'Server error' });
    }
});

// FORGOT PASSWORD
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

// RESET PASSWORD
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

// GOOGLE / FACEBOOK dummy routes
app.post('/api/auth/google', async (req, res) => {
    const { idToken } = req.body;
    console.log('Google fake login, idToken:', idToken);

    if (!idToken) {
        return res.status(400).json({ message: 'Missing idToken' });
    }

    return res.status(200).json({
        message: 'Google login success (dummy)',
        user: { id: 0, name: 'Google User' },
    });
});

app.post('/api/auth/facebook', async (req, res) => {
    const { accessToken } = req.body;
    console.log('Facebook fake login, accessToken:', accessToken);

    if (!accessToken) {
        return res.status(400).json({ message: 'Missing accessToken' });
    }

    return res.status(200).json({
        message: 'Facebook login success (dummy)',
        user: { id: 0, name: 'Facebook User' },
    });
});

/* ========== FILE UPLOAD ROUTE ========== */

app.post('/api/uploads/post-media', upload.single('media'), (req, res) => {
    if (!req.file) {
        return res.status(400).json({ message: 'No file uploaded' });
    }

    const fileUrl = `/uploads/${req.file.filename}`;

    return res.status(201).json({
        message: 'File uploaded',
        fileUrl,
    });
});

/* ========== MARKETPLACE ROUTES ========== */

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

/* ========== MESSAGES ROUTES (Marketplace) ========== */

app.post('/api/messages', async (req, res) => {
    const { itemId, buyerId, sellerId, messageText } = req.body;

    if (!itemId || !buyerId || !sellerId || !messageText) {
        return res.status(400).json({ message: 'Missing required fields' });
    }

    try {
        const pool = req.app.locals.db;
        await pool
            .request()
            .input('ItemId', sql.Int, itemId)
            .input('BuyerId', sql.Int, buyerId)
            .input('SellerId', sql.Int, sellerId)
            .input('MessageText', sql.NVarChar(1000), messageText)
            .query(`
        INSERT INTO Messages (ItemId, BuyerId, SellerId, MessageText)
        VALUES (@ItemId, @BuyerId, @SellerId, @MessageText);
      `);

        return res.status(201).json({ message: 'Message created successfully' });
    } catch (err) {
        console.error('Create message error:', err);
        return res.status(500).json({ message: 'Server error' });
    }
});

/* ========== COMMENTS ROUTES ========== */

app.post('/api/comments', async (req, res) => {
    const { postId, authorId, postOwnerId, commentText } = req.body;

    if (!postId || !authorId || !postOwnerId || !commentText) {
        return res.status(400).json({ message: 'Missing required fields' });
    }

    try {
        const pool = req.app.locals.db;
        await pool
            .request()
            .input('PostId', sql.Int, postId)
            .input('AuthorId', sql.Int, authorId)
            .input('PostOwnerId', sql.Int, postOwnerId)
            .input('CommentText', sql.NVarChar(1000), commentText)
            .query(`
        INSERT INTO Comments (PostId, AuthorId, PostOwnerId, CommentText)
        VALUES (@PostId, @AuthorId, @PostOwnerId, @CommentText);
      `);

        return res.status(201).json({ message: 'Comment saved' });
    } catch (err) {
        console.error('Create comment error:', err);
        return res.status(500).json({ message: 'Server error' });
    }
});

app.get('/api/comments/:postId', async (req, res) => {
    const postId = parseInt(req.params.postId, 10);
    if (!postId) return res.status(400).json({ message: 'Invalid post id' });

    try {
        const pool = req.app.locals.db;
        const result = await pool
            .request()
            .input('PostId', sql.Int, postId)
            .query(`
        SELECT CommentId, PostId, AuthorId, PostOwnerId, CommentText, CreatedAt
        FROM Comments
        WHERE PostId = @PostId
        ORDER BY CreatedAt ASC;
      `);

        return res.status(200).json({ comments: result.recordset });
    } catch (err) {
        console.error('Get comments error:', err);
        return res.status(500).json({ message: 'Server error' });
    }
});

/* ========== POSTS: CREATE ========== */

app.post('/api/posts', async (req, res) => {
    const { userId, content, mediaUrl, mediaType, privacy } = req.body;

    if (!userId || !privacy) {
        return res.status(400).json({ message: 'Missing required fields' });
    }

    const safeContent =
        content && typeof content === 'string' ? content : '';

    try {
        const pool = req.app.locals.db;
        await pool
            .request()
            .input('UserId', sql.Int, userId)
            .input('Content', sql.NVarChar(2000), safeContent)
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

/* ========== POSTS: GET (home feed) ========== */

app.get('/api/posts', async (req, res) => {
    try {
        const pool = req.app.locals.db;

        const result = await pool.request().query(`
      SELECT
        PostId,
        UserId,
        Content,
        MediaUrl,
        MediaType,
        Privacy,
        CreatedAt
      FROM Posts
      ORDER BY CreatedAt DESC;
    `);

        return res.status(200).json({ posts: result.recordset });
    } catch (err) {
        console.error('Get posts error:', err);
        return res.status(500).json({ message: 'Server error' });
    }
});

/* ========== NOTIFICATIONS: LIST ========== */

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

/* ========== NOTIFICATIONS: MARK READ ========== */

app.post('/api/notifications/mark-read', async (req, res) => {
    const { notificationId } = req.body;

    if (!notificationId) {
        return res.status(400).json({ message: 'notificationId is required' });
    }

    try {
        const pool = req.app.locals.db;
        const result = await pool
            .request()
            .input('NotificationId', sql.Int, notificationId)
            .query(`
        UPDATE Notifications
        SET IsRead = 1
        WHERE NotificationId = @NotificationId;
      `);

        if (result.rowsAffected[0] === 0) {
            return res.status(404).json({ message: 'Notification not found' });
        }

        return res.status(200).json({ message: 'Marked as read' });
    } catch (err) {
        console.error('Mark notification read error:', err);
        return res.status(500).json({ message: 'Server error' });
    }
});

/* ========== NOTIFICATIONS: UNREAD COUNT ========== */

app.get('/api/notifications/:userId/unread-count', async (req, res) => {
    const userId = parseInt(req.params.userId, 10);
    if (!userId) return res.status(400).json({ message: 'Invalid user id' });

    try {
        const pool = req.app.locals.db;
        const result = await pool
            .request()
            .input('UserId', sql.Int, userId)
            .query(`
        SELECT COUNT(*) AS UnreadCount
        FROM Notifications
        WHERE UserId = @UserId AND IsRead = 0;
      `);

        const count = result.recordset[0].UnreadCount;
        return res.status(200).json({ unreadCount: count });
    } catch (err) {
        console.error('Get unread notifications count error:', err);
        return res.status(500).json({ message: 'Server error' });
    }
});

/* ========== CHAT MESSAGES (ChatMessages table) ========== */

// Get all messages between two users (1-to-1)
app.get('/api/chat/messages', async (req, res) => {
    const user1 = parseInt(req.query.user1, 10);
    const user2 = parseInt(req.query.user2, 10);

    if (!user1 || !user2) {
        return res
            .status(400)
            .json({ message: 'user1 and user2 are required' });
    }

    try {
        const pool = req.app.locals.db;

        const result = await pool
            .request()
            .input('User1', sql.Int, user1)
            .input('User2', sql.Int, user2)
            .query(`
        SELECT
          MessageId,
          SenderId,
          ReceiverId,
          Content,
          Timestamp,
          IsRead
        FROM ChatMessages
        WHERE
          (SenderId = @User1 AND ReceiverId = @User2)
          OR
          (SenderId = @User2 AND ReceiverId = @User1)
        ORDER BY Timestamp ASC;
      `);

        return res.status(200).json({ messages: result.recordset });
    } catch (err) {
        console.error('Get chat messages error:', err);
        return res.status(500).json({ message: 'Server error' });
    }
});

// Send a new chat message + create notification
app.post('/api/chat/messages', async (req, res) => {
    const { senderId, receiverId, content } = req.body;

    if (!senderId || !receiverId || !content) {
        return res.status(400).json({
            message: 'senderId, receiverId, content required',
        });
    }

    try {
        const pool = req.app.locals.db;

        // 1) Insert chat message
        const msgResult = await pool
            .request()
            .input('SenderId', sql.Int, senderId)
            .input('ReceiverId', sql.Int, receiverId)
            .input('Content', sql.NVarChar(2000), content)
            .query(`
        INSERT INTO ChatMessages (SenderId, ReceiverId, Content)
        OUTPUT INSERTED.MessageId, INSERTED.SenderId, INSERTED.ReceiverId,
               INSERTED.Content, INSERTED.Timestamp, INSERTED.IsRead
        VALUES (@SenderId, @ReceiverId, @Content);
      `);

        const chatRow = msgResult.recordset[0];

        // 2) Get sender's display info
        const userResult = await pool
            .request()
            .input('SenderId', sql.Int, senderId)
            .query(`
        SELECT FullName, ProfileImageUrl
        FROM Users
        WHERE UserId = @SenderId;
      `);

        const sender = userResult.recordset[0];

        const senderName = sender ? sender.FullName : 'Unknown';
        const senderImage = sender ? sender.ProfileImageUrl : null;

        // 3) Insert notification for receiver
        await pool
            .request()
            .input('UserId', sql.Int, receiverId)
            .input('Type', sql.NVarChar(20), 'message')
            .input('Title', sql.NVarChar(150), senderName)
            .input('Body', sql.NVarChar(500), content.substring(0, 120))
            .input('SenderId', sql.Int, senderId)
            .input('SenderName', sql.NVarChar(100), senderName)
            .input('SenderImage', sql.NVarChar(300), senderImage)
            .query(`
        INSERT INTO Notifications (
          UserId, Type, Title, Body,
          SenderId, SenderName, SenderImage
        )
        VALUES (
          @UserId, @Type, @Title, @Body,
          @SenderId, @SenderName, @SenderImage
        );
      `);

        return res.status(201).json({
            message: 'Message sent',
            chatMessage: chatRow,
        });
    } catch (err) {
        console.error('Create chat message error:', err);
        return res.status(500).json({ message: 'Server error' });
    }
});

// Search users (for starting new chat)
app.get('/api/users/search', async (req, res) => {
    const q = (req.query.q || '').trim();
    if (!q) {
        return res.status(400).json({ message: 'q (query) is required' });
    }

    try {
        const pool = req.app.locals.db;
        const result = await pool
            .request()
            .input('Q', sql.NVarChar(150), `%${q}%`)
            .query(`
        SELECT TOP 20
          UserId,
          FullName,
          UniversityEmail,
          ProfileImageUrl
        FROM Users
        WHERE FullName LIKE @Q
           OR UniversityEmail LIKE @Q
        ORDER BY FullName ASC;
      `);

        return res.status(200).json({ users: result.recordset });
    } catch (err) {
        console.error('User search error:', err);
        return res.status(500).json({ message: 'Server error' });
    }
});



/* ========== CHAT CONVERSATIONS (for chat list) ========== */

app.get('/api/chat/conversations', async (req, res) => {
    const userId = parseInt(req.query.userId, 10);

    if (!userId) {
        return res.status(400).json({ message: 'userId is required' });
    }

    try {
        const pool = req.app.locals.db;

        const result = await pool
            .request()
            .input('UserId', sql.Int, userId)
            .query(`
        SELECT TOP 50
          u.UserId   AS OtherUserId,
          u.FullName AS OtherUserName,
          u.ProfileImageUrl,
          cm.Content AS LastMessage,
          cm.Timestamp AS LastMessageTime,
          0 AS UnreadCount
        FROM ChatMessages cm
        JOIN Users u
          ON (cm.SenderId = u.UserId AND cm.ReceiverId = @UserId)
          OR (cm.ReceiverId = u.UserId AND cm.SenderId = @UserId)
        WHERE u.UserId <> @UserId
        ORDER BY cm.Timestamp DESC;
      `);

        return res.status(200).json({ conversations: result.recordset });
    } catch (err) {
        console.error('Get conversations error:', err);
        return res.status(500).json({ message: 'Server error' });
    }
});

/* ========== START SERVER ========== */

app.listen(PORT, () => {
    console.log(`UniLink backend running on port ${PORT}`);
});
