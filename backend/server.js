require('dotenv').config();
const express = require('express');
const { MongoClient, ObjectId } = require('mongodb');
const cors = require('cors');
const multer = require('multer');
const path = require('path');
const crypto = require('crypto');

const app = express();

const PORT = process.env.PORT || 5000;
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/unilink';

// MongoDB connection
let db;
let client;
let isMongoConnected = false;

MongoClient.connect(MONGODB_URI)
    .then((mongoClient) => {
        client = mongoClient;
        db = mongoClient.db();
        isMongoConnected = true;
        console.log('✅ Connected to MongoDB');
        console.log(`📊 Database: ${db.databaseName}`);
        app.locals.db = db;
    })
    .catch((err) => {
        console.error('❌ MongoDB connection error:', err.message);
        console.error('💡 Make sure MongoDB is running or use MongoDB Atlas');
        console.error('💡 For local MongoDB: Install MongoDB Compass or MongoDB Server');
        console.error('💡 For cloud: Use MongoDB Atlas connection string');
        isMongoConnected = false;
    });

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

// Helper function to hash password
function hashPassword(password) {
    return crypto.createHash('sha256').update(password).digest('hex');
}

// Helper function to check MongoDB connection
function checkMongoConnection(req, res) {
    if (!isMongoConnected || !req.app.locals.db) {
        return res.status(503).json({ 
            message: 'Database not connected. Please check MongoDB connection.' 
        });
    }
    return null; // Connection OK
}

/* ========== AUTH ROUTES ========== */

// SIGNUP
app.post('/api/auth/signup', async (req, res) => {
    if (!isMongoConnected) {
        return res.status(503).json({ 
            message: 'Database not connected. Please check MongoDB connection.' 
        });
    }

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
        const db = req.app.locals.db;
        if (!db) {
            return res.status(503).json({ 
                message: 'Database not connected. Please check MongoDB connection.' 
            });
        }

        const usersCollection = db.collection('users');

        // Check for duplicates
        const existingUser = await usersCollection.findOne({
            $or: [
                { universityEmail: email },
                { studentId: studentId }
            ]
        });

        if (existingUser) {
            return res
                .status(409)
                .json({ message: 'Email or Student ID already registered' });
        }

        // Insert new user
        const newUser = {
            fullName: fullName,
            universityEmail: email,
            studentId: studentId,
            department: department,
            yearOfStudy: parseInt(yearOfStudy) || 1,
            passwordHash: hashPassword(password),
            createdAt: new Date(),
            profileImageUrl: null
        };

        const result = await usersCollection.insertOne(newUser);

        if (result.insertedId) {
            return res.status(201).json({ message: 'Account created successfully' });
        } else {
            return res.status(500).json({ message: 'Failed to create account' });
        }
    } catch (err) {
        console.error('Signup error:', err);
        return res.status(500).json({ 
            message: 'Server error: ' + (err.message || 'Unknown error'),
            error: process.env.NODE_ENV === 'development' ? err.stack : undefined
        });
    }
});

