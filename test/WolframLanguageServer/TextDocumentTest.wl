(* ::Package:: *)

BeginPackage["WolframLanguageServer`TextDocumentTest`"]
ClearAll[Evaluate[Context[] <> "*"]]


Begin["`Private`"]
ClearAll[Evaluate[Context[] <> "*"]]


TestingContext = "WolframLanguageServer`TextDocument`"
CurrentContext = "WolframLanguageServer`TextDocumentTest`"
Needs[TestingContext]
Needs["DataType`"]
Needs["WolframLanguageServer`Specification`"]


sampleCode = "\
data1=Table[Sqrt[1-x^2-y^2],{x,-1,1,0.05},{y,-1,1,0.05}];\n\
data2=Table[-Sqrt[1-x^2-y^2],{x,-1,1,0.05},{y,-1,1,0.05}];\n\
ListPlot3D[{data1,data2},PlotStyle->{Yellow,Cyan},BoxRatios->Automatic,DataRange->{{-1,1},{-1,1}}]\n\
"


sampleTextDoc = TextDocument[<|
	"uri" -> "untitled:Untitled",
	"text" -> {
		"data1=Table[Sqrt[1-x^2-y^2],{x,-1,1,0.05},{y,-1,1,0.05}];",
		"data2=Table[-Sqrt[1-x^2-y^2],{x,-1,1,0.05},{y,-1,1,0.05}];",
		"ListPlot3D[{data1,data2},PlotStyle->{Yellow,Cyan},BoxRatios->Automatic,DataRange->{{-1,1},{-1,1}}]",
		""
	},
	"version" -> 11
|>]


{

VerificationTest[
	sampletextdoc = CreateTextDocument[
		TextDocumentItem[<|
			"uri" -> "untitled:Untitled",
			"languageId" -> "wolfram",
			"version" -> 11,
			"text" -> sampleCode
		|>]
	],
	sampleTextDoc,
	TestID -> "CreateTextDocument"
],

VerificationTest[
	sampletextdoc = ChangeTextDocument[
		sampleTextDoc,
		TextDocumentContentChangeEvent[<|
			"range" -> LspRange[<|
				"start" -> LspPosition[<|
					"line" -> 0,
					"character" -> 0
				|>],
				"end" -> LspPosition[<|
					"line" -> 0,
					"character" -> 5
				|>]
			|>],
			"rangeLength" -> 5,
			"text" -> "newData"
		|>]
	]["text"],
	{
		"newData=Table[Sqrt[1-x^2-y^2],{x,-1,1,0.05},{y,-1,1,0.05}];",
		"data2=Table[-Sqrt[1-x^2-y^2],{x,-1,1,0.05},{y,-1,1,0.05}];",
		"ListPlot3D[{data1,data2},PlotStyle->{Yellow,Cyan},BoxRatios->Automatic,DataRange->{{-1,1},{-1,1}}]",
		""
	},
	TestID -> "ChangeTextDocument1"
],

VerificationTest[
	sampletextdoc = ChangeTextDocument[
		sampleTextDoc,
		TextDocumentContentChangeEvent[<|
			"range" -> LspRange[<|
				"start" -> LspPosition[<|
					"line" -> 1,
					"character" -> 6
				|>],
				"end" -> LspPosition[<|
					"line" -> 1,
					"character" -> 6
				|>]
			|>],
			"rangeLength" -> 0,
			"text" -> "\n    "
		|>]
	]["text"],
	{
		"data1=Table[Sqrt[1-x^2-y^2],{x,-1,1,0.05},{y,-1,1,0.05}];",
		"data2=",
		"    Table[-Sqrt[1-x^2-y^2],{x,-1,1,0.05},{y,-1,1,0.05}];",
		"ListPlot3D[{data1,data2},PlotStyle->{Yellow,Cyan},BoxRatios->Automatic,DataRange->{{-1,1},{-1,1}}]",
		""
	},
	TestID -> "ChangeTextDocument2"
],

VerificationTest[
	FindAllCodeRanges[TextDocument[<|
		"text" -> {
			"(* " ~~ "::Package::" ~~ " *)",
			"(* code range with one line *)"
		}
	|>]],
	{LspRange[<|
		"start" -> LspPosition[<|
			"line" -> 1,
			"character" -> 0
		|>],
		"end" -> LspPosition[<|
			"line" -> 1,
			"character" -> 30
		|>]
	|>]},
	TestID -> "FindAllCodeRangePackage1"
],

VerificationTest[
	FindAllCodeRanges[TextDocument[<|
		"text" -> {
			"(* " ~~ "::Package::" ~~ " *)",
			"",
			"(* code range with one line *)"
		}
	|>]],
	{LspRange[<|
		"start" -> LspPosition[<|
			"line" -> 2,
			"character" -> 0
		|>],
		"end" -> LspPosition[<|
			"line" -> 2,
			"character" -> 30
		|>]
	|>]},
	TestID -> "FindAllCodeRangePackage2"
],

VerificationTest[
	FindAllCodeRanges[TextDocument[<|
		"text" -> {
			"(* " ~~ "::Section::" ~~ " *)",
			"(*section name*)",
			"",
			"",
			"(* code range with four lines *)",
			"",
			"(* code range with four lines *)",
			"(* code range with four lines *)",
			"",
			""
		}
	|>]],
	{
		LspRange[<|
			"start" -> LspPosition[<|
				"line" -> 4,
				"character" -> 0
			|>],
			"end" -> LspPosition[<|
				"line" -> 9,
				"character" -> 0
			|>]
		|>]
	},
	TestID -> "FindAllCodeRangeSection1"
],

VerificationTest[
	FindAllCodeRanges[TextDocument[<|
		"text" -> {
			"(* " ~~ "::Section::" ~~ " *)",
			"(*section name*)",
			"",
			"(* code range with four lines *)",
			"",
			"(* code range with four lines *)",
			"(* code range with four lines *)",
			""
		}
	|>]],
	{
		LspRange[<|
			"start" -> LspPosition[<|
				"line" -> 3,
				"character" -> 0
			|>],
			"end" -> LspPosition[<|
				"line" -> 7,
				"character" -> 0
			|>]
		|>]
	},
	TestID -> "FindAllCodeRangeSection2"
],

VerificationTest[
	FindAllCodeRanges[TextDocument[<|
		"text" -> {
			"(* " ~~ "::Section::" ~~ " *)",
			"(*section name*)",
			"(* code range with four lines *)",
			"",
			"(* code range with four lines *)",
			"(* code range with four lines *)"
		}
	|>]],
	{
		LspRange[<|
			"start" -> LspPosition[<|
				"line" -> 2,
				"character" -> 0
			|>],
			"end" -> LspPosition[<|
				"line" -> 5,
				"character" -> 32
			|>]
		|>]
	},
	TestID -> "FindAllCodeRangeSection3"
],

VerificationTest[
	FindAllCodeRanges[TextDocument[<|
		"text" -> {
			"(* " ~~ "::Section::" ~~ " *)",
			"(*section name*)",
			"",
			"",
			"(* code range with one line *)",
			"(* " ~~ "::Section::" ~~ " *)",
			"(*section name*)",
			"",
			""
		}
	|>]],
	{
		LspRange[<|
			"start" -> LspPosition[<|
				"line" -> 4,
				"character" -> 0
			|>],
			"end" -> LspPosition[<|
				"line" -> 5,
				"character" -> 0
			|>]
		|>]
	},
	TestID -> "FindAllCodeRangeTwoSection1"
]

} // Map@Curry[Sow]@CurrentContext


End[]


EndPackage[]
