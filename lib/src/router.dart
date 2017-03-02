part of pwa_worker;

/// Decided whether a [request] matches a pattern.
typedef bool Matcher(Request request);

/// Contains the rules of selecting the appropriate [Handler] for a [Request].
class Router {
  List<_RouteRule> _rules = [];

  /// Add a pair of [matcher] and [handler] to the end of the rules.
  void add(Matcher matcher, Handler handler) {
    _rules.add(new _RouteRule(matcher, handler));
  }

  /// Add a [handler] that will get called if a [Request] is GET and it
  /// prefix-matches the [url] pattern.
  void get(Pattern url, Handler handler) {
    add(urlPrefixMatcher('get', url), handler);
  }

  /// Add a [handler] that will get called if a [Request] is POST and it
  /// prefix-matches the [url] pattern.
  void post(Pattern url, Handler handler) {
    add(urlPrefixMatcher('post', url), handler);
  }

  /// Matches the [Handler] for the [request].
  Handler match(Request request) {
    for (_RouteRule rule in _rules) {
      if (rule.matcher(request)) {
        return rule.handler;
      }
    }
    return null;
  }
}

/// Returns a [Matcher] that matches the given [method] and [url] pattern as
/// prefix-match.
Matcher urlPrefixMatcher(String method, Pattern url) {
  String methodLowerCase = method.toLowerCase();
  bool methodMatched = methodLowerCase != 'any';
  return (Request request) {
    String requestMethod = request.method.toLowerCase();
    if (methodMatched && requestMethod != methodLowerCase) return false;
    return url.matchAsPrefix(request.url) != null;
  };
}

class _RouteRule {
  final Matcher matcher;
  final Handler handler;
  _RouteRule(this.matcher, this.handler);
}
