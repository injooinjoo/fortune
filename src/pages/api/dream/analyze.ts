import type { NextApiRequest, NextApiResponse } from 'next';
import { analyzeDream } from '@/ai/flows/analyze-dream';

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  if (req.method !== 'POST') {
    res.setHeader('Allow', 'POST');
    return res.status(405).end('Method Not Allowed');
  }

  const { dreamStory } = req.body || {};

  if (typeof dreamStory !== 'string' || !dreamStory.trim()) {
    return res.status(400).json({ error: 'Invalid dreamStory' });
  }

  try {
    const result = await analyzeDream({ dreamStory });
    res.status(200).json(result);
  } catch (e) {
    console.error('Dream analysis failed', e);
    res.status(500).json({ error: 'Internal Server Error' });
  }
}
