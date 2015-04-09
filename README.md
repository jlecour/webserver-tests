# Test Driven (web) Configuration

It's tedious and error prone to manually test the web server configuration (redirections, cache directives, SSL …) so I've tried to the usual "Test Driven" dance, in Ruby.

The tools in use :

- [Minitest](https://github.com/seattlerb/minitest),
- [Mechanize](https://github.com/sparklemotion/mechanize),
- [OpenSSL](https://github.com/openssl/openssl),
- [Cipherscan](https://github.com/jvehent/cipherscan/),
- [check_ssl_cert](https://trac.id.ethz.ch/projects/nagios_plugins/wiki/check_ssl_cert)

To run the test suite :

1. replace `example.com` with your domain in the test files (`test/webserver/*_test.rb`) and in `test/support/webserver_helper.rb`
2. execute `bundle exec rake test:webserver` or `bundle exec guard`

You can set `WEBSERVER_ENV` to run the suite against a specific environment. I've been using **production** (default), **staging** or **development**, but you can change/add as many as you want.

## FAQ

### 1. How is it "test driven"?

If you know in advance how you want your web app and web server to behave (regarding redirections, cache headers, cookies, SSL configuration …) you can prepare you test suite, let it fail and drive your configuration with them.

### 2. Why didn't you use X?

If you know a better tool or a better way to test those things, I'd be happy to improve.