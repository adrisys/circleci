# Enterprise Flutter App ProGuard Rules
# These rules provide additional security through code obfuscation

# Keep Flutter and Dart code
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep native methods
-keepclasseswithmembers class * {
    native <methods>;
}

# Security: Remove logging in release builds
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int i(...);
    public static int w(...);
    public static int d(...);
    public static int e(...);
}

# Remove debug information
-printmapping mapping.txt
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# Security: Obfuscate package names and class names
-repackageclasses ''
-allowaccessmodification

# Keep serialization classes
-keepnames class * implements java.io.Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Security: Hide sensitive methods and fields
-assumenosideeffects class * {
    void setPassword(...);
    void setApiKey(...);
    void setSecret(...);
    void setToken(...);
}

# Performance optimizations
-optimizationpasses 5
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-verbose

# Preserve annotations
-keepattributes *Annotation*
-keep class * extends java.lang.annotation.Annotation { *; }

# Keep generic signatures
-keepattributes Signature

# For crash reporting
-keepattributes SourceFile,LineNumberTable