/**
* I provide functions for checking code quality.
*/
component accessors="true" {

	// properties
	property name="categories" 	type="string";
	property name="minSeverity"	type="numeric";
	property name="results" 	type="array";
	property name="rules" 		type="array";
	property name="configJSON"	type="struct";
	property name="rulesService";

	/**
	* I initialize the component.
	* @rulesService I am the Rules service object.
	* @utilService I am the Utility service object.
	* @wirebox Instance of WireBox
	* @categories I am a comma separated list of categories, _ALL for all categories.
	*/
	CodeCheckerService function init(
		required any rulesService inject="RulesService@codechecker-core",
		required any utilService inject="UtilService@codechecker-core",
		required any wireBox inject="wirebox",
		string categories = ""
	){
		// init properties
		variables.results 		= [];
		// Init DI
		variables.rulesService 		= arguments.rulesService;
		variables.wirebox 			= arguments.wirebox;
		variables.utilService 		= arguments.utilService;
		variables.categories 		= arguments.categories;
		// This can get overwritten in configure() to be a subset of all rules.
		variables.rules 			= arguments.rulesService.getRules();
		variables.componentCache	= {};
		variables.minSeverity		= 1;
		variables.configJSON		= {};

		return this;
	}

	/**
	* Configure the checker for a given directory.  A config file will be looked for
	* in this root of this folder to load additional rules.
	*/
	CodeCheckerService function configure( required path, categories='', minSeverity='' ){
		// Only checking in current directory.
		// Future feature: look up directory chain, possible overriding or adding on settings
		if( path.right( 5 ) == '.json' ) {
			var configPath = path;
		} else {
			var configPath = path & '/.codechecker.json';	
		}
		var configDir = getDirectoryFromPath( configPath );

			var defaultConfigJSON = {
				includeRules : {},
				excludeRules : {},
				ruleFiles : [],
				customRules : []
			};

		// If there is a local config file
		if( fileExists( configPath ) ) {
			var configJSON = defaultConfigJSON.append( deserializeJSON( fileRead( configPath ) ) );
		} else {
			var configJSON = defaultConfigJSON;
		}

		if( len( arguments.categories ) ) {
			configJSON.includeRules = arguments.categories.listReduce( (includeRules,c)=>{
				includeRules[c]='*';
				return includeRules;
			}, {} );
		}

		setConfigJSON( configJSON );

		if( len( minSeverity ) ) {
			setMinSeverity( arguments.minSeverity );
		} else {
			setMinSeverity( configJSON.minSeverity ?: 1 );
		}

		// Add any custom one off rules defined in JSON
		configJSON.ruleFiles.each( function( ruleFile ) {

			if( !fileExists( ruleFile ) ) {
				ruleFile = getCanonicalPath( configDir & '/' & ruleFile );
			}

			if( !fileExists( ruleFile ) ) {
				throw( message='Rule file not found.', detail=ruleFile, type='codecheckerMissingRuleFile' );
			}
			rulesService.addRuleFile( ruleFile );
		} );

		// Add any custom rules files
		configJSON.customRules.each( function( rule ) {
			rulesService.addRule( rule );
		} );

		// Used below as a handy index for finding all the rules in a category
		var rulesByCategory = rulesService.getRulesByCategory();

		// If no whitelist, assume everything
		if( !configJSON.includeRules.count() ) {
			setRules( rulesService.getRules() );
		} else {
			// Only add the ones we want
			setRules( [] );
			configJSON.includeRules.each( function( k, v ){
				// Ignore categories that don't exist
				if( rulesByCategory.keyExists( k ) ) {

					// Add all rules for this category
					if( isSimpleValue( v ) && v == '*' ) {
						getRules().addAll( rulesByCategory[ k ] );
					// Add specific rules by name in this category
					} else if( isArray( v ) ) {
						v.each( function( ruleName ){
							getRules().addAll( rulesByCategory[ k ].filter( function( rule ){ return rule.name == ruleName } ) );
						} );
					}

				}
			} );
		}

		// Process excludes
		if( configJSON.excludeRules.count() ) {

			// Only add the ones we want
			configJSON.excludeRules.each( function( k, v ){
				// Ignore categories that don't exist
				if( rulesByCategory.keyExists( k ) ) {

					// exclude all rules for this category
					if( isSimpleValue( v ) && v == '*' ) {
						setRules( getRules().filter( function( rule ){ return rule.category != k } ) );
					// remove specific rules by name in this category
					} else if( isArray( v ) ) {
						setRules( getRules().filter( function( rule ){ return rule.category != k || !v.findNoCase( rule.name ) } ) );
					}

				}
			} );
		}


		return this;
	}

	/**
	* I return whether the code check passed or failed.
	* @line I am the line of code for which to check.
	* @passonmatch I determine whether to pass or fail if the pattern is matched.
	* @pattern I am the pattern of code for which to check.
	* @caseSensitive Whether or not the match is case sensitive
	*/
	public boolean function checkCode( required string line, required boolean passonmatch, required string pattern, boolean caseSensitive = false ) {
		if ( arguments.caseSensitive ) {
			local.matched = REFind( arguments.pattern, arguments.line );
		}
		else {
			local.matched = REFindNoCase( arguments.pattern, arguments.line );
		}

		if ( ( local.matched AND NOT arguments.passonmatch ) OR ( NOT local.matched AND arguments.passonmatch ) ) {
			return false;
		}
		return true;
	}

	/**
	* I start the code review.
	* @filepath I am the directory or file path for which to review.
	* @recurse I determine whether or not to review recursively.
	*/
	public array function startCodeReview( required string filepath, boolean recurse = true ) {
		if ( DirectoryExists(arguments.filepath) ) {
			// path, recurse, listInfo, filter, sort
			// TODO: DirectoryList() should filter on type=file
			local.qryFiles = DirectoryList(arguments.filepath, arguments.recurse, "query");
			for ( local.row = 1; local.row LTE local.qryFiles.recordcount; local.row++ ) {
				if ( local.qryFiles.type[local.row] == "File" && listFindNoCase( 'cfc,cfm,html,js,css,json,xml,txt,cfml,htm', local.qryFiles.name[local.row].listLast( '.' ) ) ) {
					local.filePath = "#local.qryFiles.directory[local.row]#/#local.qryFiles.name[local.row]#";
					readFile(filepath=local.filePath);
					if ( variables.categories == "_ALL" OR ListFind( variables.categories, 'QueryParamScanner') ) {
						runQueryParamScanner(filepath=local.filePath);
					}
					if ( variables.categories == "_ALL" OR ListFind( variables.categories, 'VarScoper') ) {
						runVarScoper(filepath=local.filePath)
					}
				}
			}
		}
		else if ( FileExists(arguments.filepath) ) {
			local.filePath = arguments.filepath;
			if( !listFindNoCase( 'cfc,cfm,html,js,css,json,xml,txt,cfml,htm,inc', local.filePath.listLast( '.' ) ) ) {
				return variables.results;
			}
			readFile(filepath=local.filePath);

			if ( variables.categories == "_ALL" OR getRules().reduce( function( result, item ){ return ( result || item.category == 'QueryParamScanner' ); }, false ) ) {
				runQueryParamScanner(filepath=local.filePath);
			}
			if ( variables.categories == "_ALL" OR getRules().reduce( function( result, item ){ return ( result || item.category == 'VarScoper' ); }, false ) ) {
				runVarScoper(filepath=local.filePath)
			}
		}
		return variables.results;
	}

	/**
	* I read the file and run the rules against the file.
	* @filepath I am the file path for which to review.
	*/
	public void function readFile( required string filepath ) {
		local.dataFile = fileOpen( arguments.filepath, "read" );
		local.lineNumber = 0;

		local.disabledRules = getComponent("DisabledRulesService").parseFromFile(
			filepath: arguments.filePath
		);

		while ( !fileIsEOF( local.dataFile ) ) {
			local.lineNumber++;
			local.line = fileReadLine( local.dataFile );
			// run rules on each line
			runRules(
				filepath=arguments.filepath,
				line=local.line,
				linenumber=local.lineNumber,
				categories=variables.categories,
				disabledRules=local.disabledRules[ local.lineNumber ]
			);

			if ( fileIsEOF( local.dataFile ) ) {
				// run rules on whole file. useful for rules where you are just testing the existence of something.
				runRules(filepath=arguments.filepath);
			}
		}
		fileClose( local.dataFile );
	}

	/**
	* I run the code review rules for the line of code.
	* @filepath I am the file path for which to review.
	* @line I am the line of code for which to review.
	* @linenumber I am the line number of the code for which to review.
	* @categories I am a comma separated list of categories, _ALL for all categories.
	*/
	public void function runRules(
		required string filepath,
		string line,
		numeric linenumber,
		string categories = "",
		array disabledRules = []
	) {
		local.standardizedfilepath = Replace(arguments.filepath, "\", "/", "all");
		local.file = ListLast(local.standardizedfilepath, "/");
		local.directory = Replace(local.standardizedfilepath, local.file, "");
		local.fileextension = ListLast(local.file, ".");

		for ( local.ruleitem in variables.rules ) {

			// Skip rules of low severity
			if( local.ruleItem.severity < minSeverity ) {
				continue;
			}

			// backwards compat support for v1
			if ( local.ruleitem.componentname == "CodeChecker" ) {
				local.ruleitem.componentname = "CodeCheckerService";
			}

			// Skip this rule item if we're not running all rules and the item's category wasn't selected for execution
			//if ( arguments.categories != "_ALL" AND NOT ListFind( arguments.categories, local.ruleitem["category"] ) ) {
			//	continue;
			//}

			// Skip this rule item if the file extension doesn't match the rule's definition
			if ( NOT ListFindNoCase(local.ruleitem.extensions, local.fileextension, ",") ) {
				continue;
			}

			// Determine if we were instructed to skip the current line
			if ( structKeyExists(arguments, "line") ) {
				local.disabledRulesService = getComponent("DisabledRulesService");

				local.skip = local.disabledRulesService.shouldSkipLine(
					line: arguments.line,
					ruleItem: local.ruleItem,
					disabledRules: arguments.disabledRules
				);

				if ( local.skip ) {
					continue;
				}
			}

			if ( StructKeyExists(arguments,"line") AND NOT local.ruleitem.bulkcheck AND NOT ListLen(local.ruleitem.tagname,"|") ) {

				local.codeCheckerReturn = getComponent( local.ruleitem.componentname )[ local.ruleitem.functionname ]( argumentCollection={
																	line = arguments.line,
																	passonmatch = local.ruleitem.passonmatch,
																	pattern = local.ruleitem.pattern,
																	caseSensitive = local.ruleitem.caseSensitive ?: false
																} );

				if ( NOT local.codeCheckerReturn ) {
					recordResult(directory=local.directory, file=local.file, rule=local.ruleitem.name, message=local.ruleitem.message, linenumber=arguments.linenumber, category=local.ruleitem.category, severity=local.ruleitem.severity, codeLine=arguments.line);
				}
			}
			else if ( StructKeyExists(arguments,"line") AND NOT local.ruleitem.bulkcheck AND ListLen(local.ruleitem.tagname,"|") ) {
				if ( REFindNoCase("<#Replace(local.ruleitem.tagname,'|','|<')#", arguments.line) ) {


				local.codeCheckerReturn = getComponent( local.ruleitem.componentname )[ local.ruleitem.functionname ]( argumentCollection={
																	line = arguments.line,
																	passonmatch = local.ruleitem.passonmatch,
																	pattern = local.ruleitem.pattern,
																	caseSensitive = local.ruleitem.caseSensitive ?: false
																} );

					if ( NOT local.codeCheckerReturn ) {
						recordResult(directory=local.directory, file=local.file, rule=local.ruleitem.name, message=local.ruleitem.message, linenumber=arguments.linenumber, category=local.ruleitem.category, severity=local.ruleitem.severity, codeLine=arguments.line);
					}
				}
			}
			else if ( NOT StructKeyExists(arguments,"line") AND local.ruleitem.bulkcheck AND local.ruleitem.pattern.len() ) {
				local.objJREUtils = wirebox.getInstance( "jre-utils@codechecker-core" );
				local.dataFile = FileRead( arguments.filepath );
				local.matches = local.objJREUtils.get( local.dataFile , local.ruleitem.pattern );
				if ( ( local.ruleitem.passonmatch AND NOT ArrayLen(local.matches) ) OR ( ArrayLen(local.matches) AND NOT local.ruleitem.passonmatch ) ) {
					// TODO: report actual line number
					recordResult(directory=local.directory, file=local.file, rule=local.ruleitem.name, message=local.ruleitem.message, linenumber=-1, category=local.ruleitem.category, severity=local.ruleitem.severity, codeLine='');
		 			}
			}
			else {
				continue;
			}
		}
	}

	private function getComponent( name ) {
		if( !componentCache.keyExists( name ) ) {
			componentCache[ name ] = wirebox.getInstance( name & '@codechecker-core' );
		}
		return componentCache[ name ];
	}

	/**
	* I run the qpscanner component.
	* @filepath I am the file path for which to review.
	*/
	public void function runQueryParamScanner( required string filepath ) {
		local.standardizedfilepath = Replace(arguments.filepath, "\", "/", "all");
		local.file = ListLast(local.standardizedfilepath, "/");
		local.directory = Replace(local.standardizedfilepath, local.file, "");
		local.fileextension = ListLast(local.file, ".");
		if ( ListFindNoCase("cfm,cfc",local.fileextension) ) {

			local.objJREUtils = wirebox.getInstance( "jre-utils@codechecker-core" );

			local.objQueryParamScanner = wirebox.getInstance(
				name 			= "qpscanner@codechecker-core",
				initArguments 	= {
					jre  			= local.objJREUtils,
					StartingDir		= arguments.filepath,
					OutputFormat 	= "wddx",
					RequestTimeout 	= -1
				}
			);
			local.qpScannerResult = local.objQueryParamScanner.go();
			for ( local.row = 1; local.row LTE local.qpScannerResult.data.recordcount; local.row++ ) {
				recordResult(directory=local.directory, file=local.file, rule="Missing cfqueryparam", message="All query variables should utilize cfqueryparam. This helps prevent sql injection. It also increases query performance by caching the execution plan.", linenumber=local.qpScannerResult.data.querystartline[local.row], category="QueryParamScanner", severity="5", codeLine=local.qpScannerResult.data.QUERYCODE[local.row]);
			}
		}
	}

	/**
	* I run the varScoper component.
	* @filepath I am the file path for which to review.
	*/
	public void function runVarScoper( required string filepath ) {
		local.standardizedfilepath = Replace(arguments.filepath, "\", "/", "all");
		local.file = ListLast(local.standardizedfilepath, "/");
		local.directory = Replace(local.standardizedfilepath, local.file, "");
		local.fileextension = ListLast(local.file, ".");
		if ( local.fileextension == "cfc" ) {
			local.objVarScoper = wirebox.getInstance( name="varScoper@codechecker-core", initArguments={ fileParseText=FileRead( arguments.filepath ) } );
			local.objVarScoper.runVarscoper();
			local.varScoperResult = local.objVarScoper.getResultsArray();
			for ( local.resultitem in local.varScoperResult ) {
				for ( local.unscopedstruct in local.resultitem.unscopedarray ) {
					recordResult(directory=local.directory, file=local.file, rule="Unscoped CFC variable", message="Unscoped variable: [#local.unscopedstruct.variableName#].  All CFC variables should be scoped in order to prevent memory leaks.", linenumber=local.unscopedstruct.linenumber, category="VarScoper", severity="5", codeLine=local.unscopedstruct.variableContext);
				}
			}
		}
	}

	/**
	* I record the result of the code review.
	*/
	public void function recordResult() {
		ArrayAppend(variables.results, arguments);
	}

}
