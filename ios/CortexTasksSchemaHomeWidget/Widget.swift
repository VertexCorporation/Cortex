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

  @Environment(\.colorScheme) var colorScheme

  var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer(minLength: 0)
            Text(entry.data.widgetTitle ?? "")
                .font(.system(size: 11.0, weight: .bold)).foregroundColor((colorScheme == .dark ? Color(red: 0.5686274509803921, green: 0.6627450980392157, blue: 1.0, opacity: 1.0) : Color(red: 0.2, green: 0.4, blue: 0.9098039215686274, opacity: 1.0)))
            Color.clear
            .frame(width: 0.0, height: 7.0)
            Text(entry.data.nextTask ?? "")
                .font(.system(size: 16.0, weight: .bold)).foregroundColor((colorScheme == .dark ? Color(red: 0.9490196078431372, green: 0.9529411764705882, blue: 0.9686274509803922, opacity: 1.0) : Color(red: 0.09019607843137255, green: 0.10196078431372549, blue: 0.12941176470588237, opacity: 1.0)))
            Color.clear
            .frame(width: 0.0, height: 3.0)
            Text(entry.data.taskCount ?? "")
                .font(.system(size: 12.0)).foregroundColor((colorScheme == .dark ? Color(red: 0.6784313725490196, green: 0.7019607843137254, blue: 0.7529411764705882, opacity: 1.0) : Color(red: 0.45098039215686275, green: 0.4745098039215686, blue: 0.5215686274509804, opacity: 1.0)))
            Spacer(minLength: 0)
        }
        .padding(EdgeInsets(top: 12.0, leading: 14.0, bottom: 12.0, trailing: 14.0))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(RoundedRectangle(cornerRadius: 22.0).fill((colorScheme == .dark ? Color(red: 0.06274509803921569, green: 0.06666666666666667, blue: 0.08627450980392157, opacity: 1.0) : Color(red: 1.0, green: 1.0, blue: 1.0, opacity: 1.0))))
        .overlay(RoundedRectangle(cornerRadius: 22.0).strokeBorder((colorScheme == .dark ? Color(red: 0.18823529411764706, green: 0.2, blue: 0.23921568627450981, opacity: 1.0) : Color(red: 0.8862745098039215, green: 0.8980392156862745, blue: 0.9254901960784314, opacity: 1.0)), lineWidth: 1.0))
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
  let widgetTitle: String?
  let nextTask: String?
  let taskCount: String?

  static let paramPrefix = "home_widget.CortexTasksSchema"

  static func fromUserDefaults(_ defaults: UserDefaults?) -> CortexTasksSchemaData {
    return CortexTasksSchemaData(
      widgetTitle: (defaults?.string(forKey: "\(paramPrefix).widgetTitle") ?? "Tasks"),
      nextTask: (defaults?.string(forKey: "\(paramPrefix).nextTask") ?? "Nothing on your list yet"),
      taskCount: (defaults?.string(forKey: "\(paramPrefix).taskCount") ?? "Tap to add a task"),
    )
  }
}

