import 'package:electricsql_cli/src/util/util.dart';
import 'package:test/test.dart';

void main() {
  test('buildDatabaseURL should compose valid URL', () {
    final url = buildDatabaseURL(
      user: 'admin',
      password: 'adminpass',
      host: '192.168.1.1',
      port: 3306,
      dbName: 'mydatabase',
    );

    expect(url, 'postgresql://admin:adminpass@192.168.1.1:3306/mydatabase');
  });

  test('buildDatabaseURL without password', () {
    final url = buildDatabaseURL(
      user: 'user',
      password: '',
      host: 'example.com',
      port: 5432,
      dbName: 'sampledb',
    );

    expect(url, 'postgresql://user@example.com:5432/sampledb');
  });

  test('buildDatabaseURL with complex password', () {
    final url = buildDatabaseURL(
      user: 'user',
      password: r'p@$$w0rd!',
      host: 'example.com',
      port: 5432,
      dbName: 'sampledb',
    );

    expect(url, r'postgresql://user:p%40$$w0rd!@example.com:5432/sampledb');
  });

  test('buildDatabaseURL without SSL', () {
    final url = buildDatabaseURL(
      user: 'testuser',
      password: 'testpass',
      host: 'localhost',
      port: 5432,
      dbName: 'testdb',
    );

    expect(url, 'postgresql://testuser:testpass@localhost:5432/testdb');
  });

  test('buildDatabaseURL with SSL required', () {
    final url = buildDatabaseURL(
      user: 'testuser',
      password: 'testpass',
      host: 'localhost',
      port: 5432,
      dbName: 'testdb',
      ssl: true,
    );

    expect(
      url,
      'postgresql://testuser:testpass@localhost:5432/testdb?sslmode=require',
    );
  });

  test('buildDatabaseURL with SSL disabled', () {
    final url = buildDatabaseURL(
      user: 'testuser',
      password: 'testpass',
      host: 'localhost',
      port: 5432,
      dbName: 'testdb',
      ssl: false,
    );

    expect(
      url,
      'postgresql://testuser:testpass@localhost:5432/testdb?sslmode=disable',
    );
  });
}
