import request from 'supertest';
import app from '../index';

// supertest is a dev dependency — add it if running tests for real
// npm install --save-dev supertest @types/supertest

describe('GET /health', () => {
  it('returns 200 with status ok', async () => {
    const res = await (request(app) as any).get('/health');
    expect(res.status).toBe(200);
    expect(res.body.status).toBe('ok');
  });
});

describe('GET /', () => {
  it('returns hello message', async () => {
    const res = await (request(app) as any).get('/');
    expect(res.status).toBe(200);
    expect(res.body.message).toContain('Hello');
  });
});
