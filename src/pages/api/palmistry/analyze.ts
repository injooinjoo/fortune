import type { NextApiRequest, NextApiResponse } from 'next';
import { generatePalmReading } from '@/ai/flows/generate-palm-reading';

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') {
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }

  try {
    const { labels } = req.body ?? {};
    if (!Array.isArray(labels)) {
      res.status(400).json({ error: 'Invalid labels' });
      return;
    }
    const result = await generatePalmReading({ labels });
    res.status(200).json(result);
  } catch (err) {
    console.error('Palmistry API error', err);
    res.status(500).json({ error: 'Failed to generate palm reading' });
  }
}
