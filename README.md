# Enterprise Flutter App

A comprehensive enterprise-level Flutter application with CircleCI CI/CD pipeline, automated testing, security scanning, and deployment strategies.

## 🏗️ Architecture

This project follows Clean Architecture principles with a feature-based structure:

```
lib/
├── core/                 # Core functionality
│   ├── constants/        # App constants
│   ├── utils/           # Utility functions
│   ├── services/        # Core services
│   ├── network/         # Network layer
│   └── security/        # Security utilities
├── features/            # Feature modules
│   ├── auth/           # Authentication feature
│   ├── dashboard/      # Dashboard feature
│   ├── profile/        # User profile feature
│   └── settings/       # App settings feature
└── shared/             # Shared components
    ├── widgets/        # Reusable widgets
    ├── themes/         # App themes
    └── localization/   # Internationalization
```

## 🚀 Quick Start

### Prerequisites

- Flutter SDK (3.19.6 or later)
- Dart SDK (3.3.0 or later)
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd circleci
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate code:**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```

## 🧪 Testing

This project includes comprehensive testing at multiple levels:

### Unit Tests
```bash
flutter test test/unit/
```

### Widget Tests
```bash
flutter test test/widget/
```

### Integration Tests
```bash
flutter test test/integration/
```

### Code Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## 🔍 Code Quality

### Static Analysis
```bash
flutter analyze
```

### Code Formatting
```bash
flutter format .
```

### Import Sorting
```bash
flutter pub run import_sorter:main
```

## 🔒 Security

### Security Scanning
Run the comprehensive security scan:
```bash
./.circleci/security_scan.sh
```

### Features
- Network security configuration
- Certificate pinning (production)
- ProGuard obfuscation
- Hardcoded secrets detection
- Dependency vulnerability scanning

## 🚀 CI/CD Pipeline

### CircleCI Configuration

The pipeline includes:
- **Code Quality**: Linting, formatting, static analysis
- **Security Scanning**: Vulnerability detection, license compliance
- **Testing**: Unit, widget, and integration tests
- **Building**: Android APK and App Bundle generation
- **Deployment**: Multi-environment deployment strategy

### Workflows

1. **Development Workflow** (feature branches)
   - Code quality checks
   - Security scanning
   - Unit and widget tests

2. **Staging Workflow** (develop branch)
   - Full test suite including integration tests
   - Build artifacts
   - Deploy to staging environment

3. **Production Workflow** (main branch/tags)
   - Complete validation pipeline
   - Manual approval gate
   - Production deployment with staged rollout

4. **Nightly Workflow**
   - Scheduled security scans
   - Comprehensive testing
   - Performance benchmarks

### Environment Variables

Set these in your CircleCI project settings:

#### Required for all environments:
- `FIREBASE_TOKEN`: Firebase CLI token
- `CODECOV_TOKEN`: Codecov upload token

#### Development:
- `FIREBASE_APP_ID_ANDROID`: Firebase App Distribution ID

#### Staging:
- `GOOGLE_PLAY_SERVICE_ACCOUNT`: Google Play service account JSON

#### Production:
- `GOOGLE_PLAY_SERVICE_ACCOUNT`: Google Play service account JSON
- `APPLE_APP_STORE_CONNECT_API_KEY`: App Store Connect API key

#### Optional:
- `SLACK_WEBHOOK_URL`: Slack notifications
- `SONARQUBE_TOKEN`: SonarQube integration
- `SNYK_TOKEN`: Snyk security scanning

## 🌍 Environment Configuration

The app supports multiple environments:

### Development (`environments/dev.env`)
- Debug logging enabled
- Relaxed security settings
- Development API endpoints

### Staging (`environments/staging.env`)
- Production-like configuration
- Enhanced security
- Staging API endpoints

### Production (`environments/production.env`)
- Maximum security settings
- Production API endpoints
- Performance optimizations

## 📱 Deployment

### Development Deployment
```bash
./.circleci/deploy.sh dev
```

### Staging Deployment
```bash
./.circleci/deploy.sh staging
```

### Production Deployment
```bash
./.circleci/deploy.sh production
```

## 📊 Monitoring & Reporting

### Quality Gates
- Minimum 80% code coverage
- Zero critical security vulnerabilities
- Build time under 45 minutes
- Maximum 10 code smells

### Notifications
- Slack integration for build status
- Email alerts for critical issues
- JIRA ticket creation for quality gate failures

### Dashboards
- Build overview and trends
- Security vulnerability tracking
- Code quality metrics
- Test stability reports

## 🛠️ Development Guidelines

### Code Style
- Follow Dart/Flutter best practices
- Use `prefer_const_constructors` and trailing commas
- Maintain high test coverage (>80%)
- Document public APIs

### Git Workflow
- `main`: Production-ready code
- `develop`: Integration branch for features
- `feature/*`: Individual feature development
- `hotfix/*`: Critical production fixes

### Pull Request Process
1. Create feature branch from `develop`
2. Implement changes with tests
3. Ensure all CI checks pass
4. Request code review
5. Merge to `develop` after approval

## 📚 Dependencies

### Core Dependencies
- `flutter_bloc`: State management
- `dio`: HTTP client
- `flutter_secure_storage`: Secure data storage
- `get_it`: Dependency injection
- `equatable`: Value equality

### Development Dependencies
- `mockito`: Mocking for tests
- `bloc_test`: BLoC testing utilities
- `very_good_analysis`: Enhanced linting rules
- `build_runner`: Code generation

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Support

For questions or issues:
- Create a GitHub issue
- Contact the development team
- Check the documentation in `/docs`

## 🚀 Roadmap

- [ ] iOS CI/CD pipeline implementation
- [ ] Advanced monitoring with custom metrics
- [ ] Automated performance testing
- [ ] Multi-language support
- [ ] Advanced security features
- [ ] Offline synchronization

---

Built with ❤️ by the Enterprise Development Team
