# pagerduty
A fluent ColdFusion interface for firing PagerDuty events

## Motivation
PagerDuty is an incedent-aggregation service that consolidates alerts around a single manageable interface. Leveraging PagerDuty within DonorDrive give us real-time alerts when an incident occurs.

## Getting Started
The `pagerduty` package assumes that it will reside in a `lib` directory under the web root, or mapped in the consuming application.

## Usage
The library comprises of a `PagerDutyEvent` component, and an `IPagerDutyClient` interface.

```
pde = new lib.pagerduty.PagerDutyEvent(new MXUnitPagerDutyClient(), "MXUNIT_TEST_EVENT")
	.setComponent("MXUnit")
	.setCustomDetails({ "foo": "bar" })
	.setGroup("coldfusion")
	.setSeverity("info")
	.setSource("try.donordrive.com")
	.setSummary("PagerDuty Test from MX Unit (Trigger)")
	.setType("test");

result = pde.trigger();
```

### PagerDutyEvent Properties

The constructor takes two arguments: an implementation of `IPagerDutyClient` (see below) and an `eventKey`. The `eventKey` sets the `dedup_key` in the underlying API call.

Reference: https://v2.developer.pagerduty.com/docs/send-an-event-events-api-v2

Properties are available via `get*` and `set*`.

|Property|API Equivalent|
|---|---|
|`component`|`payload.component`|
|`customDetails`|`payload.custom_details`|
|`group`|`payload.group`|
|`severity` (required)|`payload.severity`|
|`source` (required)|`payload.source`|
|`summary` (required)|`payload.summary`|
|`timestamp`|`payload.timestamp`|
|`type`|`payload.class`|

Images may be appended to the event by calling `PagerDutyEvent.addImage()`
Links may be attached to the event by calling `PagerDutyEvent.addLink()`

### IPagerDutyClient Methods

Components implementing `IPagerDutyClient` must have the following 3 methods:

- `getAppName()`: Used to set the `client` field in the underlying API call.
- `getAppURL()`: Sets `client_url`
- `getPagerDutyKey()`: Sets `routing_key`