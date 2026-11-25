class_name RemoteApiClient
extends ApiClient

# Synchronous port implementation. Godot's coroutine functions cannot satisfy the
# synchronous ApiClient signature, so this adapter uses the built-in HTTPClient.
# A future asynchronous transport can add HTTPRequest nodes without changing ports.

const ERROR_INVALID_CONFIG: String = "INVALID_CONFIG"
const ERROR_INVALID_URL: String = "INVALID_URL"
const ERROR_CONNECT: String = "CONNECT_FAILED"
const ERROR_TIMEOUT: String = "TIMEOUT"
const ERROR_HTTP: String = "HTTP_ERROR"
const ERROR_INVALID_JSON: String = "INVALID_JSON"

var _config: BackendConfig

func _init(p_config: BackendConfig) -> void:
	_config = p_config
	simulated = false

func get_json(path: String, query: Dictionary = {}) -> ApiResponse:
	var url: String = _config.endpoint(path)
	if not query.is_empty():
		url = url + "?" + _encode_query(query)
	return _send(HTTPClient.METHOD_GET, url, "", "")

func post_json(path: String, payload: Dictionary, idempotency_key: String = "") -> ApiResponse:
	return _send(HTTPClient.METHOD_POST, _config.endpoint(path), JSON.stringify(payload), idempotency_key)

func delete_json(path: String) -> ApiResponse:
	return _send(HTTPClient.METHOD_DELETE, _config.endpoint(path), "", "")

func _encode_query(query: Dictionary) -> String:
	var parts: PackedStringArray = PackedStringArray()
	for key: Variant in query.keys():
		var encoded_key: String = str(key).uri_encode()
		var encoded_value: String = str(query[key]).uri_encode()
		parts.append("%s=%s" % [encoded_key, encoded_value])
	return "&".join(parts)

func _send(method: HTTPClient.Method, url: String, body: String, idempotency_key: String) -> ApiResponse:
	if _config == null:
		return ApiResponse.new(false, {}, ERROR_INVALID_CONFIG, 0)
	var parts: Dictionary = _split_url(url)
	if parts.is_empty():
		return ApiResponse.new(false, {}, ERROR_INVALID_URL, 0)
	var timeout_ms: int = int(maxf(1.0, _config.request_timeout_seconds) * 1000.0)
	var deadline: int = Time.get_ticks_msec() + timeout_ms
	var headers: PackedStringArray = PackedStringArray([
		"Accept: application/json",
		"Content-Type: application/json",
	])
	if not idempotency_key.is_empty():
		headers.append("Idempotency-Key: %s" % idempotency_key)
	var http: HTTPClient = HTTPClient.new()
	var tls_options: TLSOptions = null
	if bool(parts["secure"]):
		tls_options = TLSOptions.client()
	var connect_error: Error = http.connect_to_host(
		String(parts["host"]), int(parts["port"]), tls_options
	)
	if connect_error != OK:
		http.close()
		return ApiResponse.new(false, {}, ERROR_CONNECT, 0)
	while Time.get_ticks_msec() < deadline:
		http.poll()
		var status: int = http.get_status()
		if status == HTTPClient.STATUS_CONNECTED:
			break
		if status == HTTPClient.STATUS_CANT_CONNECT or status == HTTPClient.STATUS_CONNECTION_ERROR:
			http.close()
			return ApiResponse.new(false, {}, ERROR_CONNECT, 0)
		OS.delay_msec(2)
	if http.get_status() != HTTPClient.STATUS_CONNECTED:
		http.close()
		return ApiResponse.new(false, {}, ERROR_TIMEOUT, 0)
	var request_error: Error = http.request(method, String(parts["path"]), headers, body)
	if request_error != OK:
		http.close()
		return ApiResponse.new(false, {}, ERROR_CONNECT, 0)
	var response_body: String = ""
	var received_bytes: int = 0
	var empty_reads: int = 0
	while Time.get_ticks_msec() < deadline:
		http.poll()
		var response_status: int = http.get_status()
		if response_status == HTTPClient.STATUS_BODY:
			var chunk: PackedByteArray = http.read_response_body_chunk()
			if chunk.is_empty():
				empty_reads += 1
				if empty_reads >= 2:
					break
			else:
				empty_reads = 0
				received_bytes += chunk.size()
				response_body += chunk.get_string_from_utf8()
			var expected_bytes: int = http.get_response_body_length()
			if expected_bytes > 0 and received_bytes >= expected_bytes:
				break
		elif response_status == HTTPClient.STATUS_CONNECTED:
			break
		elif response_status == HTTPClient.STATUS_CONNECTION_ERROR:
			break
		OS.delay_msec(2)
	var status_code: int = http.get_response_code()
	var final_status: int = http.get_status()
	http.close()
	if final_status == HTTPClient.STATUS_CONNECTING or final_status == HTTPClient.STATUS_REQUESTING:
		return ApiResponse.new(false, {}, ERROR_TIMEOUT, status_code)
	if final_status != HTTPClient.STATUS_CONNECTED and final_status != HTTPClient.STATUS_BODY:
		return ApiResponse.new(false, {}, ERROR_CONNECT, status_code)
	if status_code < 200 or status_code >= 300:
		return ApiResponse.new(false, {}, ERROR_HTTP, status_code)
	if response_body.is_empty():
		return ApiResponse.new(true, {}, "", status_code)
	var parsed: Variant = JSON.parse_string(response_body)
	if parsed is Dictionary:
		return ApiResponse.new(true, parsed, "", status_code)
	if parsed is Array:
		return ApiResponse.new(true, {"items": parsed}, "", status_code)
	return ApiResponse.new(false, {}, ERROR_INVALID_JSON, status_code)

func _split_url(url: String) -> Dictionary:
	var scheme_end: int = url.find("://")
	if scheme_end <= 0:
		return {}
	var scheme: String = url.substr(0, scheme_end).to_lower()
	if scheme != "http" and scheme != "https":
		return {}
	var remainder: String = url.substr(scheme_end + 3)
	var path_index: int = remainder.find("/")
	var authority: String = remainder if path_index < 0 else remainder.substr(0, path_index)
	var path: String = "/" if path_index < 0 else remainder.substr(path_index)
	if authority.is_empty():
		return {}
	var port: int = 443 if scheme == "https" else 80
	var host: String = authority
	var colon_index: int = authority.rfind(":")
	if colon_index > 0 and colon_index < authority.length() - 1:
		host = authority.substr(0, colon_index)
		port = authority.substr(colon_index + 1).to_int()
	if host.is_empty() or port <= 0:
		return {}
	return {
		"host": host,
		"port": port,
		"secure": scheme == "https",
		"path": path,
	}
