//
//  ContentView.swift
//  ext1
//
//  Created by tom on 1/11/20.
//  Copyright © 2020 tom. All rights reserved.
//

import SwiftUI
import os.log

struct ContentView: View {
    var loader = Loader()
    
    var body: some View {
        VStack {
            Text("Hello, World!")
            /*.frame(maxWidth: .infinity, maxHeight: .infinity)*/
            Button(action: {
                os_log("test pressed")
                self.loader.start()
            }) {
                Text("test")
            }
            Button(action: {
                os_log("exit pressed")
                exit(0)
            }) {
                Text("exit")
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
       
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
