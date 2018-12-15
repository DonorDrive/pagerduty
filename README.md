# pagerduty
A fluent ColdFusion interface for firing PagerDuty events

## Motivation
PagerDuty is an incedent-aggregation service that consolidates alerts around a single manageable interface. Leveraging PagerDuty within DonorDrive give us real-time alerts when an incident occurs.

## Getting Started
The `pagerduty` package assumes that it will reside in a `lib` directory under the web root, or mapped in the consuming application.

## Usage
The library comprises of a `PagerDutyEvent` component, and an `IPagerDutyClient` interface. 
```
pde = new lib.pagerduty.PagerDutyEvent(eventKey = "MXUNIT_TEST_EVENT", pagerDutyClient = new MXUnitPagerDutyClient())
	.setComponent("MXUnit")
	.setCustomDetails({ "foo": "bar" })
	.setGroup("coldfusion")
	.setSeverity("info")
	.setSource("try.donordrive.com")
	.setSummary("PagerDuty Test from MX Unit (Trigger)")
	.setType("test");

result = pde.trigger();
```

Use of the `IPagerDutyClient` interface is optional, and meant to streamline instantiation. Instantiation may also be done by furnishing the properties of `IPagerDutyClient` directly  to the `PagerDutyEvent`:
```
pde = new lib.pagerduty.PagerDutyEvent(eventKey = "MXUNIT_TEST_EVENT", applicationName = "MXUnit", applicationURL = "https://www.donordrive.com", pagerDutyKey = "[YOUR PAGERDUTY KEY]")
	set...()
	.trigger();
```

### PagerDutyEvent Properties

The constructor takes two arguments: an implementation of `IPagerDutyClient` (see below) and an `eventKey`. The `eventKey` sets the `dedup_key` in the underlying API call.

Reference: https://v2.developer.pagerduty.com/docs/send-an-event-events-api-v2

Properties are available via `get*` and `set*`.

|Property|API Equivalent|
|---|---|
|`component`|`payload.component`|
|`customDetails`|`payload.custom_details`|
|`severity` (required)|`payload.severity`|
|`summary` (required)|`payload.summary`|
|`timestamp`|`payload.timestamp`|
|`type`|`payload.class`|

Images may be appended to the event by calling `PagerDutyEvent.addImage()`
Links may be attached to the event by calling `PagerDutyEvent.addLink()`

### IPagerDutyClient Methods

Components implementing `IPagerDutyClient` must have the following 3 methods:

- `getApplicationName()`: Used to set the `payload.group` field in the underlying API call.
- `getApplicationURL()`: Sets `payload.source`
- `getPagerDutyKey()`: Sets `routing_key`
