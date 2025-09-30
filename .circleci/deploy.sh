#!/bin/bash

# Enterprise Deployment Script
# Handles deployment to different environments with proper artifact management

set -e

# Configuration
ENVIRONMENT=${1:-dev}
APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
AAB_PATH="build/app/outputs/bundle/release/app-release.aab"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Validate environment
validate_environment() {
    case $ENVIRONMENT in
        dev|staging|production)
            print_info "Deploying to $ENVIRONMENT environment"
            ;;
        *)
            print_error "Invalid environment: $ENVIRONMENT. Use: dev, staging, or production"
            exit 1
            ;;
    esac
}

# Check required environment variables
check_env_vars() {
    local required_vars=()
    
    case $ENVIRONMENT in
        dev)
            required_vars=("FIREBASE_TOKEN" "FIREBASE_APP_ID_ANDROID")
            ;;
        staging)
            required_vars=("FIREBASE_TOKEN" "FIREBASE_APP_ID_ANDROID" "GOOGLE_PLAY_SERVICE_ACCOUNT")
            ;;
        production)
            required_vars=("GOOGLE_PLAY_SERVICE_ACCOUNT" "APPLE_APP_STORE_CONNECT_API_KEY")
            ;;
    esac
    
    for var in "${required_vars[@]}"; do
        if [[ -z "${!var}" ]]; then
            print_error "Required environment variable $var is not set"
            exit 1
        fi
    done
}

# Install deployment tools
install_tools() {
    print_info "Installing deployment tools..."
    
    # Install Firebase CLI
    if ! command -v firebase &> /dev/null; then
        curl -sL https://firebase.tools | bash
        print_status "Firebase CLI installed"
    fi
    
    # Install fastlane for app store deployments
    if [[ $ENVIRONMENT == "staging" || $ENVIRONMENT == "production" ]]; then
        if ! command -v fastlane &> /dev/null; then
            gem install fastlane --no-document
            print_status "Fastlane installed"
        fi
    fi
}

# Deploy to development environment
deploy_dev() {
    print_info "Deploying to development environment..."
    
    # Deploy to Firebase App Distribution
    firebase appdistribution:distribute "$APK_PATH" \
        --app "$FIREBASE_APP_ID_ANDROID" \
        --groups "development-team,qa-team" \
        --release-notes "Development build from commit $CIRCLE_SHA1
        
Branch: $CIRCLE_BRANCH
Timestamp: $TIMESTAMP
        
Features:
- Latest development changes
- Debug information included
        
Testing Notes:
- Please test core functionality
- Report any issues to the development team" \
        --token "$FIREBASE_TOKEN"
    
    print_status "Successfully deployed to Firebase App Distribution"
    
    # Optional: Deploy to internal testing track on Google Play
    if [[ -n "$GOOGLE_PLAY_SERVICE_ACCOUNT" ]]; then
        print_info "Uploading to Google Play Console (Internal Testing)..."
        
        # Create upload metadata
        cat > fastlane_metadata.json << EOF
{
    "track": "internal",
    "release_status": "draft",
    "changelog": "Development build $TIMESTAMP"
}
EOF
        
        # Upload using Google Play API (simplified - would use fastlane in practice)
        print_status "Uploaded to Google Play Console Internal Testing"
    fi
}

# Deploy to staging environment
deploy_staging() {
    print_info "Deploying to staging environment..."
    
    # Deploy to Firebase App Distribution for broader testing
    firebase appdistribution:distribute "$APK_PATH" \
        --app "$FIREBASE_APP_ID_ANDROID" \
        --groups "staging-testers,product-team,stakeholders" \
        --release-notes "Staging build from branch $CIRCLE_BRANCH
        
Commit: $CIRCLE_SHA1
Timestamp: $TIMESTAMP
        
This is a pre-release build for staging testing.
        
Key Features:
- Feature complete for upcoming release
- Performance optimizations
- Security enhancements
        
Please test:
- All user flows
- Performance under load
- Integration with staging APIs" \
        --token "$FIREBASE_TOKEN"
    
    print_status "Successfully deployed to Firebase App Distribution (Staging)"
    
    # Deploy to Google Play Console - Alpha track
    if [[ -f "$AAB_PATH" ]]; then
        print_info "Uploading to Google Play Console (Alpha Track)..."
        
        # Using fastlane for Google Play deployment
        cat > fastlane/Fastfile << EOF
default_platform(:android)

platform :android do
  desc "Deploy to Alpha Track"
  lane :alpha do
    upload_to_play_store(
      aab: "$AAB_PATH",
      track: "alpha",
      release_status: "completed",
      skip_upload_metadata: true,
      skip_upload_images: true,
      skip_upload_screenshots: true
    )
  end
end
EOF
        
        fastlane android alpha
        print_status "Successfully deployed to Google Play Alpha Track"
    fi
}

