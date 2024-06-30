/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The app's camera view.
*/

import SwiftUI

struct CameraView: View {

    let cameraImage: CGImage

    var body: some View {
        //Image(cameraImage, scale: 2, label: Text("Camera"))
        Image(cameraImage, scale: 1.0, label: Text("Camera"))
            .resizable()
            .aspectRatio(contentMode: .fill)
    }
}

