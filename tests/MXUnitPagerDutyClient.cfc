component implements = "lib.pagerduty.IPagerDutyClient" {

	string function getAppName() {
		return "DonorDrive MXUnit Test";
	}

	string function getAppURL() {
		return "https://www.donordrive.com/";
	}

	string function getPagerDutyKey() {
		return "[ YOUR INTEGRATION KEY ]";
	}

}