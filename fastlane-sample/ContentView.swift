//
//  ContentView.swift
//  fastlane-sample
//
//  Created by ohtaki hikaru on 2021/12/17.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    
    @State var manager = CLLocationManager()
    
    var body: some View {
        GoogleMapsView(manager: $manager)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
