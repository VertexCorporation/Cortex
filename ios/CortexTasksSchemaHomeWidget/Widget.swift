// GENERATED CODE - DO NOT MODIFY BY HAND
//
// Placeholder SwiftUI widget.
//
// App Group ID used here: CortexTasksSchemaHomeWidgetFlavor.appGroupId

import SwiftUI
import WidgetKit

enum CortexTasksSchemaHomeWidgetFlavor {
  static let appGroupId = "group.com.vertex.cortex"
}

struct Provider: TimelineProvider {
  func placeholder(in context: Context) -> CortexTasksSchemaHomeWidgetEntry {
    CortexTasksSchemaHomeWidgetEntry(date: Date(), data: CortexTasksSchemaData.fromUserDefaults(nil))
  }

  func getSnapshot(in context: Context, completion: @escaping (CortexTasksSchemaHomeWidgetEntry) -> Void) {
    let prefs = UserDefaults(suiteName: CortexTasksSchemaHomeWidgetFlavor.appGroupId)
    let data = CortexTasksSchemaData.fromUserDefaults(prefs)

    completion(CortexTasksSchemaHomeWidgetEntry(date: Date(), data: data))

  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
    let prefs = UserDefaults(suiteName: CortexTasksSchemaHomeWidgetFlavor.appGroupId)
    let data = CortexTasksSchemaData.fromUserDefaults(prefs)

    completion(Timeline(entries: [CortexTasksSchemaHomeWidgetEntry(date: Date(), data: data)], policy: .atEnd))

  }
}

struct CortexTasksSchemaHomeWidgetEntry: TimelineEntry {
  let date: Date
  let data: CortexTasksSchemaData
}


struct CortexTasksSchemaHomeWidgetEntryView: View {
  var entry: Provider.Entry

  var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("CORTEX  ·  TASKS")
                .font(.caption).fontWeight(.bold).foregroundColor(Color(red: 0.7411764705882353, green: 0.6549019607843137, blue: 1.0, opacity: 1.0))
            Color.clear
            .frame(width: 0.0, height: 10.0)
            Text(entry.data.nextTask ?? "")
                .font(.title).fontWeight(.bold).foregroundColor(Color(red: 0.9607843137254902, green: 0.9529411764705882, blue: 0.9803921568627451, opacity: 1.0))
            Color.clear
            .frame(width: 0.0, height: 6.0)
            Text(entry.data.taskCount ?? "")
                .font(.caption).foregroundColor(Color(red: 0.6666666666666666, green: 0.6627450980392157, blue: 0.7058823529411765, opacity: 1.0))
        }
        .padding(EdgeInsets(top: 16.0, leading: 16.0, bottom: 16.0, trailing: 16.0))
        .background(RoundedRectangle(cornerRadius: 24.0).fill(Color(red: 0.09019607843137255, green: 0.09411764705882353, blue: 0.12549019607843137, opacity: 1.0)))
        .overlay(RoundedRectangle(cornerRadius: 24.0).strokeBorder(Color(red: 0.20392156862745098, green: 0.20784313725490197, blue: 0.25098039215686274, opacity: 1.0), lineWidth: 1.0))
    .applyContainerBackground()
    .widgetURL(URL(string: "cortex://tasks?homeWidget"))
  }
}

struct CortexTasksSchemaHomeWidget: Widget {
  let kind: String = "CortexTasksSchemaHomeWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: Provider()) { entry in
      CortexTasksSchemaHomeWidgetEntryView(entry: entry)
    }
    .configurationDisplayName("CortexTasks")
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

struct CortexTasksSchemaData {
  let nextTask: String?
  let taskCount: String?

  static let paramPrefix = "home_widget.CortexTasksSchema"

  static func fromUserDefaults(_ defaults: UserDefaults?) -> CortexTasksSchemaData {
    return CortexTasksSchemaData(
      nextTask: (defaults?.string(forKey: "\(paramPrefix).nextTask") ?? "No tasks yet"),
      taskCount: (defaults?.string(forKey: "\(paramPrefix).taskCount") ?? "Open your Cortex tasks"),
    )
  }
}

