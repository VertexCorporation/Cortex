// GENERATED CODE - DO NOT MODIFY BY HAND
//
// Placeholder SwiftUI widget.
//
// App Group ID used here: CortexQuickChatSchemaHomeWidgetFlavor.appGroupId

import SwiftUI
import WidgetKit

enum CortexQuickChatSchemaHomeWidgetFlavor {
  static let appGroupId = "group.com.vertex.cortex"
}

struct Provider: TimelineProvider {
  func placeholder(in context: Context) -> CortexQuickChatSchemaHomeWidgetEntry {
    CortexQuickChatSchemaHomeWidgetEntry(date: Date())
  }

  func getSnapshot(in context: Context, completion: @escaping (CortexQuickChatSchemaHomeWidgetEntry) -> Void) {
    // Example of accessing data written by home_widget in Flutter:
    // let prefs = UserDefaults(suiteName: CortexQuickChatSchemaHomeWidgetFlavor.appGroupId)
    // let counter = prefs?.integer(forKey: "counter") ?? 0
    completion(CortexQuickChatSchemaHomeWidgetEntry(date: Date()))

  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
    completion(Timeline(entries: [CortexQuickChatSchemaHomeWidgetEntry(date: Date())], policy: .atEnd))

  }
}

struct CortexQuickChatSchemaHomeWidgetEntry: TimelineEntry {
  let date: Date
}


struct CortexQuickChatSchemaHomeWidgetEntryView: View {
  var entry: Provider.Entry
  @Environment(\.colorScheme) private var colorScheme

  var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("CORTEX")
                .font(.caption).fontWeight(.bold).foregroundColor(colorScheme == .dark ? Color(red: 0.486, green: 0.612, blue: 1.0) : Color(red: 0.051, green: 0.384, blue: 0.996))
            Color.clear
            .frame(width: 0.0, height: 10.0)
            Text("Start a new chat")
                .font(.title).fontWeight(.bold).foregroundColor(colorScheme == .dark ? Color(red: 0.96, green: 0.96, blue: 0.96) : Color(red: 0.09, green: 0.09, blue: 0.09))
            Color.clear
            .frame(width: 0.0, height: 6.0)
            Text("Tap to talk to Cortex")
                .font(.caption).foregroundColor(colorScheme == .dark ? Color(red: 0.608, green: 0.608, blue: 0.608) : Color(red: 0.40, green: 0.40, blue: 0.40))
        }
        .padding(EdgeInsets(top: 16.0, leading: 16.0, bottom: 16.0, trailing: 16.0))
        .background(RoundedRectangle(cornerRadius: 24.0).fill(colorScheme == .dark ? Color(red: 0.035, green: 0.035, blue: 0.035) : Color.white))
        .overlay(RoundedRectangle(cornerRadius: 24.0).strokeBorder(colorScheme == .dark ? Color(red: 0.173, green: 0.173, blue: 0.173) : Color(red: 0.855, green: 0.855, blue: 0.855), lineWidth: 1.0))
    .applyContainerBackground()
    .widgetURL(URL(string: "cortex://chat?homeWidget"))
  }
}

struct CortexQuickChatSchemaHomeWidget: Widget {
  let kind: String = "CortexQuickChatSchemaHomeWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: Provider()) { entry in
      CortexQuickChatSchemaHomeWidgetEntryView(entry: entry)
    }
    .configurationDisplayName("CortexQuickChat")
  }
}

extension View {
  @ViewBuilder
  func applyContainerBackground() -> some View {
    if #available(iOSApplicationExtension 17.0, *) {
      self.containerBackground(.fill.tertiary, for: .widget)
    } else if #available(iOSApplicationExtension 15.0, *) {
      self.background()
    } else {
      self
    }
  }
}


