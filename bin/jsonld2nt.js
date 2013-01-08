// standard npm modules
var util   = require("util");  
var fs     = require('fs');

// additional npm modules
var jsonld = require("jsonld");

// parse command line arguments
var input   = process.argv[2];
var context = process.argv[3];

/*
fs.exists(input, function(exists) {
    if (exists) {
        var rdf = loadJSON( input );
        fs.exists(context, function(exists) {
            if (exists) {
                input['@context'] = loadJSON(context);
            }
            var options = { 'format': 'application/nquads', 'collate': true };
            jsonld.toRDF(rdf, options, function(e,s) { util.puts(s); } );
        });
    } else {
        fail("missing file: " + (file || "") ); 
    }
});
*/

var rdf = loadJSON( input );
if (context) {
    rdf['@context'] = loadJSON(context);
}
var options = { 'format': 'application/nquads', 'collate': true };
jsonld.toRDF(rdf, options, function(e,s) { util.puts(s); } );

/////////////////////
// helper functions
//
function fail(msg) {
    process.stderr.puts(msg);
    process.exit(1);
}

function loadJSON(file) {
    return JSON.parse(fs.readFileSync(file,'utf8'));
}


