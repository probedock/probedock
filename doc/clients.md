# Clients Configuration

## Main configuration

The main configuration is placed in a directory `.rox` placed in the home directory of the user. It contains the configuration applied for all the `ROX` clients that run on the computer.

File: `~/.rox/config`

```js
{
	"url": "http://...",
	"runnerKey": "rKey",
	"tags": ["ta1", "ta2", "..."],
	"tickets": ["ti1", "ti2", "..."],
	"group": "groupName", 
	"category": "CategeroyName",
	"publish": true, // Determine if the results are sent to ROX

	"payload": {
		"save": true, // Determine if a copy of the results are stored locally
		"cache": true, // Determine if the cache mechanism should be activated or not
		"print": true // Determine if the payload is printed on the console
	}
	// ...
}
```

* `url`: The endpoint of `ROX Center` to send the payloads after a test run finished
* `runnerKey`: The runner key identifies the `ROX Center` user. Your key is in the **You** page accessible from the menu
* `tags`: A list of tags to add to any test run on the computer
* `tickets`: Same as the tags, the list is added to any test run on the computer
* `group`: The group bring the possibility to see different test run organized together in a chronological way
* `pubilsh`: Define if the results are sent to `ROX Center` or not. This allow to disable `ROX Center` without removing any piece of code
* `payload`: The configuration applied for the payloads sent to `ROX Center`
	* `save`: Enable/Disable keeping results in a file
	* `cache`: Enable/Disable caching mechanism to improve the payload size sent to `ROX Center`
	* `print`: Enable/Disable printing the payload to the logs or console (depending the `ROX` client)

## Project configuration

File: `/project/path/rox.json`

The project configuration is placed in a file in the root directory of the project to configure.

```js
{
	"url": "http://...", // Replace the parent value
	"runnerKey": "rKey", // Replace the parent value
	"tags": ["ta1", "ta2", "..."], // Replace the parent value
	"tickets": ["ti1", "ti2", "..."], // Replace the parent value
	"group": "groupName", // Replace the parent value
	"category": "categoryName", // Replace the parent value
	"publish": true, // Replace the parent value

	"payload": {
		"save": true, // Replace the parent value
		"cache": true, // Replace the parent value
		"print": true // Replace the parent value
	},
	
	"project": {
		"name": "ProjectName",
		"version": "ProjectVersion",
		"tags": ["ta1", "ta2", "..."], // Additivity with parent tags
		"tickets": ["ti1", "ti2", "..."] // Additivity with parent tickets
		"category": "categoryName", // Replace the category configured in the root
		"group": "groupName" // Replace the group configured in the root
	}
}
```
* `*`: Any configuration values such `url`, `runnerKey` and so can be replaced in the project configuration
* `payload`: The configuration for the payload can be also replaced for the project like the other configuration
* `project`: Group the configuration for a project. The configuration must be done in the project root directory.
	* `name`: The project name
	* `version`: The project version
	* `tags`: A list of tags to add to any test of the project
	* `tickets`: Same as tags. Add the tickets to any test of the project
	* `category`: Define a default category for any test of the project when no more specific one is specified
	* `group`: Override the group name from the main configuration

## MiniROX Configuration

In `~/.rox/config` file

The `MiniROX` configuration allows running tests on local computer and seeing results quickly and easily in addition of the results sent to `ROX Center`.

```js
{
	// ...
	"mini": {
		"enable": true,
		"url": "http://..."
	}
	// ...
}
```

* `mini`: Group the `MiniROX` configuration
	* `enable`: Enable/Disable the usage of `MiniROX`
	* `url`: The `URL` to contact the `MiniROX` server agent

File: `/project/path/rox.json`

As usual, you can override part of the configuration in any project configuration file.

```js
{
	// ...
	"mini": { // Replace parent value
		"enabled": true, // Replace parent value
		"single": true, // Replace parent value
		"url": "http://..." // Replace parent value
	}
	// ...
}
```

* `mini`: Replace the configuration from the root configuration

## Java Client Specifics

The `ROX Center` Java clients require some specific configuration. For that, you have the following configuration you can set in your different configuration files.

In `~/.rox/config` file

Java client configuration shared across multiple projects run. The configuration is placed in the main configuration file.

