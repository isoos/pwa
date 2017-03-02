part of pwa_worker;

/// Handles [request] and returns a Future which completes with a [Response].
typedef Future<Response> Handler(Request request);

/// The default fetch [Handler]: fetching over the network.
final Handler defaultFetchHandler = fetch;

/// Network handler that forces a network fetch, and skips disk cache.
final Handler noCacheNetworkFetch =
    (Request request) => fetch(request, new RequestInit(cache: 'no-store'));

/// Whether the [response] is valid (e.g. not an error, not a missing item).
bool isValidResponse(Response response) {
  if (response == null) return false;
  if (response.type == 'error') return false;
  return true;
}

/// Return a composite [Handler] that joins the [handlers] in serial processing,
/// completing with the first valid response. If none of the [handlers]
/// provide a valid response, it will complete with an error.
Handler joinHandlers(List<Handler> handlers) => (Request request) async {
      for (Handler handler in handlers) {
        try {
          Response response = await handler(request.clone());
          if (isValidResponse(response)) return response;
        } catch (_) {}
      }
      return new Response.error();
    };

/// Returns a composite [Handler] that runs the [handlers] in parallel and
/// completes with the first valid response. If none of the [handlers]
/// provide a valid response, it will complete with an error.
Handler raceHandlers(List<Handler> handlers) => (Request request) {
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
      for (Handler handler in handlers) {
        handler(request.clone()).then((Response response) {
          complete(response);
        }, onError: (e) {
          complete(null);
        });
      }
      return completer.future;
    };
