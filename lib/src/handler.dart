part of pwa_worker;

/// Handles [request] and returns a Future which completes with a [Response].
typedef Future<Response> RequestHandler(Request request);

/// Handles [request] and returns a Future which completes with a [Response].
@Deprecated('Use RequestHandler instead. Handler will be removed in 0.1')
typedef Future<Response> Handler(Request request);

/// Network [RequestHandler] with the default disk caching.
final RequestHandler defaultRequestHandler = fetch;

/// Network [RequestHandler] with the default disk caching.
@Deprecated(
    'Use defaultRequestHandler instead. defaultFetchHandler will be removed in 0.1')
final RequestHandler defaultFetchHandler = defaultRequestHandler;

/// Network [RequestHandler] that skips the default disk cache.
final RequestHandler noCacheNetworkRequestHandler =
    (Request request) => fetch(request, new RequestInit(cache: 'no-store'));

/// Network [RequestHandler] that skips disk cache.
@Deprecated(
    'Use noCacheNetworkRequestHandler instead. noCacheNetworkFetch will be removed in 0.1')
final RequestHandler noCacheNetworkFetch = noCacheNetworkRequestHandler;

/// Whether the [response] is valid (e.g. not an error, not a missing item).
bool isValidResponse(Response response) {
  if (response == null) return false;
  if (response.type == 'error') return false;
  return true;
}

/// Return a composite [RequestHandler] that joins the [handlers] in serial processing,
/// completing with the first valid response. If none of the [handlers]
/// provide a valid response, it will complete with an error.
RequestHandler joinHandlers(List<RequestHandler> handlers) =>
    (Request request) async {
      for (RequestHandler handler in handlers) {
        try {
          Response response = await handler(request.clone());
          if (isValidResponse(response)) return response;
        } catch (_) {}
      }
      return new Response.error();
    };

/// Returns a composite [RequestHandler] that runs the [handlers] in parallel and
/// completes with the first valid response. If none of the [handlers]
/// provide a valid response, it will complete with an error.
RequestHandler raceHandlers(List<RequestHandler> handlers) =>
    (Request request) {
      Completer<Response> completer = new Completer();
      int remaining = handlers.length;
      final complete = (Response response) {
        remaining--;
        if (completer.isCompleted) return;
        if (isValidResponse(response)) {
          completer.complete(response);
          return;
        }
        if (remaining == 0) {
          completer.complete(new Response.error());
        }
      };
      for (RequestHandler handler in handlers) {
        handler(request.clone()).then((Response response) {
          complete(response);
        }, onError: (e) {
          complete(null);
        });
      }
      return completer.future;
    };
