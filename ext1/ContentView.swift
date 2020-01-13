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

struct ToggleModel {
    var f: (Bool)->Void
    init(delegate : @escaping (Bool)->Void) {
        f = delegate
    }
    var isSet: Bool = false {
        didSet {
            f(isSet)
        }
    }
}

class Model: ObservableObject {
    static let shared = Model()
    @Published var data: [String] = []
    func enable() {
        Loader.shared.updater(closure: {line in
            DispatchQueue.main.async() {
                self.data.append(line)
            }
        })
        Loader.shared.start()
    }
}

struct ContentView: View {
    @ObservedObject var data = Model.shared
    @State var enabled = ToggleModel() { ena in
        print(ena)
        if (ena) {
            //self.enable()
            Model.shared.enable()
        }
    }
    
    
    var body: some View {
        VStack {
            Text("Hello, World!")
            /*.frame(maxWidth: .infinity, maxHeight: .infinity)*/
            Button(action: {
                os_log("test pressed")
                Loader.shared.updater(closure: {line in
                    DispatchQueue.main.async() {
                        self.data.data.append(line)
                    }
                })
                //self.loader.start()
            }) {
                Text("test")
            }
            Toggle(isOn: $enabled.isSet) {
                Text("enable")
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
