# doctor_appointment_api

[![style: dart frog lint][dart_frog_lint_badge]][dart_frog_lint_link]
[![License: MIT][license_badge]][license_link]
[![Powered by Dart Frog](https://img.shields.io/endpoint?url=https://tinyurl.com/dartfrog-badge)](https://dart-frog.dev)

An example application built with dart_frog

## Development notes

The API initializes MongoDB before serving requests and provides the database,
email service, and authentication service through Dart Frog request context.
Verification and password-reset tokens are printed to the console by the
development email service. Replace `ConsoleEmailService` with a real email
provider before deploying.

Set a `JWT_SECRET` compile-time value containing at least 32 characters for
non-development environments. The built-in fallback is only for local
development.

[dart_frog_lint_badge]: https://img.shields.io/badge/style-dart_frog_lint-1DF9D2.svg
[dart_frog_lint_link]: https://pub.dev/packages/dart_frog_lint
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT