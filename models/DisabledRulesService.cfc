component {
	DisabledRulesService function init() {
		return this;
	}


	struct function parseFromFile( required string filepath ) {
		local.dataFile = fileOpen( arguments.filepath, "read" );
		local.lineNumber = 0;
		local.skips = {};

		while ( !fileIsEOF( local.dataFile ) ) {
			local.lineNumber++;
			local.line = fileReadLine( local.dataFile );

			if ( NOT StructKeyExists( local.skips, local.lineNumber ) ) {
				local.skips[ local.lineNumber ] = [];
			}

			local.skips[ local.lineNumber + 1 ] = [];


			arrayAppend(
				local.skips[ local.lineNumber ],
				this.detectForLine( line: local.line, pattern: "disable-line" ),
				true
			);

			arrayAppend(
				local.skips[ local.lineNumber + 1 ],
				this.detectForLine( line: local.line, pattern: "disable-next-line" ),
				true
			);
		}

		fileClose( local.dataFile );

		return local.skips;
	}


	public boolean function shouldSkipLine(
		required string line,
		required struct ruleItem,
		array disabledRules = []
	) {
		for ( local.disabledRule in arguments.disabledRules ) {
			// Skip if the user didn't provide any rules (i.e. skip everything)
			if ( local.disabledRule.category == "_ALL" ) {
				return true;
			}

			// Skip when the user has elected to skip this rule's category
			if ( not len( local.disabledRule.name ) and local.disabledRule.category == arguments.ruleItem.category ) {
				return true;
			}

			// Skip when the user has elected to skip this specific rule
			if ( local.disabledRule.category == arguments.ruleItem.category and local.disabledRule.name == arguments.ruleItem.name ) {
				return true;
			}
		}

		return false;
	}


	package array function detectForLine(required string line, required string pattern) {
		if ( !reFindNoCase( ".*codechecker\s#arguments.pattern#", arguments.line ) ) {
			return [];
		}

		local.matches = reReplaceNoCase( arguments.line, ".*codechecker\s#arguments.pattern#(.*?)(\*\/|--->)?$", "\1" );

		if ( len( trim( local.matches ) ) == 0 ) {
			return [
				{
					"category": "_ALL",
					"name": ""
				}
			];
		}

		local.rules = [];

		for ( local.match in listToArray( local.matches, "|" ) ) {
			local.match = trim( local.match );

			arrayAppend(local.rules, {
				"category": trim( listFirst( local.match, ":" ) ),
				"name": trim( listRest( local.match, ":" ) )
			});
		}

		return local.rules;
	}
}
