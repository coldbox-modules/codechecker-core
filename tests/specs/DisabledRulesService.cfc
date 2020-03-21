component extends="testbox.system.BaseSpec" {
	function run() {
		var service = getMockedService();
		var testCases = getTestCases();

		story("instructions to disable execution on an individual line can be determined", function() {
			for (var testCase in testCases) {
				given("a prefix of '#testCase.prefix#' and a suffix of '#testCase.suffix#'", function() {
					when("disabling all rules ('disable-line')", function() {
						var matches = service.detectForLine(
							line: "some irrelevant content #testCase.prefix#codechecker disable-line#testCase.suffix#",
							pattern: "disable-line"
						);

						then("there should be one match", function() {
							expect( matches ).toHaveLength( 1 );
						});

						then("the disabled rule's category should be '_ALL'", function() {
							expect( matches[1].category ).toBe( "_ALL" );
						});

						then("the disabled rule's name should be empty", function() {
							expect( matches[1].name ).toBe( "" );
						});
					});

					when("disabling a category ('disable-line Rule Category')", function() {
						var matches = service.detectForLine(
							line: "some irrelevant content #testCase.prefix#codechecker disable-line Rule Category#testCase.suffix#",
							pattern: "disable-line"
						);

						then("there should be one match", function() {
							expect( matches ).toHaveLength( 1 );
						});

						then("the disabled rule's category should be 'Rule Category'", function() {
							expect( matches[1].category ).toBe( "Rule Category" );
						});

						then("the disabled rule's name should be ''", function() {
							expect( matches[1].name ).toBe( "" );
						});
					});

					when("disabling one rule in a category ('disable-line Rule Category: Rule Item')", function() {
						var matches = service.detectForLine(
							line: "some irrelevant content #testCase.prefix#codechecker disable-line Rule Category: Rule Item#testCase.suffix#",
							pattern: "disable-line"
						);

						then("there should be one match", function() {
							expect( matches ).toHaveLength( 1 );
						});

						then("the disabled rule's category should be 'Rule Category'", function() {
							expect( matches[1].category ).toBe( "Rule Category" );
						});

						then("the disabled rule's name should be 'Rule Item'", function() {
							expect( matches[1].name ).toBe( "Rule Item" );
						});
					});

					when("disabling multiple categories ('disable-line Rule Category 1 | Rule Category 2')", function() {
						var matches = service.detectForLine(
							line: "some irrelevant content #testCase.prefix#codechecker disable-line Rule Category 1 | Rule Category 2#testCase.suffix#",
							pattern: "disable-line"
						);

						then("there should be two matches", function() {
							expect( matches ).toHaveLength( 2 );
						});

						then("the first disabled rule's category should be 'Rule Category 1'", function() {
							expect( matches[1].category ).toBe( "Rule Category 1" );
						});

						then("the first disabled rule's name should be ''", function() {
							expect( matches[1].name ).toBe( "" );
						});

						then("the second disabled rule's category should be 'Rule Category 2'", function() {
							expect( matches[2].category ).toBe( "Rule Category 2" );
						});

						then("the second disabled rule's name should be ''", function() {
							expect( matches[2].name ).toBe( "" );
						});
					});

					when("disabling an entire category followed by an individual rule ('disable-line Rule Category 1 | Rule Category 2: Rule Item 3')", function() {
						var matches = service.detectForLine(
							line: "some irrelevant content #testCase.prefix#codechecker disable-line Rule Category 1 | Rule Category 2: Rule Item 3#testCase.suffix#",
							pattern: "disable-line"
						);

						then("there should be two matches", function() {
							expect( matches ).toHaveLength( 2 );
						});

						then("the first disabled rule's category should be 'Rule Category 1'", function() {
							expect( matches[1].category ).toBe( "Rule Category 1" );
						});

						then("the first disabled rule's name should be ''", function() {
							expect( matches[1].name ).toBe( "" );
						});

						then("the second disabled rule's category should be 'Rule Category 2'", function() {
							expect( matches[2].category ).toBe( "Rule Category 2" );
						});

						then("the second disabled rule's name should be 'Rule Item 3'", function() {
							expect( matches[2].name ).toBe( "Rule Item 3" );
						});
					});

					when("disabling an individual rule followed by an entire category ('disable-line Rule Category 1: Rule Item 2 | Rule Category 3')", function() {
						var matches = service.detectForLine(
							line: "some irrelevant content #testCase.prefix#codechecker disable-line Rule Category 1: Rule Item 2 | Rule Category 3#testCase.suffix#",
							pattern: "disable-line"
						);

						then("there should be two matches", function() {
							expect( matches ).toHaveLength( 2 );
						});

						then("the first disabled rule's category should be 'Rule Category 1'", function() {
							expect( matches[1].category ).toBe( "Rule Category 1" );
						});

						then("the first disabled rule's name should be 'Rule Item 2'", function() {
							expect( matches[1].name ).toBe( "Rule Item 2" );
						});

						then("the second disabled rule's category should be 'Rule Category 3'", function() {
							expect( matches[2].category ).toBe( "Rule Category 3" );
						});

						then("the second disabled rule's name should be ''", function() {
							expect( matches[2].name ).toBe( "" );
						});
					});

					when("disabling multiple rules ('disable-line Rule Category 1: Rule Item 2 | Rule Category 3: Rule Item 4')", function() {
						var matches = service.detectForLine(
							line: "some irrelevant content #testCase.prefix#codechecker disable-line Rule Category 1: Rule Item 2 | Rule Category 3: Rule Item 4#testCase.suffix#",
							pattern: "disable-line"
						);

						then("there should be two matches", function() {
							expect( matches ).toHaveLength( 2 );
						});

						then("the first disabled rule's category should be 'Rule Category 1'", function() {
							expect( matches[1].category ).toBe( "Rule Category 1" );
						});

						then("the first disabled rule's name should be 'Rule Item 2'", function() {
							expect( matches[1].name ).toBe( "Rule Item 2" );
						});

						then("the second disabled rule's category should be 'Rule Category 3'", function() {
							expect( matches[2].category ).toBe( "Rule Category 3" );
						});

						then("the second disabled rule's name should be 'Rule Item 4'", function() {
							expect( matches[2].name ).toBe( "Rule Item 4" );
						});
					});
				});
			}
		});

		story("instructions to disable execution for the next line can be determined", function() {
			for (var testCase in testCases) {
				given("a prefix of '#testCase.prefix#' and a suffix of '#testCase.suffix#'", function() {
					when("disabling all rules ('disable-next-line')", function() {
						var matches = service.detectForLine(
							line: "some irrelevant content #testCase.prefix#codechecker disable-next-line#testCase.suffix#",
							pattern: "disable-next-line"
						);

						then("there should be one match", function() {
							expect( matches ).toHaveLength( 1 );
						});

						then("the disabled rule's category should be '_ALL'", function() {
							expect( matches[1].category ).toBe( "_ALL" );
						});

						then("the disabled rule's name should be empty", function() {
							expect( matches[1].name ).toBe( "" );
						});
					});

					when("disabling a category ('disable-next-line Rule Category')", function() {
						var matches = service.detectForLine(
							line: "some irrelevant content #testCase.prefix#codechecker disable-next-line Rule Category#testCase.suffix#",
							pattern: "disable-next-line"
						);

						then("there should be one match", function() {
							expect( matches ).toHaveLength( 1 );
						});

						then("the disabled rule's category should be 'Rule Category'", function() {
							expect( matches[1].category ).toBe( "Rule Category" );
						});

						then("the disabled rule's name should be ''", function() {
							expect( matches[1].name ).toBe( "" );
						});
					});

					when("disabling one rule in a category ('disable-next-line Rule Category: Rule Item')", function() {
						var matches = service.detectForLine(
							line: "some irrelevant content #testCase.prefix#codechecker disable-next-line Rule Category: Rule Item#testCase.suffix#",
							pattern: "disable-next-line"
						);

						then("there should be one match", function() {
							expect( matches ).toHaveLength( 1 );
						});

						then("the disabled rule's category should be 'Rule Category'", function() {
							expect( matches[1].category ).toBe( "Rule Category" );
						});

						then("the disabled rule's name should be 'Rule Item'", function() {
							expect( matches[1].name ).toBe( "Rule Item" );
						});
					});

					when("disabling multiple categories ('disable-next-line Rule Category 1 | Rule Category 2')", function() {
						var matches = service.detectForLine(
							line: "some irrelevant content #testCase.prefix#codechecker disable-next-line Rule Category 1 | Rule Category 2#testCase.suffix#",
							pattern: "disable-next-line"
						);

						then("there should be two matches", function() {
							expect( matches ).toHaveLength( 2 );
						});

						then("the first disabled rule's category should be 'Rule Category 1'", function() {
							expect( matches[1].category ).toBe( "Rule Category 1" );
						});

						then("the first disabled rule's name should be ''", function() {
							expect( matches[1].name ).toBe( "" );
						});

						then("the second disabled rule's category should be 'Rule Category 2'", function() {
							expect( matches[2].category ).toBe( "Rule Category 2" );
						});

						then("the second disabled rule's name should be ''", function() {
							expect( matches[2].name ).toBe( "" );
						});
					});

					when("disabling an entire category followed by an individual rule ('disable-next-line Rule Category 1 | Rule Category 2: Rule Item 3')", function() {
						var matches = service.detectForLine(
							line: "some irrelevant content #testCase.prefix#codechecker disable-next-line Rule Category 1 | Rule Category 2: Rule Item 3#testCase.suffix#",
							pattern: "disable-next-line"
						);

						then("there should be two matches", function() {
							expect( matches ).toHaveLength( 2 );
						});

						then("the first disabled rule's category should be 'Rule Category 1'", function() {
							expect( matches[1].category ).toBe( "Rule Category 1" );
						});

						then("the first disabled rule's name should be ''", function() {
							expect( matches[1].name ).toBe( "" );
						});

						then("the second disabled rule's category should be 'Rule Category 2'", function() {
							expect( matches[2].category ).toBe( "Rule Category 2" );
						});

						then("the second disabled rule's name should be 'Rule Item 3'", function() {
							expect( matches[2].name ).toBe( "Rule Item 3" );
						});
					});

					when("disabling an individual rule followed by an entire category ('disable-next-line Rule Category 1: Rule Item 2 | Rule Category 3')", function() {
						var matches = service.detectForLine(
							line: "some irrelevant content #testCase.prefix#codechecker disable-next-line Rule Category 1: Rule Item 2 | Rule Category 3#testCase.suffix#",
							pattern: "disable-next-line"
						);

						then("there should be two matches", function() {
							expect( matches ).toHaveLength( 2 );
						});

						then("the first disabled rule's category should be 'Rule Category 1'", function() {
							expect( matches[1].category ).toBe( "Rule Category 1" );
						});

						then("the first disabled rule's name should be 'Rule Item 2'", function() {
							expect( matches[1].name ).toBe( "Rule Item 2" );
						});

						then("the second disabled rule's category should be 'Rule Category 3'", function() {
							expect( matches[2].category ).toBe( "Rule Category 3" );
						});

						then("the second disabled rule's name should be ''", function() {
							expect( matches[2].name ).toBe( "" );
						});
					});

					when("disabling multiple rules ('disable-next-line Rule Category 1: Rule Item 2 | Rule Category 3: Rule Item 4')", function() {
						var matches = service.detectForLine(
							line: "some irrelevant content #testCase.prefix#codechecker disable-next-line Rule Category 1: Rule Item 2 | Rule Category 3: Rule Item 4#testCase.suffix#",
							pattern: "disable-next-line"
						);

						then("there should be two matches", function() {
							expect( matches ).toHaveLength( 2 );
						});

						then("the first disabled rule's category should be 'Rule Category 1'", function() {
							expect( matches[1].category ).toBe( "Rule Category 1" );
						});

						then("the first disabled rule's name should be 'Rule Item 2'", function() {
							expect( matches[1].name ).toBe( "Rule Item 2" );
						});

						then("the second disabled rule's category should be 'Rule Category 3'", function() {
							expect( matches[2].category ).toBe( "Rule Category 3" );
						});

						then("the second disabled rule's name should be 'Rule Item 4'", function() {
							expect( matches[2].name ).toBe( "Rule Item 4" );
						});
					});
				});
			}
		});
	}


	component function getMockedService() {
		return makePublic(new core.models.DisabledRulesService(), "detectForLine");
	}


	array function getTestCases() {
		return [
			{ prefix: "// ", suffix: "" },
			{ prefix: "// ", suffix: " " },
			{ prefix: "// ", suffix: chr(9) },
			{ prefix: "/* ", suffix: " */" },
			{ prefix: "/*", suffix: " */" },
			{ prefix: "/* ", suffix: "*/" },
			{ prefix: "/*", suffix: "*/" },
			{ prefix: "<!--- ", suffix: " --->" },
			{ prefix: "<!---", suffix: " --->" },
			{ prefix: "<!--- ", suffix: "--->" },
			{ prefix: "<!---", suffix: "--->" }
		];
	}
}
