# pagerduty
A fluent ColdFusion interface for firing PagerDuty events

## Motivation
PagerDuty is an incedent-aggregation service that consolidates alerts around a single manageable interface. Leveraging PagerDuty within DonorDrive give us real-time alerts when an incident occurs.

## Getting Started
The `pagerduty` package assumes that it will reside in a `lib` directory under the web root, or mapped in the consuming application.

## Usage
The library comprises of a `PagerDutyEvent` component, and an `IPagerDutyClient` interface.

```
pde = new lib.pagerduty.PagerDutyEvent(new MXUnitPagerDutyClient())
	.setComponent("MXUnit")
	.setCustomDetails({ "foo": "bar" })
	.setGroup("coldfusion")
	.setSeverity("info")
	.setSource("try.donordrive.com")
	.setSummary("PagerDuty Test from MX Unit (Trigger)")
	.setType("test");

result = pde.trigger();
```

## Resources
- https://v2.developer.pagerduty.com/docs/send-an-event-events-api-v2