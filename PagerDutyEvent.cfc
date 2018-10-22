component accessors = "true" {

	property name = "component" type = "string";
	property name = "customDetails" type = "struct";
	property name = "eventAction" type = "string" setter = "false";
	property name = "severity" type = "string" setter = "false";
	property name = "summary" type = "string";
	property name = "timestamp" type = "date";
	property name = "type" type = "string";

	PagerDutyEvent function init(required IPagerDutyClient pagerDutyClient, required string eventKey) {
		variables.pagerDutyClient = arguments.pagerDutyClient;
		variables.eventKey = arguments.eventKey;

		variables.customDetails = {};
		variables.images = [];
		variables.links = [];
		variables.timestamp = now();

		return this;
	}

	struct function acknowledge() {
		return postToPagerDuty("acknowledge");
	}

	PagerDutyEvent function addImage(required string src, string href, string alt) {
		arrayAppend(
			variables.images,
			{
				"src": arguments.src,
				"href": structKeyExists(arguments, "href") ? arguments.href : javaCast("null", ""),
				"alt": structKeyExists(arguments, "alt") ? arguments.alt : javaCast("null", "")
			}
		);

		return this;
	}

	PagerDutyEvent function addLink(required string href, string text) {
		arrayAppend(
			variables.links,
			{
				"href": arguments.href,
				"text": structKeyExists(arguments, "text") ? arguments.text : javaCast("null", "")
			}
		);

		return this;
	}

	struct function resolve() {
		return postToPagerDuty("resolve");
	}

	PagerDutyEvent function setSeverity(required string severity) {
		if(arrayFindNoCase([ "critical", "error", "info", "warning" ], arguments.severity)) {
			variables.severity = arguments.severity;
		} else {
			throw(type = "PagerDutyEvent.InvalidSeverity", message = "The severity furnished is not valid; please use one of the following: critical, error, info, or warning");
		}

		return this;
	}

	struct function trigger() {
		return postToPagerDuty("trigger");
	}

	private struct function postToPagerDuty(required string eventAction) {
		if(!structKeyExists(variables, "severity")
			|| !structKeyExists(variables, "summary")
		) {
			throw(type = "PagerDutyEvent.MissingParameter", message = "Severity and summary must all be set");
		} else if(structKeyExists(variables, "httpResult")) {
			return {
				statusCode: 500,
				statusText: "This event has already been processed"
			};
		}

		local.payload = serializeJSON({
			"dedup_key": left(variables.eventKey, 255),
			"event_action": arguments.eventAction,
			"images": variables.images,
			"links": variables.links,
			"payload": {
				"class": getType(),
				"custom_details": getCustomDetails(),
				"group": variables.pagerDutyClient.getApplicationName(),
				"severity": getSeverity(),
				"source": variables.pagerDutyClient.getApplicationURL(),
				"summary": left(getSummary(), 1024),
				"timestamp": dateTimeFormat(getTimestamp(), "yyyy-mm-dd'T'HH:nn:ss.lZ")
			},
			"routing_key": variables.pagerDutyClient.getPagerDutyKey()
		});

		try {
			cfhttp(
					method = "POST",
					result = "variables.httpResult",
					timeout = "10",
					url = "https://events.pagerduty.com/v2/enqueue"
				) {
				cfhttpparam(type = "header", name = "Content-type", value = "application/json");
				cfhttpparam(type = "body", value = local.payload);
			};
		} catch(Any e) {
			variables.httpResult = {
				statusCode: 500,
				statusText: e.message & ":" & e.details
			};
		}

		return variables.httpResult;
	}

}