component extends = "mxunit.framework.TestCase" {

	/**
	* @hint given the sequential order of event escalation and resolution, run these in sequence within the suite
	*/
	function setup() {
		try {
			variables.pagerDutyClient = new MXUnitPagerDutyClient();
			variables.pagerDutyEvent = new lib.pagerduty.PagerDutyEvent("MXUNIT_TEST", variables.pagerDutyClient);
		} catch(Any e) {
			variables.exception = e;
		}
	}

	function test_1_trigger() {
//		debug(variables.exception); return;
		local.result = variables.pagerDutyEvent
			.setComponent("MXUnit")
			.setCustomDetails({ "foo": "bar" })
			.setSeverity("info")
			.setSummary("PagerDuty Test from MX Unit (Trigger)")
			.setType("test")
			.trigger();

		debug(local.result);
		assertTrue(local.result.statusCode.find("202"));
	}

	function test_1_trigger_alternate() {
		local.result = new lib.pagerduty.PagerDutyEvent(eventKey = "MXUNIT_TEST")
			.setApplicationName(variables.pagerDutyClient.getApplicationName())
			.setApplicationURL(variables.pagerDutyClient.getApplicationURL())
			.setPagerDutyKey(variables.pagerDutyClient.getPagerDutyKey())
			.setSummary("PagerDuty Test from MX Unit (Trigger)")
			.setType("test")
			.trigger();

		debug(local.result);
		assertTrue(local.result.statusCode.find("202"));
	}

	function test_1_trigger_imagesAndLinks() {
		local.result = variables.pagerDutyEvent
			.addImage(src = "https://static.donordrive.com/themes/resources/img/brand/dd-logo-black.svg", href = "https://try.donordrive.com/", alt = "foo")
			.addLink(href = "https://try.donordrive.com/", text = "test")
			.setSeverity("info")
			.setSummary("PagerDuty Test from MX Unit (Trigger)")
			.setType("test")
			.trigger();

		debug(local.result);
		assertTrue(local.result.statusCode.find("202"));
	}

	function test_2_acknowledge() {
		local.result = variables.pagerDutyEvent
			.setSeverity("info")
			.setSummary("PagerDuty Test from MX Unit (Acknowledge)")
			.acknowledge();

		debug(local.result);
		assertTrue(local.result.statusCode.find("202"));
	}

	function test_3_resolve() {
		local.result = variables.pagerDutyEvent
			.setSeverity("info")
			.setSummary("PagerDuty Test from MX Unit (Resolve)")
			.resolve();

		debug(local.result);
		assertTrue(local.result.statusCode.find("202"));
	}

}