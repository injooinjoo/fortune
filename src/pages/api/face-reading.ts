import type { NextApiRequest, NextApiResponse } from 'next'
import { getFaceReadingAction } from '@/app/actions'

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') {
    res.status(405).json({ error: 'Method not allowed' })
    return
  }

  const labels = req.body?.labels
  if (!Array.isArray(labels)) {
    res.status(400).json({ error: 'Invalid labels' })
    return
  }

  const result = await getFaceReadingAction(labels)
  if (result.error || !result.data) {
    res.status(500).json({ error: result.error || 'Failed to generate interpretation' })
    return
  }

  res.status(200).json(result.data)
}
