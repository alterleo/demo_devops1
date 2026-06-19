import pytest
from app.main import app


@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client


def test_hello_status_code(client):
    response = client.get('/')
    assert response.status_code == 200


def test_hello_contains_hostname(client):
    response = client.get('/')
    assert b'Hostname:' in response.data


def test_hello_contains_version(client):
    response = client.get('/')
    assert b'Ver. 1.0.' in response.data


def test_health_status_code(client):
    response = client.get('/health')
    assert response.status_code == 200


def test_health_json_structure(client):
    response = client.get('/health')
    json_data = response.get_json()
    assert json_data['status'] == 'healthy'