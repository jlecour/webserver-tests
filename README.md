# Test Driven (web) Configuration

It's tedious and error prone to manually test the web server configuration (redirections, cache directives, SSL …) so I've tried to the usual "Test Driven" dance, in Ruby.

This is a completely blank Rails app (4.2.1) with a test suite using 

- [Minitest](https://github.com/seattlerb/minitest),
- [Mechanize](https://github.com/sparklemotion/mechanize),
- [OpenSSL](https://github.com/openssl/openssl),
- [Cipherscan](https://github.com/jvehent/cipherscan/),
- [check_ssl_cert](https://trac.id.ethz.ch/projects/nagios_plugins/wiki/check_ssl_cert)

It's not tied to Rails at all, it's just an example of how it can be included in a Rails project.

To run the test suite :

1. replace `example.com` with your domain in the test files (`test/webserver/*_test.rb`) and in `test/support/webserver_helper.rb`
2. execute `bundle exec rake test:webserver` or `bundle exec guard`

You can set `WEBSERVER_ENV` to run the suite against a specific environment. I've been using **production** (default), **staging** or **development**, but you can change/add as many as you want.