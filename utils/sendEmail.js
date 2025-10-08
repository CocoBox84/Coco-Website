// utils/sendEmail.js
const nodemailer = require('nodemailer');

async function sendEmail(to, subject, html) {
  const transporter = nodemailer.createTransport({
    host: process.env.SMTP_HOST, // e.g. "smtp.gmail.com"
    port: process.env.SMTP_PORT, // e.g. 465 for SSL
    secure: true, // true for port 465, false for others
    auth: {
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASS
    }
  });

  await transporter.sendMail({
    from: `"Coco Website" <${process.env.SMTP_USER}>`,
    to,
    subject,
    html
  });
}

module.exports = sendEmail;
