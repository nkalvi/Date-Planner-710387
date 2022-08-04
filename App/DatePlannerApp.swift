/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI
import Combine

// Based on https://developer.apple.com/documentation/swiftui/bringing_robust_navigation_structure_to_your_swiftui_app
final class NavigationModel: ObservableObject {
    @Published var sidebarDestination: HashableBindingWrapper<Event>?
    @Published var columnVisibility: NavigationSplitViewVisibility
    
    
    init(sidebarDestination: HashableBindingWrapper<Event>? = nil, columnVisibility: NavigationSplitViewVisibility = .automatic) {
        self.sidebarDestination = sidebarDestination
        self.columnVisibility = columnVisibility
    }
}

// https://developer.apple.com/forums/thread/710387
struct HashableBindingWrapper<Value> {
    var binding: Binding<Value>
}

extension HashableBindingWrapper: Equatable where Value: Equatable {
    static func == (lhs: HashableBindingWrapper<Value>, rhs: HashableBindingWrapper<Value>) -> Bool {
        lhs.binding.wrappedValue == rhs.binding.wrappedValue
    }
}

extension HashableBindingWrapper: Hashable where Value: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(binding.wrappedValue.hashValue)
    }
}


@main
struct DatePlannerApp: App {
    @StateObject private var eventData = EventData()
    @StateObject private var navigationModel = NavigationModel()

    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                EventList()
            } detail: {
                if let wrapper = navigationModel.sidebarDestination {
                    EventEditor(event: wrapper.binding)
                } else  {
                    Text("Select an Event")
                        .foregroundStyle(.secondary)
                }
            }
            .environmentObject(eventData)
            .environmentObject(navigationModel)
            
        }
    }
}
