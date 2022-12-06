//
//  MSRWidgetBundle.swift
//  MyTravelWidgetExtension
//
//  Created by KiwiTech on 10/22/20.
//

import WidgetKit
import SwiftUI

@main
struct MSRWidgetBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        MSRJobWidget()
        LargeJobWidget()
    }
}
