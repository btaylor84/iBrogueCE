//
//  BrogueView.swift
//  iBrogueCE_iPad
//
//  Created by Robert Taylor on 4/30/22.
//  Copyright © 2022 Seth howard. All rights reserved.
//

import SwiftUI
import SpriteKit

let brogueViewController = BrogueViewController()

struct BrogueView: View {

    var scene: SKScene {
        let rect = UIScreen.main.bounds
        let scale = UIScreen.main.scale
        let scene = RogueScene(size: CGSize(width: rect.size.width * scale, height: rect.size.height * scale), rows: 34, cols: 100)
        scene.scaleMode = .fill
        return scene
    }
    
    var body: some View {
        SpriteView(scene: scene)
    }
}

struct BrogueView_Previews: PreviewProvider {
    static var previews: some View {
        BrogueView()
    }
}
