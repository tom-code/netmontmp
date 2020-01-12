//
//  ContentView.swift
//  ext1
//
//  Created by tom on 1/11/20.
//  Copyright © 2020 tom. All rights reserved.
//

import SwiftUI
import os.log


class ListData: ObservableObject {
    @Published var data: [String] = []
}

struct ContentView: View {
    var loader = Loader()
    @ObservedObject var data = ListData()
    
    var body: some View {
        VStack {
            Text("Hello, World!")
            /*.frame(maxWidth: .infinity, maxHeight: .infinity)*/
            Button(action: {
                os_log("test pressed")
                self.loader.updater(closure: {line in
                    DispatchQueue.main.async() {
                        self.data.data.append(line)
                    }
                })
                self.loader.start()
            }) {
                Text("test")
            }
            List {
                ForEach(self.data.data, id: \.self) {
                    Text("\($0) ()")
                }
            }
            Button(action: {
                self.data.data.append("x1")
            }) {
                Text("zzz")
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
