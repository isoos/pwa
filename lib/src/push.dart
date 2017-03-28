part of pwa_worker;

/// Handler of a Push notification event.
typedef FutureOr PushHandler(PushContext pushContext);

/// Describes a notification.
class Notification {
  /// The title that must be shown within the notification
  final String title;

  /// The direction of the notification; it can be auto, ltr, or rtl.
  final String dir;

  /// Specify the lang used within the notification.
  /// This string must be a valid BCP 47 language tag.
  final String lang;

  /// A string representing an extra content to display within the notification.
  final String body;

  ///  An ID for a given notification that allows you to find, replace, or
  ///  remove the notification using script if necessary.
  final String tag;

  /// The URL of an image to be used as an icon by the notification.
  final String icon;

  ///Describes a notification.
  Notification(this.title,
      {this.dir, this.lang, this.body, this.tag, this.icon});
}

/// A context object that is created for each push event.
///
// The context will contain the push event data, and provide additional helper
// methods for actions and reacting to them (e.g. click on notification).
// ignore: one_member_abstracts
abstract class PushContext {
  /// Displays a notification.
  Future showNotification(Notification notification);
}

class _PushContext extends PushContext {
  @override
  Future showNotification(Notification notification) async {
    ShowNotificationOptions options = new ShowNotificationOptions();
    if (notification.dir != null) options.dir = notification.dir;
    if (notification.lang != null) options.lang = notification.lang;
    if (notification.body != null) options.body = notification.body;
    if (notification.tag != null) options.tag = notification.tag;
    if (notification.icon != null) options.icon = notification.icon;
    await registration.showNotification(notification.title, options);
  }
}
