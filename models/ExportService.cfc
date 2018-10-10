component accessors="true" singleton {
	property name='wirebox' inject='wirebox';

	function generateExcelReport( data, categories ){

		var result=queryNew("directory,file,rule,message,linenumber,category,severity");
		
		for( var i=1; i<=ArrayLen(data);i=(i+1) ){
			queryAddRow(result);
			querySetCell(result,"directory",data[i].directory);
			querySetCell(result,"file",data[i].file);
			querySetCell(result,"rule",data[i].rule);
			querySetCell(result,"message",data[i].message);
			querySetCell(result,"linenumber",data[i].linenumber);
			querySetCell(result,"category",data[i].category);
			querySetCell(result,"severity",data[i].severity);
		}
		
		// This returns a distinct list of comma seperated categories
		vCategories = listToArray( categories);
		
		// Queries are created named from the categories
		for ( var k in vCategories ) {
			local[ safeVariable(k) ] = queryExecute(
				'select directory,file,rule,message,linenumber,category,severity 
				from result 
				where category=?
				order by category',
				[ k ],
				{ dbtype='query' }
			 );
		}
		
		
	//	writeDump(local);abort;
		
		// Spreadsheet gets dynamically created
		
		var counter = 0;
		var spreadsheet = wirebox.getInstance( 'Spreadsheet@codechecker-core');
		// spreadsheet = New spreadsheet();
		var workbook = spreadsheet.new();
		for( i=1;i<=arrayLen(vCategories);i++ ){
			counter = counter + 1;
			var value = safeVariable(vCategories[i]);
			var data = Evaluate(value);
			if( data.recordcount gt 0 ); {
				spreadsheet.createSheet( workbook, left(LCase(value),30) );
				spreadsheet.setActiveSheet(workbook, left(LCase(value),30) );
				spreadsheet.addRow(workbook=workbook, data="directory,file,rule,message,linenumber,category,severity,Developer-Assigned,Status", autoSizeColumns=1);
				spreadsheet.addRows(workbook,data);
			}
		}
		
		spreadsheet.removesheet(workbook,"Sheet1");
		spreadsheet.setActiveSheetNumber(workbook,1);
		var binary=spreadsheet.readBinary(workbook);
		return binary;
		
	}
	
	function safeVariable( inputval='' ) {
		return REReplace(ARGUMENTS.inputval,"[^0-9A-Za-z]","","all");
	}


}
