component implements = "lib.pagerduty.IPagerDutyClient" {

	string function getApplicationName() {
		return "DonorDrive MXUnit Test";
	}

	string function getApplicationURL() {
		return "https://www.donordrive.com/";
	}

	string function getPagerDutyKey() {
		return "[ YOUR INTEGRATION KEY ]";
	}

}