//
//  CaseView.swift
//  LL Trainer
//
//  Created by Luca Bergesio on 17/11/21.
//

import SwiftUI

struct SegmentedProgressView: View {
    var value: Int = 0
    var maximum: Int = 10
    var height: CGFloat = 30
    var spacing: CGFloat = 1
    var selectedColor: Color = .accentColor
    var unselectedColor: Color = Color.secondary.opacity(0.3)
    
    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0 ..< maximum) { index in
                Rectangle()
                    .foregroundColor(index < self.value ? self.selectedColor : self.unselectedColor)
            }
        }
        .frame(maxWidth: 70 , maxHeight: height)
    }
}


struct CaseView: View {
    @Binding var state: CubeCase
    
    var body: some View {
        HStack {
            let cube = Image(state.image)
            //.background(Color.red)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 90, height: 90)
            
            if state.enabled {
                cube.saturation(1)
            } else {
                cube.saturation(0)
            }
            
            VStack(alignment: .leading) {
                if state.enabled {
                    SegmentedProgressView(value: state.progressValueNormalized, maximum: 10)
                    Text("Avg: " + String(format: "%.2f", state.average)).font(Font.headline.weight(.bold))
                    Text("Num: " + state.counter.description)
                    Text("Std: " + String(format: "%.2f", state.std))
                } else {
                    SegmentedProgressView(value: 0, maximum: 10)
                    Text("Avg: -").font(Font.headline.weight(.bold))
                    Text("Num: -")
                    Text("Std: -")
                }
                
            }
        }
    }
}


struct CaseView_Previews: PreviewProvider {
    static var previews: some View {
        CaseView(state: .constant(CubeCase(image: "done")))
    }
}
