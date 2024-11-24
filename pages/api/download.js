import path from 'path';
import fs from 'fs';

const baseDownloadDirectory = path.join(process.cwd(), 'received_items');

export default async function handler(req, res) {
  if (req.method === 'GET') {
    const { folder = '', file } = req.query;

    if (!file) {
      return res.status(400).json({ error: 'File name is required' });
    }

    // Construct the file path
    const filePath = path.join(baseDownloadDirectory, folder, file);

    // Check if the file exists
    if (!fs.existsSync(filePath)) {
      return res.status(404).json({ error: 'File not found' });
    }

    // Set headers to prompt a download
    res.setHeader('Content-Disposition', `attachment; filename="${file}"`);
    res.setHeader('Content-Type', 'application/octet-stream');

    // Stream the file to the response
    const fileStream = fs.createReadStream(filePath);
    fileStream.pipe(res);
    fileStream.on('error', (error) => {
      res.status(500).json({ error: `Something went wrong: ${error.message}` });
    });
  } else {
    res.status(405).json({ error: `Method ${req.method} not allowed` });
  }
}
