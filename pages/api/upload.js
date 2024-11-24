import multer from 'multer';
import path from 'path';
import fs from 'fs';

// Base directory for uploads
const baseUploadDirectory = path.join(process.cwd(), 'received_items');

// Configure multer to dynamically set the destination based on query parameter
const upload = multer({
  storage: multer.diskStorage({
    destination: (req, file, cb) => {
      const folder = req.query.folder || ''; // Get folder from query or use empty string
      const uploadDirectory = path.join(baseUploadDirectory, folder);

      // Ensure the directory exists
      if (!fs.existsSync(uploadDirectory)) {
        fs.mkdirSync(uploadDirectory, { recursive: true });
      }

      cb(null, uploadDirectory);
    },
    filename: (req, file, cb) => cb(null, `${file.originalname}`),
  }),
});

// Helper function to handle multer as a promise-based middleware
const runMiddleware = (req, res, fn) => {
  return new Promise((resolve, reject) => {
    fn(req, res, (result) => {
      if (result instanceof Error) {
        return reject(result);
      }
      return resolve(result);
    });
  });
};

export const config = {
  api: {
    bodyParser: false, // Disable the default body parser for file uploads
  },
};

export default async function handler(req, res) {
  if (req.method === 'POST') {
    try {
      await runMiddleware(req, res, upload.single('file')); // Process the file upload
      
      // Log the file name
      console.log(`Received file: ${req.file.originalname}`);

      res.status(200).json({ message: 'File uploaded successfully' });
    } catch (error) {
      res.status(500).json({ error: `Something went wrong: ${error.message}` });
    }
  } else {
    res.status(405).json({ error: `Method ${req.method} not allowed` });
  }
}