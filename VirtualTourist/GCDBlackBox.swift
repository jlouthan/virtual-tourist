//
//  GCDBlackBox.swift
//  VirtualTourist
//
//  Created by Jennifer Louthan on 7/2/16.
//  Copyright © 2016 JennyLouthan. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(updates: () -> Void) {
    dispatch_async(dispatch_get_main_queue()) {
        updates()
    }
}

func runInBackgroundQueue(task: () -> Void) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) { 
        task()
    }
}