// LOGIN
app.post('/api/auth/login', async (req, res) => {
    if (!isMongoConnected) {
        return res.status(503).json({ 
            message: 'Database not connected. Please check MongoDB connection.' 
        });
    }

    const { email, password } = req.body;

    if (!email || !password) {
        return res
            .status(400)
            .json({ message: 'Email and password are required' });
    }

    try {
        const db = req.app.locals.db;
        if (!db) {
            return res.status(503).json({ 
                message: 'Database not connected. Please check MongoDB connection.' 
            });
        }

        const usersCollection = db.collection('users');

        // Try new schema first (universityEmail + passwordHash)
        const passwordHash = hashPassword(password);
        let user = await usersCollection.findOne({
            universityEmail: email,
            passwordHash: passwordHash
        });

        // If not found, try old schema (email + password with bcrypt)
        if (!user) {
            const bcrypt = require('bcrypt');
            user = await usersCollection.findOne({
                $or: [
                    { email: email },
                    { universityEmail: email }
                ]
            });

            if (user && user.password) {
                // Check bcrypt password
                const isValid = await bcrypt.compare(password, user.password);
                if (!isValid) {
                    user = null;
                }
            } else if (user && !user.passwordHash) {
                user = null;
            }
        }

        if (!user) {
            return res
                .status(401)
                .json({ message: 'Invalid email or password' });
        }

        // Return user data (handle both old and new schema)
        return res.status(200).json({
            message: 'Login successful',
            user: {
                id: user._id.toString(),
                name: user.fullName || user.name || '',
                email: user.universityEmail || user.email || '',
                studentId: user.studentId || '',
                department: user.department || '',
                yearOfStudy: user.yearOfStudy || 1,
                createdAt: user.createdAt || new Date(),
                profileImageUrl: user.profileImageUrl || null,
            },
        });
    } catch (err) {
        console.error('Login error:', err);
        return res.status(500).json({ 
            message: 'Server error: ' + (err.message || 'Unknown error'),
            error: process.env.NODE_ENV === 'development' ? err.stack : undefined
        });
    }
});

