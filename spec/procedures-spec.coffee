{TextEditor} = require 'atom'

describe "OpenEdge procedures grammer", ->
    grammar = null

    beforeEach ->
        waitsForPromise ->
            atom.packages.activatePackage("language-OpenEdge")

        runs ->
            grammar = atom.grammars.grammarForScopeName("source.openedge")

    it "parses the grammar", ->
        expect(grammar).toBeTruthy()
        expect(grammar.scopeName).toBe "source.openedge"

    describe "message box", ->
        it "parses basic message box", ->
            {tokens} = grammar.tokenizeLine 'message "test message" view-as alert-box.'

            expect(tokens[0].value).toEqual "message"
            expect(tokens[0].scopes).toEqual ["source.openedge", "keyword.other.message.oe"]
            expect(tokens[2].value).toEqual '"'
            expect(tokens[2].scopes).toEqual ["source.openedge", "keyword.other.message.oe", "string.quoted.oe"]
            expect(tokens[3].value).toEqual "test message"
            expect(tokens[3].scopes).toEqual ["source.openedge", "keyword.other.message.oe", "string.quoted.oe"]
            expect(tokens[4].value).toEqual '"'
            expect(tokens[4].scopes).toEqual ["source.openedge", "keyword.other.message.oe", "string.quoted.oe"]
            expect(tokens[5].value).toEqual " view-as alert-box."
            expect(tokens[5].scopes).toEqual ["source.openedge", "keyword.other.message.oe"]

        it "parses question message box", ->
            tokens = grammar.tokenizeLines """message "test message"
                view-as alert-box question buttons yes-no update vChoice as logical.
            """

            expect(tokens[0][0].value).toEqual "message"
            expect(tokens[0][0].scopes).toEqual ["source.openedge", "keyword.other.message.oe"]
            expect(tokens[0][2].value).toEqual '"'
            expect(tokens[0][2].scopes).toEqual ["source.openedge", "keyword.other.message.oe", "string.quoted.oe"]
            expect(tokens[0][3].value).toEqual "test message"
            expect(tokens[0][3].scopes).toEqual ["source.openedge", "keyword.other.message.oe", "string.quoted.oe"]
            expect(tokens[0][4].value).toEqual '"'
            expect(tokens[0][4].scopes).toEqual ["source.openedge", "keyword.other.message.oe", "string.quoted.oe"]
            expect(tokens[1][0].value.trim()).toEqual "view-as alert-box question buttons yes-no update"
            expect(tokens[1][0].scopes).toEqual ["source.openedge", "keyword.other.message.oe"]
            expect(tokens[1][1].value).toEqual "vChoice"
            expect(tokens[1][1].scopes).toEqual ["source.openedge", "keyword.other.message.oe", "variable.other.oe"]
            expect(tokens[1][3].value).toEqual "as"
            expect(tokens[1][3].scopes).toEqual ["source.openedge", "keyword.other.message.oe", "keyword.other.oe"]
            expect(tokens[1][5].value).toEqual "logical"
            expect(tokens[1][5].scopes).toEqual ["source.openedge", "keyword.other.message.oe", "storage.type.oe"]

    describe "language constants", ->
        it "tokenizes language constants", ->
            sample = "setValues(1,yes)"
            {tokens} = grammar.tokenizeLine(sample)
            expect(tokens[3].value).toEqual "yes"
            expect(tokens[3].scopes).toEqual ["source.openedge", "meta.function.oe", "constant.language.oe"]

            sample = "x = true."
            {tokens} = grammar.tokenizeLine(sample)
            expect(tokens[1].value).toEqual "true"
            expect(tokens[1].scopes).toEqual ["source.openedge", "constant.language.oe"]

            #Make sure it doesn't find anything in the statement below
            sample = "view-as alert-box buttons yes-no update vchoose"
            {tokens} = grammar.tokenizeLine(sample)
            expect(tokens[0].value).toEqual sample
            expect(tokens[0].scopes).toEqual ["source.openedge"]

            sample = "xyz(yes,no)"
            {tokens} = grammar.tokenizeLine(sample)
            expect(tokens[1].value).toEqual "yes"
            expect(tokens[1].scopes).toEqual ["source.openedge", "meta.function.oe", "constant.language.oe"]
            expect(tokens[3].value).toEqual "no"
            expect(tokens[3].scopes).toEqual ["source.openedge", "meta.function.oe", "constant.language.oe"]

    describe "other functions and methods", ->
        it 'parses functions and method statements', ->
            {tokens} = grammar.tokenizeLine "test(x,x)"

            expect(tokens[0].value).toEqual "test("
            expect(tokens[0].scopes).toEqual ["source.openedge", "meta.function.oe", "entity.name.function.oe"]
            expect(tokens[2].value).toEqual ")"
            expect(tokens[2].scopes).toEqual ["source.openedge", "meta.function.oe", "entity.name.function.oe"]

    describe "class definition", ->
        it "parses basic class definition", ->
            {tokens} = grammar.tokenizeLine "CLASS testClass:"

            expect(tokens[0].value).toEqual "CLASS "
            expect(tokens[0].scopes).toEqual ["source.openedge", "meta.class.oe", "keyword.other.oe"]
            expect(tokens[1].value).toEqual "testClass"
            expect(tokens[1].scopes).toEqual ["source.openedge", "meta.class.oe", "entity.name.type.class.oe"]
            expect(tokens[2].value).toEqual ":"
            expect(tokens[2].scopes).toEqual ["source.openedge", "meta.class.oe"]

        it "parses child class definition", ->
            {tokens} = grammar.tokenizeLine "CLASS public abstract testClass inherits testBase:"

            expect(tokens[0].value).toEqual "CLASS public abstract "
            expect(tokens[0].scopes).toEqual ["source.openedge", "meta.class.oe", "keyword.other.oe"]
            expect(tokens[1].value).toEqual "testClass"
            expect(tokens[1].scopes).toEqual ["source.openedge", "meta.class.oe", "entity.name.type.class.oe"]
            expect(tokens[3].value).toEqual "inherits"
            expect(tokens[3].scopes).toEqual ["source.openedge", "meta.class.oe", "keyword.other.oe"]
            expect(tokens[5].value).toEqual "testBase"
            expect(tokens[5].scopes).toEqual ["source.openedge", "meta.class.oe", "entity.other.inherited-class.oe"]
            expect(tokens[6].value).toEqual ":"
            expect(tokens[6].scopes).toEqual ["source.openedge", "meta.class.oe"]

    describe "comments", ->
        it "tokenizes single line comment", ->
            sample = "/*test comment*/"
            {tokens} = grammar.tokenizeLine(sample)
            expect(tokens[0].value).toEqual "/*"
            expect(tokens[0].scopes).toEqual ["source.openedge", "comment.block.oe"]
            expect(tokens[1].value).toEqual "test comment"
            expect(tokens[1].scopes).toEqual ["source.openedge", "comment.block.oe"]
            expect(tokens[2].value).toEqual "*/"
            expect(tokens[2].scopes).toEqual ["source.openedge", "comment.block.oe"]

        it "tokenizes multi-line line comment", ->
            tokens = grammar.tokenizeLines """/*
            test comment
            */
            """
            expect(tokens[0][0].value).toEqual "/*"
            expect(tokens[0][0].scopes).toEqual ["source.openedge", "comment.block.oe"]
            expect(tokens[1][0].value).toEqual "test comment"
            expect(tokens[1][0].scopes).toEqual ["source.openedge", "comment.block.oe"]
            expect(tokens[2][0].value).toEqual "*/"
            expect(tokens[2][0].scopes).toEqual ["source.openedge", "comment.block.oe"]

    describe "preprocessors", ->
        it "tokenizes include references", ->
            sample = "{include.i}"
            {tokens} = grammar.tokenizeLine(sample)

            expect(tokens[0].value).toEqual "{"
            expect(tokens[0].scopes).toEqual ["source.openedge", "string.interpolated.include.oe"]
            expect(tokens[1].value).toEqual "include.i"
            expect(tokens[1].scopes).toEqual ["source.openedge", "string.interpolated.include.oe"]
            expect(tokens[2].value).toEqual "}"
            expect(tokens[2].scopes).toEqual ["source.openedge", "string.interpolated.include.oe"]

        it "tokenizes preprocessor variable reference", ->
            sample = "{&CONST}"
            {tokens} = grammar.tokenizeLine(sample)

            expect(tokens[0].value).toEqual sample
            expect(tokens[0].scopes).toEqual ["source.openedge", "constant.other.preprocessor.oe"]

        it "parses basic &SCOPED-DEFINE statement", ->
            {tokens} = grammar.tokenizeLine "&scoped-define TESTVAR 8"

            expect(tokens[0].value).toEqual "&scoped-define"
            expect(tokens[0].scopes).toEqual ["source.openedge", "meta.preprocessor.define.oe", "keyword.other.preprocessordefine.oe"]
            expect(tokens[2].value).toEqual "TESTVAR"
            expect(tokens[2].scopes).toEqual ["source.openedge", "meta.preprocessor.define.oe", "constant.other.preprocessor.oe"]
            expect(tokens[4].value).toEqual "8"
            expect(tokens[4].scopes).toEqual ["source.openedge", "meta.preprocessor.define.oe", "constant.numeric.oe"]

    describe "strings", ->
        delimsByScope =
            "string.quoted.oe": '"'
            "string.quoted.oe": "'"

        it "tokenizes single-line strings", ->
            for scope, delim of delimsByScope
                {tokens} = grammar.tokenizeLine(delim + "x" + delim)
                expect(tokens[0].value).toEqual delim
                expect(tokens[0].scopes).toEqual ["source.openedge", scope]
                expect(tokens[1].value).toEqual "x"
                expect(tokens[1].scopes).toEqual ["source.openedge", scope]
                expect(tokens[2].value).toEqual delim
                expect(tokens[2].scopes).toEqual ["source.openedge", scope]

        it "tokenizes a string with an escape in it", ->
            for scope, delim of delimsByScope
                {tokens} = grammar.tokenizeLine(delim + "x~n" + delim)
                expect(tokens[2].value).toEqual "~n"
                expect(tokens[2].scopes).toEqual ["source.openedge", scope, "constant.character.escape.oe"]

        it "tokenizes a string with a preprocessor variable in it", ->
            for scope, delim of delimsByScope
                {tokens} = grammar.tokenizeLine(delim + "x{&VAR}" + delim)
                expect(tokens[0].value).toEqual delim
                expect(tokens[1].value).toEqual "x"
                expect(tokens[2].value).toEqual "{&VAR}"
                expect(tokens[2].scopes).toEqual ["source.openedge", scope, "constant.other.preprocessor.oe"]

    describe "define statements", ->
        it "parses single line define variable with no modifiers", ->
            lineOfText = "DEFINE VARIABLE test AS CHARACTER NO-UNDO."
            {tokens} = grammar.tokenizeLine(lineOfText)

            expect(tokens[0].value).toEqual "DEFINE"
            expect(tokens[0].scopes).toEqual ["source.openedge", "meta.define.oe", "keyword.other.define.oe"]
            expect(tokens[2].value).toEqual "VARIABLE"
            expect(tokens[2].scopes).toEqual ["source.openedge", "meta.define.oe", "keyword.other.oe"]
            expect(tokens[4].value).toEqual "test"
            expect(tokens[4].scopes).toEqual ["source.openedge", "meta.define.oe", "variable.other.oe"]
            expect(tokens[6].value).toEqual "AS"
            expect(tokens[6].scopes).toEqual ["source.openedge", "meta.define.oe", "keyword.other.oe"]
            expect(tokens[8].value).toEqual "CHARACTER"
            expect(tokens[8].scopes).toEqual ["source.openedge", "meta.define.oe", "storage.type.oe"]
            expect(tokens[10].value).toEqual "NO-UNDO"
            expect(tokens[10].scopes).toEqual ["source.openedge", "meta.define.oe", "keyword.other.define.oe"]
            expect(tokens[11].value).toEqual "."
            expect(tokens[11].scopes).toEqual ["source.openedge", "meta.define.oe"]

        it "parses single line define variable with modifiers", ->
            lineOfText = "def public static var test as log no-undo."
            {tokens} = grammar.tokenizeLine(lineOfText)

            expect(tokens[0].value).toEqual "def"
            expect(tokens[0].scopes).toEqual ["source.openedge", "meta.define.oe", "keyword.other.define.oe"]
            expect(tokens[2].value).toEqual "public static "
            expect(tokens[2].scopes).toEqual ["source.openedge", "meta.define.oe", "storage.modifier.oe"]
            expect(tokens[3].value).toEqual "var"
            expect(tokens[3].scopes).toEqual ["source.openedge", "meta.define.oe", "keyword.other.oe"]
            expect(tokens[5].value).toEqual "test"
            expect(tokens[5].scopes).toEqual ["source.openedge", "meta.define.oe", "variable.other.oe"]
            expect(tokens[7].value).toEqual "as"
            expect(tokens[7].scopes).toEqual ["source.openedge", "meta.define.oe", "keyword.other.oe"]
            expect(tokens[9].value).toEqual "log"
            expect(tokens[9].scopes).toEqual ["source.openedge", "meta.define.oe", "storage.type.oe"]
            expect(tokens[11].value).toEqual "no-undo"
            expect(tokens[11].scopes).toEqual ["source.openedge", "meta.define.oe", "keyword.other.define.oe"]
            expect(tokens[12].value).toEqual "."
            expect(tokens[12].scopes).toEqual ["source.openedge", "meta.define.oe"]

        it "parses a define variable for a class", ->
            lineOfText = 'define variable test as class common.strings no-undo.'
            {tokens} = grammar.tokenizeLine(lineOfText)

            expect(tokens[0].value).toEqual "define"
            expect(tokens[0].scopes).toEqual ["source.openedge", "meta.define.oe", "keyword.other.define.oe"]
            expect(tokens[2].value).toEqual "variable"
            expect(tokens[2].scopes).toEqual ["source.openedge", "meta.define.oe", "keyword.other.oe"]
            expect(tokens[4].value).toEqual "test"
            expect(tokens[4].scopes).toEqual ["source.openedge", "meta.define.oe", "variable.other.oe"]
            expect(tokens[6].value).toEqual "as class"
            expect(tokens[6].scopes).toEqual ["source.openedge", "meta.define.oe", "keyword.other.oe"]
            expect(tokens[8].value).toEqual "common.strings"
            expect(tokens[8].scopes).toEqual ["source.openedge", "meta.define.oe", "storage.type.oe"]
            expect(tokens[10].value).toEqual "no-undo"
            expect(tokens[10].scopes).toEqual ["source.openedge", "meta.define.oe", "keyword.other.define.oe"]
            expect(tokens[11].value).toEqual "."
            expect(tokens[11].scopes).toEqual ["source.openedge", "meta.define.oe"]

        it "parses a define variable when like a db field", ->
            lineOfText = 'define variable test like person.first_name no-undo.'
            {tokens} = grammar.tokenizeLine(lineOfText)

            expect(tokens[0].value).toEqual "define"
            expect(tokens[0].scopes).toEqual ["source.openedge", "meta.define.oe", "keyword.other.define.oe"]
            expect(tokens[2].value).toEqual "variable"
            expect(tokens[2].scopes).toEqual ["source.openedge", "meta.define.oe", "keyword.other.oe"]
            expect(tokens[4].value).toEqual "test"
            expect(tokens[4].scopes).toEqual ["source.openedge", "meta.define.oe", "variable.other.oe"]
            expect(tokens[6].value).toEqual "like"
            expect(tokens[6].scopes).toEqual ["source.openedge", "meta.define.oe", "keyword.other.oe"]
            expect(tokens[8].value).toEqual "person.first_name"
            expect(tokens[8].scopes).toEqual ["source.openedge", "meta.define.oe", "storage.type.oe"]
            expect(tokens[10].value).toEqual "no-undo"
            expect(tokens[10].scopes).toEqual ["source.openedge", "meta.define.oe", "keyword.other.define.oe"]
            expect(tokens[11].value).toEqual "."
            expect(tokens[11].scopes).toEqual ["source.openedge", "meta.define.oe"]

        it "parses a define variable as array", ->
            lineOfText = 'define variable test as int extent no-undo.'
            {tokens} = grammar.tokenizeLine(lineOfText)

            expect(tokens[0].value).toEqual "define"
            expect(tokens[0].scopes).toEqual ["source.openedge", "meta.define.oe", "keyword.other.define.oe"]
            expect(tokens[2].value).toEqual "variable"
            expect(tokens[2].scopes).toEqual ["source.openedge", "meta.define.oe", "keyword.other.oe"]
            expect(tokens[4].value).toEqual "test"
            expect(tokens[4].scopes).toEqual ["source.openedge", "meta.define.oe", "variable.other.oe"]
            expect(tokens[6].value).toEqual "as"
            expect(tokens[6].scopes).toEqual ["source.openedge", "meta.define.oe", "keyword.other.oe"]
            expect(tokens[8].value).toEqual "int"
            expect(tokens[8].scopes).toEqual ["source.openedge", "meta.define.oe", "storage.type.oe"]
            expect(tokens[10].value).toEqual "extent"
            expect(tokens[10].scopes).toEqual ["source.openedge", "meta.define.oe", "keyword.other.oe"]
            expect(tokens[12].value).toEqual "no-undo"
            expect(tokens[12].scopes).toEqual ["source.openedge", "meta.define.oe", "keyword.other.define.oe"]
            expect(tokens[13].value).toEqual "."
            expect(tokens[13].scopes).toEqual ["source.openedge", "meta.define.oe"]

        it "parses a define variable a fixed array", ->
            lineOfText = 'define variable test as int extent 10 no-undo.'
            {tokens} = grammar.tokenizeLine(lineOfText)

            expect(tokens[0].value).toEqual "define"
            expect(tokens[0].scopes).toEqual ["source.openedge", "meta.define.oe", "keyword.other.define.oe"]
            expect(tokens[2].value).toEqual "variable"
            expect(tokens[2].scopes).toEqual ["source.openedge", "meta.define.oe", "keyword.other.oe"]
            expect(tokens[4].value).toEqual "test"
            expect(tokens[4].scopes).toEqual ["source.openedge", "meta.define.oe", "variable.other.oe"]
            expect(tokens[6].value).toEqual "as"
            expect(tokens[6].scopes).toEqual ["source.openedge", "meta.define.oe", "keyword.other.oe"]
            expect(tokens[8].value).toEqual "int"
            expect(tokens[8].scopes).toEqual ["source.openedge", "meta.define.oe", "storage.type.oe"]
            expect(tokens[10].value).toEqual "extent"
            expect(tokens[10].scopes).toEqual ["source.openedge", "meta.define.oe", "keyword.other.oe"]
            expect(tokens[11].value).toEqual ' 10'
            expect(tokens[11].scopes).toEqual ["source.openedge", "meta.define.oe", "contant.numeric.oe"]
            expect(tokens[13].value).toEqual "no-undo"
            expect(tokens[13].scopes).toEqual ["source.openedge", "meta.define.oe", "keyword.other.define.oe"]
            expect(tokens[14].value).toEqual "."
            expect(tokens[14].scopes).toEqual ["source.openedge", "meta.define.oe"]

        it "parses single line define buffer", ->
            lineOfText = "def buffer btest for test."
            {tokens} = grammar.tokenizeLine(lineOfText)

            expect(tokens[0].value).toEqual "def"
            expect(tokens[0].scopes).toEqual ["source.openedge", "meta.define.oe", "keyword.other.define.oe"]
            expect(tokens[2].value).toEqual "buffer"
            expect(tokens[2].scopes).toEqual ["source.openedge", "meta.define.oe", "keyword.other.oe"]
            expect(tokens[4].value).toEqual "btest"
            expect(tokens[4].scopes).toEqual ["source.openedge", "meta.define.oe", "variable.other.oe"]
            expect(tokens[6].value).toEqual "for"
            expect(tokens[6].scopes).toEqual ["source.openedge", "meta.define.oe", "keyword.other.oe"]
            expect(tokens[8].value).toEqual "test"
            expect(tokens[8].scopes).toEqual ["source.openedge", "meta.define.oe", "storage.name.table.oe"]

        it "parses define buffer statement with scope modifiers", ->
            lineOfText = "DEFINE PROTECTED static BUFFER btest FOR test."
            {tokens} = grammar.tokenizeLine(lineOfText)

            expect(tokens[0].value).toEqual "DEFINE"
            expect(tokens[0].scopes).toEqual ["source.openedge", "meta.define.oe", "keyword.other.define.oe"]
            expect(tokens[2].value).toEqual "PROTECTED static "
            expect(tokens[2].scopes).toEqual ["source.openedge", "meta.define.oe", "storage.modifier.oe"]
            expect(tokens[3].value).toEqual "BUFFER"
            expect(tokens[3].scopes).toEqual ["source.openedge", "meta.define.oe", "keyword.other.oe"]
            expect(tokens[5].value).toEqual "btest"
            expect(tokens[5].scopes).toEqual ["source.openedge", "meta.define.oe", "variable.other.oe"]
            expect(tokens[7].value).toEqual "FOR"
            expect(tokens[7].scopes).toEqual ["source.openedge", "meta.define.oe", "keyword.other.oe"]
            expect(tokens[9].value).toEqual "test"
            expect(tokens[9].scopes).toEqual ["source.openedge", "meta.define.oe", "storage.name.table.oe"]

        it "parses a define buffer statement with all the keyword options filled in on multiple lines", ->
            tokens = grammar.tokenizeLines """DEFINE NEW SHARED STATIC BUFFER btest FOR TEMP-TABLE test PRESELECT
                                                  LABEL nottest
                                                  NAMESPACE-URI test-ns
                                                  namespace-prefix ns-prefix
                                                  XML-NODE-NAME testNodeName."""

            expect(tokens[0][0].value).toEqual "DEFINE"
            expect(tokens[0][0].scopes).toEqual ["source.openedge", "meta.define.oe", "keyword.other.define.oe"]
            expect(tokens[0][2].value).toEqual "NEW SHARED STATIC "
            expect(tokens[0][2].scopes).toEqual ["source.openedge", "meta.define.oe", "storage.modifier.oe"]
            expect(tokens[0][3].value).toEqual "BUFFER"
            expect(tokens[0][3].scopes).toEqual ["source.openedge", "meta.define.oe", "keyword.other.oe"]
            expect(tokens[0][5].value).toEqual "btest"
            expect(tokens[0][5].scopes).toEqual ["source.openedge", "meta.define.oe", "variable.other.oe"]
            expect(tokens[0][7].value).toEqual "FOR TEMP-TABLE"
            expect(tokens[0][7].scopes).toEqual ["source.openedge", "meta.define.oe", "keyword.other.oe"]
            expect(tokens[0][9].value).toEqual "test"
            expect(tokens[0][9].scopes).toEqual ["source.openedge", "meta.define.oe", "storage.name.table.oe"]
            expect(tokens[0][11].value).toEqual "PRESELECT"
            expect(tokens[0][11].scopes).toEqual ["source.openedge", "meta.define.oe", "keyword.other.oe"]
            expect(tokens[1][0].value.trim()).toEqual "LABEL"
            expect(tokens[1][0].scopes).toEqual ["source.openedge", "meta.define.oe", "keyword.other.oe"]
            expect(tokens[1][1].value).toEqual " nottest"
            expect(tokens[1][1].scopes).toEqual ["source.openedge", "meta.define.oe", "variable.other.oe"]
            expect(tokens[2][0].value.trim()).toEqual "NAMESPACE-URI"
            expect(tokens[2][0].scopes).toEqual ["source.openedge", "meta.define.oe", "keyword.other.oe"]
            expect(tokens[2][1].value).toEqual " test-ns"
            expect(tokens[2][1].scopes).toEqual ["source.openedge", "meta.define.oe", "variable.other.oe"]
            expect(tokens[3][0].value.trim()).toEqual "namespace-prefix"
            expect(tokens[3][0].scopes).toEqual ["source.openedge", "meta.define.oe", "keyword.other.oe"]
            expect(tokens[3][1].value).toEqual " ns-prefix"
            expect(tokens[3][1].scopes).toEqual ["source.openedge", "meta.define.oe", "variable.other.oe"]
            expect(tokens[4][0].value.trim()).toEqual "XML-NODE-NAME"
            expect(tokens[4][0].scopes).toEqual ["source.openedge", "meta.define.oe", "keyword.other.oe"]
            expect(tokens[4][1].value).toEqual " testNodeName"
            expect(tokens[4][1].scopes).toEqual ["source.openedge", "meta.define.oe", "variable.other.oe"]

    describe "FOR statement", ->
        it "parses basic FOR statement", ->
            tokens = grammar.tokenizeLines """for each table
                                                    where table.field = 1:
                                                x = 1.
                                            """
            expect(tokens[0][0].value).toEqual "for "
            expect(tokens[0][0].scopes).toEqual ["source.openedge", "keyword.other.for.oe"]
            expect(tokens[0][1].value).toEqual "each "
            expect(tokens[0][1].scopes).toEqual ["source.openedge", "keyword.other.for.oe"]
            expect(tokens[0][2].value).toEqual "table"
            expect(tokens[0][2].scopes).toEqual ["source.openedge", "keyword.other.for.oe", "storage.name.table.oe"]
            expect(tokens[1][0].value.trim()).toEqual "where"
            expect(tokens[1][0].scopes).toEqual ["source.openedge", "keyword.other.for.oe"]
            expect(tokens[1][1].value).toEqual "table.field"
            expect(tokens[1][1].scopes).toEqual ["source.openedge", "keyword.other.for.oe", "storage.name.table.field.oe"]
            expect(tokens[1][3].value).toEqual "="
            expect(tokens[1][3].scopes).toEqual ["source.openedge", "keyword.other.for.oe", "keyword.operator.comparison.oe"]
            expect(tokens[1][5].value).toEqual "1"
            expect(tokens[1][5].scopes).toEqual ["source.openedge", "keyword.other.for.oe", "constant.numeric.oe"]
            expect(tokens[1][6].value).toEqual ":"
            expect(tokens[1][6].scopes).toEqual ["source.openedge", "keyword.other.for.oe"]
            expect(tokens[2][0].scopes).toEqual ["source.openedge"]

        it "parses multi-line for statement", ->
            tokens = grammar.tokenizeLines """for each table no-lock
                                                    where table.field = 1,
                                                  each table2 exclusive-lock
                                                    where table2.field = table.field:
                                                x = 1.
                                            """
            expect(tokens[0][0].value).toEqual "for "
            expect(tokens[0][0].scopes).toEqual ["source.openedge", "keyword.other.for.oe"]
            expect(tokens[0][1].value).toEqual "each "
            expect(tokens[0][1].scopes).toEqual ["source.openedge", "keyword.other.for.oe"]
            expect(tokens[0][2].value).toEqual "table"
            expect(tokens[0][2].scopes).toEqual ["source.openedge", "keyword.other.for.oe", "storage.name.table.oe"]
            expect(tokens[0][3].value).toEqual " no-lock"
            expect(tokens[0][3].scopes).toEqual ["source.openedge", "keyword.other.for.oe"]
            expect(tokens[1][0].value.trim()).toEqual "where"
            expect(tokens[1][0].scopes).toEqual ["source.openedge", "keyword.other.for.oe"]
            expect(tokens[1][1].value).toEqual "table.field"
            expect(tokens[1][1].scopes).toEqual ["source.openedge", "keyword.other.for.oe", "storage.name.table.field.oe"]
            expect(tokens[1][3].value).toEqual "="
            expect(tokens[1][3].scopes).toEqual ["source.openedge", "keyword.other.for.oe", "keyword.operator.comparison.oe"]
            expect(tokens[1][5].value).toEqual "1"
            expect(tokens[1][5].scopes).toEqual ["source.openedge", "keyword.other.for.oe", "constant.numeric.oe"]
            expect(tokens[2][1].value).toEqual "each "
            expect(tokens[2][1].scopes).toEqual ["source.openedge", "keyword.other.for.oe"]
            expect(tokens[2][2].value).toEqual "table2"
            expect(tokens[2][2].scopes).toEqual ["source.openedge", "keyword.other.for.oe", "storage.name.table.oe"]
            expect(tokens[2][3].value).toEqual " exclusive-lock"
            expect(tokens[2][3].scopes).toEqual ["source.openedge", "keyword.other.for.oe"]
            expect(tokens[3][0].value.trim()).toEqual "where"
            expect(tokens[3][0].scopes).toEqual ["source.openedge", "keyword.other.for.oe"]
            expect(tokens[3][1].value).toEqual "table2.field"
            expect(tokens[3][1].scopes).toEqual ["source.openedge", "keyword.other.for.oe", "storage.name.table.field.oe"]
            expect(tokens[3][3].value).toEqual "="
            expect(tokens[3][3].scopes).toEqual ["source.openedge", "keyword.other.for.oe", "keyword.operator.comparison.oe"]
            expect(tokens[3][5].value).toEqual "table.field"
            expect(tokens[3][5].scopes).toEqual ["source.openedge", "keyword.other.for.oe", "storage.name.table.field.oe"]
            expect(tokens[3][6].value).toEqual ":"
            expect(tokens[3][6].scopes).toEqual ["source.openedge", "keyword.other.for.oe"]
            expect(tokens[4][0].scopes).toEqual ["source.openedge"]

    describe "Language Functions", ->
        it "parses language function statements", ->
            {tokens} = grammar.tokenizeLine("int('')")
            expect(tokens[0].value).toEqual "int("
            expect(tokens[0].scopes).toEqual ["source.openedge", "support.function.oe"]
            expect(tokens[1].value).toEqual "'"
            expect(tokens[1].scopes).toEqual ["source.openedge", "string.quoted.oe"]
            expect(tokens[2].value).toEqual "'"
            expect(tokens[2].scopes).toEqual ["source.openedge", "string.quoted.oe"]
            expect(tokens[3].value).toEqual ")"
            expect(tokens[3].scopes).toEqual ["source.openedge", "support.function.oe"]

    ///describe "IF statements", ->
        it "parses basic IF-THEN statement", ->
            {tokens} = grammar.tokenizeLine "IF x = 1 then"
            expect(tokens[0].value).toEqual "IF"
            expect(tokens[0].scopes).toEqual ["source.openedge", "keyword.other.if.oe"]
            expect(tokens[2].value).toEqual "="
            expect(tokens[2].scopes).toEqual ["source.openedge", "keyword.operator.math.oe"]
            expect(tokens[4].value).toEqual "1"
            expect(tokens[4].scopes).toEqual ["source.openedge", "constant.numeric.oe"]
            expect(tokens[6].value).toEqual "then"
            expect(tokens[6].scopes).toEqual ["source.openedge", "keyword.other.then.oe"]

        it "parses basic IF-THEN-ELSE statement", ->
            {tokens} = grammar.tokenizeLine "if x = 1 then 'hello' else 'not hello'"
            expect(tokens[0].value).toEqual "if"
            expect(tokens[0].scopes).toEqual ["source.openedge", "keyword.other.if.oe"]
            expect(tokens[2].value).toEqual "="
            expect(tokens[2].scopes).toEqual ["source.openedge", "keyword.operator.math.oe"]
            expect(tokens[4].value).toEqual "1"
            expect(tokens[4].scopes).toEqual ["source.openedge", "constant.numeric.oe"]
            expect(tokens[6].value).toEqual "then"
            expect(tokens[6].scopes).toEqual ["source.openedge", "keyword.other.then.oe"]
            expect(tokens[12].value).toEqual "else"
            expect(tokens[12].scopes).toEqual ["source.openedge", "keyword.other.else.oe"]///

    describe "DO blocks", ->
        it "parses basic DO block", ->
            tokens = grammar.tokenizeLines """if x = 1 then do:
            x = 1.
            end.
            """

            expect(tokens[0][1].value).toEqual "do"
            expect(tokens[0][1].scopes).toEqual ["source.openedge", "keyword.other.doblock.oe"]
            expect(tokens[0][2].value).toEqual ":"
            expect(tokens[0][2].scopes).toEqual ["source.openedge", "keyword.other.doblock.oe"]
            expect(tokens[1][0].scopes).toEqual ["source.openedge"]