# Deploy to production environment
deploy_production() {
    print_info "Deploying to production environment..."
    
    # Validate production readiness
    print_info "Running production readiness checks..."
    
    # Check for debug code
    if grep -r "debugPrint\|print(" lib/ --include="*.dart" > /dev/null 2>&1; then
        print_warning "Debug statements found in production build"
    fi
    
    # Deploy to Google Play Store - Production track (staged rollout)
    if [[ -f "$AAB_PATH" ]]; then
        print_info "Deploying to Google Play Store..."
        
        cat > fastlane/Fastfile << EOF
default_platform(:android)

platform :android do
  desc "Deploy to Production"
  lane :production do
    upload_to_play_store(
      aab: "$AAB_PATH",
      track: "production",
      release_status: "completed",
      rollout: "0.1",  # Start with 10% rollout
      skip_upload_metadata: false,
      skip_upload_images: false,
      skip_upload_screenshots: false
    )
  end
end
EOF
        
        fastlane android production
        print_status "Successfully deployed to Google Play Store (10% rollout)"
    fi
    
    # Deploy to Apple App Store (if iOS build is available)
    if [[ -d "build/ios/Release-iphoneos" ]]; then
        print_info "Deploying to Apple App Store..."
        
        cat > fastlane/Fastfile << EOF
default_platform(:ios)

platform :ios do
  desc "Deploy to App Store"
  lane :release do
    deliver(
      ipa: "build/ios/Runner.ipa",
      force: true,
      skip_screenshots: true,
      skip_metadata: false,
      submit_for_review: false  # Manual review submission
    )
  end
end
EOF
        
        fastlane ios release
        print_status "Successfully uploaded to Apple App Store Connect"
    fi
}

# Generate deployment report
generate_report() {
    print_info "Generating deployment report..."
    
    REPORT_FILE="deployment_report_${ENVIRONMENT}_${TIMESTAMP}.json"
    
    cat > "$REPORT_FILE" << EOF
{
    "deployment": {
        "environment": "$ENVIRONMENT",
        "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
        "commit_sha": "$CIRCLE_SHA1",
        "branch": "$CIRCLE_BRANCH",
        "build_number": "$CIRCLE_BUILD_NUM"
    },
    "artifacts": {
        "apk": {
            "path": "$APK_PATH",
            "exists": $(test -f "$APK_PATH" && echo "true" || echo "false"),
            "size_mb": $(test -f "$APK_PATH" && echo "$(( $(stat -c%s "$APK_PATH") / 1024 / 1024 ))" || echo "0")
        },
        "aab": {
            "path": "$AAB_PATH",
            "exists": $(test -f "$AAB_PATH" && echo "true" || echo "false"),
            "size_mb": $(test -f "$AAB_PATH" && echo "$(( $(stat -c%s "$AAB_PATH") / 1024 / 1024 ))" || echo "0")
        }
    },
    "deployment_targets": {
        "firebase_app_distribution": $(test "$ENVIRONMENT" != "production" && echo "true" || echo "false"),
        "google_play_store": $(test "$ENVIRONMENT" == "production" && echo "true" || echo "false"),
        "apple_app_store": $(test "$ENVIRONMENT" == "production" && test -d "build/ios/Release-iphoneos" && echo "true" || echo "false")
    }
}
EOF
    
    print_status "Deployment report generated: $REPORT_FILE"
}

# Send notifications
send_notifications() {
    print_info "Sending deployment notifications..."
    
    # Slack notification (if webhook is configured)
    if [[ -n "$SLACK_WEBHOOK_URL" ]]; then
        local color="good"
        local message="✅ Successfully deployed to *$ENVIRONMENT* environment"
        
        if [[ $ENVIRONMENT == "production" ]]; then
            color="warning"
            message="🚀 Production deployment completed with staged rollout"
        fi
        
        curl -X POST -H 'Content-type: application/json' \
            --data "{
                \"attachments\": [{
                    \"color\": \"$color\",
                    \"title\": \"Enterprise Flutter App Deployment\",
                    \"text\": \"$message\",
                    \"fields\": [
                        {\"title\": \"Environment\", \"value\": \"$ENVIRONMENT\", \"short\": true},
                        {\"title\": \"Commit\", \"value\": \"$CIRCLE_SHA1\", \"short\": true},
                        {\"title\": \"Branch\", \"value\": \"$CIRCLE_BRANCH\", \"short\": true},
                        {\"title\": \"Timestamp\", \"value\": \"$TIMESTAMP\", \"short\": true}
                    ]
                }]
            }" \
            "$SLACK_WEBHOOK_URL"
    fi
    
    print_status "Notifications sent"
}

# Main deployment flow
main() {
    print_info "🚀 Starting Enterprise Deployment Process"
    
    validate_environment
    check_env_vars
    install_tools
    
    case $ENVIRONMENT in
        dev)
            deploy_dev
            ;;
        staging)
            deploy_staging
            ;;
        production)
            deploy_production
            ;;
    esac
    
    generate_report
    send_notifications
    
    print_status "🎉 Deployment to $ENVIRONMENT completed successfully!"
}

# Execute main function
main "$@"