```js
{
	// ...
	"java": {
		"optimizer" {
			"storeClass": "<packageName>.<className>", // The class used in the caching mechanism
			"cacheDir": "/path/to/caching/directory" 
		},
		"serializerClass": "<packageName>.<className>", // Serializer class used to save the results locally (XML/JSON)
		
		"sopaui": { // SoapUI Java Client specific configuration
			"verbosity": { // To fix the verbosity of messages set in the message part of a test result
				"fail": "", // The verbosity for the fail messages (values: WARN, INFO, DEBUG, TRACE, default: DEBUG)
				"success": "" // The verbosity for the sucess messages (values: WARN, INFO, DEBUG, TRACE, default: INFO)
			}
		}
	}
	// ...	
}
```

* `java`: Group the configuration for the Java clients
	* `optimizer`: Configure the optimizer that is used to send payload that are as small as possible to `ROX Center`
		* `storeClass`: The class that is responsible to store the optimization results between runs
		* `cacheDir`: A cache directory where Java clients store some values to improve the payload size
	* `serializerClass`: The default class that is used to serialize the payloads when they are saved on the disk. This allows changing the file format used to store the payloads (json, xml, ...).
	* `soapui`: Specific configuration for the `SoapUI` Java client
		* `verbosity`: Allows configuring the verbosity level of the message build in the tests run by `SoapUI`
			* `fail`: The verbosity for the failing tests (values: WARN, INFO, DEBUG, TRACE, default: DEBUG)
			* `success`: The verbosity for the passing tests (values: WARN, INFO, DEBUG, TRACE, default: INFO)

In `/project/path/rox.json` file

As usual, the configuration of the Java clients can be replaced by the configuration in the project configuration file

```js
{
	// ...
	"java": { // Replace the parent value
		"optimizer" { // Replace the parent value
			"storeClass": "<packageName>.<className>", // Replace the parent value
			"cacheDir": "/path/to/caching/directory" // Replace the parent value
		},
		"serializerClass": "<packageName>.<className>", // Replace the parent value

		"sopaui": {
			"verbosity": {
				"fail": "", // Replace the parent value
				"success": "" // Replace the parent value
			}
		}
	}
	// ...
}
```

* `java`: Replace the parent configuration

## C# Client Specifics

In the same logic as the Java clients, the C# clients require some specific configuration that should be done by configuring the main configuration file.

In `~/.rox/config` file

```js
{
	// ...
	"csharp": {
		"serializer" : {
        	"assemblyName" : "<assemblyName>", // Assembly Name to lookup the serializer class
        	"serializerClass" : "<namespace>.<className>" // Serializer class
    	},
    
    	"optimizer": {
        	"assemblyName": "<assemblyName>", // Assembly Name to lookup the optimizer class 
        	"storeClass": "<namespace>.<className>", // Optimizer class
        	"cacheDir" : "path/to/caching/directory"
    	}
	}
	// ...
}
```

* `csharp`: Group the configuration for the C# clients
	* `serializer`: Same idea as the Java clients, you can configure which serializer is used to save payloads
		* `assemblyName`: The assembly name serves to lookup for the serializer class
		* `serializerClass`: The serializer class to choose the format of the payload files (json, xml, ...)
	* `optimizer`: Configure the optimizer that is used to send payload that are as small as possible to `ROX Center`
		* `assemblyName`: The assembly name serves to lookup for the optimizer class
		* `storeClass`: The class that is responsible to store the optimization results between runs
		* `cacheDir`: A cache directory where C# clients store some values to improve the payload size
	
In `/project/path/rox.json` file

As usual, the configuration of the C# clients can be replaced by the configuration in the project configuration file

```js
{
	...
	"csharp": {  // Replace the parent value
		"serializer" : {  // Replace the parent value
    		"assemblyName" : "<assemblyName>",  // Replace the parent value
    		"serializerClass" : "<namespace>.<className>"  // Replace the parent value
		},	

		"optimizer": {  // Replace the parent value
    		"assemblyName": "<assemblyName>",  // Replace the parent value
    		"storeClass": "<namespace>.<className>",  // Replace the parent value
    		"cacheDir" : "path/to/caching/directory" // Replace the parent value
		}
	}
	...
}
```

* `csharp`: Replace the parent configuration