// FORGOT PASSWORD
app.post('/api/auth/forgot-password', async (req, res) => {
    const { email } = req.body;

    if (!email) {
        return res.status(400).json({ message: 'Email is required' });
    }

    try {
        const db = req.app.locals.db;
        const usersCollection = db.collection('users');

        const user = await usersCollection.findOne({
            universityEmail: email
        });

        if (!user) {
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
        const db = req.app.locals.db;
        const usersCollection = db.collection('users');

        const passwordHash = hashPassword(newPassword);
        const result = await usersCollection.updateOne(
            { universityEmail: email },
            { $set: { passwordHash: passwordHash } }
        );

        if (result.matchedCount === 0) {
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
        const dbCheck = checkMongoConnection(req, res);
        if (dbCheck) return dbCheck;

        const db = req.app.locals.db;
        
        // Try marketplaceItems first, fallback to listings
        let itemsCollection = db.collection('marketplaceItems');
        let testItems = await itemsCollection.find({}).limit(1).toArray();
        
        // If marketplaceItems is empty, try listings collection
        if (testItems.length === 0) {
            const listingsCollection = db.collection('listings');
            const testListings = await listingsCollection.find({}).limit(1).toArray();
            if (testListings.length > 0) {
                itemsCollection = listingsCollection;
            }
        }

        // Build query - don't filter by isActive if field doesn't exist
        let query = {};
        
        // Only add isActive filter if we know items have this field
        // Otherwise, get all items
        if (testItems.length > 0 || (await itemsCollection.findOne({ isActive: { $exists: true } }))) {
            query.isActive = { $ne: false };
        }
        
        if (category && category !== 'All') {
            query.category = category;
        }

        const items = await itemsCollection
            .find(query)
            .sort({ postedDate: -1 })
            .toArray();

        // Convert _id to string and map field names
        const formattedItems = items.map(item => ({
            ItemId: item._id.toString(),
            SellerId: item.sellerId,
            Title: item.title,
            Description: item.description,
            Price: item.price,
            ImageUrl: item.imageUrl || null,
            Category: item.category,
            Condition: item.condition,
            IsNegotiable: item.isNegotiable,
            IsActive: item.isActive,
            PostedDate: item.postedDate
        }));

        return res.status(200).json({ items: formattedItems });
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
        const dbCheck = checkMongoConnection(req, res);
        if (dbCheck) return dbCheck;

        const db = req.app.locals.db;
        const itemsCollection = db.collection('marketplaceItems');

        const newItem = {
            sellerId: sellerId,
            title: title,
            description: description,
            price: price,
            imageUrl: imageUrl || null,
            category: category,
            condition: condition,
            isNegotiable: isNegotiable ?? true,
            isActive: true,
            postedDate: new Date()
        };

        await itemsCollection.insertOne(newItem);

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
        const dbCheck = checkMongoConnection(req, res);
        if (dbCheck) return dbCheck;

        const db = req.app.locals.db;
        const messagesCollection = db.collection('messages');

        const newMessage = {
            itemId: itemId,
            buyerId: buyerId,
            sellerId: sellerId,
            messageText: messageText,
            createdAt: new Date()
        };

        await messagesCollection.insertOne(newMessage);

        return res.status(201).json({ message: 'Message created successfully' });
    } catch (err) {
        console.error('Create message error:', err);
        return res.status(500).json({ message: 'Server error' });
    }
});

/* ========== LIKES ROUTES ========== */

// Like/Unlike a post
app.post('/api/posts/:postId/like', async (req, res) => {
    const postId = req.params.postId;
    const { userId } = req.body;

    if (!postId || !userId) {
        return res.status(400).json({ message: 'postId and userId are required' });
    }

    try {
        const dbCheck = checkMongoConnection(req, res);
        if (dbCheck) return dbCheck;

        const db = req.app.locals.db;
        const likesCollection = db.collection('likes');
        const postsCollection = db.collection('posts');
        const notificationsCollection = db.collection('notifications');
        const usersCollection = db.collection('users');

        // Check if post exists - handle both ObjectId and string
        let post;
        try {
            post = await postsCollection.findOne({ _id: new ObjectId(postId) });
        } catch (e) {
            post = await postsCollection.findOne({ _id: postId });
        }
        if (!post) {
            return res.status(404).json({ message: 'Post not found' });
        }

        // Check if user already liked this post
        const existingLike = await likesCollection.findOne({
            postId: postId,
            userId: userId
        });

        if (existingLike) {
            // Unlike: Remove the like
            await likesCollection.deleteOne({ _id: existingLike._id });
            
            // Remove notification if exists
            await notificationsCollection.deleteMany({
                type: 'like',
                postId: postId,
                senderId: userId
            });

            // Get updated like count
            const likeCount = await likesCollection.countDocuments({ postId: postId });

            return res.status(200).json({
                message: 'Post unliked',
                isLiked: false,
                likeCount: likeCount
            });
        } else {
            // Like: Add the like
            await likesCollection.insertOne({
                postId: postId,
                userId: userId,
                createdAt: new Date()
            });

            // Create notification for post owner (if not liking own post)
            if (post.userId !== userId) {
                let liker;
                try {
                    liker = await usersCollection.findOne({ _id: new ObjectId(userId) });
                } catch (e) {
                    liker = await usersCollection.findOne({ _id: userId });
                }
                if (!liker) {
                    // Try finding by any field that might match
                    liker = await usersCollection.findOne({ 
                        $or: [
                            { _id: userId },
                            { userId: userId }
                        ]
                    });
                }
                await notificationsCollection.insertOne({
                    userId: post.userId,
                    type: 'like',
                    title: liker ? (liker.fullName || liker.name || 'Someone') : 'Someone',
                    body: 'liked your post',
                    senderId: userId,
                    senderName: liker ? (liker.fullName || liker.name) : null,
                    senderImage: liker ? liker.profileImageUrl : null,
                    postId: postId,
                    timestamp: new Date(),
                    isRead: false
                });
            }

            // Get updated like count
            const likeCount = await likesCollection.countDocuments({ postId: postId });

            return res.status(200).json({
                message: 'Post liked',
                isLiked: true,
                likeCount: likeCount
            });
        }
    } catch (err) {
        console.error('Like post error:', err);
        return res.status(500).json({ message: 'Server error: ' + err.message });
    }
});

// Get likes for a post
app.get('/api/posts/:postId/likes', async (req, res) => {
    const postId = req.params.postId;

    try {
        const dbCheck = checkMongoConnection(req, res);
        if (dbCheck) return dbCheck;

        const db = req.app.locals.db;
        const likesCollection = db.collection('likes');
        const usersCollection = db.collection('users');

        const likes = await likesCollection.find({ postId: postId }).toArray();
        const userIds = likes.map(l => l.userId);

        const users = await usersCollection.find({
            _id: { $in: userIds.map(id => {
                try {
                    return new ObjectId(id);
                } catch {
                    return id;
                }
            })}
        }).toArray();

        const userMap = {};
        users.forEach(u => {
            userMap[u._id.toString()] = u;
        });

        const formattedLikes = likes.map(like => {
            const user = userMap[like.userId] || {};
            return {
                userId: like.userId,
                userName: user.fullName || user.name || `User ${like.userId}`,
                userAvatar: user.profileImageUrl || null,
                createdAt: like.createdAt
            };
        });

        return res.status(200).json({ likes: formattedLikes, count: formattedLikes.length });
    } catch (err) {
        console.error('Get likes error:', err);
        return res.status(500).json({ message: 'Server error: ' + err.message });
    }
});

/* ========== COMMENTS ROUTES ========== */

app.post('/api/comments', async (req, res) => {
    const { postId, authorId, postOwnerId, commentText } = req.body;

    if (!postId || !authorId || !postOwnerId || !commentText) {
        return res.status(400).json({ message: 'Missing required fields' });
    }

    try {
        const dbCheck = checkMongoConnection(req, res);
        if (dbCheck) return dbCheck;

        const db = req.app.locals.db;
        const commentsCollection = db.collection('comments');
        const notificationsCollection = db.collection('notifications');
        const usersCollection = db.collection('users');

        const newComment = {
            postId: postId,
            authorId: authorId,
            postOwnerId: postOwnerId,
            commentText: commentText,
            createdAt: new Date()
        };

        const result = await commentsCollection.insertOne(newComment);

        // Create notification for post owner (if not commenting on own post)
        if (postOwnerId !== authorId) {
            let commenter;
            try {
                commenter = await usersCollection.findOne({ _id: new ObjectId(authorId) });
            } catch (e) {
                commenter = await usersCollection.findOne({ _id: authorId });
            }
            if (!commenter) {
                commenter = await usersCollection.findOne({ 
                    $or: [
                        { _id: authorId },
                        { userId: authorId }
                    ]
                });
            }
            await notificationsCollection.insertOne({
                userId: postOwnerId,
                type: 'comment',
                title: commenter ? (commenter.fullName || commenter.name || 'Someone') : 'Someone',
                body: commentText.length > 50 ? commentText.substring(0, 50) + '...' : commentText,
                senderId: authorId,
                senderName: commenter ? (commenter.fullName || commenter.name) : null,
                senderImage: commenter ? commenter.profileImageUrl : null,
                postId: postId,
                timestamp: new Date(),
                isRead: false
            });
        }

        return res.status(201).json({
            message: 'Comment saved',
            comment: {
                CommentId: result.insertedId.toString(),
                PostId: postId,
                AuthorId: authorId,
                PostOwnerId: postOwnerId,
                CommentText: commentText,
                CreatedAt: newComment.createdAt
            }
        });
    } catch (err) {
        console.error('Create comment error:', err);
        return res.status(500).json({ message: 'Server error: ' + err.message });
    }
});

app.get('/api/comments/:postId', async (req, res) => {
    const postId = req.params.postId;
    if (!postId) return res.status(400).json({ message: 'Invalid post id' });

    try {
        const dbCheck = checkMongoConnection(req, res);
        if (dbCheck) return dbCheck;

        const db = req.app.locals.db;
        const commentsCollection = db.collection('comments');
        const usersCollection = db.collection('users');

        const comments = await commentsCollection
            .find({ postId: postId })
            .sort({ createdAt: 1 })
            .toArray();

        // Get user info for all comment authors
        const authorIds = [...new Set(comments.map(c => c.authorId))];
        const users = await usersCollection.find({
            _id: { $in: authorIds.map(id => {
                try {
                    return new ObjectId(id);
                } catch {
                    return id;
                }
            })}
        }).toArray();

        const userMap = {};
        users.forEach(u => {
            userMap[u._id.toString()] = u;
        });

        // Format comments with user info
        const formattedComments = comments.map(comment => {
            const user = userMap[comment.authorId] || userMap[comment.authorId?.toString()] || {};
            return {
                CommentId: comment._id.toString(),
                PostId: comment.postId,
                AuthorId: comment.authorId,
                AuthorName: user.fullName || user.name || `User ${comment.authorId}`,
                AuthorAvatar: user.profileImageUrl || null,
                PostOwnerId: comment.postOwnerId,
                CommentText: comment.commentText,
                CreatedAt: comment.createdAt
            };
        });

        return res.status(200).json({ comments: formattedComments });
    } catch (err) {
        console.error('Get comments error:', err);
        return res.status(500).json({ message: 'Server error: ' + err.message });
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
        const dbCheck = checkMongoConnection(req, res);
        if (dbCheck) return dbCheck;

        const db = req.app.locals.db;
        const postsCollection = db.collection('posts');

        const newPost = {
            userId: userId,
            content: safeContent,
            mediaUrl: mediaUrl || null,
            mediaType: mediaType || null,
            privacy: privacy,
            createdAt: new Date()
        };

        await postsCollection.insertOne(newPost);

        return res.status(201).json({ message: 'Post created successfully' });
    } catch (err) {
        console.error('Create post error:', err);
        return res.status(500).json({ message: 'Server error' });
    }
});

/* ========== POSTS: GET (home feed) ========== */

app.get('/api/posts', async (req, res) => {
    const currentUserId = req.query.userId; // Optional: to check if user liked posts
    
    try {
        const dbCheck = checkMongoConnection(req, res);
        if (dbCheck) return dbCheck;

        const db = req.app.locals.db;
        const postsCollection = db.collection('posts');
        const usersCollection = db.collection('users');
        const likesCollection = db.collection('likes');
        const commentsCollection = db.collection('comments');

        const posts = await postsCollection
            .find({})
            .sort({ createdAt: -1 })
            .toArray();

        // Get all user IDs from posts
        const userIds = [...new Set(posts.map(p => p.userId))];
        const users = await usersCollection.find({
            _id: { $in: userIds.map(id => {
                try {
                    return new ObjectId(id);
                } catch {
                    return id;
                }
            })}
        }).toArray();
        
        const userMap = {};
        users.forEach(u => {
            userMap[u._id.toString()] = u;
            // Also map by userId if it's stored as string
            if (u._id) userMap[u._id.toString()] = u;
        });

        // Get like counts and check if current user liked each post
        const postIds = posts.map(p => p._id.toString());
        const likes = await likesCollection.find({
            postId: { $in: postIds }
        }).toArray();

        const likeCounts = {};
        const userLikedPosts = {};
        likes.forEach(like => {
            likeCounts[like.postId] = (likeCounts[like.postId] || 0) + 1;
            if (currentUserId && like.userId === currentUserId) {
                userLikedPosts[like.postId] = true;
            }
        });

        // Get comment counts
        const comments = await commentsCollection.find({
            postId: { $in: postIds }
        }).toArray();

        const commentCounts = {};
        comments.forEach(comment => {
            commentCounts[comment.postId] = (commentCounts[comment.postId] || 0) + 1;
        });

        // Format posts with user info and counts
        const formattedPosts = posts.map(post => {
            const postId = post._id.toString();
            const user = userMap[post.userId] || userMap[post.userId?.toString()] || {};
            
            return {
                PostId: postId,
                UserId: post.userId,
                UserName: user.fullName || user.name || `User ${post.userId}`,
                UserAvatar: user.profileImageUrl || null,
                Content: post.content || '',
                MediaUrl: post.mediaUrl,
                MediaType: post.mediaType,
                Privacy: post.privacy,
                CreatedAt: post.createdAt,
                LikeCount: likeCounts[postId] || 0,
                CommentCount: commentCounts[postId] || 0,
                IsLiked: currentUserId ? (userLikedPosts[postId] || false) : false
            };
        });

        return res.status(200).json({ posts: formattedPosts });
    } catch (err) {
        console.error('Get posts error:', err);
        return res.status(500).json({ message: 'Server error: ' + err.message });
    }
});

/* ========== NOTIFICATIONS: LIST ========== */

app.get('/api/notifications/:userId', async (req, res) => {
    const userId = req.params.userId;
    if (!userId) return res.status(400).json({ message: 'Invalid user id' });

    try {
        const dbCheck = checkMongoConnection(req, res);
        if (dbCheck) return dbCheck;

        const db = req.app.locals.db;
        const notificationsCollection = db.collection('notifications');

        // Try to find notifications by userId (as string or ObjectId)
        let notifications = await notificationsCollection
            .find({ userId: userId })
            .sort({ timestamp: -1 })
            .toArray();
        
        // If no notifications found, try with ObjectId
        if (notifications.length === 0) {
            try {
                notifications = await notificationsCollection
                    .find({ userId: new ObjectId(userId) })
                    .sort({ timestamp: -1 })
                    .toArray();
            } catch (e) {
                // userId is not a valid ObjectId, that's okay
            }
        }

        // Format notifications
        const formattedNotifications = notifications.map(notif => ({
            NotificationId: notif._id.toString(),
            UserId: notif.userId,
            Type: notif.type,
            Title: notif.title,
            Body: notif.body,
            SenderId: notif.senderId,
            SenderName: notif.senderName,
            SenderImage: notif.senderImage,
            PostId: notif.postId,
            ItemId: notif.itemId,
            Timestamp: notif.timestamp,
            IsRead: notif.isRead
        }));

        return res.status(200).json({ notifications: formattedNotifications });
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
        const dbCheck = checkMongoConnection(req, res);
        if (dbCheck) return dbCheck;

        const db = req.app.locals.db;
        const notificationsCollection = db.collection('notifications');

        const result = await notificationsCollection.updateOne(
            { _id: new ObjectId(notificationId) },
            { $set: { isRead: true } }
        );

        if (result.matchedCount === 0) {
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
    const userId = req.params.userId;
    if (!userId) return res.status(400).json({ message: 'Invalid user id' });

    try {
        const dbCheck = checkMongoConnection(req, res);
        if (dbCheck) return dbCheck;

        const db = req.app.locals.db;
        const notificationsCollection = db.collection('notifications');

        const count = await notificationsCollection.countDocuments({
            userId: userId,
            isRead: false
        });

        return res.status(200).json({ unreadCount: count });
    } catch (err) {
        console.error('Get unread notifications count error:', err);
        return res.status(500).json({ message: 'Server error' });
    }
});

/* ========== CHAT MESSAGES (ChatMessages table) ========== */

// Get all messages between two users (1-to-1)
app.get('/api/chat/messages', async (req, res) => {
    const user1 = req.query.user1;
    const user2 = req.query.user2;

    if (!user1 || !user2) {
        return res
            .status(400)
            .json({ message: 'user1 and user2 are required' });
    }

    try {
        const dbCheck = checkMongoConnection(req, res);
        if (dbCheck) return dbCheck;

        const db = req.app.locals.db;
        const chatMessagesCollection = db.collection('chatMessages');

        const messages = await chatMessagesCollection
            .find({
                $or: [
                    { senderId: user1, receiverId: user2 },
                    { senderId: user2, receiverId: user1 }
                ]
            })
            .sort({ timestamp: 1 })
            .toArray();

        // Format messages
        const formattedMessages = messages.map(msg => ({
            MessageId: msg._id.toString(),
            SenderId: msg.senderId,
            ReceiverId: msg.receiverId,
            Content: msg.content,
            Timestamp: msg.timestamp,
            IsRead: msg.isRead
        }));

        return res.status(200).json({ messages: formattedMessages });
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
        const dbCheck = checkMongoConnection(req, res);
        if (dbCheck) return dbCheck;

        const db = req.app.locals.db;
        const chatMessagesCollection = db.collection('chatMessages');
        const usersCollection = db.collection('users');
        const notificationsCollection = db.collection('notifications');

        // 1) Insert chat message
        const newMessage = {
            senderId: senderId,
            receiverId: receiverId,
            content: content,
            timestamp: new Date(),
            isRead: false
        };

        const msgResult = await chatMessagesCollection.insertOne(newMessage);
        const chatMessage = {
            MessageId: msgResult.insertedId.toString(),
            SenderId: senderId,
            ReceiverId: receiverId,
            Content: content,
            Timestamp: newMessage.timestamp,
            IsRead: false
        };

        // 2) Get sender's display info
        const sender = await usersCollection.findOne({ _id: new ObjectId(senderId) });
        const senderName = sender ? sender.fullName : 'Unknown';
        const senderImage = sender ? sender.profileImageUrl : null;

        // 3) Insert notification for receiver
        const notification = {
            userId: receiverId,
            type: 'message',
            title: senderName,
            body: content.substring(0, 120),
            senderId: senderId,
            senderName: senderName,
            senderImage: senderImage,
            timestamp: new Date(),
            isRead: false
        };

        await notificationsCollection.insertOne(notification);

        return res.status(201).json({
            message: 'Message sent',
            chatMessage: chatMessage,
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
        const dbCheck = checkMongoConnection(req, res);
        if (dbCheck) return dbCheck;

        const db = req.app.locals.db;
        const usersCollection = db.collection('users');

        const users = await usersCollection
            .find({
                $or: [
                    { fullName: { $regex: q, $options: 'i' } },
                    { universityEmail: { $regex: q, $options: 'i' } }
                ]
            })
            .limit(20)
            .sort({ fullName: 1 })
            .toArray();

        // Format users
        const formattedUsers = users.map(user => ({
            UserId: user._id.toString(),
            FullName: user.fullName,
            UniversityEmail: user.universityEmail,
            ProfileImageUrl: user.profileImageUrl || null
        }));

        return res.status(200).json({ users: formattedUsers });
    } catch (err) {
        console.error('User search error:', err);
        return res.status(500).json({ message: 'Server error' });
    }
});

/* ========== CHAT CONVERSATIONS (for chat list) ========== */

app.get('/api/chat/conversations', async (req, res) => {
    const userId = req.query.userId;

    if (!userId) {
        return res.status(400).json({ message: 'userId is required' });
    }

    try {
        const dbCheck = checkMongoConnection(req, res);
        if (dbCheck) return dbCheck;

        const db = req.app.locals.db;
        const chatMessagesCollection = db.collection('chatMessages');
        const usersCollection = db.collection('users');

        // Get all messages involving this user
        const messages = await chatMessagesCollection
            .find({
                $or: [
                    { senderId: userId },
                    { receiverId: userId }
                ]
            })
            .sort({ timestamp: -1 })
            .limit(50)
            .toArray();

        // Get unique other users and their last message
        const conversationsMap = new Map();
        for (const msg of messages) {
            const otherUserId = msg.senderId === userId ? msg.receiverId : msg.senderId;
            if (!conversationsMap.has(otherUserId)) {
                conversationsMap.set(otherUserId, msg);
            }
        }

        // Get user details for each conversation
        const conversations = [];
        for (const [otherUserId, lastMessage] of conversationsMap) {
            try {
                let otherUser;
                try {
                    otherUser = await usersCollection.findOne({ _id: new ObjectId(otherUserId) });
                } catch (e) {
                    otherUser = await usersCollection.findOne({ _id: otherUserId });
                }
                if (!otherUser) {
                    // Try finding by any matching field
                    otherUser = await usersCollection.findOne({
                        $or: [
                            { _id: otherUserId },
                            { userId: otherUserId }
                        ]
                    });
                }
                if (otherUser) {
                    conversations.push({
                        OtherUserId: otherUser._id ? otherUser._id.toString() : otherUserId,
                        OtherUserName: otherUser.fullName || otherUser.name || `User ${otherUserId}`,
                        ProfileImageUrl: otherUser.profileImageUrl || null,
                        LastMessage: lastMessage.content || '',
                        LastMessageTime: lastMessage.timestamp || lastMessage.createdAt || new Date(),
                        UnreadCount: 0
                    });
                }
            } catch (err) {
                console.error('Error getting user for conversation:', err);
                // Skip invalid user IDs but still add conversation
                conversations.push({
                    OtherUserId: otherUserId,
                    OtherUserName: `User ${otherUserId}`,
                    ProfileImageUrl: null,
                    LastMessage: lastMessage.content || '',
                    LastMessageTime: lastMessage.timestamp || new Date(),
                    UnreadCount: 0
                });
            }
        }

        return res.status(200).json({ conversations: conversations });
    } catch (err) {
        console.error('Get conversations error:', err);
        return res.status(500).json({ message: 'Server error' });
    }
});

/* ========== SETTINGS ROUTES ========== */

// Update notification settings
app.post('/api/settings/notifications', async (req, res) => {
    const { userId, enabled } = req.body;

    if (!userId || typeof enabled !== 'boolean') {
        return res.status(400).json({ message: 'userId and enabled are required' });
    }

    try {
        const dbCheck = checkMongoConnection(req, res);
        if (dbCheck) return dbCheck;

        const db = req.app.locals.db;
        const usersCollection = db.collection('users');

        // Update user's notification settings
        let result;
        try {
            result = await usersCollection.updateOne(
                { _id: new ObjectId(userId) },
                { $set: { notificationEnabled: enabled } }
            );
        } catch (e) {
            result = await usersCollection.updateOne(
                { _id: userId },
                { $set: { notificationEnabled: enabled } }
            );
        }

        if (result.matchedCount === 0) {
            return res.status(404).json({ message: 'User not found' });
        }

        return res.status(200).json({ 
            message: 'Notification settings updated',
            enabled: enabled
        });
    } catch (err) {
        console.error('Update notification settings error:', err);
        return res.status(500).json({ message: 'Server error: ' + err.message });
    }
});

// Get user settings
app.get('/api/settings/:userId', async (req, res) => {
    const userId = req.params.userId;

    try {
        const dbCheck = checkMongoConnection(req, res);
        if (dbCheck) return dbCheck;

        const db = req.app.locals.db;
        const usersCollection = db.collection('users');

        let user;
        try {
            user = await usersCollection.findOne({ _id: new ObjectId(userId) });
        } catch (e) {
            user = await usersCollection.findOne({ _id: userId });
        }

        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        return res.status(200).json({
            notificationEnabled: user.notificationEnabled !== false, // default to true
            privacy: user.privacy || 'public'
        });
    } catch (err) {
        console.error('Get settings error:', err);
        return res.status(500).json({ message: 'Server error: ' + err.message });
    }
});

/* ========== START SERVER ========== */

app.listen(PORT, '0.0.0.0', () => {
    console.log(`UniLink backend running on port ${PORT}`);
    console.log(`MongoDB URI: ${MONGODB_URI}`);
});

// Graceful shutdown
process.on('SIGINT', async () => {
    if (client) {
        await client.close();
        console.log('MongoDB connection closed');
    }
    process.exit(0);
});
