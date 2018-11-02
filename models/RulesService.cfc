/**
* I set the rules for the code checker.
*/
component accessors="true" {

	property name="categories" 		type="array";
	property name="rules" 			type="array";
	property name="rulesByCategory"	type="struct";

	/**
	* @hint I initialize the component.
	* @rulesDirPath I am the directory path containing the rules.
	*/
	RulesService function init( string rulesDirPath = expandPath( '/codechecker-core/rules' ) ){

		variables.categories 	= [];
		variables.rules 		= [];
		variables.rulesByCategory = {};

		//TODO: support cfscript patterns
		//TODO: support multiline
		//TODO: unscoped variables in cfm pages
		//TODO: unnecessary use of pound signs
		//TODO: reserved words/functions
		//TODO: deprecated functions
		//TODO: require return statement for return types other than void

		// path, recurse, listInfo, filter, sort
		local.rulesFilePaths = directoryList(
			arguments.rulesDirPath,
			true,
			"path",
			"*.json",
			"asc"
		);

		for ( var ruleFile in local.rulesFilePaths ) {
			addRuleFile( ruleFile );
		}

		return this;
	}

	/**
	* Add a single rule as a struct.  Missing keys will be defaulted.
	*/
	function addRule( required struct rule ) {
		
		var defaultRule = {
	        "pattern": "",
	        "message": "",
	        "componentname": "CodeChecker",
	        "category": "Maintenance",
	        "name": "Don't use CFoutput",
	        "passonmatch": false,
	        "extensions": "cfm,cfc",
	        "severity": "3",
	        "customcode": "",
	        "bulkcheck": false,
	        "tagname": "",
	        "functionname": "checkCode", 
	        "excludePaths": [] 
	    };
	    
	    rule = defaultRule.append( rule, true );
	    variables.rules.append( rule );
	    
		if ( NOT arrayFind( variables.categories, rule.category ) ) {
			arrayAppend( variables.categories, rule.category);
			rulesByCategory[ rule.category ] = [];
		}
		
		rulesByCategory[ rule.category ].append( rule );	    
	}

	/**
	* Add all rules in a JSON file.
	* @ruleFile A fully expanded file system path to a JSON file containing an array of structs defining rules
	*/
	function addRuleFile( required string ruleFile ) {
		
		// merge array of config data
		if ( findNoCase( 'disabled', ruleFile ) == 0 ) {
			var ruleFileJSON = deserializeJSON( fileRead( ruleFile ) );
			ruleFileJSON.each( function( rule ){
				addRule( rule );
			} );
		}
		
	}

}
