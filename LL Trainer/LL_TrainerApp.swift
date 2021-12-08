//
//  LL_TrainerApp.swift
//  LL Trainer
//
//  Created by Luca Bergesio on 17/11/21.
//

import SwiftUI

@main
struct LL_TrainerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 1620, maxWidth: .infinity,
                       minHeight: 900, maxHeight: .infinity)
        }
        .commands {
            CommandGroup(replacing: CommandGroupPlacement.systemServices) {
                EmptyView()
            }
            CommandGroup(replacing: CommandGroupPlacement.textEditing) {
                EmptyView()
            }
            
        }
    }
    
    
}
