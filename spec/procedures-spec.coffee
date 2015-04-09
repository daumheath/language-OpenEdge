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

    describe "language constants", ->
        it "tokenizes language constants", ->
            sample = "setValues(1,yes)"
            {tokens} = grammar.tokenizeLine(sample)
            expect(tokens[2].value).toEqual "yes"
            expect(tokens[2].scopes).toEqual ["source.openedge", "constant.language.oe"]

            sample = "x = true."
            {tokens} = grammar.tokenizeLine(sample)
            expect(tokens[2].value).toEqual "true"
            expect(tokens[2].scopes).toEqual ["source.openedge", "constant.language.oe"]

            sample = "view-as alert-box buttons yes-no update vchoose"
            {tokens} = grammar.tokenizeLine(sample)
            expect(tokens[0].value).toEqual sample
            expect(tokens[0].scopes).toEqual ["source.openedge"]

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

    describe "strings", ->
        delimsByScope =
            "string.quoted.double.oe": '"'
            "string.quoted.single.oe": "'"

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
            lineOfText = "define variable test as character no-undo."
            {tokens} = grammar.tokenizeLine(lineOfText)

            expect(tokens[0].value).toEqual "define "
            expect(tokens[0].scopes).toEqual ["source.openedge", "meta.keyword.other.define.oe"]
            expect(tokens[1].value).toEqual "variable "
            expect(tokens[1].scopes).toEqual ["source.openedge", "meta.keyword.other.define.oe"]
            expect(tokens[2].value).toEqual "test"
            expect(tokens[2].scopes).toEqual ["source.openedge", "meta.keyword.other.define.oe", "variable.other.oe"]
            expect(tokens[3].value).toEqual " as "
            expect(tokens[3].scopes).toEqual ["source.openedge", "meta.keyword.other.define.oe"]
            expect(tokens[4].value).toEqual "character"
            expect(tokens[4].scopes).toEqual ["source.openedge", "meta.keyword.other.define.oe", "storage.type.oe"]
            expect(tokens[5].value).toEqual " no-undo"
            expect(tokens[5].scopes).toEqual ["source.openedge", "meta.keyword.other.define.oe"]
            expect(tokens[6].value).toEqual "."
            expect(tokens[6].scopes).toEqual ["source.openedge", "meta.keyword.other.define.oe"]

        it "parses single line define variable with modifiers", ->
            lineOfText = "define public static variable test as log no-undo."
            {tokens} = grammar.tokenizeLine(lineOfText)

            expect(tokens[0].value).toEqual "define "
            expect(tokens[1].value).toEqual "public"
            expect(tokens[1].scopes).toEqual ["source.openedge", "meta.keyword.other.define.oe", "storage.modifier.oe"]
            expect(tokens[3].value).toEqual "static"
            expect(tokens[3].scopes).toEqual ["source.openedge", "meta.keyword.other.define.oe", "storage.modifier.oe"]
            expect(tokens[4].value).toEqual " variable "
            expect(tokens[4].scopes).toEqual ["source.openedge", "meta.keyword.other.define.oe"]
            expect(tokens[5].value).toEqual "test"
            expect(tokens[5].scopes).toEqual ["source.openedge", "meta.keyword.other.define.oe", "variable.other.oe"]
            expect(tokens[6].value).toEqual " as "
            expect(tokens[6].scopes).toEqual ["source.openedge", "meta.keyword.other.define.oe"]
            expect(tokens[7].value).toEqual "log"
            expect(tokens[7].scopes).toEqual ["source.openedge", "meta.keyword.other.define.oe", "storage.type.oe"]
            expect(tokens[8].value).toEqual " no-undo"
            expect(tokens[8].scopes).toEqual ["source.openedge", "meta.keyword.other.define.oe"]
            expect(tokens[9].value).toEqual "."
            expect(tokens[9].scopes).toEqual ["source.openedge", "meta.keyword.other.define.oe"]

    describe "for loops", ->
        it "parses basic for loop", ->
            tokens = grammar.tokenizeLines """for each table:
            end.
            """
            expect(tokens[0][0].value).toEqual "for"
            expect(tokens[0][0].scopes).toEqual ["source.openedge", "entity.name.section.forloop.oe"]
            expect(tokens[0][1].value).toEqual " each table:"
            expect(tokens[0][1].scopes).toEqual ["source.openedge", "entity.name.section.forloop.oe"]
            expect(tokens[1][0].value).toEqual "end"
            expect(tokens[1][0].scopes).toEqual ["source.openedge", "entity.name.section.forloop.oe"]
