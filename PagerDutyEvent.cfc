component accessors = "true" {

	property name = "applicationName" type = "string" setter = "false";
	property name = "applicationURL" type = "string" setter = "false";
	property name = "component" type = "string";
	property name = "customDetails" type = "struct";
	property name = "eventAction" type = "string" setter = "false";
	property name = "pagerDutyKey" type = "string" setter = "false";
	property name = "severity" type = "string" setter = "false";
	property name = "summary" type = "string" default = "info";
	property name = "timeout" type = "numeric" default = "10";
	property name = "timestamp" type = "date";
	property name = "type" type = "string";

	PagerDutyEvent function init(required string eventKey, IPagerDutyClient pagerDutyClient, string applicationName, string applicationURL, string pagerDutyKey) {
		variables.eventKey = arguments.eventKey;

		if(structKeyExists(arguments, "pagerDutyClient")) {
			variables.applicationName = arguments.pagerDutyClient.getApplicationName();
			variables.applicationURL = arguments.pagerDutyClient.getApplicationURL();
			variables.pagerDutyKey = arguments.pagerDutyClient.getPagerDutyKey();
		} else if(structKeyExists(arguments, "applicationName") && structKeyExists(arguments, "applicationURL") && structKeyExists(arguments, "pagerDutyKey")) {
			variables.applicationName = arguments.applicationName;
			variables.applicationURL = arguments.applicationURL;
			variables.pagerDutyKey = arguments.pagerDutyKey;
		} else {
			throw(type = "PagerDutyEvent.MissingParameter", message = "IPagerDutyClient or applicationName + applicationURL + pagerDutyKey must be furnished");
		}

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

	private struct function postToPagerDuty(required string eventAction) {
		if(!structKeyExists(variables, "severity") || !structKeyExists(variables, "summary")) {
			throw(type = "PagerDutyEvent.MissingParameter", message = "Severity and summary must be set");
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
				"group": getApplicationName(),
				"severity": getSeverity(),
				"source": getApplicationURL(),
				"summary": left(getSummary(), 1024),
				"timestamp": dateTimeFormat(getTimestamp(), "yyyy-mm-dd'T'HH:nn:ss.lZ")
			},
			"routing_key": getPagerDutyKey()
		});

		try {
			cfhttp(
					method = "POST",
					result = "variables.httpResult",
					timeout = getTimeout(),
					url = "https://events.pagerduty.com/v2/enqueue"
				) {
				cfhttpparam(type = "header", name = "Content-Type", value = "application/json");
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

}