//
//  OneFlowDestination.swift
//  DestinationsExample
//
//  Created by Cody Garvin on 1/15/21.
//

// MIT License
//
// Copyright (c) 2021 Segment
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation
import Segment
import _1Flow

/*
 // This is how application will configure segment
 
 func setupSegmentManager() {
     let config = Configuration(writeKey: "SEGMENT_KEY")
         .trackApplicationLifecycleEvents(true)
         .flushAt(3)
         .flushInterval(10)
             
     self.analytics = Analytics(configuration: config)
     let destination = OneFlowDestination(oneFlowKey: "ONEFLOW_KEY")
     self.analytics?.add(plugin: destination)
 }
 */
  
public class OneFlowDestination: DestinationPlugin, RemoteNotifications {
    public let timeline = Timeline()
    public let type = PluginType.destination
    public let key = "1Flow Mobile Plugin"
    public var analytics: Analytics? = nil
    
    public func update(settings: Settings, type: UpdateType) {
        guard type == .initial else { return }
        guard
            let tempSettings: OneFlowSettings = settings.integrationSettings(forPlugin: self),
            let oneFlowProjectKey = tempSettings.apiKey else {
            return
        }
        // Configure 1Flow
        OneFlow.configure(oneFlowProjectKey)
    }

    public func identify(event: IdentifyEvent) -> IdentifyEvent? {
        // Ensure that the userID is set and valid
        guard let userID = event.userId else {
            return event
        }
        OneFlow.logUser(userID, userDetails: event.traits?.dictionaryValue)
        return event
    }
    
    public func track(event: TrackEvent) -> TrackEvent? {
        OneFlow.recordEventName(event.event, parameters: event.properties?.dictionaryValue)
        return event
    }
    
    public func screen(event: ScreenEvent) -> ScreenEvent? {
        OneFlow.recordEventName(event.name ?? "screen_view", parameters: event.properties?.dictionaryValue)
        return event
    }
    
    public func group(event: GroupEvent) -> GroupEvent? {
        return nil
    }
    
    public func alias(event: AliasEvent) -> AliasEvent? {
        return nil
    }
    
    public func reset() {
        flush()
        analytics?.log(message: "oneFlow reset")
    }
    
    public func flush() {
        analytics?.log(message: "oneFlow Flush")
    }
}

private struct OneFlowSettings: Codable {
    var apiKey: String?
}

extension OneFlowDestination: VersionedPlugin {
    public static func version() -> String {
        return __destination_version
    }
}
