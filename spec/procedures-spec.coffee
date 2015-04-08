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

  describe "strings", ->
    it "tokenizes single-line strings", ->
      delimsByScope =
        "string.quoted.double.oe": '"'

      for scope, delim of delimsByScope
        {tokens} = grammar.tokenizeLine(delim + "x" + delim)
        expect(tokens.length).toEqual 3
        expect(tokens[0].value).toEqual delim
        expect(tokens[0].scopes).toEqual ["source.openedge", scope]
        expect(tokens[1].value).toEqual "x"
        expect(tokens[1].scopes).toEqual ["source.openedge", scope]
        expect(tokens[2].value).toEqual delim
        expect(tokens[2].scopes).toEqual ["source.openedge", scope]
