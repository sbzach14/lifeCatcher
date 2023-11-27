

import SwiftUI

struct TestView: View {
    
    let result = BlurDetector_8().BlurDetectSingleTest()
    
    var body: some View {
        Text("111")
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
