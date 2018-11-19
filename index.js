var AWS = require('aws-sdk');
exports.handler = function (event, context) {

	//////////////////////////////////////////////////Function call for CLients of Each Region////////////////////////////////////////////

	var regionNames = ['eu-central-1'];
	regionNames.forEach(function (region) {
		describeAllInstances(region);
	});

	/////////////////////////////////////////// Function to Describe Instances  //////////////////////////////////////////

	function describeAllInstances(region) {
		var regionName = region;
		var info = {
			region: ''
		};
		info.region = regionName;
		var EC2 = new AWS.EC2(info);
		var params = {
			Filters: [
				{
					Name: 'instance-state-name',
					Values: [
	                'running'
	            ],
	        },
				{
					Name: 'tag:stop',
					Values: [
	                    'StopWeekDays'
	            ],
	        },
		]
		};
		EC2.describeInstances(params, function (err, data) {
			if (err) return console.log("Error connecting, No Such Instance Found!");
			var Ids = {
				InstanceIds: []
			};
			data.Reservations.forEach(function (reservation) {
				reservation.Instances.forEach(function (instance) {
					Ids.InstanceIds.push(instance.InstanceId);
				});
			});

			//function stop instances called/////////

			stop(EC2, Ids, region);

		});
	}

	////////////////////////////////////////////Function for Stopping Instances///////////////////////////////

	function stop(EC2, Ids, region) {
		var Id = Ids;
		var ec = EC2;
		ec.stopInstances(Id, function (err, data) {
			if (err) console.log("OOps! Instance(s) in " + region + " region doesn't fall in the condition this lambda function has been written for!"); // an error occurred
			else console.log(JSON.stringify(data, null, 4)); // successful response
		});
	}
};
