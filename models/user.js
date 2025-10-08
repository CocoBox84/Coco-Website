const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  username: { type: String, required: true, unique: true, trim: true },
  email:    { type: String, required: true, unique: true, lowercase: true, trim: true },
  password: { type: String, required: true },
  role:     { type: String, default: 'user', enum: ['user', 'admin'] },

  // verification + password reset
  isVerified:         { type: Boolean, default: false },
  verificationToken:  { type: String },
  resetToken:         { type: String },
  resetTokenExpiry:   { type: Date }
}, { timestamps: true });

module.exports = mongoose.model('User', userSchema);
