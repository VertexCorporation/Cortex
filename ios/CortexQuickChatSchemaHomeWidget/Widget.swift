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
    CortexQuickChatSchemaHomeWidgetEntry(date: Date(), data: CortexQuickChatSchemaData.fromUserDefaults(nil))
  }

  func getSnapshot(in context: Context, completion: @escaping (CortexQuickChatSchemaHomeWidgetEntry) -> Void) {
    let prefs = UserDefaults(suiteName: CortexQuickChatSchemaHomeWidgetFlavor.appGroupId)
    let data = CortexQuickChatSchemaData.fromUserDefaults(prefs)

    completion(CortexQuickChatSchemaHomeWidgetEntry(date: Date(), data: data))

  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
    let prefs = UserDefaults(suiteName: CortexQuickChatSchemaHomeWidgetFlavor.appGroupId)
    let data = CortexQuickChatSchemaData.fromUserDefaults(prefs)

    completion(Timeline(entries: [CortexQuickChatSchemaHomeWidgetEntry(date: Date(), data: data)], policy: .atEnd))

  }
}

struct CortexQuickChatSchemaHomeWidgetEntry: TimelineEntry {
  let date: Date
  let data: CortexQuickChatSchemaData
}


struct CortexQuickChatSchemaHomeWidgetEntryView: View {
  var entry: Provider.Entry

  @Environment(\.colorScheme) var colorScheme

  var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer(minLength: 0)
            Text("CORTEX AI")
                .font(.system(size: 11.0, weight: .bold)).foregroundColor((colorScheme == .dark ? Color(red: 0.5686274509803921, green: 0.6627450980392157, blue: 1.0, opacity: 1.0) : Color(red: 0.2, green: 0.4, blue: 0.9098039215686274, opacity: 1.0)))
            Color.clear
            .frame(width: 0.0, height: 9.0)
            HStack(alignment: .center, spacing: 0) {
                Text(entry.data.messageHint ?? "")
                    .font(.system(size: 14.0)).foregroundColor((colorScheme == .dark ? Color(red: 0.6784313725490196, green: 0.7019607843137254, blue: 0.7529411764705882, opacity: 1.0) : Color(red: 0.45098039215686275, green: 0.4745098039215686, blue: 0.5215686274509804, opacity: 1.0)))
                Spacer(minLength: 0)
                Text("↗")
                    .font(.system(size: 18.0, weight: .bold)).foregroundColor((colorScheme == .dark ? Color(red: 0.5686274509803921, green: 0.6627450980392157, blue: 1.0, opacity: 1.0) : Color(red: 0.2, green: 0.4, blue: 0.9098039215686274, opacity: 1.0)))
            }
            .padding(EdgeInsets(top: 10.0, leading: 12.0, bottom: 10.0, trailing: 12.0))
            .background(RoundedRectangle(cornerRadius: 16.0).fill((colorScheme == .dark ? Color(red: 0.10588235294117647, green: 0.11764705882352941, blue: 0.14901960784313725, opacity: 1.0) : Color(red: 0.9529411764705882, green: 0.9607843137254902, blue: 0.9764705882352941, opacity: 1.0))))
            Spacer(minLength: 0)
        }
        .padding(EdgeInsets(top: 12.0, leading: 14.0, bottom: 12.0, trailing: 14.0))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(RoundedRectangle(cornerRadius: 22.0).fill((colorScheme == .dark ? Color(red: 0.06274509803921569, green: 0.06666666666666667, blue: 0.08627450980392157, opacity: 1.0) : Color(red: 1.0, green: 1.0, blue: 1.0, opacity: 1.0))))
        .overlay(RoundedRectangle(cornerRadius: 22.0).strokeBorder((colorScheme == .dark ? Color(red: 0.18823529411764706, green: 0.2, blue: 0.23921568627450981, opacity: 1.0) : Color(red: 0.8862745098039215, green: 0.8980392156862745, blue: 0.9254901960784314, opacity: 1.0)), lineWidth: 1.0))
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

struct CortexQuickChatSchemaData {
  let messageHint: String?

  static let paramPrefix = "home_widget.CortexQuickChatSchema"

  static func fromUserDefaults(_ defaults: UserDefaults?) -> CortexQuickChatSchemaData {
    return CortexQuickChatSchemaData(
      messageHint: (defaults?.string(forKey: "\(paramPrefix).messageHint") ?? "Ask anything"),
    )
  }
}

