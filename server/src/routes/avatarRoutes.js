import express from 'express';
import { AvatarController } from '../controllers/avatarController.js';

const router = express.Router();

router.get('/', AvatarController.fetch);
router.put('/', AvatarController.save);

export default router;
