package com.wings.profi

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import com.google.android.gms.common.ConnectionResult
import com.google.android.gms.common.GoogleApiAvailability

class MainActivity : FlutterActivity() {
    private val PLAY_SERVICES_RESOLUTION_REQUEST = 9000
    private val TAG = "ProfiMainActivity"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        checkGooglePlayServices()
    }

    override fun onResume() {
        super.onResume()
        checkGooglePlayServices()
    }

    private fun checkGooglePlayServices() {
        val googleAPI = GoogleApiAvailability.getInstance()
        val resultCode = googleAPI.isGooglePlayServicesAvailable(this)

        if (resultCode != ConnectionResult.SUCCESS) {
            if (googleAPI.isUserResolvableError(resultCode)) {
                googleAPI.getErrorDialog(this, resultCode, PLAY_SERVICES_RESOLUTION_REQUEST)
                    ?.show()
            } else {
                // Handle the error in a way that makes sense for your app
                // For example, display a message to the user or exit the app
                print("$TAG: Inside MainActivity: Google Play Service Error!")
            }
        } else {
            print("$TAG: Google Play Service is Available - Good to Go!")
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == PLAY_SERVICES_RESOLUTION_REQUEST) {
            // Check again if Google Play services are available
            checkGooglePlayServices()
        }
    }
}
