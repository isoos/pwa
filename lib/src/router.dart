part of pwa_worker;

/// Decided whether a [request] matches a pattern.
typedef bool RequestMatcher(Request request);

/// Contains the rules of selecting the appropriate [RequestHandler] for a [Request].
class FetchRouter {
  List<_RouteRule> _rules = [];

  /// Add a pair of [matcher] and [handler] to the end of the rules.
  void registerMatcher(RequestMatcher matcher, RequestHandler handler) {
    _rules.add(new _RouteRule(matcher, handler));
  }

  /// Add a [handler] that will get called if [Request.method] equals [method]
  /// and the [url] pattern prefix matches [Request.url].
  void registerUrl(String method, Pattern url, RequestHandler handler) {
    String methodLowerCase = method.toLowerCase();
    bool methodMatched = methodLowerCase != 'any';
    RequestMatcher matcher = (Request request) {
      String requestMethod = request.method.toLowerCase();
      if (methodMatched && requestMethod != methodLowerCase) return false;
      return url.matchAsPrefix(request.url) != null;
    };

    registerMatcher(matcher, handler);
  }

  /// Add a [handler] that will get called if [Request.method] is GET
  /// and the [url] pattern prefix matches [Request.url].
  void registerGetUrl(Pattern url, RequestHandler handler) =>
      registerUrl('get', url, handler);

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

class _RouteRule {
  final RequestMatcher matcher;
  final RequestHandler handler;
  _RouteRule(this.matcher, this.handler);
}
