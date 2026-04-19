import app from '../index';

describe('app', () => {
  it('exports an express instance with a request handler', () => {
    expect(app).toBeDefined();
    expect(typeof app).toBe('function');
  });

  it('sanity: arithmetic still works', () => {
    expect(1 + 1).toBe(2);
  });
});
