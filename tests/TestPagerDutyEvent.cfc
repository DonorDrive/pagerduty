component extends = "mxunit.framework.TestCase" {

	/**
	* @hint given the sequential order of event escalation and resolution, run these in sequence within the suite
	*/
	function setup() {
		try {
			variables.pagerDutyClient = new MXUnitPagerDutyClient();
			variables.pagerDutyEvent = new lib.pagerduty.PagerDutyEvent(eventKey = "MXUNIT_TEST", pagerDutyClient = variables.pagerDutyClient);
		} catch(Any e) {
			variables.exception = e;
		}
	}

	function test_0_init_alternate() {
//		debug(variables.exception); return;
		local.pagerDutyEvent = new lib.pagerduty.PagerDutyEvent(
			eventKey = "MXUNIT_TEST",
			applicationName = variables.pagerDutyClient.getApplicationName(),
			applicationURL = variables.pagerDutyClient.getApplicationURL(),
			pagerDutyKey = variables.pagerDutyClient.getPagerDutyKey()
		);
	}

	function test_0_init_invalid() {
		try {
			local.pagerDutyEvent = new lib.pagerduty.PagerDutyEvent(
				eventKey = "MXUNIT_TEST"
			);
			fail("should not be here");
		} catch(Any e) {
			assertEquals("PagerDutyEvent.MissingParameter", e.type);
		}
	}

	function test_1_trigger() {
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