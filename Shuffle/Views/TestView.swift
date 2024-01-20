

import SwiftUI

struct TestView: View {
    
    //let result = BlurDetector_8().BlurDetectSingleTest()
    
    let cameraImage = cropTest()

    var body: some View {
        Image(cameraImage, scale: 1.0, label: Text("Camera"))
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
