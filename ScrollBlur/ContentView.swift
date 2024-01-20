//
//  ContentView.swift
//  ScrollBlur
//
//  Created by Brian Masse on 12/3/23.
//

import SwiftUI
import SwiftData

//MARK: Implementation
struct ContentView: View {
    var body: some View {
        VStack {
            ForEach( 0...15, id: \.self ) { i in
                HStack {
                    Spacer()
                    Text("\(i)")
                    Spacer()
                }
                .padding(20)
                .background( .blue )
                .cornerRadius(20)
            }
        }
        .padding(.horizontal)
        .blurScroll(10, blurHeight: 0.15, blurPosition: .top)
    }
}

//MARK: ViewModifier
struct BlurScroll: ViewModifier {
    
    enum BlurPosition {
        case top
        case bottom
    }
    
    let blur: CGFloat
    let blurHeight: CGFloat
    let blurPosition: BlurPosition
    
    let coordinateSpaceName = "scroll"
    
    @State private var scrollPosition: CGPoint = .zero
    
    func body(content: Content) -> some View {
        
        let gradient = LinearGradient(stops: [
            .init(color: .white, location: 0.10),
            .init(color: .clear, location: blurHeight)],
                                      startPoint: .bottom,
                                      endPoint: .top)
        
        let invertedGradient = LinearGradient(stops: [
            .init(color: .clear, location: 0.10),
            .init(color: .white, location: blurHeight)],
                                              startPoint: .bottom,
                                              endPoint: .top)
        
        GeometryReader { topGeo in
            ScrollView {
                ZStack(alignment: .top) {
                    content
                        .mask(
                            VStack {
                                (blurPosition == .bottom ? invertedGradient : gradient)
                                    .frame(height: topGeo.size.height, alignment: .top)
                                    .offset(y:  -scrollPosition.y )
                                Spacer()
                            }
                        )
                    
                    content
                        .blur(radius: 15)
                        .frame(height: topGeo.size.height, alignment: .top)
                        .mask(
                            (blurPosition == .bottom ? gradient : invertedGradient)
                            .frame(height: topGeo.size.height)
                            .offset(y:  -scrollPosition.y )
                        )
                        .ignoresSafeArea()
                }
                .padding(.bottom, topGeo.size.height * 0.25)
                .background(GeometryReader { geo in
                    Color.clear
                        .preference(key: ScrollOffsetPreferenceKey.self,
                                    value: geo.frame(in: .named(coordinateSpaceName)).origin)
                })
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    self.scrollPosition = value
                }
            }
            .coordinateSpace(name: coordinateSpaceName)
        }
        .ignoresSafeArea()
    }
}

//MARK: PreferenceKey
private struct ScrollOffsetPreferenceKey: PreferenceKey {
    
    static var defaultValue: CGPoint = .zero
    
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) { }
}

//MARK: Extension

extension View {
    func blurScroll(_ blur: CGFloat,
                    blurHeight: CGFloat = 0.25,
                    blurPosition: BlurScroll.BlurPosition = .bottom ) -> some View {
        
        modifier(BlurScroll(blur: blur,
                            blurHeight: blurPosition == .bottom ? blurHeight : 1 - blurHeight,
                            blurPosition: blurPosition))
    }
}

#Preview {
    ContentView()
}
