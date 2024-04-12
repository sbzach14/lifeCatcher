//
//  LoadingView.swift
//  Shuffle
//
//  Created by Apple on 2024/1/24.
//  Copyright © 2024 Apple. All rights reserved.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack{
            Spacer().frame(height: 250)
            HStack{
                //Image("Logo")
            }
            Spacer()
        }.background(Image("bg").resizable().scaledToFill()).edgesIgnoringSafeArea(.all)
    }
}

struct LoadingView_Previews: PreviewProvider{
    static var previews: some View{
        return LoadingView()
    }
}

