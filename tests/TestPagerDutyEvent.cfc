component extends = "mxunit.framework.TestCase" {

	function setup() {
		try {
			variables.pagerDutyEvent = new lib.pagerduty.PagerDutyEvent(new MXUnitPagerDutyClient())
				.setDedupeKey("MXUNIT_TEST");
		} catch(Any e) {
			variables.exception = e;
		}
	}

	function test_1_trigger() {
//		debug(variables.exception); return;

		local.result = variables.pagerDutyEvent
			.setComponent("MXUnit")
			.setCustomDetails({ "foo": "bar" })
			.setGroup("coldfusion")
			.setSeverity("info")
			.setSource("try.donordrive.com")
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
			.setSource("try.donordrive.com")
			.setSummary("PagerDuty Test from MX Unit (Trigger)")
			.setType("test")
			.trigger();

		debug(local.result);
		assertTrue(local.result.statusCode.find("202"));
	}

	function test_2_acknowledge() {
		local.result = variables.pagerDutyEvent
			.setSeverity("info")
			.setSource("try.donordrive.com")
			.setSummary("PagerDuty Test from MX Unit (Acknowledge)")
			.acknowledge();

		debug(local.result);
		assertTrue(local.result.statusCode.find("202"));
	}

	function test_3_resolve() {
		local.result = variables.pagerDutyEvent
			.setSeverity("info")
			.setSource("try.donordrive.com")
			.setSummary("PagerDuty Test from MX Unit (Resolve)")
			.resolve();

		debug(local.result);
		assertTrue(local.result.statusCode.find("202"));
	}

}