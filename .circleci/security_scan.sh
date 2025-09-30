#!/bin/bash

# Enterprise Security Scanning Script
# This script performs comprehensive security checks on the Flutter application

set -e

echo "🔍 Starting Enterprise Security Scan..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Install security tools
echo "📦 Installing security scanning tools..."
dart pub global activate pana
dart pub global activate security_audit

# 1. Dependency Vulnerability Scanning
echo "🔒 Scanning for vulnerable dependencies..."
if flutter pub deps --json | dart pub global run security_audit; then
    print_status "No critical vulnerabilities found in dependencies"
else
    print_warning "Vulnerabilities detected in dependencies - review required"
fi

# 2. License Compliance Check
echo "📄 Checking license compliance..."
flutter pub deps --json > temp_dependencies.json
if [ -f temp_dependencies.json ]; then
    # Count GPL/AGPL licenses (often restricted in enterprise)
    RESTRICTED_LICENSES=$(grep -i "gpl\|agpl" temp_dependencies.json | wc -l || echo "0")
    if [ "$RESTRICTED_LICENSES" -gt 0 ]; then
        print_warning "Found $RESTRICTED_LICENSES potentially restricted licenses"
        echo "Please review these licenses for enterprise compliance"
    else
        print_status "No restricted licenses detected"
    fi
    rm temp_dependencies.json
fi

# 3. Code Quality Security Analysis
echo "🧹 Running security-focused code analysis..."
if flutter analyze --fatal-infos --fatal-warnings; then
    print_status "Code analysis passed"
else
    print_error "Code analysis failed - security issues detected"
    exit 1
fi

# 4. Check for Hardcoded Secrets
echo "🔑 Scanning for hardcoded secrets..."
SECRET_PATTERNS=(
    "password\s*=\s*['\"][^'\"]+['\"]"
    "api[_-]?key\s*[=:]\s*['\"][^'\"]+['\"]"
    "secret\s*[=:]\s*['\"][^'\"]+['\"]"
    "token\s*[=:]\s*['\"][^'\"]+['\"]"
    "-----BEGIN\s+(RSA\s+)?PRIVATE\s+KEY-----"
)

SECRETS_FOUND=0
for pattern in "${SECRET_PATTERNS[@]}"; do
    if grep -r -i -E "$pattern" lib/ --include="*.dart" > /dev/null 2>&1; then
        print_warning "Potential hardcoded secret found matching pattern: $pattern"
        SECRETS_FOUND=$((SECRETS_FOUND + 1))
    fi
done

if [ "$SECRETS_FOUND" -eq 0 ]; then
    print_status "No hardcoded secrets detected"
else
    print_warning "$SECRETS_FOUND potential hardcoded secrets found - manual review required"
fi

# 5. Network Security Configuration Check
echo "🌐 Checking network security configuration..."
if [ -f "android/app/src/main/res/xml/network_security_config.xml" ]; then
    print_status "Network security configuration found"
else
    print_warning "No network security configuration found - consider adding for production"
fi

# 6. Check for Debug Code in Production
echo "🐛 Scanning for debug code..."
DEBUG_PATTERNS=(
    "print\("
    "debugPrint\("
    "kDebugMode.*print"
    "flutter_logs"
)

DEBUG_FOUND=0
for pattern in "${DEBUG_PATTERNS[@]}"; do
    if grep -r -E "$pattern" lib/ --include="*.dart" > /dev/null 2>&1; then
        DEBUG_FOUND=$((DEBUG_FOUND + 1))
    fi
done

if [ "$DEBUG_FOUND" -eq 0 ]; then
    print_status "No debug statements found in production code"
else
    print_warning "$DEBUG_FOUND debug statements found - ensure they're properly gated"
fi

# 7. Permissions Audit (Android)
echo "📱 Auditing Android permissions..."
if [ -f "android/app/src/main/AndroidManifest.xml" ]; then
    SENSITIVE_PERMISSIONS=$(grep -c "android.permission\.\(CAMERA\|RECORD_AUDIO\|ACCESS_FINE_LOCATION\|READ_CONTACTS\|WRITE_EXTERNAL_STORAGE\)" android/app/src/main/AndroidManifest.xml || echo "0")
    if [ "$SENSITIVE_PERMISSIONS" -gt 0 ]; then
        print_warning "Found $SENSITIVE_PERMISSIONS sensitive permissions - ensure proper justification"
    else
        print_status "No sensitive permissions detected"
    fi
fi

# 8. Generate Security Report
echo "📊 Generating security report..."
REPORT_FILE="security_report.json"
cat > "$REPORT_FILE" << EOF
{
  "scan_timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "scan_type": "enterprise_security_audit",
  "results": {
    "dependency_vulnerabilities": "checked",
    "license_compliance": "checked",
    "code_analysis": "passed",
    "hardcoded_secrets": "$SECRETS_FOUND potential issues",
    "debug_code": "$DEBUG_FOUND occurrences",
    "network_security": "reviewed",
    "permissions_audit": "completed"
  },
  "recommendations": [
    "Review any flagged vulnerabilities",
    "Implement network security configuration",
    "Gate debug code with kDebugMode",
    "Use secure storage for sensitive data",
    "Regular dependency updates"
  ]
}
EOF

print_status "Security scan completed - report saved to $REPORT_FILE"
echo "🏁 Enterprise Security Scan Complete!"

exit 0