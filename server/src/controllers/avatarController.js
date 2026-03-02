import { getAvatarConfig, saveAvatarConfig } from '../services/avatarService.js';

function extractToken(req) {
  const auth = req.headers.authorization || '';
  if (auth.toLowerCase().startsWith('bearer ')) {
    return auth.slice(7);
  }
  return req.body?.firebaseIdToken || null;
}

export class AvatarController {
  static async fetch(req, res, next) {
    try {
      const firebaseIdToken = extractToken(req);
      const result = await getAvatarConfig(firebaseIdToken);
      res.status(200).json({ success: true, config: result.config, userId: result.userId });
    } catch (error) {
      next(error);
    }
  }

  static async save(req, res, next) {
    try {
      const firebaseIdToken = extractToken(req);
      const config = req.body?.config;
      if (!config) {
        return res.status(400).json({ error: 'config is required' });
      }
      const result = await saveAvatarConfig(firebaseIdToken, config);
      res.status(200).json({ success: true, userId: result.userId });
    } catch (error) {
      next(error);
    }
  }
}
