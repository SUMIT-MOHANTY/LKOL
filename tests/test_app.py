import unittest
import json
from app import app

class TestApp(unittest.TestCase):
    def setUp(self):
        self.app = app.test_client()
        self.app.testing = True

    def test_home_status_code(self):
        response = self.app.get('/')
        self.assertEqual(response.status_code, 200)

    def test_health_endpoint(self):
        response = self.app.get('/api/health')
        data = json.loads(response.data)
        self.assertEqual(response.status_code, 200)
        self.assertEqual(data['status'], 'healthy')

    def test_echo_endpoint(self):
        test_data = {'message': 'Hello, world!'}
        response = self.app.post('/api/echo',
                                json=test_data,
                                content_type='application/json')
        data = json.loads(response.data)
        self.assertEqual(response.status_code, 200)
        self.assertEqual(data['message'], 'Hello, world!')

if __name__ == '__main__':
    unittest.main()
