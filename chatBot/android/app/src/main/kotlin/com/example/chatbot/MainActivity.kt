package com.example.chatbot

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "app/background"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "moveToBackground") {
                moveTaskToBack(true)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }
}


//package com.example.chatbot
//
//import io.flutter.embedding.android.FlutterActivity
//
//class MainActivity: FlutterActivity() {
//
//    override fun onCreate(savedInstanceState: Bundle?) {
//        // Read extras before super
//        val name = intent?.getStringExtra("name")
//        val address = intent?.getStringExtra("password")
//
//        if (name != null && address != null) {
//            // Build a route like: /fillForm?name=...&address=...
//            val route = "/fillForm?name=${Uri.encode(name)}&password=${Uri.encode(address)}"
//            intent.putExtra("route", route)
//        }
//
//        super.onCreate(savedInstanceState)
//    }
//
//    override fun getInitialRoute(): String? {
//        val route = intent?.getStringExtra("route")
//        return route ?: super.getInitialRoute()
//    }
//}