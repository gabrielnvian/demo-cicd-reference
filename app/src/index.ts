import express, { Request, Response } from 'express';

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

app.get('/health', (_req: Request, res: Response) => {
  res.json({ status: 'ok', version: process.env.APP_VERSION || 'local' });
});

app.get('/', (_req: Request, res: Response) => {
  res.json({
    message: 'Hello from the CI/CD reference app!',
    environment: process.env.NODE_ENV || 'development',
    version: process.env.APP_VERSION || 'local',
  });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

export default app;
