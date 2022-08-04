/*
 See the License.txt file for this sample’s licensing information.
 */

import SwiftUI

struct EventEditor: View {
    @Binding var event: Event
    var isNew = false
    @EnvironmentObject var navigationModel: NavigationModel
    
    @State private var isDeleted = false
    @EnvironmentObject var eventData: EventData
    @Environment(\.dismiss) private var dismiss
    
    // Keep a local copy in case we make edits, so we don't disrupt the list of events.
    // This is important for when the date changes and puts the event in a different section.
    @State private var eventCopy = Event()
    @State private var isEditing = false
    
    var body: some View {
        VStack {
            EventDetail(event: $eventCopy, isEditing: isNew ? true : isEditing)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        if isNew {
                            Button("Cancel") {
                                dismiss()
                            }
                        }
                    }
                    ToolbarItem {
                        Button {
                            if isNew {
                                eventData.events.append(eventCopy)
                                navigationModel.sidebarDestination = HashableBindingWrapper<Event>(binding: $eventCopy)
                                dismiss()
                            } else {
                                if isEditing && !isDeleted {
                                    print("Done, saving any changes to \(event.title).")
                                    withAnimation {
                                        event = eventCopy // Put edits (if any) back in the store.
                                        navigationModel.sidebarDestination = HashableBindingWrapper<Event>(binding: $eventCopy)
                                    }
                                }
                                isEditing.toggle()
                            }
                        } label: {
                            Text(isNew ? "Add" : (isEditing ? "Done" : "Edit"))
                        }
                    }
                }
                .onReceive(navigationModel.$sidebarDestination) { value in
                    // .onReceive fires when the view appears also
                    // eventCopy needs to be updated in this manner as selection updates the value
                    // instead of the pushing a new EventEditor view.
                    guard value != nil && !isEditing && !isNew else { return }
                    eventCopy = (value?.binding.wrappedValue)!
                }
            
            if isEditing && !isNew {
                
                Button(role: .destructive, action: {
                    isDeleted = true
                    navigationModel.sidebarDestination?.binding.wrappedValue = Event()
                    navigationModel.sidebarDestination = nil
                    
                    eventData.delete(event)
                }, label: {
                    Label("Delete Event", systemImage: "trash.circle.fill")
                        .font(.title2)
                        .foregroundColor(.red)
                })
                .padding()
            }
        }
    }
}

struct EventEditor_Previews: PreviewProvider {
    static var previews: some View {
        EventEditor(event: .constant(Event()))
    }
}
