package com.uptrail.app;

import android.os.Bundle;
import android.view.WindowManager;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String SECURITY_CHANNEL = "com.uptrail.security/screenshot";
    private static final String RECORDING_CHANNEL = "com.uptrail.security/recording";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        // Enable FLAG_SECURE to prevent screenshots and screen recording
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_SECURE, WindowManager.LayoutParams.FLAG_SECURE);
    }

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        
        // Screenshot prevention method channel
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), SECURITY_CHANNEL)
            .setMethodCallHandler((call, result) -> {
                if (call.method.equals("preventScreenshots")) {
                    enableScreenshotPrevention();
                    result.success(true);
                } else {
                    result.notImplemented();
                }
            });
        
        // Screen recording detection method channel (Android doesn't have direct API)
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), RECORDING_CHANNEL)
            .setMethodCallHandler((call, result) -> {
                if (call.method.equals("isScreenRecording")) {
                    // Android doesn't have a direct API to detect screen recording
                    // FLAG_SECURE prevents it, so we return false
                    result.success(false);
                } else {
                    result.notImplemented();
                }
            });
    }
    
    private void enableScreenshotPrevention() {
        // FLAG_SECURE is already set in onCreate, but we can reinforce it here
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_SECURE, WindowManager.LayoutParams.FLAG_SECURE);
    }
}