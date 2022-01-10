//
//  ContentView.swift
//  fastlane-sample
//
//  Created by ohtaki hikaru on 2021/12/17.
//

import SwiftUI
import GoogleMaps
import CoreLocation
import FirebaseFirestoreSwift

struct ContentView: View {
    let mapView: GMSMapView
    @ObservedObject var contentViewModel: ContentViewModel
            
    var body: some View {
        ZStack {
            GoogleMapsView(
                mapView: mapView,
                onSelectPort: { port in
                    contentViewModel.setSelectedPort(port: port)
                },
                onUpdateIndicatorArea: { geoPoint, radius in
                    contentViewModel.setIndicatorArea(location: geoPoint, radius: radius)
                }
            ).edgesIgnoringSafeArea(.all)
            
//            VStack {
//                Spacer()
//                HStack {
//                    Spacer()
//                    Button(action: {
//                        contentViewModel.setPortMarkers()
//                    }){
//                        Text("ポートを表示")
//                            .fontWeight(.bold)
//                            .padding()
//                            .background(Color.purple)
//                            .cornerRadius(40)
//                            .foregroundColor(.white)
//                    }.padding()
//                }
//            }
        }.onAppear {
            Task {
                await contentViewModel.setPortMarkers()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let mapView = GMSMapView(frame: .zero)
        ContentView(mapView: mapView, contentViewModel: .init(mapView: mapView))
    }
}
