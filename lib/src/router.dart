part of pwa_worker;

/// Decided whether a [request] matches a pattern.
typedef bool RequestMatcher(Request request);

/// Decided whether a [request] matches a pattern.
@Deprecated('Use RequestMatcher instead. Matcher will be removed in 0.1')
typedef bool Matcher(Request request);

/// Contains the rules of selecting the appropriate [RequestHandler] for a [Request].
class FetchRouter {
  List<_RouteRule> _rules = [];

  /// Add a pair of [matcher] and [handler] to the end of the rules.
  void add(RequestMatcher matcher, RequestHandler handler) {
    _rules.add(new _RouteRule(matcher, handler));
  }

  /// Add a [handler] that will get called if [Request.method] equals [method]
  /// and the [url] pattern prefix matches [Request.url].
  void registerUrl(String method, Pattern url, RequestHandler handler) {
    // ignore: deprecated_member_use
    add(urlPrefixMatcher(method, url), handler);
  }

  /// Add a [handler] that will get called if [Request.method] is GET
  /// and the [url] pattern prefix matches [Request.url].
  @Deprecated('Use registerGetUrl instead. get will be removed in 0.1')
  void get(Pattern url, RequestHandler handler) => registerGetUrl(url, handler);

  /// Add a [handler] that will get called if [Request.method] is GET
  /// and the [url] pattern prefix matches [Request.url].
  void registerGetUrl(Pattern url, RequestHandler handler) =>
      registerUrl('get', url, handler);

  /// Add a [handler] that will get called if [Request.method] is POST
  /// and the [url] pattern prefix matches [Request.url].
  @Deprecated('Use registerPostUrl instead. post will be removed in 0.1')
  void post(Pattern url, RequestHandler handler) =>
      registerUrl('post', url, handler);

  /// Add a [handler] that will get called if [Request.method] is POST
  /// and the [url] pattern prefix matches [Request.url].
  void registerPostUrl(Pattern url, RequestHandler handler) =>
      registerUrl('post', url, handler);

  /// Matches the [RequestHandler] for the [request].
  RequestHandler match(Request request) {
    for (_RouteRule rule in _rules) {
      if (rule.matcher(request)) {
        return rule.handler;
      }
    }
    return null;
  }
}

/// Contains the rules of selecting the appropriate [RequestHandler] for a [Request].
@Deprecated('Use FetchRouter instead. Router will be removed in 0.1')
class Router extends FetchRouter {}

/// Returns a [RequestMatcher] that matches the given [method] and [url] pattern as
/// prefix-match.
@Deprecated(
    'Use FetchRouter.registerUrl instead. urlPrefixMatcher will be internal in 0.1')
RequestMatcher urlPrefixMatcher(String method, Pattern url) {
  String methodLowerCase = method.toLowerCase();
  bool methodMatched = methodLowerCase != 'any';
  return (Request request) {
    String requestMethod = request.method.toLowerCase();
    if (methodMatched && requestMethod != methodLowerCase) return false;
    return url.matchAsPrefix(request.url) != null;
  };
}

class _RouteRule {
  final RequestMatcher matcher;
  final RequestHandler handler;
  _RouteRule(this.matcher, this.handler);
}
